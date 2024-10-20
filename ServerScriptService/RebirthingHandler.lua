-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Plrs = game:GetService("Players")
-- Modules
local MAIN_LIB = require(RepStorage.Modules.MainLib)
local CASH_LIB = require(RepStorage.Modules.CashLib)

local function SORT_ITEMS(Plr)
	local AVAILABLE_ITEMS = {}
	for I, ITEM in pairs(RepStorage.Items:GetChildren()) do
		local ITEM_INFO = require(ITEM.ItemStats)
		if ITEM_INFO.SpecialTags["RebirthChance"] and ITEM_INFO.SpecialTags["RebirthReq"] then -- checks if item is reborn item
			if Plr.Rebirth.Value >= ITEM_INFO.SpecialTags.RebirthReq then -- checks if player s high enough rebirth
				AVAILABLE_ITEMS[#AVAILABLE_ITEMS+1] = ITEM
			end
		end
	end
	return AVAILABLE_ITEMS
end

function IS_REBIRTH_PROOF(ITEM)
	local ITEM_INFO = require(ITEM.ItemStats)
	local TIER_NAME, TIER_DATA = MAIN_LIB.GET_ITEM_TIER_INFO(ITEM.Name)
	local IS_PROOF = false
	if ITEM_INFO.SpecialTags["RebornProof"] then		-- If that item in specific is Rebirth Proof
		IS_PROOF = true
	end
	-- No elseif here cause that breaks stuff :/
	if TIER_DATA["RebornProof"] then		-- If that item's tier in specific is Rebirth Proof
		IS_PROOF = true
	end
	return IS_PROOF
end

function CLEAR_PLOT(Plr, PLR_PLOT)
	if Plr then
		for i,ITEM in pairs(PLR_PLOT.PlacedItems:GetChildren()) do
			local ITEM_INFO = require(ITEM.ItemStats)
			if IS_REBIRTH_PROOF(ITEM) then	-- give player items back from plot if it's rebirth proof
				_G["global_data"][Plr.Name]["Items"][ITEM_INFO.ItemId]["Amount"] += 1
			end
			ITEM:Destroy()
		end
		-- loops through inventory, checking for non-rebirth proof items
		for ID, DATA_ITEM in pairs(_G["global_data"][Plr.Name]["Items"]) do
			if DATA_ITEM and DATA_ITEM["Amount"] ~=  0  then
				local ITEM = MAIN_LIB.ITEM_FROM_ID(ID)
				if not IS_REBIRTH_PROOF(ITEM) then
					DATA_ITEM["Amount"] = 0	-- removes item from inventory
				end
			end
		end
	end
end

function REBIRTH(Plr)
	if Plr then
		local PLR_PLOT = Plr.SetPlot.Value
		if ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name).Value >= CASH_LIB.GET_REBIRTH_COST(Plr) and PLR_PLOT then
			local ITEMS_OBTAINABLE = SORT_ITEMS(Plr) -- Gets the items each time a rebirth is done.
			if #ITEMS_OBTAINABLE < 2 then
				RepStorage.Events.MessageClient:FireClient(Plr, "screen", {["message"] = "THE GAME DOESN'T HAVE AT LEAST 2 REBIRTH ITEMS THAT ARE FOR REBIRTH 0+, THIS RESULTS IN REBIRTHING NOT WORKING!"})
				warn("At least 2 rebirth items with RebirthReq 0 are needed to be added for rebirthing to work!")
				return false
			end
			local OLD_REBIRTHS = Plr.Rebirth.Value
			Plr.Rebirth.Value += 1
			local NEW_REBIRTHS = Plr.Rebirth.Value
			-- Clear plot stuff (Ores, Placed Items, Non-Rebirth-Proof Items etc.)
			PLR_PLOT.MiscInfo.OresDropped:ClearAllChildren()
			CLEAR_PLOT(Plr,PLR_PLOT)
			ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name).Value = 100
			-- Give the default Inventory
			_G["global_data"][Plr.Name]["Items"][1]["Amount"] = 3		-- 3 Stone Mines
			_G["global_data"][Plr.Name]["Items"][2]["Amount"] = 3		-- 3 Standard Conveyors
			_G["global_data"][Plr.Name]["Items"][3]["Amount"] = 1		-- 1 Standard Furnace
			-- Choose a reward item from items that are possible to get from the ITEMS_OBTAINABLE Array
			local CHOSEN_ITEM = ITEMS_OBTAINABLE[math.random(1, #ITEMS_OBTAINABLE)]
			local CHOSEN_ITEM_INFO = require(CHOSEN_ITEM.ItemStats)
			-- Now everything has happened, give the reward item.
			ServerStorage.Events.ItemGive:Invoke(Plr, CHOSEN_ITEM_INFO.ItemId, 1)
			return true
		end
	end
	return false
end
RepStorage.Events.Rebirth.OnServerInvoke = REBIRTH
