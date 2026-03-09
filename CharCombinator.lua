local Color = require("Color")

local CharCombinator = {}

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

local charCoefs = {
    0 ,
    19/54 ,
    25/54 ,
    21/54 ,
    13/54 ,
    19/54 ,
    18/54 ,
    12/54 ,
    36/54 ,
    0 ,
    0 ,
    14/54 ,
    17/54 ,
    0 ,
    15/54 ,
    22/54 ,
    13/54 ,
    13/54 ,
    20/54 ,
    12/54 ,
    19/54 ,
    20/54 ,
    8/54 ,
    24/54 ,
    13/54 ,
    13/54 ,
    11/54 ,
    11/54 ,
    7/54 ,
    10/54 ,
    13/54 ,
    13/54 ,
    0 ,
    6/54 ,
    6/54 ,
    20/54 ,
    15/54 ,
    11/54 ,
    15/54 ,
    3/54 ,
    9/54 ,
    9/54 ,
    6/54 ,
    9/54 ,
    3/54 ,
    5/54 ,
    2/54 ,
    7/54 ,
    19/54 ,
    12/54 ,
    16/54 ,
    14/54 ,
    15/54 ,
    17/54 ,
    15/54 ,
    12/54 ,
    17/54 ,
    15/54 ,
    4/54 ,
    5/54 ,
    7/54 ,
    10/54 ,
    7/54 ,
    14/54 ,
    24/54 ,
    18/54 ,
    20/54 ,
    13/54 ,
    18/54 ,
    17/54 ,
    13/54 ,
    17/54 ,
    17/54 ,
    11/54 ,
    10/54 ,
    15/54 ,
    11/54 ,
    17/54 ,
    17/54 ,
    16/54 ,
    14/54 ,
    16/54 ,
    18/54 ,
    15/54 ,
    11/54 ,
    15/54 ,
    13/54 ,
    17/54 ,
    13/54 ,
    9/54 ,
    15/54 ,
    11/54 ,
    7/54 ,
    11/54 ,
    5/54 ,
    5/54 ,
    3/54 ,
    14/54 ,
    16/54 ,
    11/54 ,
    16/54 ,
    15/54 ,
    11/54 ,
    17/54 ,
    14/54 ,
    6/54 ,
    11/54 ,
    12/54 ,
    7/54 ,
    13/54 ,
    12/54 ,
    12/54 ,
    14/54 ,
    14/54 ,
    9/54 ,
    13/54 ,
    9/54 ,
    12/54 ,
    9/54 ,
    14/54 ,
    9/54 ,
    15/54 ,
    13/54 ,
    9/54 ,
    7/54 ,
    9/54 ,
    6/54 ,
    1/3 ,
    0 ,
    1/6 ,
    1/6 ,
    1/3 ,
    1/6 ,
    1/3 ,
    1/3 ,
    1/2 ,
    1/6 ,
    1/3 ,
    1/3 ,
    1/2 ,
    1/3 ,
    1/2 ,
    1/2 ,
    2/3 ,
    1/6 ,
    1/3 ,
    1/3 ,
    1/2 ,
    1/3 ,
    1/2 ,
    1/2 ,
    2/3 ,
    1/3 ,
    1/2 ,
    1/2 ,
    2/3 ,
    1/2 ,
    2/3 ,
    2/3 ,
    5/6 ,
    0 ,
    6/54 ,
    13/54 ,
    16/54 ,
    16/54 ,
    17/54 ,
    6/54 ,
    20/54 ,
    2/54 ,
    20/54 ,
    11/54 ,
    10/54 ,
    7/54 ,
    5/54 ,
    18/54 ,
    5/54 ,
    8/54 ,
    14/54 ,
    7/54 ,
    8/54 ,
    2/54 ,
    15/54 ,
    19/54 ,
    4/54 ,
    2/54 ,
    8/54 ,
    12/54 ,
    10/54 ,
    14/54 ,
    13/54 ,
    17/54 ,
    9/54 ,
    16/54 ,
    16/54 ,
    19/54 ,
    18/54 ,
    16/54 ,
    15/54 ,
    20/54 ,
    14/54 ,
    18/54 ,
    18/54 ,
    21/54 ,
    18/54 ,
    11/54 ,
    11/54 ,
    12/54 ,
    11/54 ,
    19/54 ,
    17/54 ,
    16/54 ,
    16/54 ,
    17/54 ,
    16/54 ,
    16/54 ,
    9/54 ,
    19/54 ,
    13/54 ,
    13/54 ,
    12/54 ,
    13/54 ,
    9/54 ,
    14/54 ,
    19/54 ,
    16/54 ,
    16/54 ,
    19/54 ,
    18/54 ,
    16/54 ,
    15/54 ,
    17/54 ,
    13/54 ,
    17/54 ,
    17/54 ,
    20/54 ,
    17/54 ,
    7/54 ,
    7/54 ,
    8/54 ,
    7/54 ,
    15/54 ,
    16/54 ,
    14/54 ,
    14/54 ,
    17/54 ,
    16/54 ,
    14/54 ,
    7/54 ,
    15/54 ,
    14/54 ,
    14/54 ,
    13/54 ,
    14/54 ,
    17/54 ,
    13/54 ,
    17/54 ,
}

local combineColors = function (colorT,colorB,coef) 
    local r = colorT[1]*coef + (1-coef)*colorB[1]
    local g = colorT[2]*coef + (1-coef)*colorB[2]
    local b = colorT[3]*coef + (1-coef)*colorB[3]
    return {r,g,b}
end

-- Calculate the difference between two colors
local differenceColors = function (color1,color2)
    return ( (color1[1]-color2[1])^2+(color1[2]-color2[2])^2+(color1[3]-color2[3])^2 )
end

function CharCombinator:new(nbSearched,usedChars)
    usedChars = usedChars and usedChars or {}
    nbSearched = nbSearched and nbSearched or 1

    local o = {}
    o.usedChars = usedChars
    o.nbSearched = nbSearched
    o.combinationTable = {}
    o.charCoefs = charCoefs

    if ( #usedChars == 0) then
        o.usedChars = {}
        for i=1,255 do
            --if (o.charCoefs[i] ~= -1) then
                o.usedChars[#o.usedChars+1] = i-1
            --end
        end
    end

    o.usedCharsCoef = {}
    for _,charNum in ipairs(o.usedChars) do
        table.insert( o.usedCharsCoef , o.charCoefs[charNum+1] )
    end

    setmetatable(o,{
        __index=function(_,k)
            return self[k]
        end
    })
    return o
end


function CharCombinator:init(image,palette)

    local combinationTable = {}
    for textColNum=1,#palette do

        local colorT = palette[textColNum]
        combinationTable[textColNum] = {}

        for backColNum=1,#palette do

            local colorB = palette[backColNum]
            combinationTable[textColNum][backColNum] = {}

            local closeness = differenceColors(colorT,colorB) 

            if (textColNum~=backColNum) then

                for i=1,#self.usedChars do

                        local coef = self.usedCharsCoef[i]
                        
                        if ( coef == 0.5 and backColNum < textColNum) then
                            combinationTable[textColNum][backColNum][i] = nil
                        else
                            local color = combineColors(colorT,colorB,coef)

                            combinationTable[textColNum][backColNum][i] = {color,closeness}
                        end
                end 
            else
                combinationTable[textColNum][backColNum] = nil
            end
        end 
    end
    self.combinationTable = combinationTable
end


function CharCombinator:findCombination(u,v,x,y,image,palette)
    local colorNew = image:getPx(u,v)
    local searchedColor = {colorNew[1],colorNew[2],colorNew[3]}

    local combinationTable = self.combinationTable
    local usedChars = self.usedChars
    local nbSearched = self.nbSearched

    local best = {}   -- sorted by dif ascending

    for textColNum = 1, #combinationTable do
        local row = combinationTable[textColNum]

        for backColNum = 1, #row do
            local cell = row[backColNum]

            if cell then
                for i = 1, #usedChars do
                    local charNum = usedChars[i]
                    local comb = cell[i]

                    if comb then
                        local color = comb[1]
                        local closeness = comb[2]

                        local dif = differenceColors(color,searchedColor)

                        -- inline sorted insertion
                        local inserted = false
                        local len = #best

                        for j = 1, len do
                            if dif < best[j][4] then
                                table.insert(best,j, {
                                    textColNum,
                                    backColNum,
                                    charNum,
                                    dif,
                                    closeness
                                })
                                inserted = true
                                break
                            end
                        end

                        if not inserted then
                            best[len + 1] = {
                                textColNum,
                                backColNum,
                                charNum,
                                dif,
                                closeness
                            }
                        end

                        if #best > nbSearched then
                            best[nbSearched + 1] = nil
                        end
                    end
                end
            end
        end
    end

    -- select smallest closeness among best difs
    local bestIdx = 1
    local bestClose = best[1][5]

    for i = 2, #best do
        local cclose = best[i][5]
        if cclose < bestClose then
            bestClose = cclose
            bestIdx = i
        end
    end

    local r = best[bestIdx]

    return {string.char(r[3]),hexTable[r[1]],hexTable[r[2]]}

end

return CharCombinator