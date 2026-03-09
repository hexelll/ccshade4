local MediaParser = require "MediaParser"
local SimpleCombinator = require "SimpleCombinator"
local ImageHandler = require "ImageHandler"
local Color = require "Color"
local Renderer = require "Renderer"

local mon = peripheral.find("monitor")
local width,height = mon.getSize()

local screen = Renderer:new{term=mon}

screen
:render(MediaParser:open(arg[1]))
.display()