local Color = require("Color")

local SimpleCombinator = {}


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

function SimpleCombinator:new()
    local o = {}
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function SimpleCombinator:init()

end

function SimpleCombinator:findCombination(u,v,x,y,image,palette)
    local indexColor = image:getPx(u,v):findClosest(palette)
    return {string.char(0),"0",hexTable[indexColor]}
end

return SimpleCombinator