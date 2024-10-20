-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Plrs = game:GetService("Players")
-- Modules
local MAIN_LIB = require(RepStorage.Modules.MainLib)
local BOT_PRESETS = require(RepStorage.Modules.BotPresets)
-- Variables
	-- Arrays
local DEBOUNCE = {}
warn("Main [SERVER] loading...")

_G["equipped_bots"] = {}
_G["script_changes"] = {}

function NOTIFICATION_EVENT_LISTENER(input_id:any)
	local id, data = nil, nil
	while true do
		local plr, id, data = RepStorage.Events.Notification.OnServerEvent:Wait()
		print(plr, id, data)
		if id == input_id then
			return plr, data
		end
	end
end

function PLACE_ITEM(Plr, PLACED_ITEMS, ITEMS)
	if Plr and PLACED_ITEMS and ITEMS then
		local ITEM_FAILED = false
		for I, ITEM in pairs(ITEMS) do
			local ITEM_REP = RepStorage.Items:FindFirstChild(ITEM["ITEM_NAME"])
			local ITEM_INFO = require(ITEM_REP.ItemStats)
			if _G["global_data"][Plr.Name]["Items"][ITEM_INFO.ItemId]["Amount"] > 0 then
				local REAL_ITEM = ITEM_REP:Clone()
				REAL_ITEM:SetPrimaryPartCFrame(ITEM["ITEM_LOCATION"])
				REAL_ITEM.Parent = PLACED_ITEMS
				_G["global_data"][Plr.Name]["Items"][ITEM_INFO.ItemId]["Amount"] -= 1
				spawn(function()
					for E, DESCENDANT in pairs(REAL_ITEM:GetDescendants()) do
						if DESCENDANT:IsA("Script") then
							DESCENDANT.Disabled = DESCENDANT:FindFirstChild("ForceDisabled")
						end
						if E%50 == 0 then
							wait()
						end
					end
					RepStorage.Events.InventoryUpdate:FireClient(Plr)
				end)
			else
				ITEM_FAILED = true
			end
		end
		return not ITEM_FAILED
	end
	return false
end

function GET_INVENTORY(Plr, INVENTORY_TYPE)
	local INV_GETTING = Plr		-- Make this be the Plot Owner if possible but if not be the Plr
	return _G["global_data"][INV_GETTING.Name][INVENTORY_TYPE]
end

function BUY_ITEM(Plr, ITEM_ID, AMOUNT)
	local CASH = ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name)
	if CASH then
		local CANT_BUY_TYPES = {"special", "cantbuy"}
		local AMOUNT = AMOUNT or 1
		local ITEM_ID = ITEM_ID
		local COST_VAL = 0
		if type(ITEM_ID) ~= "table" then
			ITEM_ID = {ITEM_ID}
		end
		local BOUGHT_ITEMS = {}
		for I, REAL_ID in pairs(ITEM_ID) do
			local REAL_ITEM = MAIN_LIB.ITEM_FROM_ID(REAL_ID)
			local ITEM_INFO = require(REAL_ITEM.ItemStats)
			if table.find(CANT_BUY_TYPES, ITEM_INFO.ItemType) == nil then	-- string.lower(ITEM_INFO.ItemType) == "special" or string.lower(ITEM_INFO.CostType) == "cantbuy" then
				if CASH.Value >= math.floor(ITEM_INFO.Cost*AMOUNT) then
					COST_VAL += math.floor(ITEM_INFO.Cost*AMOUNT)
					BOUGHT_ITEMS[#BOUGHT_ITEMS+1] = REAL_ID
				end
			end
		end
		if #BOUGHT_ITEMS == #ITEM_ID then
			CASH.Value -= COST_VAL
			for I, ITEM_ID in pairs(BOUGHT_ITEMS) do
				ServerStorage.Events.ItemGive:Invoke(Plr, ITEM_ID, AMOUNT)
			end
			return true
		end
	end
	return false
end

function SELL_ITEM(Plr, ITEMS)
	local CASH = ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name)
	if CASH then
		local CANT_SELL_TYPES = {"special", "cantbuy"}
		local ITEM_ID = ITEMS
		local COST_VAL = 0
		if type(ITEM_ID) ~= "table" then
			ITEM_ID = {ITEM_ID}
		end
		for I, REAL_ID in pairs(ITEM_ID) do
			local ITEM_INFO = require(REAL_ID.ItemStats)
			if table.find(CANT_SELL_TYPES, ITEM_INFO.ItemType) == nil then	-- string.lower(ITEM_INFO.ItemType) == "special" or string.lower(ITEM_INFO.CostType) == "cantbuy" then
				if CASH.Value >= math.floor(ITEM_INFO.Cost) then
					CASH.Value += ITEM_INFO.Cost
					REAL_ID:Destroy()
				end
			end
		end
		return true
	end
	return false
end

function WITHDRAW_ITEMS(Plr, ITEMS)
	if DEBOUNCE[Plr.Name] then
		return false
	else
		DEBOUNCE[Plr.Name] = true
		spawn(function()
			wait(.3)
			DEBOUNCE[Plr.Name] = nil
		end)
	end
	if Plr then
		for I, ITEM in pairs(ITEMS) do
			local ITEM_INFO = require(ITEM.ItemStats)
			_G["global_data"][Plr.Name]["Items"][ITEM_INFO.ItemId]["Amount"] += 1
			ITEM:Destroy()
		end
		RepStorage.Events.InventoryUpdate:FireClient(Plr)
		return true
	end
	return false
end

function UPDATE_STORT(Plr, SORT_VAL_NAME, NEW_SORT)
	local SORT_VAL = Plr:FindFirstChild(SORT_VAL_NAME)
	if SORT_VAL then
		if NEW_SORT ~= SORT_VAL.Value then
			SORT_VAL.Value = NEW_SORT
			return true
		end
	end
	return false
end

function toggle_update(plr, toggle_name)
	local real_setting = plr.Settings:FindFirstChild(toggle_name)
	if real_setting ~= nil then
		real_setting.Value = not real_setting.Value
		return true
	end
	warn(toggle_name.." doesn't exist for "..plr.Name.." so it's either failed to load or not been implemented!")
	return false
end

-- Function/Event Responses
RepStorage.Events.GetInventoryType.OnServerInvoke = GET_INVENTORY
RepStorage.Events.WithdrawItems.OnServerInvoke = WITHDRAW_ITEMS
RepStorage.Events.UpdateStorting.OnServerInvoke = UPDATE_STORT
RepStorage.Events.UpdateToggle.OnServerInvoke = toggle_update
RepStorage.Events.PlaceItem.OnServerInvoke = PLACE_ITEM
RepStorage.Events.SellItem.OnServerInvoke = SELL_ITEM
RepStorage.Events.BuyItem.OnServerInvoke = BUY_ITEM

-- Server Locked Stuff
function ItemGive(Plr, ITEM_ID, AMOUNT)
	if _G["global_data"][Plr.Name]["Items"][ITEM_ID] then
		_G["global_data"][Plr.Name]["Items"][ITEM_ID]["Amount"] += AMOUNT
		RepStorage.Events.MessageClient:FireClient(Plr, "screen", {["message"] = "You got x"..AMOUNT.." "..MAIN_LIB.ITEM_FROM_ID(ITEM_ID).Name.."'s!"})
		RepStorage.Events.InventoryUpdate:FireClient(Plr)
		return true
	end
	return false
end

function CHANGE_ITEM_IDENTIFIER(PLR, ITEM, VALUE)
	if ITEM.ItemStats:FindFirstChild("Identifier") then
		ITEM.ItemStats.Identifier.Value = VALUE
	end
end

function CircuitHandler(PLR, INS, DATA)
	if INS == "Update" then
		local Bot = DATA[1]
		local Info = DATA[2]
	end
end

function GetBots(PLR)
	warn(_G)
	if _G["global_data"][PLR.Name] then
		RepStorage.Events.BotComms:FireClient(PLR, "ReturnedBotData", _G["global_data"][PLR.Name]["BotData"])
		return
	end
	RepStorage.Events.Notification:FireClient(PLR, "Warning", "Unable to get data; Roblox services may be down. Contact us if you feel this is a bug.", "ContentBased", 3)
end

function unloadCframe(item, plot)
	return {(plot.SavePositionOrigin.CFrame:Inverse() * item:GetPivot()):components()}
end

function loadCframe(list, plot)
	return plot.SavePositionOrigin.CFrame * CFrame.new(unpack(list))
end

function loadBotCircuit(plr, BotData)
	local Plot = plr.SetPlot.Value
	if not Plot then return end
	local WireMap = BotData["Circuit"]["Wiring"]
	local ModelMap = BotData["Circuit"]["Model"]
	local LineMap = BotData["Circuit"]["LineMap"]
	
	warn(BotData)
	
	local NewLineMap = {}
	for i, v in pairs(LineMap) do
		NewLineMap[i] = {}
		for j, k in pairs(v) do
			NewLineMap[i][j] = {}
			local plotX, plotY, plotZ = Plot.SavePositionOrigin.Position.X, Plot.SavePositionOrigin.Position.Y, Plot.SavePositionOrigin.Position.Z
			local Pos1, Pos2 = Vector3.new(k[1][1] + plotX, k[1][2] + plotY, k[1][3] + plotZ), Vector3.new(k[2][1] + plotX, k[2][2] + plotY, k[2][3] + plotZ)
			NewLineMap[i][j][1] = Pos1
			NewLineMap[i][j][2] = Pos2
		end
	end
	
	local model = {}
	for i, v in pairs(ModelMap) do
		model[i] = {v[1], v[2], loadCframe(v[3], Plot)}
	end
	
	return model, NewLineMap, WireMap
end

function UpdateCircuitForBot(PLR, BotId, Data)
	warn(Data)
	local plot = PLR.SetPlot.Value
	if not plot then return end
	local wiring = Data[1]
	local model = Data[2]
	local LineMap = Data[3]
	
	local ModelMap = {}
	for i, v in pairs(model) do
		table.insert(ModelMap, v)
		--if v:IsA("Model") then
		--	local s = v.Name:split("--")
		--	table.insert(ModelMap, {s[1], s[2], unloadCframe(v, plot)})
		--end
	end
	
	local FixedLineMap = {}
	for i, v in pairs(LineMap) do
		FixedLineMap[i] = {}
		for j, k in pairs(v) do
			FixedLineMap[i][j] = {}
			local plotX, plotY, plotZ = plot.SavePositionOrigin.Position.X, plot.SavePositionOrigin.Position.Y, plot.SavePositionOrigin.Position.Z
			local X1, Y1, Z1 = k[1].X-plotX, k[1].Y-plotY, k[1].Z-plotZ
			local X2, Y2, Z2 = k[2].X-plotX, k[2].Y-plotY, k[2].Z-plotZ
			FixedLineMap[i][j][1] = {X1, Y1, Z1}
			FixedLineMap[i][j][2] = {X2, Y2, Z2}
		end
	end
	
	if _G["global_data"][PLR.Name]["BotData"][BotId] then
		_G["global_data"][PLR.Name]["BotData"][BotId]["Circuit"] = {
			["Wiring"] = wiring,
			["LineMap"] = FixedLineMap,
			["Model"] = ModelMap
		}
		return true
	end
	return false
end

function CreateBot(PLR, preset, name)
	if _G["global_data"][PLR.Name] then
		if #_G["global_data"][PLR.Name]["BotData"] < 5 then
			if BOT_PRESETS.GetPreset(preset) then
				local bot = BOT_PRESETS.GetPreset(preset)
				bot["Id"] = (#_G["global_data"][PLR.Name]["BotData"]+1)
				bot["SaveTime"] = tick()
				if name == "<BotName>" or name == "" or name == nil then
					name = "Bot"..bot["Id"]
				end
				bot["Name"] = name
				table.insert(_G["global_data"][PLR.Name]["BotData"], bot)
				RepStorage.Events.BotComms:FireClient(PLR, "BotCreationSuccess", _G["global_data"][PLR.Name]["BotData"])
				RepStorage.Events.Notification:FireClient(PLR, "Success", "Created successfully!", "Timer", 5)
				return
			end
			local bot = {
				["Name"] = "Bot"..(#_G["global_data"][PLR.Name]["BotData"]+1),
				["Id"] = (#_G["global_data"][PLR.Name]["BotData"]+1),
				["Circuit"] = {
					["Wiring"] = {},
					["LineMap"] = {},
					["Model"] = {}
				},
				["Model"] = {},
				["Script-1"] = {},
				["SaveTime"] = tick(),
				["IsDeployed"] = false
			}
			if name == "<BotName>" or name == "" or name == nil then
				name = "Bot"..bot["Id"]
			end
			bot["Name"] = name
			table.insert(_G["global_data"][PLR.Name]["BotData"], bot)
			RepStorage.Events.BotComms:FireClient(PLR, "BotCreationSuccess", _G["global_data"][PLR.Name]["BotData"])
			RepStorage.Events.Notification:FireClient(PLR, "Success", "Created successfully!", "Timer", 5)
			return
		end
	end
	RepStorage.Events.Notification:FireClient(PLR, "Notice", "Creation limit reached or exceeded!", "ContentBased", 3)
end

function DeleteBot(PLR, botID)
	if _G["global_data"][PLR.Name] then
		if _G["global_data"][PLR.Name]["BotData"][botID] then
			local text = "WARNING: Are you sure you want to delete Bot '".._G["global_data"][PLR.Name]["BotData"][botID]["Name"].."'? This action can NOT be undone. Press NO to CANCEL, or YES to CONFIRM."
			local stream_id = PLR.UserId.."#"..tick().."#"..math.random(1, 200)
			warn(stream_id)
			RepStorage.Events.Notification:FireClient(PLR, "2ChoicePrompt", text, "NONE", "NONE", stream_id)
			local NewPlayer, SelectedValue = NOTIFICATION_EVENT_LISTENER(stream_id)
			print(NewPlayer, SelectedValue)
			if NewPlayer == PLR then
				if SelectedValue == "YES" then
					table.remove(_G["global_data"][PLR.Name]["BotData"], botID)
					RepStorage.Events.BotComms:FireClient(PLR, "BotDeletionSuccess", _G["global_data"][PLR.Name]["BotData"])
					RepStorage.Events.Notification:FireClient(PLR, "Notice", "Bot deleted successfully. If this was an accident, contact me immediately.", "ContentBased", 3)
					return
				end
			end
		end
	end
end
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

function LOAD_BOT_MODEL(Plr, BOT_MODEL_DATA)
	Plr:WaitForChild("SetPlot")
	local PLR_PLOT = Plr.SetPlot.Value
	for I, item_data in pairs(BOT_MODEL_DATA) do
		if item_data["item_pos"] then
			local ITEM_MODEL = MAIN_LIB.ITEM_FROM_ID(item_data["ITEM_ID"])
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

function UNLOAD_PLOT(Plr)
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

function CUSTOM_CLEAR_PLOT(Plr)
	-- Objects
	local PLOTS = workspace.Plots
	local REAL_PLOT = Plr.SetPlot.Value
	-- Reset platform
	MAIN_LIB.MOVE_BUILD_PLATFORM(Plr, REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value, -REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value + 1)
	REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value = 1
	-- Clear Placed Items
	REAL_PLOT.PlacedItems:ClearAllChildren()
	-- Clear Misc Info (Ores etc.)
	for I, MISC_INFO in pairs(REAL_PLOT.MiscInfo:GetChildren()) do
		MISC_INFO:ClearAllChildren()
	end

	-- Now it's done, tell the game it's cleared!
	warn(Plr.Name.." PLOT HAS BEEN CLEARED, SUCCESS!")
end

function LoadBot(PLR: Player, DATA:any)
	if _G["global_data"][PLR.Name] then
		if _G["global_data"][PLR.Name]["BotData"][DATA] then
			local text = "ATTENTION: Are you sure you want to load Bot '".._G["global_data"][PLR.Name]["BotData"][DATA]["Name"].."'? This action will replace any UNSAVED changes. Press NO to CANCEL, or YES to CONFIRM"
			local stream_id = PLR.UserId.."#"..tick().."#"..math.random(1, 200)
			RepStorage.Events.Notification:FireClient(PLR, "2ChoiceNotice", text, "NONE", "NONE", stream_id)
			local NewPlayer, SelectedValue = NOTIFICATION_EVENT_LISTENER(stream_id)
			print(NewPlayer, SelectedValue)
			if NewPlayer == PLR then
				if SelectedValue == "YES" then
					UNLOAD_PLOT(PLR) -- unload current model from plot
					CUSTOM_CLEAR_PLOT(PLR)
					
					local bot = _G["global_data"][PLR.Name]["BotData"][DATA]
					LOAD_BOT_MODEL(PLR, bot["Model"]) -- Load the bot's model
					
					local model, lineMap, wireMap = loadBotCircuit(PLR, bot) -- get the bot's circuitry
					warn(model, lineMap, wireMap)
					-- tell the client to load the bots circuitry
					RepStorage.Events.CircuitryHandler:FireClient(PLR, "LoadBotCircuit", {model, lineMap, wireMap})
					_G["equipped_bots"][PLR.Name] = DATA
					RepStorage.Events.Notification:FireClient(PLR, "Notice", "Bot loaded successfully.", "ContentBased", 3)
					return
				end
			end
		end
	end
end

function SaveBot(PLR:Player, DATA:any)
	if _G["global_data"][PLR.Name] then
		if _G["global_data"][PLR.Name]["BotData"][DATA] then
			local text = "ATTENTION: Are you sure you want to save this bot to slot '".._G["global_data"][PLR.Name]["BotData"][DATA]["Name"].."'? This action will REPLACE and OVERWRITE the slot. Press NO to CANCEL, or YES to CONFIRM"
			local stream_id = PLR.UserId.."#"..tick().."#"..math.random(1, 200)
			RepStorage.Events.Notification:FireClient(PLR, "2ChoiceNotice", text, "NONE", "NONE", stream_id)
			local NewPlayer, SelectedValue = NOTIFICATION_EVENT_LISTENER(stream_id)
			print(NewPlayer, SelectedValue)
			if NewPlayer == PLR then
				if SelectedValue == "YES" then
					local plot_items = UNLOAD_PLOT(PLR)
					if plot_items then
						_G["global_data"][PLR.Name]["BotData"][DATA]["Model"] = plot_items
					end
					local currentPlayerScript = _G["script_changes"][PLR.Name] or nil
					if currentPlayerScript then
						if currentPlayerScript ~= "" then
							_G["global_data"][PLR.Name]["BotData"][DATA]["Script-1"]["Text"] = _G["script_changes"][PLR.Name]
						end
					end
					local Circuit = nil
					RepStorage.Events.CircuitryHandler:FireClient(PLR, "RequestingUpdatedBotCircuit", DATA)
					repeat
						local plr = RepStorage.Events.BotComms.OnServerEvent:Wait()
						warn(plr)
					until plr == PLR
					RepStorage.Events.Notification:FireClient(PLR, "Notice", "Bot saved successfully.", "ContentBased", 3)
					return
				end
			end
		end
	end
end


function ManageBot(PLR, INS, DATA)
	if INS == "CreateBot" then
		CreateBot(PLR, DATA[1], DATA[2])
		
	elseif INS == "UpdateBotCircuit" then
		UpdateCircuitForBot(PLR, DATA[1], DATA[2])
		
	elseif INS == "GetBotData" then
		GetBots(PLR)
		
	elseif INS == "DeleteBot" then
		DeleteBot(PLR, DATA)
		
	elseif INS == "LoadBot" then
		LoadBot(PLR, DATA)
		
	elseif INS == "SaveBot" then
		SaveBot(PLR, DATA)
		
	end
end

function ScriptingPhaseEvent(Plr, Instruction, Data)
	if Instruction == "RequestingEquippedBotData" then
		if _G["equipped_bots"][Plr.Name] then
			local equippedBotIndex = _G["equipped_bots"][Plr.Name]
			local equippedBot = _G["global_data"][Plr.Name]["BotData"][equippedBotIndex]
			RepStorage.Events.ScriptingHandler:FireClient(Plr, "EquippedBotData", equippedBot)
		end
	elseif Instruction == "SaveScriptChanges" then
		_G["script_changes"][Plr.Name] = Data
	end
end


-- Server Locked Functions/Events
ServerStorage.Events.ItemGive.OnInvoke = ItemGive
RepStorage.Events.ItemIdentifierModification.OnServerEvent:Connect(CHANGE_ITEM_IDENTIFIER)
RepStorage.Events.CircuitryHandler.OnServerEvent:Connect(CircuitHandler)
RepStorage.Events.BotComms.OnServerEvent:Connect(ManageBot)
RepStorage.Events.ScriptingHandler.OnServerEvent:Connect(ScriptingPhaseEvent)

workspace.Plots.Plot1.Owner.Changed:Connect(function()
	warn(tick())
end)

warn("Main [SERVER] loaded!")