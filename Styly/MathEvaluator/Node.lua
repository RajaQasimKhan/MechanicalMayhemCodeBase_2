--[[

    Node

    Responsible for the managing
    of tokens and how their
    logic should be executed.

]]

local Node = {}

--[[
    Create a new number node
]]
function Node.Number(token)
    local self = setmetatable({}, {
        __tostring = function(t)
            return string.format('NODE<NUMBER>(%s)',tostring(t.value))
        end
    })

    self.name = 'Number'
    self.value = token.value

    return self
end

--[[
    Create a new unary operation node
]]
function Node.UnaryOperation(token, node)
    local self = setmetatable({}, {
        __tostring = function(t)
            return string.format('NODE<UNARYOP:%s>(%s)', tostring(t.token), tostring(t.node))
        end
    })

    self.name = 'UnaryOperation'
    self.token = token
    self.node = node

    return self
end

--[[
    Create a new binary operation node
]]
function Node.BinaryOperation(token, leftNode, rightNode)
    local self = setmetatable({}, {
        __tostring = function(t)
            return string.format('NODE<BINARYOP:%s>(%s,%s)', tostring(t.token), tostring(t.nodes[1]), tostring(t.nodes[2]))
        end
    })

    self.name = 'BinaryOperation'
    self.token = token
    self.nodes = {
        leftNode,
        rightNode
    }

    return self
end

--[[
	Create an empty operation node
]]
function Node.NoOperation()
	local self = setmetatable({}, {
		__tostring = function(t)
			return 'NODE<NOOP>'
		end
	})

	self.name = 'NoOperation'

	return self
end

--[[
	Create a function node
]]
function Node.Function(token, param)
	local self = setmetatable({}, {
		__tostring = function(t)
			return 'NODE<FUNC>'
		end
	})

	self.name = 'Function'
	self.token = token
	self.param = param

	return self
end

return Node