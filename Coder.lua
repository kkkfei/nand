local coder = {}

local function decimalToBinary(num) 
    local b = {}
    for i=16,1,-1 do
        b[i] = num%2
        num = num//2
    end
    return table.concat(b)
end

local function codeJump(jump)
    if jump == "" then return 0, 0, 0
    elseif jump == "JGT" then return 0, 0, 1
    elseif jump == "JEQ" then return 0, 1, 0
    elseif jump == "JGE" then return 0, 1, 1
    elseif jump == "JLT" then return 1, 0, 0
    elseif jump == "JNE" then return 1, 0, 1
    elseif jump == "JLE" then return 1, 1, 0
    elseif jump == "JMP" then return 1, 1, 1
    end
end

local function codeDest(dest)
    if dest == "" then return 0, 0, 0 end

    local a=0
    local m=0
    local d=0
    for i = 1, #dest do
        local c = dest:sub(i, i)
        if c == "A" then a = 1 
        elseif c == "M" then m = 1
        elseif c == "D" then d = 1
        end
    end
    return a, d, m
end

local function codeComp(comp)
    if comp == "0" then return      1, 0, 1, 0, 1, 0
    elseif comp == "1" then return  1, 1, 1, 1, 1, 1
    elseif comp == "-1" then return 1, 1, 1, 0, 1, 0
    elseif comp == "D" then return  0, 0, 1, 1, 0, 0
    elseif comp == "A" then return  1, 1, 0, 0, 0, 0
    elseif comp == "!D" then return 0, 0, 1, 1, 0, 1
    elseif comp == "!A" then return 1, 1, 0, 0, 0, 1
    elseif comp == "-D" then return  0, 0, 1, 1, 1, 1
    elseif comp == "-A" then return  1, 1, 0, 0, 1, 1
    elseif comp == "D+1" then return 0, 1, 1, 1, 1, 1
    elseif comp == "A+1" then return 1, 1, 0, 1, 1, 1
    elseif comp == "D-1" then return 0, 0, 1, 1, 1, 0
    elseif comp == "A-1" then return 1, 1, 0, 0, 1, 0
    elseif comp == "D+A" then return 0, 0, 0, 0, 1, 0
    elseif comp == "D-A" then return 0, 1, 0, 0, 1, 1
    elseif comp == "A-D" then return 0, 0, 0, 1, 1, 1
    elseif comp == "D&A" then return 0, 0, 0, 0, 0, 0
    elseif comp == "D|A" then return 0, 1, 0, 1, 0, 1
    else
        error("Code comp Error! " .. comp)
    end
end

function coder.codeAInstruction(value)
    return decimalToBinary(value)
end


function coder.codeCInstruction(comp, dest, jump)
    local b = {}
    b[1] = 1
    b[2] = 1
    b[3] = 1

    comp, b[4] = string.gsub(comp, "M", "A")
    
    b[5], b[6], b[7], b[8], b[9], b[10] = codeComp(comp)

    b[11], b[12], b[13] = codeDest(dest)

    b[14], b[15], b[16] = codeJump(jump)

    return table.concat(b)
end

return coder