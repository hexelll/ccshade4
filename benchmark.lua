local Renderer = require "Renderer"
local Color = require "Color"
local ImageHandler = require "ImageHandler"
local MediaParser = require "MediaParser"

local combinator = require("combinators."..arg[1]):new()
local meanT = 0
local N = tonumber(arg[2])
local mon = peripheral.find("monitor")
local screen = Renderer:new{
    term=mon,
    combinators={combinator}
}
--local image = ImageHandler:new(screen.sx,screen.sy):process(function(self,u,v)return Color(u,v)end):linearize()
local image = MediaParser:open("images/gar.qoi"):resize(screen.sx,math.floor(screen.sy*3/2+0.5))

for i=1,N do
    local tstart = os.clock()
    local palette = image:findPalette(nil,nil,0.001,50)
    combinator:onPaletteChange(palette)
    screen:render(image,palette).display()
    meanT = meanT + os.clock()-tstart
end

print(meanT/N)