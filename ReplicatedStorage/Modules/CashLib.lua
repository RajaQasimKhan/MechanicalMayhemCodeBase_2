-- Services
local RepStorage = game:GetService("ReplicatedStorage")
-- Modules
local Enums = require(RepStorage.Modules.CustomEnums)
-- CashLib
local CASH_LIB = {}
CASH_LIB.NUM_SUFFIXES = {"k", "M", "B", "T", "Qd", "Qn", "S", "Sp"}

function CASH_LIB.SUFFIX_NUM(NUM)
	-- Converts a number given into a suffix, if no suffix for numbers that high then simpily give it a "e+" value
	local i = math.floor(math.log(NUM, 1e3))
	local v = math.pow(10, i * 3)
	local CASH_START = ("%.1f"):format(NUM / v):gsub("%.?0+$", "")
	local ENDING_NONE = "e+"..i * 3
	if NUM < 1000 then
		ENDING_NONE = ""
	end
	if NUM < 1 then
		return NUM
	end
	return CASH_START..(CASH_LIB.NUM_SUFFIXES[i] or ENDING_NONE)
end

function CASH_LIB.GET_REBIRTH_COST(Plr)
	if Plr then
		local STARTER_COST = Enums.Nums.STARTER_REBIRTH_COST
		local FINAL_COST = STARTER_COST * ((((((Plr.Rebirth.Value + 1) / ((math.floor(Plr.Rebirth.Value / 164) + 1))  * ((math.floor(Plr.Rebirth.Value / 5) + 1))) * ((math.floor(Plr.Rebirth.Value / 316)) + 1)) + 1) ^ 1.17) / 2.37 * (1.4 + (math.floor(Plr.Rebirth.Value / 974))))
		if Plr.Rebirth.Value == 0 and FINAL_COST ~= STARTER_COST then
			FINAL_COST = STARTER_COST
		end
		return FINAL_COST
	end
end

return CASH_LIB
