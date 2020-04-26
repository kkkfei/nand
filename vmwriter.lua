local t = {}
local lableCnt = 1

function t.writeFunctionHead(name, cnt)
    io.write(string.format("function %s %d\n", name, cnt))
end

function t.writePush(segment, idx)
    io.write(string.format("push %s %s\n", segment, idx))
end

function t.writePop(segment, idx)
    io.write(string.format("pop %s %s\n", segment, idx))
end

--local opt = {'+' , '-' , '*' , '/' , '&' , '|' , '<' , '>' , '='}
local opT =
{
    ["+"] = "add",
    ["-"] = "sub",
    ["="] = "eq",
    [">"] = "gt",
    ["<"] = "lt",
    ["&"] = "and",
    ["|"] = "or"
}
function t.writeOP(op)
    io.write(opT[op] .. "\n")
end

function t.writeFunctionCall(name, args)
    io.write(string.format("call %s %d\n", name, args))
end

function t.writeReturn()
    io.write("return\n")
end

function t.writeIfgoto(labelName)
    io.write(string.format("if-goto %s\n", labelName))
end

function t.writeLabel(labelName)
    io.write(string.format("label %s\n", labelName))
end

function t.writeGoto(labelName)
    io.write(string.format("goto %s\n", labelName))
end

return t