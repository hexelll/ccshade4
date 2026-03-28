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

function VerboseCombinator:new(textColor,backColor,usedColors,usedStrings,stringSeparator,cacheSize,cascadeRatio)
    local o = {}

    local typeTextColor = type(textColor)
    if ( typeTextColor == "table" )then
        o.desiredTextColor = textColor

    elseif ( typeTextColor == "number" ) then
        o.textColorShader = function (pixelColor,palette)
            local r,g,b = table.unpack(pixelColor)
            return Color:new(clamp(r*textColor),clamp(g*textColor),clamp(b*textColor)):findClosest(palette)
        end

    elseif ( typeTextColor == "function" ) then
        o.textColorShader = textColor
    end

    local typeBackColor = type(backColor)
    if ( typeBackColor == "table" )then
        o.desiredBackColor = backColor

    elseif ( typeBackColor == "number" ) then
        o.backColorShader = function (pixelColor,palette)
            local r,g,b = table.unpack(pixelColor)
            return Color:new(clamp(r*backColor),clamp(g*backColor),clamp(b*backColor)):findClosest(palette)
        end

    elseif ( typeBackColor == "function" ) then
        o.backColorShader = backColor
    end

    o.usedColors = usedColors and usedColors or {}
    for i, color in ipairs(o.usedColors) do
        if (type(color)=="string") then
            o.usedColors[i] = Color.fromHex(color)
        end
    end

    o.usedStrings = usedStrings and usedStrings or {}
    if (stringSeparator) then
        for i, string in ipairs(o.usedStrings) do
            o.usedStrings[i] = string..stringSeparator 
        end
    end

    o.cascadeRatio = cascadeRatio and cascadeRatio or 0;

    o.cache = {}
    o.cacheSize = cacheSize and cacheSize or 100

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

    local stringIndex = self.usedColors and pixelColor:findClosest(self.usedColors) or nil ;
    
    local char = ' ';
    if ( stringIndex ) then
        local txt = self.usedStrings[stringIndex]
        local i = round( u* (renderer.sx-1) + self.cascadeRatio*v*(renderer.sy-1)  ) % txt:len() +1
        char = string.sub(txt,i,i)
    end
    
    return {char,hexTable[indexT],hexTable[indexB]}
end

return VerboseCombinator