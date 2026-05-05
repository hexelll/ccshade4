local Color = require("Color")

local SimpleCombinator = {name="SimpleCombinator"}


local hexTable = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}

local function round(x)
    return math.floor(x+0.5)
end

local function colorToIndex(c, size)
    local r = round(c[1] * (size - 1))
    local g = round(c[2] * (size - 1))
    local b = round(c[3] * (size - 1))

    return r * size * size + g * size + b
end

function SimpleCombinator:new(args)
    --[[ args {
        cacheSize = int
    } ]]
    args = args and args or {}
    local o = {}

    o.cacheSize = args.cacheSize and args.cacheSize or 100
    o.cache = {}

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function SimpleCombinator:onPaletteChange()
    self.cache = {}
end

function SimpleCombinator:onImageChange()

end

function SimpleCombinator:findCombination(u,v,image,palette)
    local px = image:getPx(u,v)

    local index = colorToIndex(px,self.cacheSize)

    local cacheResult = self.cache[index]
    if ( cacheResult ) then
        return cacheResult
    else  
        local indexColor = px:findClosest(palette)

        local combination = {string.char(0),"0",hexTable[indexColor]}
        self.cache[index] = combination
        return combination
    end
end

return SimpleCombinator