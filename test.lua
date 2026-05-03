local MediaParser = require "MediaParser"
local Renderer = require "Renderer"
local Color = require "Color"
local SimpleCombinator = require "combinators.SimpleCombinator":new()
local CharCombinator = require "combinators.CharCombinator":new{
    nbSearched = 100,
    cacheSize = 100,
    usedChars = {127,20,0,164,167,169,174,37,42,15,2,190,187,177,61,29,34,120,48}
}
local SmoothCombinator = require "combinators.MyCharX":new{
    cacheSize = 100,
    usedChars = {127,20,0,164,167,169,174,37,42,15,2,190,187,177,61,29,34,120,48}
}
local SSmoothCombinator = require "combinators.SmoothCharCombinator":new{
    cacheSize = 100,
    usedChars = {127,20,0,164,167,169,174,37,42,15,2,190,187,177,61,29,34,120,48}
}
local PixelBoxCombinator = require "combinators.PixelBoxCombinator":new()
local SquarePixelCombinator = require "combinators.SquarePixelCombinator":new(100)
local FlowCombinator = require "combinators.FlowCombinator":new{limit=0.2,defaultchar='+'}
local ASCIICombinator = require "combinators.ASCIICombinator":new()
local VerboseCombinator = require "combinators.VerboseCombinator":new{
    textColor = nil,
    backColor = Color:new(0,0,0),
    usedColors = {Color:new(1,1,1),Color:new(1,0,0),Color:new(0,1,0),"#b7b7b7","#000000","#383636"},
    usedStrings = {"white","red","green","light gray","black","dark gray"},
    shiftToEdges = false,
    stringSeparator = " ",--"\183"
    cacheSize = 100,
    cascadeRatio = 0
}
local ImageHandler = require "ImageHandler"

local function round(x)
    return math.floor(x+0.5)
end

local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
local width,height = mon.getSize()

local screen = Renderer:new{
    term=mon,
    defaultCombinator=SquarePixelCombinator,
    combinators={
        --FlowCombinator,
        SSmoothCombinator,
        --CharCombinator,
        SmoothCombinator,
        --PixelBoxCombinator,
        --VerboseCombinator,
        --ASCIICombinator,
        --SimpleCombinator
    },debug=false}
local image = MediaParser:open("images/"..arg[1])

function testAllCombs(self,u,v)
    local k = 1/#screen.combinators
    for i=1,#screen.combinators do
        if u <= i*k then
            return screen.combinators[i]
        end
    end
    return SimpleCombinator
end

function edger(img,c1,c2)
    return function(self,u,v)
        local vec = {0,0}
        local color = self:getPx(u,v)
        for x=-1,1 do
            for y=-1,1 do
                ku,kv = x/(self.sx-1),y/(self.sy-1)
                local px = img:getPx(u+ku,v+kv)
                px = px and px or Color:new()
                local d = color:distance(px)
                vec[1] = vec[1] + x*d
                vec[2] = vec[2] + y*d
            end
        end
        local l = math.sqrt(vec[1]^2+vec[2]^2)
        if l > 1.5 then
            return c2
        end
   
        return c1
    end
end

image = image:new(width,height):process(function(self,u,v)return Color(u,v)end)--image:resize(width,round(height*3/2))
local palette = image:findPalette()
while true do
    
    print("start display")
    local t = os.clock()
    
    --ka = (1+math.sin(t))/2
    --image:process(shader)--:process(edgeShader)
    screen.mask = ImageHandler:new(screen.sx,screen.sy):process(testAllCombs)--:process(edger(image,CharCombinator,SquarePixelCombinator))--:process(edger(image,CharCombinator,SquarePixelCombinator,PixelBoxCombinator))
    screen
        :render(image,palette)
        .display()
    print("end display:",os.clock()-t)
    sleep(0.1)
end
