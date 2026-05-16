--[[
    this file allows for use of combox without polluting your environment with a bunch of files,
    this is very useful if you need to save on space
]]

local combinators = {
    "ASCIICombinator",
    "CharCombinator",
    "FastCharCombinator",
    "FlowCombinator",
    "MathCharCombinator",
    "SquarePixelCombinator",
    "VerboseCombinator",
    "SimpleCombinator"
}

local files = {
    "MediaParser",
    "png",
    "deflate",
    "qoi",
    "numberlua",
    "Color",
    "ImageHandler",
    "Renderer",
    "combox"
}

local function githubUrl(username,repo,path)
    return "https://api.github.com/repos/"..username.."/"..repo.."/contents/"..path
end

local function getUnwrappedResponse(url)
    local response = {http.get(url)}
    if not response[1] then
        error(response[2])
    end
    return response[1].readAll()
end

local url = githubUrl("hexelll","Combox","")
local combox = {
    combinators = {}
}

local response = textutils.unserializeJSON(getUnwrappedResponse(url))
for _,p in pairs(response) do
    if p.name == "combinators" then
        rep = textutils.unserialiseJSON(getUnwrappedResponse(p.url))
        for i,pt in pairs(rep) do
            for _,pc in pairs(combinators) do
                if pc..".lua" == pt.name then
                    local fn = loadstring(getUnwrappedResponse(pt.download_url))
                    setfenv(fn,_ENV)
                    combox.combinators[pc] = fn()
                end
            end
        end
    end
    for _,pf in pairs(files) do
        if p.name == pf..".lua" then
            local fn = loadstring(getUnwrappedResponse(p.download_url))
            setfenv(fn,_ENV)
            combox[pf] = fn()
        end
    end
end

return combox