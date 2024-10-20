local Outputs = require(script.Parent["I/O_Control"])

local module = {}

module.ErrorIndex = {
	["9999x15"] = "Pin/Port not compatible with command",
	
	["4x90"] = "Parameter must be an integer NUMBER",
	
	["4x89"] = "Parameter(s) missing / mismatched",
	
	["4x88"] = "Unable to calculate",
	
	["4x87"] = "No label found",
	
	["3x32"] = "Unknown operator",
	
	["2x21"] = "Invalid command",
	
	["2x20"] = "Invalid syntax",
	
	["2x19"] = "Unknown identifier",
	
	["2x18"] = "Unknown method",
	
	["1x42"] = "Unable to process Non-Numeric string",
	
	["1x41"] = "Unable to process item(s)",
	
	["1x40"] = "Invalid parameter(s) type",
	
	["1x39"] = "String must be of length 1 or more",
	
	["1x38"] = "Out of bounds exception",
	
	["1x37"] = "Parameter(s) must be greater than or equal to 1",
	
	["1x36"] = "Unable to process Non-Boolean string",
	
	["1x35"] = "Parameter(s) must be in range 0-255 (inclusive)",
	
	["1x34"] = "Index not present in table",
	
	["0x00"] = "Unkown Error, Report:"
}

function module.CreateError(code, line)
	local err = code
	if module.ErrorIndex[code] then
		err = module.ErrorIndex[code]
	end
	Outputs.MakeLineStatus(err, line, true, Color3.fromRGB(170, 0, 0))
end

function module.CreateBlank()
	Outputs.MakeBlankLineStatus()
end

return module
