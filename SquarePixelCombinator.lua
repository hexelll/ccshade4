local Color = require "Color"

local combinator = {}

local hexTable = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f"
}

local function round(x)
    return math.floor(x+0.5)
end

function combinator:new(cacheSize)
    cacheSize = cacheSize or 50
    local o = {cacheSize=cacheSize,cache={}}
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function combinator:init(palette)
    self.cache = {}
end

function combinator:findCombination(u,v,image,palette,renderer)
    local function addToCache(rawcol)
        col = Color:new(round(rawcol[1]*self.cacheSize)/self.cacheSize,round(rawcol[2]*self.cacheSize)/self.cacheSize,round(rawcol[3]*self.cacheSize)/self.cacheSize)
        local hcol = col:toHex()
        self.cache[hcol] = self.cache[hcol] and self.cache[hcol] or col:findClosest(palette)
        return self.cache[hcol]
    end
    local combination = {}
    local step = 1/(renderer.sy-1)
    if round(v*(renderer.sy-1))%2 == 0 then
        local col = addToCache(image:getPx(u,v))
        local othercol = image:getPx(u,v+step*2/3)
        if othercol then
            othercol = addToCache(othercol)
        else
            othercol = 1
        end
        combination[1] = '\143'
        combination[2] = hexTable[col]
        combination[3] = hexTable[othercol]
    else
        local col = image:getPx(u,v+step/3)
        col = col and col or image:getPx(u,v)
        col = addToCache(col)
        local othercol = image:getPx(u,v-step/3)
        if othercol then
            othercol = addToCache(othercol)
        else
            othercol = 1
        end
        combination[1] = '\131'
        combination[3] = hexTable[col]
        combination[2] = hexTable[othercol]
    end
    return combination
end

return combinator