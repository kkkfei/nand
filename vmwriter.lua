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


local opT =
{
    ["+"] = "add",
    ["not"] = "not"
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

return t