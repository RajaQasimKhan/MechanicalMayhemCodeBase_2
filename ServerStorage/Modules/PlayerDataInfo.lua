local PLAYER_DATA = {}

PLAYER_DATA.SETTINGS_VALUES = {
	--[[
	["Template"] = {
		["VALUE_TYPE"] = "BoolValue",
		["DEFAULT"] = true,
	},
	]]
	["MinesActive"] = {
		["VALUE_TYPE"] = "BoolValue",
		["DEFAULT"] = true,
	},
}

PLAYER_DATA.SIMPLE_VALS = {
	--[[
	["Template"] = {
		["VALUE_TYPE"] = "NumberValue",
		["DEFAULT"] = 500,
	},
	]]
	["Rebirth"] = {
		["VALUE_TYPE"] = "NumberValue",
		["DEFAULT"] = 0,
	},
	["InvSort"] = {
		["VALUE_TYPE"] = "StringValue",
		["DEFAULT"] = "Newest",
	},
	["Citrine"] = {
		["VALUE_TYPE"] = "NumberValue",
		["DEFAULT"] = 0,
	},
	["KnowledgePoints"] = {
		["VALUE_TYPE"] = "NumberValue",
		["DEFAULT"] = 0,
	},
}

PLAYER_DATA.INVENTORY_TYPES = {
	"Items",
}

return PLAYER_DATA
