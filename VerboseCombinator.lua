local Color = require("Color")

local VerboseCombinator = {}

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

local function clamp(x)
    return math.min(math.max(x,0),1)
end

local function colorToIndex(c, size)
    local r = round(c[1] * (size - 1))
    local g = round(c[2] * (size - 1))
    local b = round(c[3] * (size - 1))

    return r * size * size + g * size + b
end

function VerboseCombinator:new(args)
    --[[ args {
        textColor = Color or number or nil or function(pixelColor,palette)
        backColor = Color or number or nil or function(pixelColor,palette)
        usedColors = {Color or string}
        usedStrings = {string}
        stringSeparator = string
        cacheSize = int
        cascadeRatio = int
    } ]]
        
    local o = {}

    local typeTextColor = type(args.textColor)
    if ( typeTextColor == "table" )then
        o.desiredTextColor = args.textColor

    elseif ( typeTextColor == "number" ) then
        o.textColorShader = function (pixelColor,palette)
            local r,g,b = table.unpack(pixelColor)
            return Color:new(clamp(r*args.textColor),clamp(g*args.textColor),clamp(b*args.textColor)):findClosest(palette)
        end

    elseif ( typeTextColor == "function" ) then
        o.textColorShader = args.textColor
    end

    local typeBackColor = type(args.backColor)
    if ( typeBackColor == "table" )then
        o.desiredBackColor = args.backColor

    elseif ( typeBackColor == "number" ) then
        o.backColorShader = function (pixelColor,palette)
            local r,g,b = table.unpack(pixelColor)
            return Color:new(clamp(r*args.backColor),clamp(g*args.backColor),clamp(b*args.backColor)):findClosest(palette)
        end

    elseif ( typeBackColor == "function" ) then
        o.backColorShader = args.backColor
    end

    o.usedColors = args.usedColors and args.usedColors or nil
    for i, color in ipairs(o.usedColors) do
        if (type(color)=="string") then
            o.usedColors[i] = Color.fromHex(color)
        end
    end

    o.usedStrings = args.usedStrings and args.usedStrings or {}
    if (args.stringSeparator) then
        for i, string in ipairs(o.usedStrings) do
            o.usedStrings[i] = string..args.stringSeparator 
        end
    end
    o.stringSeparator = args.stringSeparator and args.stringSeparator or ""

    o.edgeSeparator = args.edgeSeparator and string.sub(args.edgeSeparator,1,1) or " "

    o.shiftToEdges = args.shiftToEdges
    o.lastBoundaryPosition = math.huge
    o.lastBoundaryStringIndex = -1

    o.cascadeRatio = args.cascadeRatio and args.cascadeRatio or 0

    o.cache = {}
    o.cacheSize = args.cacheSize and args.cacheSize or 100

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end

function VerboseCombinator:onPaletteChange(palette)
    self.usedTextColorIndex = self.desiredTextColor and self.desiredTextColor:findClosest(palette) or nil
    self.usedBackColorIndex = self.desiredBackColor and self.desiredBackColor:findClosest(palette) or nil

    self.cache = {}
end

function VerboseCombinator:onImageChange(image)

end


function VerboseCombinator:findCombination(u,v,image,palette,renderer)

    local pixelColor = image:getPx(u,v)

    local indexT,indexB

    local index = colorToIndex(pixelColor,self.cacheSize)

    local cacheResult = self.cache[index]
    if ( cacheResult ) then
        indexT,indexB = table.unpack(cacheResult)
    else  

        indexT = self.usedTextColorIndex 
        if ( not indexT )then
            if ( self.textColorShader) then
                indexT = self.textColorShader(pixelColor,palette,image,renderer)
            else
                indexT = pixelColor:findClosest(palette)
            end
        end

        indexB = self.usedBackColorIndex 
        if ( not indexB ) then
            if (self.backColorShader) then
                indexB = self.backColorShader(pixelColor,palette,image,renderer)
            else
                indexB = pixelColor:findClosest(palette)
            end
        end

        self.cache[index] = {indexT,indexB}
    end

    local usedStringIndex = self.usedColors and pixelColor:findClosest(self.usedColors) or nil ;
    
    local char = ' ';
    if ( usedStringIndex ) then 
        local usedString = self.usedStrings[usedStringIndex]

        if (self.shiftToEdges) then

            local i

            local texelPosition = u*(renderer.sx-1)
            
            if ( texelPosition < self.lastBoundaryPosition) then
                self.lastBoundaryPosition = texelPosition 
                self.lastBoundaryStringIndex = usedStringIndex
            end
            if (usedStringIndex ~= self.lastBoundaryStringIndex) then
                self.lastBoundaryPosition = texelPosition 
                self.lastBoundaryStringIndex = usedStringIndex

                char = self.edgeSeparator
            else
                local offset = self.lastBoundaryPosition == 0 and 0 or 1
                i = round( texelPosition - self.lastBoundaryPosition -offset + self.cascadeRatio*v*(renderer.sy-1) ) % usedString:len() +1
                char = string.sub(usedString,i,i)
            end
            
        else 
            local i = round( u* (renderer.sx-1) + self.cascadeRatio*v*(renderer.sy-1)  ) % usedString:len() +1
            char = string.sub(usedString,i,i)
        end 
        
    end
    
    return {char,hexTable[indexT],hexTable[indexB]}
end

return VerboseCombinator