local w = require("vmwriter")
local t = {}

local function getNextToken()
    assert(t.idx+1 <= #(t.tokens))
    local a = t.tokens[t.idx]
    local b = t.tokens[t.idx+1]
    t.idx = t.idx + 2
    return a, b
end

local function eatSymbol(symbol)
    local a, b = getNextToken()
    assert(b == symbol)
end

local function eatIdentifier()
    local a, b = getNextToken()
    assert(a == "identifier")
    return b
end

local function peekNextToken()
    assert(t.idx+1 <= #(t.tokens))
    local a = t.tokens[t.idx]
    local b = t.tokens[t.idx+1]
    return a, b
end

local function peekNextNextToken()
    assert(t.idx+3 <= #(t.tokens))
    local a = t.tokens[t.idx+2]
    local b = t.tokens[t.idx+3]
    return a, b
end

local function pushVar(name)
    local kind, objectIdx
    if t.tm[name] then
        kind = t.tm[name].kind
        objectIdx = t.tm[name].idx

        if kind == "var" then kind = "local" end
        w.writePush(kind, objectIdx)
    end

    if t.tc[name] then
        kind = t.tc[name].kind
        objectIdx = t.tc[name].idx

        if kind == "field" then kind = "this" end
        w.writePush(kind, objectIdx)
    end
end

local function popVar(name)
    local kind, objectIdx
    if t.tm[name] then
        kind = t.tm[name].kind
        objectIdx = t.tm[name].idx

        if kind == "var" then kind = "local" end
        w.writePop(kind, objectIdx)
    end

    if t.tc[name] then
        kind = t.tc[name].kind
        objectIdx = t.tc[name].idx

        if kind == "field" then kind = "this" end
        w.writePop(kind, objectIdx)
    end
end

local function getFunctionLabel()
    local labelCnt = t.labelCnt
    local label = t.className .. "_" .. labelCnt
    t.labelCnt = labelCnt + 1
    return label
end

local st_class = {}
local st_method = {}


function t.init(tks)
    t.tokens = tks
    t.idx = 1

    t.tc = {}
    t.tm = {}

    t.labelCnt = 0
    t.staticCnt = 0
    t.fieldCnt = 0
    t.argumentCnt = 0
    t.varCnt = 0
end



--class: 'class' className '{' classVarDec* subroutineDec* '}'
function t.compileClass()
    local a, b  = getNextToken()
    assert(b == "class")

    t.className = eatIdentifier()

    eatSymbol("{")

    while t.compileClassVarDec() do end

    while t.compileSubroutine() do end

    eatSymbol("}")
end

local function addTc(name, kind, type)
    t.staticCnt = t.staticCnt or 0
    t.fieldCnt = t.fieldCnt or 0

    local row = {}
    row.kind = kind
    row.type = type
    if kind == "static" then 
        row.idx = t.staticCnt
        t.staticCnt = t.staticCnt + 1
    else
        row.idx = t.fieldCnt
        t.fieldCnt = t.fieldCnt + 1
    end

    t.tc[name] = row
end

local function printTc()
    io.write("[class] " .. t.className .. "\n")
    
    for k, v in pairs(t.tc) do
        io.write(k,",", v.kind,",",v.type,",", v.idx, "\n")
    end
    io.write("")
end

local function addTm(name, kind, type)
    t.argumentCnt = t.argumentCnt or 0
    t.varCnt = t.varCnt or 0

    local row = {}
    row.kind = kind
    row.type = type
    if kind == "argument" then 
        row.idx = t.argumentCnt
        t.argumentCnt = t.argumentCnt + 1
    else
        row.idx = t.varCnt
        t.varCnt = t.varCnt + 1
    end

    t.tm[name] = row
end

local function printTm()
    io.write("[function] " .. t.functionName .. "\n")
    
    for k, v in pairs(t.tm) do
        io.write(k,",", v.kind,",",v.type,",", v.idx, "\n")
    end
    io.write("")
end

-- classVarDec: ('static' | 'field') type varName (',' varName)* ';'
function t.compileClassVarDec()
    local a, b  = peekNextToken()
    if b ~= "static" and b ~= "field" then return false end

    a, b  = getNextToken()
    assert(b == "static" or b == "field")
    local kind = b
    --type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
    local type = b

    local name = eatIdentifier()
    addTc(name, kind, type)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end

        eatSymbol(",")
        name = eatIdentifier()
        addTc(name, kind, type)
    end

    eatSymbol(";")
    
    return true
end

--[[
subroutineDec: ('constructor' | 'function' | 'method')
                ('void' | type) subroutineName '(' parameterList ')'
                subroutineBody

]]
function t.compileSubroutine()
    t.tm = {}
    t.argumentCnt = 0
    t.varCnt = 0

    local a, b  = peekNextToken()
    t.functionType = b
    if b ~= "constructor" and b ~= "function" and b ~= "method" then return false end


    a, b  = getNextToken()

    --void | type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "void" or b == "int" or b == "char" or b == "boolean" or a == "identifier")
    
    local name = eatIdentifier()
    t.functionName = string.format("%s.%s", t.className, name)
    
    if t.functionType == "constructor" then
    elseif t.functionType == "method" then
        addTm("this", "argument", t.className)
    end

    eatSymbol("(")
    t.compileParameterList()
    eatSymbol(")")
    t.compileSubroutineBody()

    io.write("\n")

    return true
end

-- subroutineBody: '{' varDec* statements '}'
function t.compileSubroutineBody()
    eatSymbol("{")
    
    while t.compileVarDec() do end

    w.writeFunctionHead(t.functionName, t.varCnt)
    if t.functionType == "constructor" then
        w.writePush("constant", t.fieldCnt)
        w.writeFunctionCall("Memory.alloc", "1")
        w.writePop("pointer", "0")
    elseif t.functionType == "method" then
        w.writePush("argument", "0") 
        w.writePop("pointer", "0")
    end

    t.compileStatements()

    eatSymbol("}")
end

-- parameterList: ((type varName) (',' type varName)*)?
function t.compileParameterList()
 
    local kind = "argument"
    local a, b  = peekNextToken()
    if b == "int" or b == "char" or b == "boolean" or a == "identifier" then
        a, b  = getNextToken()
    local type = b

    local name = eatIdentifier()

    addTm(name, kind, type)
    while true do
        a, b = peekNextToken()
        if b ~= "," then break end
        eatSymbol(",")
        
        a, b  = getNextToken()
        assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
        type = b
        
        name =  eatIdentifier(lv)
        addTm(name, kind, type)
        end
    end
end

-- varDec: 'var' type varName (',' varName)* ';'
function t.compileVarDec()
    local kind = "var"

    local a, b  = peekNextToken()
    if  b ~= "var" then return false end
    a, b = getNextToken()

     -- type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
    local type = b
    local name = eatIdentifier()
    addTm(name, kind, type)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end
        eatSymbol(",")
        name = eatIdentifier()
        addTm(name, kind, type)
    end

    eatSymbol(";")
    return true
end

-- statements: statement*
function t.compileStatements()
    while t.compileStatement() do end
end

--[[
    statement: letStatement | ifStatement | whileStatement |
    doStatement | returnStatement
]] 
function t.compileStatement()
    local a, b  = peekNextToken()
    if b == "let" then
        t.compileLet()
    elseif b == "do" then
        t.compileDo()
        w.writePop("temp", 0)
    elseif b == "if" then
        t.compileIf()
    elseif b == "while" then
        t.compileWhile()
    elseif b == "return" then
        t.compileReturn()
    else
        return false
    end

    return true
end

--[[
    doStatement: 'do' subroutineCall ';'
]]
function t.compileDo()

    local a, b  = getNextToken()

    t.compileSubroutineCall()

    eatSymbol(";")
 
end

--[[
    letStatement: 'let' varName ('[' expression ']')? '=' expression ';'
]]
function t.compileLet()
    local a, b  = getNextToken()
    local name = eatIdentifier()

    local objectIdx = nil
    local kind = nil
    if t.tm[name] then
        kind = t.tm[name].kind
        objectIdx = t.tm[name].idx
    end
    
    a, b  = peekNextToken()
    local isArr = false
    if b == "[" then
        eatSymbol("[")
        t.compileExpression()
        eatSymbol("]")
        isArr = true
    end

    eatSymbol("=")
    t.compileExpression()
    eatSymbol(";")

    if isArr then

    else
        popVar(name)
    end
end

--[[
    whileStatement: 'while' '(' expression ')' '{' statements '}'
]]
function t.compileWhile()
    local label1 = getFunctionLabel()
    local label2 = getFunctionLabel()
    local a, b  = getNextToken()
    
    w.writeLabel(label1)
    eatSymbol("(")
    t.compileExpression()
    eatSymbol(")")

    io.write("not\n")
    w.writeIfgoto(label2)
    
    eatSymbol("{")
    t.compileStatements()
    eatSymbol("}")

    w.writeGoto(label1)
    w.writeLabel(label2)
end

--[[
   ReturnStatement 'return' expression? ';' 
]]
function t.compileReturn()

    local a, b  = getNextToken()
 
    local hasReturn = false
    a, b  = peekNextToken()
    if b ~= ";" then
        t.compileExpression()
        hasReturn = true
    end

    eatSymbol(";")

    if not hasReturn then
        w.writePush("constant", "0")
    end
    w.writeReturn()
    
end

--[[
    ifStatement: 'if' '(' expression ')' '{' statements '}'
    ('else' '{' statements '}')?    

    if-goto 
]]
function t.compileIf()

    local a, b  = getNextToken()
    eatSymbol("(")
    t.compileExpression()
    eatSymbol(")")
    io.write("not\n")
    local label1 = getFunctionLabel()
    w.writeIfgoto(label1)

    eatSymbol("{")
    t.compileStatements()
    eatSymbol("}")

    a, b  = peekNextToken()
    if b == "else" then
        local label2 = getFunctionLabel()
        w.writeGoto(label2)
        w.writeLabel(label1)

        local a, b  = getNextToken()
        eatSymbol("{")
        t.compileStatements()
        eatSymbol("}")
        
        w.writeLabel(label2)
    else
        w.writeLabel(label1)
    end

end

--[[
    subroutineCall: subroutineName '(' expressionList ')' | (className |
varName) '.' subroutineName '(' expressionList ')'
]]
function t.compileSubroutineCall()

    local name1 = eatIdentifier()
    local name2 = nil
    local isMethodCall = false
    local type = nil
    local objectIdx = nil
    local kind = nil
    local functionName = nil

    if t.tc[name1] then
        type = t.tc[name1].type
        kind = t.tc[name1].kind
        objectIdx = t.tc[name1].idx
        isMethodCall = true
    end
    if t.tm[name1] then
        type = t.tm[name1].type
        kind = t.tm[name1].kind
        objectIdx = t.tm[name1].idx
        isMethodCall = true
    end
    
    local a, b = peekNextToken()
    if b == "." then
        eatSymbol(".")
        name2 = eatIdentifier()
    end

    local cnt = 0
    if name2 then
        if isMethodCall then
            functionName = type .. "." .. name2
            cnt = 1
            pushVar(name1)
        else
            functionName = name1 .. "." .. name2
        end
    else
        cnt = 1
        functionName = t.className .. "." .. name1
        w.writePush("pointer", 0)
    end

    eatSymbol("(")
    cnt = cnt + t.compileExpressionList()
    w.writeFunctionCall(functionName, cnt)
    eatSymbol(")")
end

local function isOp(str)
    
    local opt = {'+' , '-' , '*' , '/' , '&' , '|' , '<' , '>' , '='}

    for k, v in ipairs(opt) do
        if str == v then
            return true
        end
    end

    return false
end

-- expression: term (op term)*
function t.compileExpression()
 
    t.compileTerm()

    while true do
        local a, b = peekNextToken()
        if not isOp(b) then
            break
        end

        a, b = getNextToken()

        t.compileTerm()

        --Math.multiply() and Math.divide()
        if b == "*" then
            w.writeFunctionCall("Math.multiply", 2)
        elseif b == "/" then
            w.writeFunctionCall("Math.divide", 2)
        else
            w.writeOP(b)
        end
    end
end

local function isKeywordConstant(str)
    return str == "true" or str == "false" or str == "null" or str == "this"
end

local function pushString(str)
    w.writePush("constant", #str)
    w.writeFunctionCall("String.new", 1)
    w.writePop("temp", 1)
    for i=1, #str do
        w.writePush("temp", 1)
        local c = string.byte(str, i, i)
        w.writePush("constant", c)
        w.writeFunctionCall("String.appendChar", 2)
        w.writePop("temp", 0)
    end
    w.writePush("temp", 1)
end

--[[
    term: integerConstant | stringConstant | keywordConstant |
varName | varName '[' expression ']' | subroutineCall |
'(' expression ')' | unaryOp term
]]
function t.compileTerm()
 
    local a, b = peekNextToken()
    
    if a == "integerConstant" then
        a, b = getNextToken()
        w.writePush("constant", b)

    elseif a == "stringConstant" then
        a, b = getNextToken()
        pushString(b)
    elseif  isKeywordConstant(b)  then
        --'true' | 'false' | 'null' | 'this'
        a, b = getNextToken()
        
        if b == "true" then 
            w.writePush("constant", "1")
            io.write("neg\n")
        elseif b == "false" or b == "null" then
            w.writePush("constant", "0")
        elseif b == "this" then
            w.writePush("pointer", "0")
        end

    elseif b == "(" then
        eatSymbol("(")
        t.compileExpression()
        eatSymbol(")")
    elseif b == "-"  then
        a, b = getNextToken()
        t.compileTerm()
        io.write("neg\n")
        
    elseif b == "~" then
        a, b = getNextToken()
        t.compileTerm()

        io.write("not\n")
    else
        -- varName | varName '[' expression ']' | subroutineCall |
        a,b = peekNextNextToken()

        if b == "(" or  b == "." then
            t.compileSubroutineCall()
        elseif b == "[" then
            eatIdentifier()
            eatSymbol("[")
            t.compileExpression()
            eatSymbol("]")
        else
            -- varName
            local varname = eatIdentifier()
            pushVar(varname)
        end
    end
 
end

--[[
expressionList: (expression (',' expression)* )?    
]]
function t.compileExpressionList()
 
    local cnt = 0

    local a, b = peekNextToken()
    if b ~= ")" then
        t.compileExpression()
        cnt = cnt + 1

        while true do
            a,b = peekNextToken()
            if b ~= "," then break end

            eatSymbol(",")
            t.compileExpression()
            cnt = cnt + 1
        end
    end

    return cnt
end

return t