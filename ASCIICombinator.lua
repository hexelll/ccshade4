local Color = require "Color"
local chars = {
    ' ','.','+','=','%','\7','\14','\15','#','@'
}

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

local combinator = {}

function combinator:new()
    local o = {}
    setmetatable(o,{__index=self})
    return o
end

function combinator:onPaletteChange()

end

function combinator:onImageChange()

end

local function round(x)
    return math.floor(x+0.5)
end

function combinator:findCombination(u,v,image,palette)
    local px = image:getPx(u,v)
    px = px and px or Color:new()
    local k = (px[1]+px[2]+px[3])/3
    return {chars[round(k*#chars)],hexTable[px:findClosest(palette)],hexTable[Color:new():findClosest(palette)]}
end

return combinator