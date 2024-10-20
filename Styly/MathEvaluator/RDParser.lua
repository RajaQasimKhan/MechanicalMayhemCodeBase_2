--[[

    Parser (Recursive Descent)

    The parser will take a lexer and read its tokens. From
    these tokens it will generate an abstract syntax tree (AST).
    
    The original parser used a parse tree which relied on grammatical
    expressions. Generating an AST is significantly cheaper and
    the result is more dense.

    The tree can be passed to the interpreter to carry out logic.
    
    For unambiguous grammar use the Shunting Yard parser
    with its respective interpreter.

]]

local Parser = {}

local Token = require(script.Parent.Token)
local Node = require(script.Parent.Node)

local TERM_TOKENS = {
    Token.Type.ASTERIK,
    Token.Type.SLASH,
}

local EXPR_TOKENS = {
    Token.Type.PLUS,
    Token.Type.MINUS
}

local EXPO_TOKENS = {
	Token.Type.CARET
}

--[[
    Create a new parser
    instance
]]
function Parser.new(lexer)
    assert(lexer.tokens ~= nil and (#lexer.tokens ~= 0), 'Cannot parse an empty lexer')

    local self = setmetatable({}, {__index = Parser})

    self.lexer = lexer
    self.position = 0
    
    self:next()

    return self
end

--[[
    Parse tokens
]]
function Parser:parse()
    return self:expr()
end

--[[
    Raise a syntax error
]]
function Parser:error(msg, ...)
    error(string.format('Invalid syntax: ' .. msg, ...))
end

--[[
    Advance the parser to
    the next token
]]
function Parser:next()
    if (self.position == #self.lexer.tokens) then
        self.token = nil
        return
    end

    self.position += 1
    self.token = self.lexer.tokens[self.position]
end

--[[
	Peek to the next token
]]
function Parser:peek()
	if (self.position == #self.lexer.tokens) then
		error('Cannot peek!')
	end
	
	return self.lexer.tokens[self.position + 1]
end

function Parser:factor()
	local token = self.token

	if (token.type == Token.Type.NUMBER) then
        self:next()
        return Node.Number(token)
    elseif (token.type == Token.Type.LPAREN) then
        self:next()

        local result = self:expr()

        if (self.token == nil) then
            self:error('Expected right parentheses token')
        elseif (self.token.type ~= Token.Type.RPAREN) then
            self:error('Expected right parentheses token')
        end

        self:next()
        return result
    elseif (token.type == Token.Type.PLUS) then
        self:next()
        return Node.UnaryOperation(token, self:factor())
    elseif (token.type == Token.Type.MINUS) then
        self:next()
		return Node.UnaryOperation(token, self:factor())
	elseif (token.type == Token.Type.ID) then
		self:next()
		if (not self.token) then
			self:error('Incomplete identifier')
		end
		if (self.token.type == Token.Type.LBRACKET) then
			self:next()
			if (not self.token) then
				self:error('Incomplete identifier')
			end
			local expr = self:expr()
			if (self.token.type == Token.Type.RBRACKET) then
				return Node.Function(token, expr)
			else
				self:error('Expected ] to close function')
			end
		else
			self:error('Expected [ after function identifier')
		end
    end
end

function Parser:exponent()
	local node = self:factor()
	
	while (table.find(EXPO_TOKENS, self.token ~= nil and self.token.type or {})) do
		local token = self.token
		
		if (token.type == Token.Type.CARET) then
			self:next()
			-- EBNF suggests :factor() should be called not :exponent() ???
			-- might cause associativity problems should revise grammar in the future
			node = Node.BinaryOperation(token, node, self:exponent())
		end
	end
	
	return node
end

function Parser:term()
	local node = self:exponent()

    while (table.find(TERM_TOKENS, self.token ~= nil and self.token.type or {})) do
        local token = self.token

        if (token.type == Token.Type.ASTERIK or token.type == Token.Type.SLASH) then
            self:next()
			node = Node.BinaryOperation(token, node, self:exponent())
        end
    end

    return node
end

function Parser:expr()
	local node = self:term()

    while (table.find(EXPR_TOKENS, self.token ~= nil and self.token.type or {})) do
        local token = self.token

        self:next()

        node = Node.BinaryOperation(token, node, self:term())
    end

    return node
end


return Parser