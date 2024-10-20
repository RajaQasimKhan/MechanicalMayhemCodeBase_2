-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Plrs = game:GetService("Players")
-- Item Handling
local module = {}

function module.GET_REAL_TIER(ITEM_INFO)
	local SHOP_TYPES = {"MineTab", "MachineTab", "ProcessorTab", "DecorTab"}
	local TIER_ID = ITEM_INFO.TierId
	if table.find(SHOP_TYPES, ITEM_INFO.ItemType) then
		if ITEM_INFO.Cost >= 1000000000 then
			TIER_ID = 7
		elseif ITEM_INFO.Cost >= 100000000 then
			TIER_ID = 6
		elseif ITEM_INFO.Cost >= 10000000 then
			TIER_ID = 5
		elseif ITEM_INFO.Cost >= 1250000 then
			TIER_ID = 4
		elseif ITEM_INFO.Cost >= 750000 then
			TIER_ID = 3
		elseif ITEM_INFO.Cost >= 300000 then
			TIER_ID = 2
		elseif ITEM_INFO.Cost >= 75000 then
			TIER_ID = 1
		end
	end
	return TIER_ID
end

function module.DROP_ORE(PLOT, MINE, DROP_PART, ORE_SIZE, ORE_COLOR, ORE_MATERIAL, ORE_WORTH)
	local PLOT_OWNER = Plrs:FindFirstChild(PLOT.Owner.Value)
	if PLOT_OWNER then
		local ORE = Instance.new("Part")
		ORE.Name = MINE.Name
		ORE.Size = ORE_SIZE
		local CASH_VALUE = Instance.new("NumberValue", ORE)
		CASH_VALUE.Name = "Cash"
		CASH_VALUE.Value = ORE_WORTH
		ORE.Color = ORE_COLOR
		ORE.Material = ORE_MATERIAL
		ORE.CFrame = DROP_PART.CFrame
		return ORE, CASH_VALUE
	end
	return nil, nil
end

function module.PROCESS_ORE(PLOT, FURNACE, SMELT_PART, ORE_ADD, ORE_MULTI, ORE)
	local PLOT_OWNER = Plrs:FindFirstChild(PLOT.Owner.Value)
	local OWNER_CASH = ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(PLOT.Owner.Value)
	if PLOT_OWNER and OWNER_CASH then
		local CASH_VAL = ORE.Cash.Value
		if ORE_ADD > 0 then
			CASH_VAL += ORE_ADD
		end
		if ORE_MULTI > 0 then
			CASH_VAL *= ORE_MULTI
		end
		OWNER_CASH.Value += CASH_VAL
		RepStorage.Events.MessageClient:FireClient(PLOT_OWNER, "visual", {["visual_part"] = SMELT_PART, ["message"] = "+$"..CASH_VAL, ["message_color"] = Color3.fromRGB(134, 207, 101)})
		return true
	end
	return false
end

function module.UPGRADE_ORE(PLOT, UPGRADER, ORE, ORE_ADD, ORE_MULTI, TAG_NAME, LIMIT_USE)
	local PLOT_OWNER = Plrs:FindFirstChild(PLOT.Owner.Value)
	if ORE:FindFirstChild("Cash") then
		local TAG = ORE:FindFirstChild(TAG_NAME)
		if TAG then
			if TAG.Value > LIMIT_USE then
				return false
			end
		end
		if TAG == nil then
			TAG = Instance.new("NumberValue", ORE)
			TAG.Name = TAG_NAME
			TAG.Value = 0
		end
		TAG.Value += 1		-- Do this here cause it's best place, don't move it >:C
		if ORE_MULTI > 0 then
			ORE.Cash.Value *= ORE_MULTI
		end
		if ORE_ADD > 0 then
			ORE.Cash.Value += ORE_ADD
		end
		return true
	end
	return false
end

function module.CONVEYOR_MOVE(CONVEYOR, SPEED)
	CONVEYOR.AssemblyLinearVelocity = CONVEYOR.CFrame.LookVector * SPEED
end

return module
