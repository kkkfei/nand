function GetName(filePath)
    local path, name = string.match(filePath, "(.-([^/]+))%.asm$")
    if path == nil then error("file name error!") end
    return path, name
end

local filePath = arg[1]
local path, name = GetName(filePath)
print(path..".hack")





