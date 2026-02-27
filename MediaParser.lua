local qoi = require "qoi"
local ImageHandler = require "ImageHandler"
local Color = require "Color"

local MediaParser = {
    parsers = {
        qoi={
            decode=qoi.decode,
            encode=function()end
        }
    }
}

local function findExtension(path)
    local i = path:find("%.")
    while i do
        path = path:sub(i+1,#path)
        i = path:find("%.")
    end
    return path
end

function MediaParser:parse(data,type)
    local pixels,desc = {},{}
    if self.parsers[type] then
        pixels,desc = self.parsers[type].decode(data)
    end
    local imageData = {}
    for i=1,#pixels do
        local p = pixels[i]
        imageData[i] = Color:new(p[1]/255,p[2]/255,p[3]/255,p[4]/255)
    end
    return ImageHandler:new(desc.width,desc.height,imageData):initUnique()
end

function MediaParser:open(path)
    local fp = fs.open(shell.resolve(path),"r")
    local data = fp.readAll()
    return self:parse(data,findExtension(path))
end

function MediaParser.convert(image)

end

function MediaParser.write(data,path)

end

return MediaParser