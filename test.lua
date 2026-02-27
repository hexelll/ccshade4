local MediaParser = require "MediaParser"
local SimpleCombinator = require "SimpleCombinator"
local ImageHandler = require "ImageHandler"
local Color = require "Color"

local combinator = SimpleCombinator:new()

while true do
    local mon = peripheral.find("monitor")

    local width,height = mon.getSize()

    local img = ImageHandler:new(width,height):process(function(self,u,v)
        local k = (1+math.sin(os.clock()))/2
        return Color:new(0,u*k,v*k)
    end)
    local palette = img:findPalette()
    for i=1,#palette do
        local p = palette[i]
        mon.setPaletteColor(2^(i-1),p[1],p[2],p[3])
    end
    local t = os.clock()
    for y=1,img.sy do
        mon.setCursorPos(1,y)
        for x=1,img.sx do
            local u,v = x/img.sx, y/img.sy
            local c = combinator:findCombination(u,v,img,palette)
            mon.blit(table.unpack(c))
        end
    end
    local endt = os.clock()
    print(endt-t)
    sleep()
end