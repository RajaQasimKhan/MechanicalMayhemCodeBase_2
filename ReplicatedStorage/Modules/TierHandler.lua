-- Item Handling
local module = {}

module.ITEM_TIERS = {
	["Regular"] = {
		["TIER_ID"] = 1,
		["TIER_COLOR"] = Color3.fromRGB(88, 99, 107),
	},
	["Irregular"] = {
		["TIER_ID"] = 2,
		["TIER_COLOR"] = Color3.fromRGB(154, 141, 91),
	},
	["Rare"] = {
		["TIER_ID"] = 3,
		["TIER_COLOR"] = Color3.fromRGB(107, 154, 103),
	},
	["Distinctive"] = {
		["TIER_ID"] = 4,
		["TIER_COLOR"] = Color3.fromRGB(62, 111, 108),
	},
	["Epic"] = {
		["TIER_ID"] = 5,
		["TIER_COLOR"] = Color3.fromRGB(77, 153, 103),
	},
	["Legendary"] = {
		["TIER_ID"] = 6,
		["TIER_COLOR"] = Color3.fromRGB(209, 91, 75),
	},
	["Mythical"] = {
		["TIER_ID"] = 7,
		["TIER_COLOR"] = Color3.fromRGB(154, 0, 0),
	},

	-- Non-Shop items
	["Reborn"] = {
		["TIER_ID"] = 50,
		["TIER_COLOR"] = Color3.fromRGB(87, 198, 165),
		["RebornProof"] = true,
	},
}

return module
