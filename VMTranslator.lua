local VMTranslator = {}
local Parser = {}
 

local C_PUSH = 1
local C_POP = 2
local C_A = 3


local function GetName(filePath)
    local path, name = string.match(filePath, "(.-([^\\]+))%.vm$")
    if path == nil then error("file name error!") end
    return path, name
end

local function CodePush(num)
    io.write("@"..num.."\n")
    io.write([[
D=A
@SP
A=M
M=D
@SP
M=M+1
]])
end

local function CodeArthmetic(arth)
    if arth == "add" then
        io.write([[
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
]])
    end
end
 
function VMTranslator.start(filePath)
    local path, name = GetName(filePath)
    local outFile = path..".asm"

    print(path, name)
    local lines = Parser.parse(filePath)
    io.output(outFile)

    for _, line in pairs(lines) do
        if line[1] == C_PUSH then
            if line[2] == "constant" then
                CodePush(line[3])
            end
 
        elseif line[1] == C_A then
            CodeArthmetic(line[2])
        end
    end
end

 
function Parser.parse(filePath)
    local res = {}
    for line in io.lines(filePath) do
        line = string.gsub(line, "//.*", "")
        line = string.gsub(line, "^%s*", "")

        if line == "" then
            -- space
            --print("-->space")
        elseif string.match(line, "^push ") then
            print(line)
            local a, b = string.match(line, "^push (%a+) (%w+)")
            res[#res+1] = {C_PUSH, a, b}
            print("->push command: ", a, b)

        elseif string.match(line, "^add$") then
            print(line)
            local a = string.match(line, "^(%w+)")
            print("->arithmetic command:", a)
            res[#res+1] = {C_A, a}
        else
            print(line)
        end
    end
    return res
end


VMTranslator.start(arg[1])











