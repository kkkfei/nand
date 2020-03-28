local Parser = {}

local function GetAInstruction(valueStr)

    local valueType, value
    local num = tonumber(valueStr, 10)
    if num then
        valueType = "d"
        value = num
    else 
        valueType = "w"
        value = valueStr
    end
    return valueType, value
end

local function GetCInstruction(valueStr)

    
    local a, b, c = string.match(valueStr, "^([AMD]-)=?([^%s;=]+);?([%u]-)$")
    if a == nil then error("C Instruction error!!") end
    return a, b, c
end

function Parser.parse(filePath)
    local res = {}
    for line in io.lines(filePath) do
        line = string.gsub(line, "[%s]*", "")
        line = string.gsub(line, "//.*", "")
        --print(line)
        if line == "" then
            -- space
            --print("-->space")
        elseif string.sub(line,1,1) == "(" then
            --print("-->label")
            local info = {}
            res[#res+1] = info
            info.name = line
            info[1] = "L"
            info[2] = string.match(line, "[%w_%.%$:]+")
        else
            local info = {}
            res[#res+1] = info
            info.name = line
            -- Instruction
            local typea = string.match(line, "^[%s]*@([%w_%.%$:]+)")
            if typea ~= nil then
                info[1] = "a"
                local vt, v = GetAInstruction(typea)
                info[2] = vt
                info[3] = v
                --print("--> A-instruction", vt, v)
            else
                info[1] = "c"
                local dest, comp, jump = GetCInstruction(line)
                info[2] = comp
                info[3] = dest
                info[4] = jump
                --print("--> c-instruction", dest, comp, jump)
            end
        end
    end
    return res
end


return Parser