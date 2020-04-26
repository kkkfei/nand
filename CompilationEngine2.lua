local w = require("vmwriter")
local t = {}

local function getPrefix(lv)
    return ""
end

local wn = function(a, v, lv)
end

local ws = function(a, lv)
end

local we = function(a, lv)
end

 

local function getNextToken()
    assert(t.idx+1 <= #(t.tokens))
    local a = t.tokens[t.idx]
    local b = t.tokens[t.idx+1]
    t.idx = t.idx + 2
    return a, b
end

local function eatSymbol(symbol, lv)
    local a, b = getNextToken()
    assert(b == symbol)
    wn(a, b, lv)
end

local function eatIdentifier()
    local a, b = getNextToken()
    assert(a == "identifier")
    return b
end

function peekNextToken()
    assert(t.idx+1 <= #(t.tokens))
    local a = t.tokens[t.idx]
    local b = t.tokens[t.idx+1]
    return a, b
end

function peekNextNextToken()
    assert(t.idx+3 <= #(t.tokens))
    local a = t.tokens[t.idx+2]
    local b = t.tokens[t.idx+3]
    return a, b
end

local st_class = {}
local st_method = {}


function t.init(tks)
    t.tokens = tks
    t.idx = 1

    t.tc = {}
    t.tm = {}
end


--class: 'class' className '{' classVarDec* subroutineDec* '}'
function t.compileClass()
    ws("class")
    local lv = 1

    local a, b  = getNextToken()
    assert(b == "class")
    wn(a, b, lv)

    t.className = eatIdentifier(lv)

    eatSymbol("{", lv)

    while t.compileClassVarDec(lv) do end

    while t.compileSubroutine(lv) do end

    eatSymbol("}", lv)

    we("class")
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
function t.compileClassVarDec(lv)
    local a, b  = peekNextToken()
    if b ~= "static" and b ~= "field" then return false end

    ws("classVarDec", lv)
    lv = lv + 1

    a, b  = getNextToken()
    assert(b == "static" or b == "field")
    wn(a, b, lv)
local kind = b

    --type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
    wn(a, b, lv)
local type = b

local name = eatIdentifier(lv)
addTc(name, kind, type)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end

        eatSymbol(",", lv)
name = eatIdentifier(lv)
addTc(name, kind, type)
        end

        eatSymbol(";", lv)
    
        lv = lv - 1
        we("classVarDec", lv)

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
    if b ~= "constructor" and b ~= "function" and b ~= "method" then return false end


    a, b  = getNextToken()

    --void | type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "void" or b == "int" or b == "char" or b == "boolean" or a == "identifier")
    
    local name = eatIdentifier()
    t.functionName = string.format("%s.%s", t.className, name)
    
    eatSymbol("(")
    
    t.compileParameterList(lv)
    
    eatSymbol(")", lv)
    
    t.compileSubroutineBody(lv)

    return true
end

-- subroutineBody: '{' varDec* statements '}'
function t.compileSubroutineBody(lv)
    eatSymbol("{")
    
    while t.compileVarDec() do end
    w.writeFunctionHead(t.functionName, t.varCnt)

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
function t.compileVarDec(lv)
local kind = "var"

    local a, b  = peekNextToken()
    if  b ~= "var" then return false end

    ws("varDec", lv)
    lv = lv + 1

    a, b = getNextToken()
    wn(a, b, lv)

     -- type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
    wn(a, b, lv)
local type = b

local name = eatIdentifier(lv)

addTm(name, kind, type)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end
        eatSymbol(",", lv)
        
name = eatIdentifier(lv)
addTm(name, kind, type)
    end 

    eatSymbol(";", lv)
    
    lv = lv - 1
    we("varDec", lv)
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
function t.compileDo(lv)

    local a, b  = getNextToken()

    t.compileSubroutineCall()

    eatSymbol(";")
 
end

--[[
    letStatement: 'let' varName ('[' expression ']')? '=' expression ';'
]]
function t.compileLet(lv)
    ws("letStatement", lv)
    lv = lv + 1

    local a, b  = getNextToken()
    wn(a, b, lv)

    eatIdentifier(lv)

    local a, b  = peekNextToken()
    if b == "[" then
        eatSymbol("[", lv)
        t.compileExpression(lv)
        eatSymbol("]", lv)
    end

    eatSymbol("=", lv)

    t.compileExpression(lv)

    eatSymbol(";", lv)
 
    lv = lv - 1
    we("letStatement", lv)
end

--[[
    whileStatement: 'while' '(' expression ')' '{' statements '}'
]]
function t.compileWhile(lv)
    ws("whileStatement", lv)
    lv = lv + 1

    local a, b  = getNextToken()
    wn(a, b, lv)
 
    eatSymbol("(", lv)

    t.compileExpression(lv)

    eatSymbol(")", lv)

    eatSymbol("{", lv)

    t.compileStatements(lv)

    eatSymbol("}", lv)
 
    lv = lv - 1
    we("whileStatement", lv)
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
]]
function t.compileIf(lv)
    ws("ifStatement", lv)
    lv = lv + 1

    local a, b  = getNextToken()
    wn(a, b, lv)

    eatSymbol("(", lv)

    t.compileExpression(lv)

    eatSymbol(")", lv)

    eatSymbol("{", lv)
    
    t.compileStatements(lv)

    eatSymbol("}", lv)

    a, b  = peekNextToken()
    if b == "else" then
        local a, b  = getNextToken()
        wn(a, b, lv)

        eatSymbol("{", lv)
    
        t.compileStatements(lv)
    
        eatSymbol("}", lv)
    end

    lv = lv - 1
    we("ifStatement", lv)
end

--[[
    subroutineCall: subroutineName '(' expressionList ')' | (className |
varName) '.' subroutineName '(' expressionList ')'
]]
function t.compileSubroutineCall()

    local name1 = eatIdentifier()
    local name2 = nil
    local isMethodCall = false
    local className = nil
    local objectIdx = nil
    local kind = nil
    local functionName = nil
    if t.tc[name] then
        className = t.tc[name].type
        kind = t.tc[name].kind
        objectIdx = t.tc[name].idx
        isMethodCall = true
    end
    if t.tm[name] then
        className = t.tm[name].type
        kind = t.tm[name].kind
        objectIdx = t.tm[name].idx
        isMethodCall = true
    end
    
    local a, b = peekNextToken()
    if b == "." then
        eatSymbol(".")
        name2 = eatIdentifier()
    end

    if name2 then
        if isMethodCall then
            functionName = className .. "." .. name2
        else
            functionName = name1 .. "." .. name2
        end
    else
        functionName = name1
    end

    eatSymbol("(")

    local cnt = t.compileExpressionList()
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
    elseif  isKeywordConstant(b)  then
        --'true' | 'false' | 'null' | 'this'
        a, b = getNextToken()

    elseif b == "(" then
        eatSymbol("(")
        t.compileExpression()
        eatSymbol(")")
    elseif b == "-" or b == "~" then
        a, b = getNextToken()

        t.compileTerm()
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
            eatIdentifier()
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