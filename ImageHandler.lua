local Color = require("Color")

local ImageHandler = {}


local function round(x)
    return math.floor(x+0.5)
end

local function uvToIndex(sx,sy,u,v)
    local x,y = round(u*(self.sx-1)) , round(v*(self.sy-1))
    return y*self.sx + x + 1
end

function ImageHandler:new(sx,sy,data)
    local sx,sy = math.max(sx,0),math.max(sy,0)

    if (not data) then
        data = {}
        for i=1,sx*sy do
            data[i] = Color:new(0,0,0,0)
        end
    end

    local o = {sx=sx,sy=sy,data=data}

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })

    return o
end

function ImageHandler:duplicate()
    local newData = {}
    for i=1,#self.data do
        newData[i] = data[i]:duplicate()
    end

    return ImageHandler:new(self.sx,self.sy,newData)
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

    self.uniqueColors[color:toHex()] = color
    return self
end

function ImageHandler:findPalette(distanceFunction,paletteSize,eps,maxIteration)
    distanceFunction = distanceFunction and distanceFunction or Color.distance
    maxIteration=maxIteration and maxIteration or 10
    eps=eps and eps or 0.05
    paletteSize = paletteSize and paletteSize or 16
    local palette = {}
    for i=1,paletteSize do
        local c = Color:new(term.nativePaletteColor(2^(i-1)))
        palette[i] = c
    end
    for _=1,N do
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
            clusters[minj] = c
        end
        local calcCentroid = function(cluster)
            local mean = {0,0,0}
            if #cluster > 0 then
                local l = 0
                for i=1,#cluster do
                    local c = cluster[i]
                    mean[1] = mean[1] + c[1]
                    mean[2] = mean[2] + c[2]
                    mean[3] = mean[3] + c[3]
                end
                mean[1] = math.min(1,math.max(0,mean[1]/#clusters))
                mean[2] = math.min(1,math.max(0,mean[2]/#clusters))
                mean[3] = math.min(1,math.max(0,mean[3]/#clusters))
            end
            return Color:new(table.unpack(mean),1)
        end
        local newpalette = {}
        local maxd = 0
        for i,cluster in pairs(clusters) do
            local c = calcCentroid(cluster)
            local d = distanceFunction(c,palette[i])
            newpalette[#newpalette+1]=c
            maxd = maxd<d and d or maxd
        end
        for i=1,#newpalette do
            palette[i] = newpalette[i]
        end
        if maxd < eps then
            break
        end
    end
    return palette
end

return ImageHandler