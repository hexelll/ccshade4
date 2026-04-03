local Color = require "Color"

local patterns = {
    {0,1,'-'},
    {1,0,'|'},
    {0.5,-0.5,'\\'},
    {0.5,0.5,'/'}
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

local function distance(v1,v2)
    return math.abs(v1[1]*v2[2]-v1[2]*v2[1])
end

local function findClosest(vec)
    local mini = 1
    local mind = distance(patterns[1],vec)
    for i=2,#patterns do
        local d = distance(patterns[i],vec)
        if d < mind then
            mind = d
            mini = i
        end
    end
    return patterns[mini]
end

function combinator:findCombination(u,v,image,palette,renderer)
    local vec = {0,0}
    local color = image:getPx(u,v)
    for x=-1,1 do
        for y=-1,1 do
            ku,kv = x/(renderer.sx-1),y/(renderer.sy-1)
            local px = image:getPx(u+ku,v+kv)
            px = px and px or Color:new()
            local d = color:distance(px)
            vec[1] = vec[1] + x*d
            vec[2] = vec[2] + y*d
        end
    end
    local l = math.sqrt(vec[1]^2+vec[2]^2)
    local char = '`'
    if l > 0 then
        vec[1] = vec[1]/l
        vec[2] = vec[2]/l
        char = findClosest(vec)[3]
    end
    return {char,hexTable[Color:new():findClosest(palette)],hexTable[color:findClosest(palette)]}
end

return combinator