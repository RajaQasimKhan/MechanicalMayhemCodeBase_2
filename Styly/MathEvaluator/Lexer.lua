--[[

    Lexer

    The lexer generates tokens based off the provided text.
    The lexer can then be passed to a parser to generate
    an abstract syntax tree from the tokens.

]]

local Lexer = {}

local Token = require(script.Parent.Token)
local Stack = require(script.Parent.Stack)

--[[
    Utility function for
    determining if a character
    is a whitespace
]]
local WHITESPACES = {'', ' ', '\n', '\t'}
local function isWhitespace(char)
    return table.find(WHITESPACES, char) and true or false
end

--[[
    Utility function for
    determining if a character
    is part of a function (e.g. sqrt[])
]]
local FUNCTIONS = {'[', ']'}
local function isFunction(char)
    return table.find(FUNCTIONS, char) and true or false
end

--[[
    Utility function for
    determining if a character
    is a digit
]]
local DIGITS = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
local function isDigit(char)
    char = tostring(char)
    return table.find(DIGITS, char) and true or false
end

--[[
    Utility function for
    determining if the
    current character is
    part of a number stream
]]
local function isNumberStream(char)
    return (char ~= nil and (char == '.' or isDigit(char)))
end

--[[
	Utility function for
	determining if the
	current character is
	alphanumeric
]]
local function isAlphaNum(char)
	return not string.match(char, '%W')
end

--[[
    Utility function for
    resolving an independent
    period in a number
]]
local function resolveIndependentDecimal(array: {string})
	if (array[1] == '.') then
		table.insert(array, 1, '0')
	end

	if (array[#array] == '.') then
		table.insert(array, '0')
	end

	return array
end

--[[
    Create a new lexer
    instance
]]
function Lexer.new(text)
    local self = setmetatable({}, {__index = Lexer})

    self.text = string.gsub(text, '\n', '')
    self.position = 0

    self:next()

    return self
end

--[[
    Advance the lexer to
    the next character
]]
function Lexer:next()
    if (self.position == string.len(self.text)) then
        self.character = nil
        return
    end

    self.position += 1
    self.character = string.sub(self.text, self.position, self.position)
end

--[[
    Raise a syntax error
]]
function Lexer:error(msg, ...)
	error(string.format('Invalid syntax:' .. msg, ...))
end

--[[
	Raise a syntax error
	with a custom stack trace
]]
function Lexer:errorTrace(char, pos, msg, ...)
	local whitespaces = {}
	for i = 1, pos - 1 do
		table.insert(whitespaces, ' ')
	end
	self:error('\n\tUnexpected character "%s" at col %d\n\t\t%sv\n\t\t%s\n%s',
		char, pos, table.concat(whitespaces), self.text, msg and string.format(msg, ...) or '')
end

--[[
    Peek to the next
    character
]]
function Lexer:peek()
    return string.sub(self.text, self.position + 1, self.position + 1)
end

--[[
    Tokenize the
    provided text
]]
function Lexer:tokenize()
    local tokens = {}

    while (self.character ~= nil) do
        local result = self:resolve(self.character)
        if (result) then
            table.insert(tokens, result)
        end
    end

	self.tokens = tokens

    return self
end

--[[
    Resolve a
    provided character
]]
function Lexer:resolve(char)
    if (isWhitespace(char)) then
        self:next()
    elseif (char == '.' or isDigit(char)) then
        return self:resolveNumber()
    elseif (char == '+') then
        self:next()
        return Token.new(Token.Type.PLUS)
    elseif (char == '-') then
        self:next()
        return Token.new(Token.Type.MINUS)
    elseif (char == '*') then
        self:next()
        return Token.new(Token.Type.ASTERIK)
    elseif (char == '/') then
        self:next()
        return Token.new(Token.Type.SLASH)
    elseif (char == '^') then
        self:next()
        return Token.new(Token.Type.CARET)
    elseif (char == '(') then
        self:next()
        return Token.new(Token.Type.LPAREN)
    elseif (char == ')') then
        self:next()
		return Token.new(Token.Type.RPAREN)
	elseif (isAlphaNum(char)) then
		local ident = self:resolveIdentifier()
		if (not ident) then
			self:errorTrace(char, self.position)
		end
		return ident
	elseif (char == '[') then
		self:next()
		return Token.new(Token.Type.LBRACKET)
	elseif (char == ']') then
		self:next()
		return Token.new(Token.Type.RBRACKET)
	else
		self:errorTrace(char, self.position)
    end
end

--[[
    Resolve a
    number
]]
function Lexer:resolveNumber()
	local array = { self.character }
    local decimals = 0

    self:next()
    
    while (isNumberStream(self.character)) do
        if (self.character == '.') then
            decimals += 1
            if (decimals > 1) then
                break
            end
        end

		table.insert(array, self.character)
        self:next()
    end

    if (decimals > 0) then
		array = resolveIndependentDecimal(array)
	end

	return Token.new(Token.Type.NUMBER, tonumber(table.concat(array)))
end

--[[
	Resolve an identifier
]]
function Lexer:resolveIdentifier()
	local stack = Stack.new()
	
	local initialPos, initialChar = self.position, self.character
	while (self.character ~= nil and isAlphaNum(self.character)) do
		stack:push(self.character)
		self:next()
	end
	
	local result = table.concat(stack:get())
	
	if (not Token.Value[string.upper(result)]) then
		self:errorTrace(initialChar, initialPos, '\tUnrecognized identifier')
	end
	
	return Token.new(Token.Type.ID, Token.Value[string.upper(result)])
end

return Lexer