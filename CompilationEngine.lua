local t = {}

local w = function(str)
    io.write(str .. "\n")
end

local function getPrefix(lv)
    lv = lv or 0
    local prefix = ""
    while lv > 0 do
        prefix = prefix .. "  "
        lv = lv - 1
    end
    return prefix
end

local wn = function(a, v, lv)

    v = string.gsub(v, "&", "&amp;")
    v = string.gsub(v, "<", "&lt;")
    v = string.gsub(v, ">", "&gt;")
    v = string.gsub(v, "\"", "&quot;")

    io.write(string.format("%s<%s> %s </%s>\n", getPrefix(lv), a, v, a))
end

local ws = function(a, lv)
    io.write(string.format("%s<%s>\n", getPrefix(lv), a))
end

local we = function(a, lv)
    io.write(string.format("%s</%s>\n", getPrefix(lv), a))
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

local function eatIdentifier(lv)
    local a, b = getNextToken()
    assert(a == "identifier")
    wn(a, b, lv)
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

function t.init(tks)
    t.tokens = tks
    t.idx = 1
end


--class: 'class' className '{' classVarDec* subroutineDec* '}'
function t.compileClass()
    ws("class")
    local lv = 1

    local a, b  = getNextToken()
    assert(b == "class")
    wn(a, b, lv)

    eatIdentifier(lv)

    eatSymbol("{", lv)

    while t.compileClassVarDec(lv) do end

    while t.compileSubroutine(lv) do end

    eatSymbol("}", lv)

    we("class")
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

    --type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
    wn(a, b, lv)

    eatIdentifier(lv)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end

        eatSymbol(",", lv)

        eatIdentifier(lv)
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
function t.compileSubroutine(lv)
    local a, b  = peekNextToken()
    if b ~= "constructor" and b ~= "function" and b ~= "method" then return false end

    ws("subroutineDec", lv)
    lv = lv + 1

    a, b  = getNextToken()
    wn(a, b, lv)

    --void | type: 'int' | 'char' | 'boolean' | className
    a, b = getNextToken()
    assert(b == "void" or b == "int" or b == "char" or b == "boolean" or a == "identifier")
    wn(a, b, lv)

    
    eatIdentifier(lv)
    
    eatSymbol("(", lv)
    
    t.compileParameterList(lv)
    
    eatSymbol(")", lv)
    
    t.compileSubroutineBody(lv)
 
    lv = lv - 1
    we("subroutineDec", lv)
    return true
end

-- subroutineBody: '{' varDec* statements '}'
function t.compileSubroutineBody(lv)
    ws("subroutineBody", lv)
    lv = lv + 1

    eatSymbol("{", lv)
    
    while t.compileVarDec(lv) do end

    t.compileStatements(lv)

    eatSymbol("}", lv)

    lv = lv - 1
    we("subroutineBody", lv)
end

-- parameterList: ((type varName) (',' type varName)*)?
function t.compileParameterList(lv)
    ws("parameterList", lv)
    lv = lv + 1
 
    local a, b  = peekNextToken()
    if b == "int" or b == "char" or b == "boolean" or a == "identifier" then
        a, b  = getNextToken()
        wn(a, b, lv)

        eatIdentifier(lv)

        while true do
            a, b = peekNextToken()
            if b ~= "," then break end
            eatSymbol(",", lv)
    
            a, b  = getNextToken()
            assert(b == "int" or b == "char" or b == "boolean" or a == "identifier")
            wn(a, b, lv)

            eatIdentifier(lv)
        end
    end
 
    lv = lv - 1
    we("parameterList", lv)
end

-- varDec: 'var' type varName (',' varName)* ';'
function t.compileVarDec(lv)
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

    eatIdentifier(lv)

    while true do
        a, b = peekNextToken()
        if b ~= "," then break end
        eatSymbol(",", lv)
        
        eatIdentifier(lv)
    end 

    eatSymbol(";", lv)
    
    lv = lv - 1
    we("varDec", lv)
    return true
end

-- statements: statement*
function t.compileStatements(lv)
    ws("statements", lv)
    lv = lv + 1

    while t.compileStatement(lv) do end
 
    lv = lv - 1
    we("statements", lv)
end

--[[
    statement: letStatement | ifStatement | whileStatement |
    doStatement | returnStatement
]] 
function t.compileStatement(lv)
    local a, b  = peekNextToken()
    if b == "let" then
        t.compileLet(lv)
    elseif b == "do" then
        t.compileDo(lv)
    elseif b == "if" then
        t.compileIf(lv)
    elseif b == "while" then
        t.compileWhile(lv)
    elseif b == "return" then
        t.compileReturn(lv)
    else
        return false
    end

    return true
end

--[[
    doStatement: 'do' subroutineCall ';'
]]
function t.compileDo(lv)
    ws("doStatement", lv)
    lv = lv + 1

    local a, b  = getNextToken()
    wn(a, b, lv)

    t.compileSubroutineCall(lv)

    eatSymbol(";", lv)
 
    lv = lv - 1
    we("doStatement", lv)
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
function t.compileReturn(lv)
    ws("returnStatement", lv)
    lv = lv + 1

    local a, b  = getNextToken()
    wn(a, b, lv)
 
    local a, b  = peekNextToken()
    if b ~= ";" then
        t.compileExpression(lv)
    end

    eatSymbol(";", lv)
 
    lv = lv - 1
    we("returnStatement", lv)
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
function t.compileSubroutineCall(lv)
    --ws("subroutineCall", lv)
    lv = lv + 1

    eatIdentifier(lv)
    
    local a, b = peekNextToken()
    if b == "." then
        eatSymbol(".", lv)
        eatIdentifier(lv)
    end

    eatSymbol("(", lv)

    t.compileExpressionList(lv)

    eatSymbol(")", lv)

    lv = lv - 1
    --we("subroutineCall", lv)
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
function t.compileExpression(lv)
    ws("expression", lv)
    lv = lv + 1

    t.compileTerm(lv)

    while true do
        local a, b = peekNextToken()
        if not isOp(b) then
            break
        end

        a, b = getNextToken()
        wn(a, b, lv)

        t.compileTerm(lv)
    end

    lv = lv - 1
    we("expression", lv)
end

local function isKeywordConstant(str)
    return str == "true" or str == "false" or str == "null" or str == "this"
end

--[[
    term: integerConstant | stringConstant | keywordConstant |
varName | varName '[' expression ']' | subroutineCall |
'(' expression ')' | unaryOp term
]]
function t.compileTerm(lv)
    ws("term", lv)
    lv = lv + 1

    local a, b = peekNextToken()
    
    if a == "integerConstant" or a == "stringConstant" or isKeywordConstant(b) then
        a, b = getNextToken()
        wn(a, b, lv)
    elseif b == "(" then
        eatSymbol("(", lv)
        t.compileExpression(lv)
        eatSymbol(")")
    elseif b == "-" or b == "~" then
        a, b = getNextToken()
        wn(a, b, lv)

        t.compileTerm(lv)
    else
        -- varName | varName '[' expression ']' | subroutineCall |
        a,b = peekNextNextToken()

        if b == "(" or  b == "." then
            t.compileSubroutineCall(lv)
        elseif b == "[" then
            eatIdentifier(lv)
            eatSymbol("[", lv)
            t.compileExpression(lv)
            eatSymbol("]", lv)
        else
            eatIdentifier(lv)
        end
    end

    lv = lv - 1
    we("term", lv)
end

--[[
expressionList: (expression (',' expression)* )?    
]]
function t.compileExpressionList(lv)
    ws("expressionList", lv)
    lv = lv + 1

    local a, b = peekNextToken()
    if b ~= ")" then
        t.compileExpression(lv)

        while true do
            a,b = peekNextToken()
            if b ~= "," then break end

            eatSymbol(",", lv)
            t.compileExpression(lv)
        end
    end

    lv = lv - 1
    we("expressionList", lv)    
end

return t