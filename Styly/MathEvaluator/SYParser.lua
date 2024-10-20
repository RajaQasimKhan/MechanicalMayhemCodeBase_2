--[[

    Parser (Shunting Yard Algorithm)
    
    This parser uses the Shuting Yard algorithm to parse
    expressions in infix by convering it to postfix
    notation then evaluating.
    
    Postfix notation is essentially an AST as a string
    rather than a tree of nodes.
    
	One advantage includes unambiguous associativity
	as well as interpretation being far cheaper. SY is
	best for mathematical expressions and is therefore
	the preferred parser for this module.
	
	For an example of how this algorithm works
	view the bottom of this script.

]]

local Parser = {}

local Token = require(script.Parent.Token)
local Stack = require(script.Parent.Stack)
local Queue = require(script.Parent.Queue)

-- Precedence table for different operators
local PRECEDENCE = {
	[Token.Type.MINUS] = 0,
	[Token.Type.PLUS] = 0,
	[Token.Type.ASTERIK] = 1,
	[Token.Type.SLASH] = 1,
	[Token.Type.UMINUS] = 2,
	[Token.Type.CARET] = 3,
	[Token.Type.ID] = 4,
}

-- Associativity table for different operators
-- 0 = LTR (Left To Right)
-- 1 = RTL (Right To Left)
local ASSOCIATIVITY = {
	[Token.Type.MINUS] = 0,
	[Token.Type.PLUS] = 0,
	[Token.Type.ASTERIK] = 0,
	[Token.Type.SLASH] = 0,
	[Token.Type.CARET] = 1,
	[Token.Type.UMINUS] = 1,
	[Token.Type.ID] = 0,
}

-- Valid operators
local OPERATORS = {
	Token.Type.PLUS,
	Token.Type.MINUS,
	Token.Type.ASTERIK,
	Token.Type.SLASH,
	Token.Type.CARET,
	Token.Type.UMINUS,
	Token.Type.ID,
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
	self.queue = Queue.new()
	self.stack = Stack.new()

	return self
end

--[[
	Utility function
	for checking if a
	token is an operator
]]
local function isOperator(token)
	return table.find(OPERATORS, token.type) and true or false
end

--[[
	Utility function
	for getting precedence
]]
local SOFT_OPERATORS = {Token.Type.LBRACKET, Token.Type.LPAREN}
local function getPrecedence(operator)
	local isSoftOp = table.find(SOFT_OPERATORS, operator.type) and true or false
	
	if (not isOperator(operator) and not isSoftOp) then
		return -1
	end
	
	if (PRECEDENCE[operator.type] and not isSoftOp) then
		return PRECEDENCE[operator.type]
	elseif (isSoftOp) then
		return 10
	else
		return -1
	end
end

--[[
	Preprocess tokens
]]
function Parser:preprocess()
	local initialTokens = self.lexer.tokens
	for index, token in pairs(initialTokens) do
		if (token.type == Token.Type.MINUS and (index == 1 or getPrecedence(self.lexer.tokens[index - 1]) >= 0)) then
			self.lexer.tokens[index] = Token.new(Token.Type.UMINUS)
		end 
	end
	
	self:next()
end

--[[
    Raise a syntax error
]]
function Parser:error(msg, ...)
	error(string.format('Invalid syntax: ' .. msg, ...))
end

--[[
    Parse tokens
]]
function Parser:parse()
	self:preprocess()
	
	while (self.token) do
		local token = self.token
		
		if (token.type == Token.Type.NUMBER) then
			self.queue:enqueue(tonumber(token.value))
		elseif (isOperator(token)) then
			while (not self.stack:isEmpty()
				and ASSOCIATIVITY[token.type]
				and PRECEDENCE[token.type]
				and ASSOCIATIVITY[self.stack:top().type]
				and PRECEDENCE[self.stack:top().type]
				and ((ASSOCIATIVITY[token.type] == 0 and PRECEDENCE[token.type] <= PRECEDENCE[self.stack:top().type])
					or (ASSOCIATIVITY[token.type] == 1 and PRECEDENCE[token.type] < PRECEDENCE[self.stack:top().type]))) do
				self.queue:enqueue(self.stack:pop())
			end
			self.stack:push(token)
		elseif (token.type == Token.Type.LPAREN) then
			self.stack:push(token)
		elseif (token.type == Token.Type.RPAREN) then
			if (not self.stack:isEmpty()) then
				while (self.stack:top().type ~= Token.Type.LPAREN) do
					self.queue:enqueue(self.stack:pop())
				end
				self.stack:pop()
			else
				self:error('Expected opening parentheses to closing parentheses on token %d', self.position)
				
			end
		elseif (token.type == Token.Type.LBRACKET) then
			if (not self.stack:isEmpty() and self.stack:top().type == Token.Type.ID) then
				self.stack:push(token)
			else
				self:error('Expected identifier before token "["')
			end
		elseif (token.type == Token.Type.RBRACKET) then
			while (not self.stack:isEmpty() and self.stack:top().type ~= Token.Type.LBRACKET) do
				self.queue:enqueue(self.stack:pop())
			end
			self.stack:pop()
		end
		self:next()
	end
	while (not self.stack:isEmpty()) do
		self.queue:enqueue(self.stack:pop())
	end
	
	print(self.queue._raw)
	
	return self.queue
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
		self:error('Unable to peek further')
	end

	return self.lexer.tokens[self.position + 1]
end

return Parser

--[[

	EXAMPLE #1

	Infix: 3 * 2 ^ 4

	Apply Shunting Algorithm:
	
	TOKEN		ACTION				QUEUE				STACK
	----------------------------------------------------------------------
	3			| Enqueue			| [3]				| []
	*			| Push to stack		| [3]				| [*]
	2			| Enqueue			| [3,2]				| [*]
	^			| Push to stack		| [3,2]				| [*,^]
	4			| Enqueue			| [3,2,4]			| [*,^]
	
	Postfix: 3 2 4 ^ *
	Evaluate:
		1) 3 16 *
		2) 48
	Result: 48

]]

--[[

	EXAMPLE #2
	
	Infix: 2 ^ 2 ^ 3
	
	Apply Shunting Algorithm:
	
	TOKEN		ACTION				QUEUE				STACK
	----------------------------------------------------------------------
	2			| Enqueue			| [2]				| []
	^			| Push to stack		| [2]				| [^]
	2			| Enqueue			| [2,2]				| [^]
	^			| Push to stack		| [2,2]				| [^,^]
	3			| Enqueue			| [2,2,3]			| [^,^]
	
	Postfix: 2 2 3 ^ ^
	Evaluate:
		1) 2 8 ^
		2) 256
	Result: 256
	
]]