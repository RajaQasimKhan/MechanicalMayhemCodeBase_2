--[[
	
	Queue
	
	Lua implementation of a
	queue.

]]

local Queue = {}
local QueueClass = {}

--[[
	Create a new queue
]]
function Queue.new(initial: {any}?)
	local self = setmetatable({}, {
		__index = QueueClass,
		__tostring = function(t)
			return string.format('Queue(%d)', #t._raw)
		end,
	})
	
	self._raw = initial or {}
	
	return self
end

--[[
	Enqueue a value
]]
function QueueClass:enqueue(value: any)
	table.insert(self._raw, value)
end

--[[
	Dequeue a value
]]
function QueueClass:dequeue()
	return table.remove(self._raw, 1)
end

--[[
	Get the queue
]]
function QueueClass:get()
	return self._raw
end

return Queue