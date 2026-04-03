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
    local t
    if self.debug then
        t = os.clock()
        print("start findPalette")
    end
    self:findUniqueColors()
    distanceFunction = distanceFunction and distanceFunction or Color.distance
    maxIteration=maxIteration and maxIteration or 50
    eps=eps and eps or 0.0001
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

return ImageHandler