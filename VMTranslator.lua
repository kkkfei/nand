local VMTranslator = {}
local Parser = {}
 
local C_PUSH = 1
local C_POP = 2
local C_A = 3
local C_LABEL = 4
local C_GOTO = 5
local C_IF = 6
local C_FUNCTION = 7
local C_RETURN = 8
local C_CALL = 9

local lable_cnt= 1
local labelPrefix = ""


local function GetName(filePath)
    local path, name = string.match(filePath, "(.-([^/\\]+))%.vm$")
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

function CodeLabel(label)
    return "("..labelPrefix..label.. ")\n"
end

function CodeIf(label)
    local str = 
[[
@SP
AM=M-1
D=M
@__LABEL__
D;JNE
]]

    str = string.gsub(str, "__LABEL__", labelPrefix..label)
    return str
end

function CodeGoto(label)
    return "@" .. labelPrefix..label .. "\n0;JMP\n"
end



function CodeFunction(fn, lcl_cnt)
    --[[
        local变量处理
    ]]
    local outStr = "(" .. fn .. ")\n"
local pushLocal =
[[
@SP
A=M
M=0
@SP
M=M+1    
]]
    for i=1, lcl_cnt do
        outStr = outStr .. pushLocal
    end
    return outStr
end

function CodeReturn()
    local str =
[[
//Save return addr in R14
//Save return value addr in R15
@ARG
D=M
@R15
M=D
@LCL
A=M-1
D=A
@R13 
M=D
//Restore THAT
A=D
D=M
@THAT
M=D
//Restore THIS
@R13
AM=M-1
D=M
@THIS
M=D
//Restore ARG
@R13
AM=M-1
D=M
@ARG
M=D
//Restore LCL
@R13
AM=M-1
D=M
@LCL
M=D
//Get Return addr
@R13
A=M-1
D=M
@R14
M=D
//Set return value
@SP
A=M-1
D=M
@R15
A=M
M=D
//Set SP
@R15
D=M+1
@SP
M=D
//JMP back to caller
@R14
A=M
0;JMP
]]

    return str
end

function CodeCall(fn, args_cnt)
local str =
[[
//new ARG
@SP
D=M
@__ARGS_CNT__
D=D-A
@R13
M=D

//save return
@__CALL_RETURN__
D=A
@SP
A=M
M=D
@SP
M=M+1

//save LCL
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1

//save ARG
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1

//save THIS
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1

//save THAT
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1

//Set New LCL
@SP
D=M
@LCL
M=D

//Set New ARG
@R13
D=M
@ARG
M=D

@__FUN_NAME__
0;JMP
(__CALL_RETURN__)
]]

    str = string.gsub(str, "__FUN_NAME__", fn)
    str = string.gsub(str, "__CALL_RETURN__", "LABEL_RETURN_" .. tostring(lable_cnt))
    str = string.gsub(str, "__ARGS_CNT__", args_cnt)
    lable_cnt = lable_cnt + 1
    return str

end
 
function VMTranslator.translate(filePath)
    local lines = Parser.parse(filePath)

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
        elseif line[1] == C_LABEL then
            io.write(CodeLabel(line[2]))
        elseif line[1] == C_IF then
            io.write(CodeIf(line[2]))
        elseif line[1] == C_GOTO then
            io.write(CodeGoto(line[2]))
        elseif line[1] == C_FUNCTION then
            io.write(CodeFunction(line[2], line[3]))
        elseif line[1] == C_RETURN then
            io.write(CodeReturn())
        elseif line[1] == C_CALL then
            io.write(CodeCall(line[2], line[3]))
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
        elseif string.match(line, "^label ") then
            print(line)
            local a = string.match(line, "^label ([^%s]*)")
            res[#res+1] = {C_LABEL, a, src=line}
            print("->label command: ", a )
            
        elseif string.match(line, "^if%-goto") then
            print(line)
            local a = string.match(line, "^if%-goto ([^%s]*)")
            res[#res+1] = {C_IF, a, src=line}
            print("->if command: ", a )
        elseif string.match(line, "^goto") then
            print(line)
            local a = string.match(line, "^goto ([^%s]*)")
            res[#res+1] = {C_GOTO, a, src=line}
            print("->goto command: ", a )
        elseif string.match(line, "^function") then
            print(line)
            local a, b = string.match(line, "^function ([^%s]*) ([^%s]*)")
            res[#res+1] = {C_FUNCTION, a, b, src=line}
            print("->function command: ", a , b)
        elseif string.match(line, "^return") then
            print(line)
            res[#res+1] = {C_RETURN, src=line}
            print("->return  command: ")
        elseif string.match(line, "^call") then
            print(line)
            local a, b = string.match(line, "^call ([^%s]*) ([^%s]*)")
            res[#res+1] = {C_CALL, a, b, src=line}
            print("->call command: ", a , b)
        else
            print(line)
            local a = string.match(line, "^(%w+)")
            print("->arithmetic command:", a)
            res[#res+1] = {C_A, a, src=line}

        end
    end
    return res
end

function codeBootstrap()
    -- body
    local str =
[[
//sp = 256
@256
D=A
@SP
M=D

//call sys.init
//@Sys.init
//0;JMP
]]
    return str .. CodeCall("Sys.init", 0)
end


function VMTranslator.start()
    local outFile = nil
    local idx = 1
    if arg[2] ~= nil then
        outFile = arg[1]
        idx = 2
    else
        outFile = path..".asm"
    end
    
    io.output(outFile)
    io.write(codeBootstrap())
    while arg[idx] do
        local path, name = GetName(arg[idx])
        labelPrefix = name .. "$"
        VMTranslator.translate(arg[idx])
        idx = idx+1
    end
end
 
VMTranslator.start()











