local MediaParser = require "MediaParser"
local CharCombinator = require "CharCombinator":new(arg[1]*1,100)--{127,20,0,164,167,169,174,37,42,15,2,190,187,177,61,29,34,120,48})
local SimpleCombinator = require "SimpleCombinator":new()

local ImageHandler = require "ImageHandler"
local Color = require "Color"
local Renderer = require "Renderer"

local mon = peripheral.find("monitor")
local width,height = mon.getSize()

local screen = Renderer:new{term=mon,defaultcombinator=CharCombinator,combinators={CharCombinator,SimpleCombinator}}

local image = MediaParser:open(arg[2])

screen.mask = ImageHandler:new(screen.sx,screen.sy,nil,true)
    for i=0,screen.sx-1 do
        for j=0,screen.sy-1 do
            local u,v = i/(screen.sx-1),j/(screen.sy-1)
            if(u<1)then
                screen.mask:setPx(u,v,Color:new(CharCombinator))
            else
                screen.mask:setPx(u,v,Color:new(SimpleCombinator))
            end
            
        end
    end

screen
:render(image)
.display()