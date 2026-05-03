local Color = require "Color"

local combinator = {name="SquarePixelCombinator"}

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
    cacheSize = cacheSize and cacheSize or 16
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
    local hcol = rawcol:toHash(self.cacheSize)
    if self.cache[hcol] then
        return self.cache[hcol]
    end
    local c = rawcol:findClosest(palette)
    self.cache[hcol] = c
    return c
end
function combinator:findCombination(u,v,image,palette,renderer)
    local combination = {}
    local step = 1/(renderer.sy-1)
    local c = image:getPx(u,v)
    if round(v*(renderer.sy-1))%2 == 0 then
        local col = addToCache(self,palette,c)
        local othercol = image:getPx(u,v+step*2/3)
        othercol = othercol and othercol or c
        othercol = addToCache(self,palette,othercol)
        combination[1] = '\143'
        combination[2] = hexTable[col]
        combination[3] = hexTable[othercol]
    else
        local col = image:getPx(u,v+step/3)
        col = col and col or c
        col = addToCache(self,palette,col)
        local othercol = image:getPx(u,v-step/3)
        othercol = othercol and othercol or c
        othercol = addToCache(self,palette,othercol)
        combination[1] = '\131'
        combination[3] = hexTable[col]
        combination[2] = hexTable[othercol]
    end
    return combination
end

return combinator