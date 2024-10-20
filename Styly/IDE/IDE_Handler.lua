local module = {}

module.Scripts = {}

function module.ValidateString(str:string)
	--ALLOWED CHARS: Aplphabet, Numeric, Underscores
	local AllowedChars = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_"}
	for i = 1, str:len() do
		local sub = str:sub(i, i)
		if table.find(AllowedChars, sub) then
			continue
		else
			return false
		end
	end
	return true
end

function module.ScriptObj()
	local obj = {}
	obj["Content"] = ""
	obj["ExecStart"] = 1
	obj["ExecRate"] = 10
	return obj
end

function module.CreateScript(name:string)
	if module.Scripts[name] then
		return {false, "Script Already Exists"}
	end
	if typeof(name) ~= "string" then
		return {false, "Invalid Name"}
	end
	if not module.ValidateString(name) then
		return {false, "Name can only contain characters: 'A' to 'Z', 'a' to 'z', '0' to '9', and '_'"}
	end
end

return module
