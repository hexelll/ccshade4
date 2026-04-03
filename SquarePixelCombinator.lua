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
    cacheSize = cacheSize or 10
    local o = {cacheSize=cacheSize,cache={}}
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function combinator:onPaletteChange()
    self.cache = {}
end

function combinator:onImageChange()

end
local function addToCache(self,palette,rawcol)
    col = Color:new(round(rawcol[1]*self.cacheSize)/self.cacheSize,round(rawcol[2]*self.cacheSize)/self.cacheSize,round(rawcol[3]*self.cacheSize)/self.cacheSize)
    local hcol = col:toHex()
    if self.cache[hcol] then
        return self.cache[hcol]
    end
    local c = col:findClosest(palette)
    self.cache[hcol] = c
    return c
end
function combinator:findCombination(u,v,image,palette,renderer)
    local combination = {}
    local step = 1/(renderer.sy-1)
    if round(v*(renderer.sy-1))%2 == 0 then
        local col = addToCache(self,palette,image:getPx(u,v))
        local othercol = image:getPx(u,v+step*2/3)
        if othercol then
            othercol = addToCache(self,palette,othercol)
        else
            othercol = addToCache(self,palette,image:getPx(u,v))
        end
        combination[1] = '\143'
        combination[2] = hexTable[col]
        combination[3] = hexTable[othercol]
    else
        local col = image:getPx(u,v+step/3)
        col = col and col or image:getPx(u,v)
        col = addToCache(self,palette,col)
        local othercol = image:getPx(u,v-step/3)
        if othercol then
            othercol = addToCache(self,palette,othercol)
        else
            othercol = addToCache(self,palette,image:getPx(u,v))
        end
        combination[1] = '\131'
        combination[3] = hexTable[col]
        combination[2] = hexTable[othercol]
    end
    return combination
end

return combinator