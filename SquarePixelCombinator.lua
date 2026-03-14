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

function combinator:new()
    local o = {}
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function combinator:init()

end

function combinator:findCombination(u,v,x,y,image,palette,renderer)
    local combination = {}
    local step = 1/(renderer.sy-1)
    if (y-1)%2 == 0 then
        local col = image:getPx(u,v):findClosest(palette)
        local othercol = image:getPx(u,v+step*2/3)
        if othercol then
            othercol = othercol:findClosest(palette)
        else
            othercol = 1
        end
        combination[1] = '\143'
        combination[2] = hexTable[col]
        combination[3] = hexTable[othercol]
    else
        local col = image:getPx(u,v+step/3)
        col = col and col or image:getPx(u,v)
        col = col:findClosest(palette)
        local othercol = image:getPx(u,v-step/3)
        if othercol then
            othercol = othercol:findClosest(palette)
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