local Color = require("Color")

local ImageHandler = {}


local function round(x)
    return math.floor(x+0.5)
end

local function clamp(x)
    return math.min(math.max(x,0),1)
end

local function uvToIndex(sx,sy,u,v)
    local x,y = round(u*(sx-1)) , round(v*(sy-1))
    return y*sx + x + 1
end

function ImageHandler:new(sx,sy,data,debug)

    local sx,sy = math.max(sx,0),math.max(sy,0)

    if (not data) then
        data = {}
        for i=1,sx*sy do
            data[i] = Color:new(0,0,0,0)
        end
    end

    local o = {sx=sx,sy=sy,data=data,uniqueColors={},debug=debug}

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })

    return o
end

function ImageHandler:copy()
    local newData = {}
    for i=1,self.sx*self.sy do
        newData[i] = self.data[i]
    end

    local img = ImageHandler:new(self.sx,self.sy,newData)
    return img
end
function ImageHandler:duplicate()
    local newData = {}
    for i=1,self.sx*self.sy do
        newData[i] = self.data[i]:duplicate()
    end

    local img = ImageHandler:new(self.sx,self.sy,newData)
    return img
end

function ImageHandler:resize(newSx, newSy)
    local newData = {}
    for i=0,newSx-1 do
        for j=0,newSy-1 do
            local u,v = i/(newSx-1),j/(newSy-1)
            newData[uvToIndex(newSx,newSy,u,v)] = self:getPx(u,v)
        end
    end
    self.data = newData
    self.sx = newSx
    self.sy = newSy
    return self
end

function ImageHandler:resizeMean(newSx,newSy)
    local newData = {}
    local dx = round(self.sx/newSx)
    local dy = round(self.sy/newSy)
    print(newSx,self.sx,dx,newSy,self.sy,dy)
    for i=0,self.sx-1 do
        for j=0,self.sy-1 do
            local cs = Color()
            local k = 0
            for di=0,dx do
                for dj=0,dy do
                    local u,v = (i+di)/(self.sx-1),(j+dj)/(self.sy-1)
                    local px = self:getPx(u,v)
                    if px then
                        cs[1] = cs[1] + px[1]
                        cs[2] = cs[2] + px[2]
                        cs[3] = cs[3] + px[3]
                        k=k+1
                    end
                end
            end
            cs[1] = cs[1]/k
            cs[2] = cs[2]/k
            cs[3] = cs[3]/k
            local u,v = (i)/(self.sx-1),(j)/(self.sy-1)
            newData[uvToIndex(newSx,newSy,u,v)] = cs
        end
    end
    self.data = newData
    self.sx = newSx
    self.sy = newSy
    return self
end

function ImageHandler:getPx(u,v)
    local index = uvToIndex(self.sx,self.sy,u,v)
    return self.data[index]
end

function ImageHandler:setPx(u,v,color)
    local index = uvToIndex(self.sx,self.sy,u,v)
    self.data[index] = color
    return self
end

function ImageHandler:findUniqueColors(interval)
    interval = interval or 0.01
    self.uniqueColors = {}
    for u=0,1,interval do
        for v=0,1,interval do
            local color = self:getPx(u,v)
            self.uniqueColors[color:toHex()] = color
        end
    end
end

function ImageHandler:findPalette(distanceFunction,paletteSize,eps,maxIteration)
    sleep()
    local t
    if self.debug then
        t = os.clock()
        print("start findPalette")
    end
    self:findUniqueColors()
    distanceFunction = distanceFunction and distanceFunction or Color.distance
    maxIteration=maxIteration and maxIteration or 50
    eps=eps and eps or 0.00001
    paletteSize = paletteSize and paletteSize or 16
    local palette = {}
    for i=1,paletteSize do
        local r,g,b = term.nativePaletteColor(2^(i-1))
        local c = Color:new(r,g,b,1)
        palette[i] = c
    end
    local timeYield = os.clock()
    for _=1,maxIteration do
        if (os.clock() - timeYield > 5) then
            sleep()
        end
        local clusters = {}
        for _,c in pairs(self.uniqueColors) do
            local minj = 1
            local mind = distanceFunction(c,palette[1])
            for j=2,#palette do
                local d = distanceFunction(c,palette[j])
                if d < mind then
                    minj = j
                    mind = d
                end
            end
            clusters[minj] = clusters[minj] and clusters[minj] or {}
            clusters[minj][#clusters[minj]+1] = c
        end
        local calcCentroid = function(cluster)
            local mean = {0,0,0}
            local lcluster = #cluster
            if lcluster > 0 then
                for i=1,lcluster do
                    local c = cluster[i]
                    mean[1] = mean[1] + c[1]
                    mean[2] = mean[2] + c[2]
                    mean[3] = mean[3] + c[3]
                end
                mean[1] = clamp(mean[1]/lcluster)
                mean[2] = clamp(mean[2]/lcluster)
                mean[3] = clamp(mean[3]/lcluster)
            end
            return Color:new(mean[1],mean[2],mean[3],1)
        end
        local newpalette = {}
        local maxd = 0
        local i = 0
        for _,cluster in pairs(clusters) do
            i=i+1
            local c = calcCentroid(cluster)
            local d = distanceFunction(c,palette[i])
            newpalette[i]=c
            maxd = maxd<d and d or maxd
        end
        for i=1,#newpalette do
            palette[i] = newpalette[i]
        end
        if maxd < eps then
            break
        end
    end
    if self.debug then
        print("end findPalette:",os.clock()-t)
    end
    return palette
end

function ImageHandler:process(shader)
    local t
    if self.debug then
        t = os.clock()
        print("start process")
    end
    local timeYield = os.clock()
    for i=0,self.sx-1 do
        for j=0,self.sy-1 do
            if (os.clock() - timeYield > 5) then
                sleep()
                timeYield = os.clock()
            end
            local u,v = i/(self.sx-1),j/(self.sy-1)
            local color = shader(self,u,v)
            self:setPx(u,v,color)
        end
    end
    if self.debug then
        print("end process:",os.clock()-t)
    end
    return self
end

function ImageHandler:unlinearize()
    return self:process(function(s,u,v)
        local px = s:getPx(u,v)
        local col = Color()
        for i=1,3 do
            col[i] = px[i] <= 0.0031308 and 12.92*px[i] or 1.055*(px[i]^(1/2.4))-0.055
        end
        return col
    end)
end

function ImageHandler:linearize()
    return self:process(function(s,u,v)
        local px = s:getPx(u,v)
        return px:linearize()
    end)
end

function ImageHandler:map(shader,sx,sy)
    sx = sx and sx or self.sx
    sy = sy and sy or self.sy
    local newImg = ImageHandler:new(sx,sy)
    local timeYield = os.clock()
    for i=0,sx-1 do
        for j=0,sy-1 do
            if (os.clock() - timeYield > 5) then
                sleep()
                timeYield = os.clock()
            end
            local u,v = i/(sx-1),j/(sy-1)
            local color = shader(self,u,v)
            newImg:setPx(u,v,color)
        end
    end
    return newImg
end

return ImageHandler