--[[
	
	Stack
	
	Lua implementation of a
	stack.

]]

local Stack = {}
local StackClass = {}

--[[
	Create a new stack
]]
function Stack.new(initial: {any}?)
	local self = setmetatable({}, {
		__index = StackClass,
		__tostring = function(t)
			return string.format('Stack(%d)', #t._raw)
		end,
	})
	
	self._raw = initial or {}
	
	return self
end

--[[
	Push a value onto the stack
]]
function StackClass:push(value: any)
	table.insert(self._raw, value)
end

--[[
	Pop a value from the stack
]]
function StackClass:pop()
	return table.remove(self._raw)
end

--[[
	Get the stack
]]
function StackClass:get()
	return self._raw
end

--[[
	Get the top of the stack
]]
function StackClass:top()
	return self._raw[#self._raw]
end

--[[
	Check if a stack is empty
]]
function StackClass:isEmpty()
	return #self._raw == 0
end

return Stack