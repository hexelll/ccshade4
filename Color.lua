local Color = {}

local hexTableI = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["a"] = 10,
    ["b"] = 11,
    ["c"] = 12,
    ["d"] = 13,
    ["e"] = 14,
    ["f"] = 15
}

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

-- rgb 0-1
function Color:new(r,g,b,a)
    if type(r) == "string" then
        return Color.fromHex(r)
    end
    r = r and r or 0
    g = g and g or 0
    b = b and b or 0
    a = a and a or 1
    local o = {r,g,b,a}
    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end,
        __tostring=function(s)
            return "("..(round(s[1]*100)/100)..","..(round(s[2]*100)/100)..","..(round(s[3]*100)/100)..","..(round(s[4]*100)/100)..")"
        end,
        __sub=function(a,b)
            if type(a) ~= "table" or type(b) ~= "table" then
                error("both values must be colors")
            end
            return a:distance(b)
        end,
        __mul=function(a,b)
            if type(a) == "number" and type(b) == "table" then
                a,b=b,a
            end
            if type(a) == "table" and type(b) == "number" then
                return Color:new(a[1]*b,a[2]*b,a[3]*b,a[4])
            end
        end,
        __eq=function(a,b)
            return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
        end
    })
    return o
end

function Color:distance(color)
    return (self[1]-color[1])^2+(self[2]-color[2])^2+(self[3]-color[3])^2
end

local function interp(a,b,k)
    return a*k+b*(1-k)
end

function Color:mix(color,k)
    return Color:new(interp(self[1],color[1],k),interp(self[2],color[2],k),interp(self[3],color[3],k),interp(self[4],color[4],k))
end

function Color:findClosest(palette,distanceFunction)
    distanceFunction = distanceFunction and distanceFunction or self.distance
    local mindist = distanceFunction(self,palette[1])
    local mini = 1
    for i=2,#palette do
        local dist = distanceFunction(self,palette[i])
        if dist < mindist then
            mindist = dist
            mini = i
        end
    end
    return mini
end

function Color:toOklab()
    local r, g, b = self[1],self[2],self[3]

    -- Convert to Oklab
    local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

    local l_, m_, s_ = l^(1/3), m^(1/3), s^(1/3)

    local L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    local A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    local B = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

    -- Explicitly convert for nearly achromatic colors
    if math.abs(A) < 1e-4 then A = 0 end
    if math.abs(B) < 1e-4 then B = 0 end

    -- Normalize to appropriate range
    local k1, k2 = 0.206, 0.03
    local k3 = (1 + k1) / (1 + k2)
    L = 0.5 * (k3 * L - k1 + math.sqrt((k3 * L - k1) ^ 2 + 4 * k2 * k3 * L))
    return Color:new( 100 * L, 100 * A, 100 * B, self[4] )
end

function Color:distanceOklab(color)
    return self.distance(self:toOklab(),color:toOklab())
end

function Color.fromHex(hex)
    hex = string.lower(hex)
    local j = hex:sub(1,1) == "#" and 1 or 0
    local rgb = {}
    for i=0,2 do
        local n = hexTableI[hex:sub(j+2*i+1,j+2*i+1)]+hexTableI[hex:sub(j+2*i+2,j+2*i+2)]*16
        rgb[i+1] = n/255
    end
    return Color:new(table.unpack(rgb))
end

function Color:toHex()
    local rgb = {round(self[1]*255),round(self[2]*255),round(self[3]*255)}
    local hex = hexTable[(rgb[1] % 16)+1]..hexTable[(round((rgb[1]-(rgb[1] % 16))/16)%16)+1]..
        hexTable[(rgb[2] % 16)+1]..hexTable[(round((rgb[2]-(rgb[2] % 16))/16)%16)+1]..
        hexTable[(rgb[3] % 16)+1]..hexTable[(round((rgb[3]-(rgb[3] % 16))/16)%16)+1]
    return hex
end

function Color:duplicate()
    return Color:new(table.unpack(self))
end

function Color:toHash(size)
    local r = round(self[1]*size)
    local g = round(self[2]*size)
    local b = round(self[3]*size)
    return r*size*size+g*size+b
end

setmetatable(Color,{__call=function(self,...)
    return self:new(...)
end})

return Color