local combinator = {name="FastCharCombinator"}


local hexTable = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}

local charCoefs = {0 ,19/54 ,25/54 ,21/54 ,13/54 ,19/54 ,18/54 ,12/54 ,36/54 ,0 ,0 ,14/54 ,17/54 ,0 ,15/54 ,22/54 ,13/54 ,13/54 ,20/54 ,12/54 ,19/54 ,20/54 ,8/54 ,24/54 ,13/54 ,13/54 ,11/54 ,11/54 ,7/54 ,10/54 ,13/54 ,13/54 ,0 ,6/54 ,6/54 ,20/54 ,15/54 ,11/54 ,15/54 ,3/54 ,9/54 ,9/54 ,6/54 ,9/54 ,3/54 ,5/54 ,2/54 ,7/54 ,19/54 ,12/54 ,16/54 ,14/54 ,15/54 ,17/54 ,15/54 ,12/54 ,17/54 ,15/54 ,4/54 ,5/54 ,7/54 ,10/54 ,7/54 ,14/54 ,24/54 ,18/54 ,20/54 ,13/54 ,18/54 ,17/54 ,13/54 ,17/54 ,17/54 ,11/54 ,10/54 ,15/54 ,11/54 ,17/54 ,17/54 ,16/54 ,14/54 ,16/54 ,18/54 ,15/54 ,11/54 ,15/54 ,13/54 ,17/54 ,13/54 ,9/54 ,15/54 ,11/54 ,7/54 ,11/54 ,5/54 ,5/54 ,3/54 ,14/54 ,16/54 ,11/54 ,16/54 ,15/54 ,11/54 ,17/54 ,14/54 ,6/54 ,11/54 ,12/54 ,7/54 ,13/54 ,12/54 ,12/54 ,14/54 ,14/54 ,9/54 ,13/54 ,9/54 ,12/54 ,9/54 ,14/54 ,9/54 ,15/54 ,13/54 ,9/54 ,7/54 ,9/54 ,6/54 ,1/3 ,0 ,1/6 ,1/6 ,1/3 ,1/6 ,1/3 ,1/3 ,1/2 ,1/6 ,1/3 ,1/3 ,1/2 ,1/3 ,1/2 ,1/2 ,2/3 ,1/6 ,1/3 ,1/3 ,1/2 ,1/3 ,1/2 ,1/2 ,2/3 ,1/3 ,1/2 ,1/2 ,2/3 ,1/2 ,2/3 ,2/3 ,5/6 ,0 ,6/54 ,13/54 ,16/54 ,16/54 ,17/54 ,6/54 ,20/54 ,2/54 ,20/54 ,11/54 ,10/54 ,7/54 ,5/54 ,18/54 ,5/54 ,8/54 ,14/54 ,7/54 ,8/54 ,2/54 ,15/54 ,19/54 ,4/54 ,2/54 ,8/54 ,12/54 ,10/54 ,14/54 ,13/54 ,17/54 ,9/54 ,16/54 ,16/54 ,19/54 ,18/54 ,16/54 ,15/54 ,20/54 ,14/54 ,18/54 ,18/54 ,21/54 ,18/54 ,11/54 ,11/54 ,12/54 ,11/54 ,19/54 ,17/54 ,16/54 ,16/54 ,17/54 ,16/54 ,16/54 ,9/54 ,19/54 ,13/54 ,13/54 ,12/54 ,13/54 ,9/54 ,14/54 ,19/54 ,16/54 ,16/54 ,19/54 ,18/54 ,16/54 ,15/54 ,17/54 ,13/54 ,17/54 ,17/54 ,20/54 ,17/54 ,7/54 ,7/54 ,8/54 ,7/54 ,15/54 ,16/54 ,14/54 ,14/54 ,17/54 ,16/54 ,14/54 ,7/54 ,15/54 ,14/54 ,14/54 ,13/54 ,14/54 ,17/54 ,13/54 ,17/54}

function combinator:new(args)
    args = args and args or {}
    local o = {}

    o.cacheSize = args.cacheSize and args.cacheSize or 100
    
    o.usedChars = args.usedChars and args.usedChars or {}
    if ( #o.usedChars == 0) then
        o.usedChars = {}
        for i=1,255 do
            o.usedChars[#o.usedChars+1] = i-1
        end
    end

    o.usedCharsCoef = {}
    for _,charNum in ipairs(o.usedChars) do
        o.usedCharsCoef[#o.usedCharsCoef+1] = charCoefs[charNum+1]
    end

    o.sortedCharsCoeff = {}
    local l = #o.usedCharsCoef
    for i=1,l do
        o.sortedCharsCoeff[i] = {coef=o.usedCharsCoef[i],char=o.usedChars[i]}
    end
    local sorted = false
    while not sorted do
        sorted = true
        for i=1,l-1 do
            local t1,t2 = o.sortedCharsCoeff[i],o.sortedCharsCoeff[i+1]
            if t1.coef > t2.coef then
                o.sortedCharsCoeff[i],o.sortedCharsCoeff[i+1] = t2,t1
                sorted = false
            end
        end
    end

    o.palettesize = 0

    o.cache = {}

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })

    return o
end


function combinator:onPaletteChange(palette)
    self.palettesize = #palette
    self.cache = {}
end

function combinator:onImageChange()

end

local function round(x)
    return math.floor(x+0.5)
end

local function findClosestChar(self,c)
    local l = #self.sortedCharsCoeff
    local i = 1+round(c*(l-1))
    local ma = l
    local mi = 1
    local ok = true
    local char = self.sortedCharsCoeff[1]
    while ok do
        local t = self.sortedCharsCoeff[i]
        local tc = t.coef
        if tc == c then
            ok = false
            char = t
        end
        if mi >= ma then
            ok = false
            char = t
        end
        if c < tc then
            ma = math.max(i-1,1)
            i = round((mi+i)/2)
        end
        if c > tc then
            mi = math.min(i+1,l)
            i = round((ma+i)/2)
        end
    end
    return char
end

function combinator:findCombination(u,v,image,palette)

    local col = image:getPx(u,v)
    local hash = col:toHash(self.cacheSize)
    if self.cache[hash] then
        return self.cache[hash]
    end
    local size = self.palettesize
    local firstclosest = col:findClosest(palette,nil,size)

    local secondclosest = 1
    local mind = col:distance(palette[1])
    for i=2,size do
        if i ~= firstclosest then
            local d = col:distance(palette[i])
            if d < mind then
                mind = d
                secondclosest = i
            end
        end
    end

    local d1 = palette[firstclosest]:distance(col)
    local d2 = palette[secondclosest]:distance(col)

    local c = d1/(d1+d2)
    local char1 = findClosestChar(self,c)
    local char2 = findClosestChar(self,1-c)
    local reverse = math.abs(c-char1.coef) > math.abs(1-c-char2.coef)
    local char = char1
    if reverse then
        secondclosest,firstclosest = firstclosest,secondclosest
        char = char2
    end
    
    local tab = {string.char(char.char),hexTable[secondclosest],hexTable[firstclosest]}
    self.cache[hash] = tab
    return tab
end

return combinator