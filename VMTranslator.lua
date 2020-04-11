local VMTranslator = {}
local Parser = {}
 

local C_PUSH = 1
local C_POP = 2
local C_A = 3

local lable_cnt= 1


local function GetName(filePath)
    local path, name = string.match(filePath, "(.-([^\\]+))%.vm$")
    if path == nil then error("file name error!") end
    return path, name
end

local function CodePushNum(num)
io.write("//------push constant num -------\n")
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
    print(arth)
    if arth == "add" then
        io.write([[
//add            
@SP
M=M-1
A=M
D=M
A=A-1
M=D+M
]])
    elseif arth == "sub" then
        io.write([[
//sub
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
]])        

    elseif arth == "neg" then
        io.write([[
//neg
@SP
A=M
A=A-1
M=-M
]])          

    elseif arth == "eq" then
        local str = [[
//eq            
@SP
M=M-1
A=M
D=M
A=A-1
D=M-D
@LABEL_TRUE
D;JEQ
D=0
@END
0;JMP
(LABEL_TRUE)
D=-1
(END)
@SP
A=M
A=A-1
M=D
]]
    str = string.gsub(str, "LABEL_TRUE", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1

    str = string.gsub(str, "END", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1
    io.write(str, "\n")

    elseif arth == "gt" then
        local str = [[
//gt            
@SP
M=M-1
A=M
D=M
A=A-1
D=M-D
@LABEL_TRUE
D;JGT
D=0
@END
0;JMP
(LABEL_TRUE)
D=-1
(END)
@SP
A=M
A=A-1
M=D
]]
    str = string.gsub(str, "LABEL_TRUE", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1

    str = string.gsub(str, "END", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1
    io.write(str, "\n")

    elseif arth == "lt" then
        local str = [[
//lt            
@SP
M=M-1
A=M
D=M
A=A-1
D=M-D
@LABEL_TRUE
D;JLT
D=0
@END
0;JMP
(LABEL_TRUE)
D=-1
(END)
@SP
A=M
A=A-1
M=D
]]
    str = string.gsub(str, "LABEL_TRUE", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1

    str = string.gsub(str, "END", "COMPILER_L_"..tostring(lable_cnt)) 
    lable_cnt = lable_cnt + 1
    io.write(str, "\n")

    elseif arth == "and" then
        io.write([[
//and            
@SP
M=M-1
A=M
D=M
A=A-1
M=D&M
]])        

    elseif arth == "or" then
        io.write([[
//or            
@SP
M=M-1
A=M
D=M
A=A-1
M=D|M
]])
    elseif arth == "not" then
        io.write([[
//not            
@SP
A=M
A=A-1
M=!M
]])
    end
end

local pushStr =
[[
//--------push------
@__NUM__
D=A             
@__SEGMENT__
A=D+M
D=M
@SP
A=M
M=D
@SP
M=M+1
//--------end push------

]]

function pushSegment(segment, idx)
    local str = string.gsub(pushStr, "__NUM__", idx)
    str = string.gsub(str, "__SEGMENT__", segment)
    return str
end

function pushBaseOff(base, idx)
    local pos = tonumber(idx) + base
    local str =
[[
@__NUM__
D=M             
@SP
A=M
M=D
@SP
M=M+1
]]
    str = string.gsub(str, "__NUM__", tostring(pos))
    return str
end
 
local popStr =
[[     
@__SEGMENT__
D=M
@__NUM__
D=D+A

@SP
A=M
M=D
A=A-1
D=M
A=A+1
A=M
M=D
@SP
M=M-1
]]

function popSegment(segment, idx)
    local str = string.gsub(popStr, "__NUM__", idx)
    str = string.gsub(str, "__SEGMENT__", segment)
    return str
end

function popBaseOff(base, idx)
    local pos = tonumber(idx) + base
    local str =
[[
@SP
AM=M-1
D=M
@__NUM__
M=D             
]]
    str = string.gsub(str, "__NUM__", tostring(pos))
    return str
end
 
function VMTranslator.start(filePath)
    local path, name = GetName(filePath)
    local outFile = path..".asm"

    print(path, name)
    local lines = Parser.parse(filePath)
    io.output(outFile)

    for _, line in pairs(lines) do
        io.write("//", line.src, "\n")
        if line[1] == C_PUSH then
            if line[2] == "constant" then
                CodePushNum(line[3])
            elseif line[2] == "local" then
                io.write(pushSegment("LCL", line[3]))
            elseif line[2] == "argument" then
                io.write(pushSegment("ARG", line[3]))
            elseif line[2] ==  "this" then
                io.write(pushSegment("THIS", line[3]))
            elseif line[2] == "that" then
                io.write(pushSegment("THAT", line[3]))
            elseif line[2] == "pointer" then
                io.write(pushBaseOff(3, line[3]))
            elseif line[2] == "temp" then
                io.write(pushBaseOff(5, line[3]))
            elseif line[2] == "static" then
                io.write(pushBaseOff(16, line[3]))
            end
        
        elseif line[1] == C_POP then

            if line[2] == "local" then
                io.write(popSegment("LCL", line[3]))
            elseif line[2] == "argument" then
                io.write(popSegment("ARG", line[3]))
            elseif line[2] ==  "this" then
                io.write(popSegment("THIS", line[3]))
            elseif line[2] == "that" then
                io.write(popSegment("THAT", line[3]))
            elseif line[2] == "pointer" then
                io.write(popBaseOff(3, line[3]))
            elseif line[2] == "temp" then
                io.write(popBaseOff(5, line[3]))
            elseif line[2] == "static" then
                io.write(popBaseOff(16, line[3]))
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
            res[#res+1] = {C_PUSH, a, b, src=line}
            print("->push command: ", a, b)
        elseif string.match(line, "^pop ") then
            print(line)
            local a, b = string.match(line, "^pop (%a+) (%w+)")
            res[#res+1] = {C_POP, a, b, src=line}
            print("->pop command: ", a, b)
        else
            print(line)
            local a = string.match(line, "^(%w+)")
            print("->arithmetic command:", a)
            res[#res+1] = {C_A, a, src=line}

        end
    end
    return res
end


VMTranslator.start(arg[1])











