local Renderer = {}
local SimpleCombinator = require "SimpleCombinator"
local Color = require "Color"
local ImageHandler = require "ImageHandler"

function Renderer:new(params)
    local o = {}
    o.term = params.term and params.term or term
    o.defaultcombinator = params.defaultcombinator and params.defaultcombinator or SimpleCombinator:new()
    local defaultcombinators = {o.defaultcombinator}
    o.combinators = params.combinators and params.combinators or defaultcombinators
    local width,height = o.term.getSize()
    o.sx,o.sy = params.sx and params.sx or width, params.sy and params.Sy or height
    o.mask = params.mask and params.mask
    o.px,o.py = params.px and params.px or 0, params.py and params.py or 0
    o.debug = params.debug
    if not o.mask then
        o.mask = ImageHandler:new(o.sx,o.sy,nil,true)
        for i=0,o.sx-1 do
            for j=0,o.sy-1 do
                local u,v = i/(o.sx-1),j/(o.sy-1)
                o.mask:setPx(u,v,Color:new(defaultcombinators[1]))
            end
        end
    end
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function Renderer:setMask(u,v,combinator)
    self.mask:setPx(u,v,Color:new(combinator))
    return self
end

function Renderer:resize(sx,sy)
    self.sx = sx
    self.sy = sy
    self.mask:resize(sx,sy)
    return self
end

function Renderer:getCombinator(u,v)
    return self.mask:getPx(u,v)[1]
end

function Renderer:render(image,palette)
    local t
    if self.debug then
        t = os.clock()
        print("start render")
    end
    palette = palette and palette or image:findPalette()
    
    local equal = true
    if self.lastPalette then
        for i=1,#palette do
            if not (self.lastPalette[i] == palette[i]) then
                equal = false
                break
            end
        end
    else
        equal = false
    end
    if not equal then
        for _,combinator in pairs(self.combinators) do
            combinator:init(palette)
        end
    end
    self.lastPalette = palette
    self.palette = palette
    local timeYield = os.clock()
    local lines = {}
    for i=1,self.sy do
        lines[i] = {"","",""}
        for j=1,self.sx do
            local v,u = (i-1)/((self.sy-1)),(j-1)/((self.sx-1))
            local combinator = self:getCombinator(u,v)
            local combination = combinator:findCombination(u,v,image,palette,self)
            lines[i][1] = lines[i][1]..combination[1]
            lines[i][2] = lines[i][2]..combination[2]
            lines[i][3] = lines[i][3]..combination[3]

            if ( os.clock() > timeYield+5 ) then
                sleep()
                timeYield = os.clock()
            end
        end
    end
    if self.debug then
        print("end render:",os.clock()-t)
    end
    return {lines=lines,display=function()
        self:display(lines)
        return self
    end}
end

function Renderer:display(lines)
    local t
    if self.debug then
        t = os.clock()
        print("start display")
    end
    local palette = self.palette
    for i=1,#palette do
        self.term.setPaletteColor(2^(i-1),palette[i][1],palette[i][2],palette[i][3])
    end
    for i=1,#lines do
        self.term.setCursorPos(1+self.px,i+self.py)
        self.term.blit(table.unpack(lines[i]))
    end
    if self.debug then
        print("end display:",os.clock()-t)
    end
    return self
end

return Renderer