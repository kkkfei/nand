local t = {}

kw = {
    'class' , 'constructor' , 'function' ,
        'method' , 'field' , 'static' , 'var' ,
        'int' , 'char' , 'boolean' , 'void' , 'true' ,
        'false' , 'null' , 'this' , 'let' , 'do' ,
        'if' , 'else' , 'while' , 'return'
}

local print = function() end


function t.parse(filePath)
    if keyDic == nil then
        keyDic = {}
        for _, k in ipairs(kw) do
            keyDic[k] = true
        end
    end

    local res = {}
    local isInComment = false
    for line in io.lines(filePath) do
        line = string.gsub(line, "//.*", "")
        line = string.gsub(line, "^%s*", "")

        print("==" .. line .. "==")
        local idx = 1
        while idx <= #line do
            --取消前置空格
            local a, b = string.find(line, "^[%s]+", idx)
            if a then idx = b + 1 end

            if isInComment then
                -- 结束注释
                if string.find(line, "%*/", idx) then
                    local a, b =  string.find(line, "%*/", idx)
                    print("****[comment end]****")
                    isInComment = false
                    idx = b + 1
                else
                    break
                end
            else
                -- 开始注释
                if string.find(line, "^/%*", idx) then
                    local a, b =  string.find(line, "^/%*", idx)
                    print("****[comment start]****")
                    isInComment = true
                    idx = b + 1
                elseif string.find(line, "^[_%a][_%w]*", idx) then
                    print("****[word]****")
                    local a, b, word =  string.find(line, "^([_%a][_%w]*)", idx)
                    idx = b + 1
                    print(word)

                    local type = "identifier"
                    if keyDic[word] then type = "keyword" end
                    res[#res+1] = type
                    res[#res+1] = word
                elseif string.find(line, "^%d+",  idx) then
                    print("****[int]****")
                    local a, b, word =  string.find(line, "^(%d+)", idx)
                    print(word)
                    idx = b + 1

                    res[#res+1] = "integerConstant"
                    res[#res+1] = word
                elseif string.find(line, "^[^%s%w\"]",  idx) then
                    print("****[symbol]****")
                    local a, b, word =  string.find(line, "^([^%s%w])", idx)
                    print(word)
                    idx = b + 1

                    res[#res+1] = "symbol"
                    res[#res+1] = word
                elseif string.find(line, "^\".*\"",  idx) then
                    print("****[string]****")
                    local a, b, word =  string.find(line, "^\"(.*)\"", idx)
                    print(word)
                    idx = b + 1

                    res[#res+1] = "stringConstant"
                    res[#res+1] = word
                end


                --取消前置空格
                local a, b = string.find(line, "^[%s]+", idx)
                if a then idx = b + 1 end
            end -- end if 

        end --while line

    end
    return res
end
 


return t