local parser = require("Parser")
local coder = require("Coder")

local Assembler = {}

function GetName(filePath)
    local path, name = string.match(filePath, "(.-([^\\]+))%.asm$")
    if path == nil then error("file name error!") end
    return path, name
end

function Assembler.InitSymbolTable()
    local t = {}
    Assembler.symbolTable = t
    t["SP"] = 0
    t["LCL"] = 1
    t["ARG"] = 2
    t["THIS"] = 3
    t["THAT"] = 4
    t["SCREEN"] = 16384
    t["KBD"] = 24576
    for i=0, 15 do 
        t["R"..tostring(i)] = i
    end
    Assembler.nextVPos = 16
end

function Assembler.GetSymbolValue(smb)
    local t = Assembler.symbolTable
    if t[smb] == nil then
        t[smb] = Assembler.nextVPos
        print("******add value", smb, Assembler.nextVPos)
        Assembler.nextVPos = Assembler.nextVPos + 1
    end
    return t[smb]
end


function Assembler.AddLable(smb, value)
    local t = Assembler.symbolTable
    t[smb] = value
    --print("******add Lable", smb, value)
end

function Assembler.start(filePath)
    Assembler.InitSymbolTable()

    local path, name = GetName(filePath)
    local outFile = path..".hack"
    
    local lines = parser.parse(filePath)
    io.output(outFile)

    local cnt = 0
    for _, line in pairs(lines) do
        if line[1] == "L" then
            Assembler.AddLable(line[2], cnt)
        else
            cnt = cnt + 1
        end
    end

    for _, line in pairs(lines) do
        if line[1] == "a" then
            if line[2] == "w" then
                line[3] = Assembler.GetSymbolValue(line[3])
            end
            local acode = coder.codeAInstruction(line[3])
            -- print(line.name, "A-Cmd", line[3])
            -- print(acode)

            io.write(acode,"\n")
        elseif line[1] == "c" then
            local ccode = coder.codeCInstruction(line[2], line[3], line[4])
            -- print(line.name, "C-Cmd", "COMP:" .. line[2], "DEST:" .. line[3], "JMP" .. line[4])
            -- print(ccode, "\n")

            io.write(ccode,"\n")
        end
    end
end

Assembler.start(arg[1])









