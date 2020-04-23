 local tokenizer = require "JackTokenizer"
 

local function getName(filePath)
    local path, name = string.match(filePath, "(.-([^/\\]+))%.jack$")
    if path == nil then error("file name error!") end
    return path, name
end

local function outTokens(tokens)
    local i = 1
    while i < #tokens do
        local tp = tokens[i]
        local v = tokens[i+1]
        i = i + 2

        v = string.gsub(v, "&", "&amp;")
        v = string.gsub(v, "<", "&lt;")
        v = string.gsub(v, ">", "&gt;")
        v = string.gsub(v, "\"", "&quot;")
        io.write(string.format("<%s> %s </%s>\n", tp, v, tp))
    end
end

local function start()
    local idx = 1
    while arg[idx] do
        local path, name = getName(arg[idx])
        local outFile = path .. "T_m.xml"
        io.output(outFile)
        io.write("<tokens>\n")
        local tokens = tokenizer.parse(arg[idx])
        outTokens(tokens)
        io.write("</tokens>\n")
        idx = idx+1
    end
end

start()