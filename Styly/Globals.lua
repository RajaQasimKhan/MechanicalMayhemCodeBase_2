local module = {}

module.Globals = {}

function module.Add(name, val)
	module.Globals[name] = val
	return "0x00"
end

function module.Remove(name)
	module.Globals[name] = nil
	return "2x19"
end

return module
