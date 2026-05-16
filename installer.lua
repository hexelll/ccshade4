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

local function ptabs(n)
    local str = ""
    for i=1,n do
        str = str.."  "
    end
    return str
end

local function downloadRepo(path,url,doTests)
    local response = textutils.unserializeJSON(getUnwrappedResponse(url))

    for _,p in pairs(response) do
        if p.name == "combinators" then
            rep = textutils.unserialiseJSON(getUnwrappedResponse(p.url))
            for i,pt in pairs(rep) do
                for _,pc in pairs(combinators) do
                    if pc..".lua" == pt.name then
                        term.write(ptabs(1))
                        print(pt.path)
                        local h = fs.open(path..pt.path,"w")
                        h.write(getUnwrappedResponse(pt.download_url))
                        h.close()
                    end
                end
            end
        elseif doTests and p.name == "tests" then
            rep = textutils.unserialiseJSON(getUnwrappedResponse(p.url))
            for _,pt in pairs(rep) do
                term.write(ptabs(1))
                print(pt.path)
                local h = fs.open(path..pt.path,"w")
                h.write(getUnwrappedResponse(pt.download_url))
                h.close()
            end
        end
        for _,pf in pairs(files) do
            if p.name == pf..".lua" then
                print(p.path)
                if p.download_url then
                    local h = fs.open(path..p.path,"w")
                    h.write(getUnwrappedResponse(p.download_url))
                    h.close()
                end
            end
        end
    end  
end

if arg[1] == "-h" then
    print("this program installs all files for ComBox \n usage: installer <path> -t\n -t => optional, installs tests folder")
    return
end
local path = arg[1] == "-t" and "./" or arg[1]
local doTests = arg[1] == "-t" or arg[2] == "-t"
if not arg[1] and not arg[2] then
    print("install path:")
    path = read()
    print("install tests?: [y/N]")
    local ans = read()
    doTests = ans == 'y' or ans == 'Y'
end

downloadRepo(path,githubUrl("hexelll","ComBox",""),doTests)