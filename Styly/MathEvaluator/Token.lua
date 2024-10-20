--[[

    Token

    Responsible for handling
    tokens that are built of certain
    characters or strings of text.

]]

local Token = {}

local Symbol = require(script.Parent.Symbol)

Token.Type = {
    NUMBER      = Symbol.new('NUMBER'),
    PLUS        = Symbol.new('PLUS'),
    MINUS       = Symbol.new('MINUS'),
    ASTERIK     = Symbol.new('ASTERIK'),
    SLASH       = Symbol.new('SLASH'),
    CARET       = Symbol.new('CARET'),
    LPAREN      = Symbol.new('LPAREN'),
    RPAREN      = Symbol.new('RPAREN'),
	LBRACKET	= Symbol.new('LBRACKET'),
	RBRACKET	= Symbol.new('RBRACKET'),
	ID			= Symbol.new('ID'),
	UMINUS		= Symbol.new('UMINUS'),		-- Unique to SY
}

Token.Value = {
	UNDEFINED	= Symbol.new('UNDEFINED'),
	SQRT		= Symbol.new('SQRT'),
	SIN			= Symbol.new('SIN'),
	COS			= Symbol.new('COS'),
	TAN			= Symbol.new('TAN'),
	ASIN		= Symbol.new('ASIN'),
	ACOS		= Symbol.new('ACOS'),
	ATAN		= Symbol.new('ATAN'),
	ABS			= Symbol.new('ABS')
}

--[[
    Create a new token with
    the provided type and value
]]
function Token.new(tokenType, tokenValue)
    local self = setmetatable({}, {
        __tostring = function(t)
            return string.format('%s(%s)', t.type.name, type(t.value) == 'userdata' and t.value.name or t.value)
        end
    })

    self.type = tokenType
    self.value = tokenValue or Token.Value.UNDEFINED

    return self
end

return Token