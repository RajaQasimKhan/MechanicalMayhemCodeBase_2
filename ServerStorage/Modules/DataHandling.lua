-- Services
local RepStorage = game:GetService("ReplicatedStorage")
-- Modules
local MainLib = require(RepStorage.Modules.MainLib)
-- DataHandling
local DataHandling = {}

local function LOAD_ITEM_BASICS(ITEM)
	for I, DESCENDANT in pairs(ITEM:GetDescendants()) do
		if DESCENDANT:IsA("Script") then
			DESCENDANT.Disabled = DESCENDANT:FindFirstChild("ForceDisabled")
		end
		if I%50 == 0 then
			wait()
		end
	end
end

function DataHandling.LOAD_PLOT(Plr, PLOT_DATA)
	Plr:WaitForChild("SetPlot")
	local PLR_PLOT = Plr.SetPlot.Value
	for I, item_data in pairs(PLOT_DATA) do
		if item_data["item_pos"] then
			local ITEM_MODEL = MainLib.ITEM_FROM_ID(item_data["ITEM_ID"])
			if ITEM_MODEL.PrimaryPart ~= ITEM_MODEL.Hitbox then
				ITEM_MODEL.PrimaryPart = ITEM_MODEL.Hitbox
			end
			ITEM_MODEL = ITEM_MODEL:Clone()
			local item_pos = PLR_PLOT.SavePositionOrigin.CFrame * CFrame.new(unpack(item_data["item_pos"]))
			local item_stats = ITEM_MODEL.ItemStats
			if item_stats:FindFirstChild("Identifier") then
				item_stats.Identifier.Value = item_data["identifier"]
			end
			ITEM_MODEL:SetPrimaryPartCFrame(item_pos)
			ITEM_MODEL.Parent = PLR_PLOT.PlacedItems
			LOAD_ITEM_BASICS(ITEM_MODEL)
		else
			_G["global_data"][Plr.Name]["Items"][item_data["ITEM_ID"]].Amount += 1
		end
	end
end

function DataHandling.UNLOAD_PLOT(Plr)
	if Plr:FindFirstChild("SetPlot") then
		local PLR_PLOT = Plr.SetPlot.Value
		local PLOT_DATA = {}
		for I, ITEM in pairs(PLR_PLOT.PlacedItems:GetChildren()) do
			if ITEM:FindFirstChild("Hitbox") and ITEM:FindFirstChild("ItemStats") then
				local ITEM_INFO = require(ITEM.ItemStats)
				if ITEM.ItemStats:FindFirstChild("Identifier") then
					PLOT_DATA[#PLOT_DATA+1] = {
						["ITEM_ID"] = ITEM_INFO.ItemId,
						["item_pos"] = {(PLR_PLOT.SavePositionOrigin.CFrame:Inverse() * ITEM.PrimaryPart.CFrame):components()},
						["identifier"] = ITEM.ItemStats.Identifier.Value or ""
					}
				else
					PLOT_DATA[#PLOT_DATA+1] = {
						["ITEM_ID"] = ITEM_INFO.ItemId,
						["item_pos"] = {(PLR_PLOT.SavePositionOrigin.CFrame:Inverse() * ITEM.PrimaryPart.CFrame):components()},
					}
				end
			end
		end
		return PLOT_DATA
	end
end

return DataHandling
