package.path = package.path .. ";../?.lua" -- this is used so we can require from a parent directory

local combox = require "combox"
local Color = combox.Color

if not arg[1] then
    error("the first argument should be the name of a combinator, ex: FastCharCombinator")
end

local combinator = require ("combinators."..arg[1]):new()

local mon = peripheral.find("monitor")
if mon then
    mon.setTextScale(0.5)
end

local screen = combox.Renderer:new{
    term=mon,
    combinators = { combinator }
}

local image = combox.ImageHandler:new(
    screen.sx,
    screen.sy
):process(function(self,u,v)
    return Color(u,v):gamma2()
end)

screen:render(image):display()