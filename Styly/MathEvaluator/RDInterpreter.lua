--[[

    Interpreter (Recursive Descent)

    The interpreter will take a tree created
    by the parser and carry out the expected
    logic.

]]

local Interpreter = {}

local Token = require(script.Parent.Token)

--[[
    Visit a node and apply logic
    based on its token

    Python uses this same approach
    for its AST
]]
function Interpreter:visit(node)
    local methodName = 'visit' .. node.name
    if (self[methodName] ~= nil) then
        return self[methodName](self, node)
    else
        error(string.format('Intepreter unable to interpret %s node', node.name))
    end
end

--[[
    Visit a number node
]]
function Interpreter:visitNumber(node)
    return node.value
end

--[[
    Visit a unary operation node
]]
function Interpreter:visitUnaryOperation(node)
    if (node.token.type == Token.Type.PLUS) then
        return self:visit(node.node)
    elseif (node.token.type == Token.Type.MINUS) then
        return -self:visit(node.node)
    end
end

--[[
    Visit a binary operation node
]]
function Interpreter:visitBinaryOperation(node)
    if (node.token.type == Token.Type.PLUS) then
        return self:visit(node.nodes[1]) + self:visit(node.nodes[2])
    elseif (node.token.type == Token.Type.MINUS) then
        return self:visit(node.nodes[1]) - self:visit(node.nodes[2])
    elseif (node.token.type == Token.Type.ASTERIK) then
        return self:visit(node.nodes[1]) * self:visit(node.nodes[2])
    elseif (node.token.type == Token.Type.SLASH) then
        return self:visit(node.nodes[1]) / self:visit(node.nodes[2])
    elseif (node.token.type == Token.Type.CARET) then
        return math.pow(self:visit(node.nodes[1]), self:visit(node.nodes[2]))
    end
end

--[[
	Visit a no operation node
]]
function Interpreter:visitNoOperation(node)
	return self:visit(node)
end

--[[
	Visit a function node
]]
function Interpreter:visitFunction(node)
	if (node.token.value == Token.Value.SQRT) then
		return math.sqrt(self:visit(node.param))
	elseif (node.token.value == Token.Value.SIN) then
		return math.sin(self:visit(node.param))
	elseif (node.token.value == Token.Value.COS) then
		return math.cos(self:visit(node.param))
	elseif (node.token.value == Token.Value.TAN) then
		return math.tan(self:visit(node.param))
	elseif (node.token.value == Token.Value.ASIN) then
		return math.asin(self:visit(node.param))
	elseif (node.token.value == Token.Value.ACOS) then
		return math.acos(self:visit(node.param))
	elseif (node.token.value == Token.Value.ATAN) then
		return math.atan(self:visit(node.param))
	elseif (node.token.value == Token.Value.ABS) then
		return math.abs(self:visit(node.param))
	else
		error('Unknown function ' .. node.token.value)
	end
end

return Interpreter