local MediaParser = require "MediaParser"
local SimpleCombinator = require "SimpleCombinator":new()
local CharCombinator = require "RoughCharCombinator":new(50,{127,20,0,164,167,169,174,37,42,15,2,190,187,177,61,29,34,120,48})
local SquarePixelCombinator = require "SquarePixelCombinator":new(10)
local ImageHandler = require "ImageHandler"
local Color = require "Color"
local Renderer = require "Renderer"

local width,height = term.getSize()

local screen = Renderer:new{combinators={
    SquarePixelCombinator,
    CharCombinator
},debug=false}
----print("start open")
local t = os.clock()
local rawimage = MediaParser:open(arg[1]):resize(300,300)
--print("end open:",os.clock()-t)
--[[local image = ImageHandler:new(100,100):process(function(self,u,v)
    return Color:new(u,v)
end)]]
--print("start processes")
local t = os.clock()
rawimage.doUnique = false
local rImage = rawimage:copy():process(function(self,u,v)
    return Color:new(self:getPx(u,v)[1])
end)
local gImage = rawimage:copy():process(function(self,u,v)
    return Color:new(0,self:getPx(u,v)[2])
end)
local bImage = rawimage:copy():process(function(self,u,v)
    return Color:new(0,0,self:getPx(u,v)[3])
end)
--print("end processes:",os.clock()-t)

local image = rawimage:process(function(self,u,v)
    local k = 1/(self.sx-1)
    local pr = rImage:getPx(math.max(0,u-4*k),v)
    local pg = gImage:getPx(u,v)
    local pb = bImage:getPx(math.min(1,u+4*k),v)
    return Color:new(pr[1]+pg[1]+pb[1],pr[2]+pg[2]+pb[2],pr[3]+pg[3]+pb[3])
end)

--local palette = image:findPalette()
--[[local rawPalette = {
    {0,   0,   0},     
    {255,255,255} ,    
    {128,128,128} ,    

    {255,  0,  0} ,   
    {0, 255,  0} ,     
    {0,   0,255} ,     
    {255,255,  0} ,    
    {255,  0,255} ,    
    {0, 255,255}  ,    

    {128,  0,  0} ,    
    {0, 128,  0}  ,    
    {0,   0,128}  ,    
    {128,128,  0} ,    
    {128,  0,128}  ,   
    {0, 128,128} ,     
    {192,192,192}     
}
local palette = {}
for i,c in pairs(rawPalette) do
    palette[i] = Color:new(c[1]/255,c[2]/255,c[3]/255)
end]]

local rawPalette = {{0.07843137254902,0.047058823529412,0.10980392156863},{0.26666666666667,0.14117647058824,0.20392156862745},{0.18823529411765,0.20392156862745,0.42745098039216},{0.30588235294118,0.29019607843137,0.30588235294118},{0.52156862745098,0.29803921568627,0.18823529411765},{0.20392156862745,0.39607843137255,0.14117647058824},{0.8156862745098,0.27450980392157,0.28235294117647},{0.45882352941176,0.44313725490196,0.38039215686275},{0.34901960784314,0.49019607843137,0.8078431372549},{0.82352941176471,0.49019607843137,0.17254901960784},{0.52156862745098,0.5843137254902,0.63137254901961},{0.42745098039216,0.66666666666667,0.17254901960784},{0.82352941176471,0.66666666666667,0.6},{0.42745098039216,0.76078431372549,0.7921568627451},{0.85490196078431,0.83137254901961,0.36862745098039},{0.87058823529412,0.93333333333333,0.83921568627451}}

local palette = image:findPalette()--{}
for i,c in pairs(rawPalette) do
    --palette[i] = Color:new(table.unpack(c))
end

screen.mask = ImageHandler:new(2,2,nil,true,true):process(function(self,u,v)
    if u < 0.5 then
        return Color:new(CharCombinator)
    end
    return Color:new(SquarePixelCombinator)
end)
local image = ImageHandler:new(width,height)

while true do
    --print("start display")
    local t = os.clock()
    local ka = 0--1+math.sin(os.clock()*2)--math.random()
    image:process(function(self,u,v)
        local k = 1/(self.sx-1)
        local pr = rImage:getPx(math.max(0,u-10*k*ka),v)
        local pg = gImage:getPx(u,v)
        local pb = bImage:getPx(math.min(1,u+10*k*ka),v)
        return Color:new(pr[1]+pg[1]+pb[1],pr[2]+pg[2]+pb[2],pr[3]+pg[3]+pb[3])
    end)

    screen
    :render(image,palette)
    .display()
    --print("end display:",os.clock()-t)
    sleep(0.1)
end