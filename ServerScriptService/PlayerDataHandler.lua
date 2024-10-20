-- Basic Needs
_G["global_data"] = {}
-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Plrs = game:GetService("Players")
-- Modules
local DATA_FUNCTION_HANDLING = require(ServerStorage.Modules.DataSavingHandler.DataHandling)
local DATA_HANDLING = require(ServerStorage.Modules.DataSavingHandler)
local PLAYER_DATA_INFO = require(ServerStorage.Modules.PlayerDataInfo)
local CASH_LIB = require(RepStorage.Modules.CashLib)
local MainLib = require(RepStorage.Modules.MainLib)
-- Constants
local data_code = "plr_data_4"		-- Change this string to reset data

if workspace:FindFirstChild("Items") then
	workspace.Items.Parent = RepStorage
end

local function SAVE_DATA(Plr)
	if Plr:FindFirstChild("DataLoaded") == nil then
		return false
	end
	local plr_data = {}
	-- Save Basic Values.
	for val_name,_ in pairs(PLAYER_DATA_INFO.SIMPLE_VALS) do
		local val_obj = Plr:FindFirstChild(val_name)
		plr_data[val_name] = val_obj.Value
	end
	-- Save Player Settings.
	for val_name,_ in pairs(PLAYER_DATA_INFO.SETTINGS_VALUES) do
		local val_obj = Plr.Settings:FindFirstChild(val_name)
		plr_data["setting"..val_name] = val_obj.Value
	end
	-- Cash Saving
	local plr_cash = ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name)
	if plr_cash then
		plr_data["Cash"] = plr_cash.Value
	end
	-- Save the Player's Inventory!
	plr_data["InvItemSaveData"] = _G["global_data"][Plr.Name]["Items"]
	-- Save the Player's Plot Items!
	local base_data = game.HttpService:JSONEncode(DATA_FUNCTION_HANDLING.UNLOAD_PLOT(Plr))
	plr_data["PlotItemPlaced"] = base_data
	-- Save the Player's Bots
	local bot_data = _G["global_data"][Plr.Name]["BotData"]
	bot_data = game.HttpService:JSONEncode(bot_data)
	plr_data["BotSaveData"] = bot_data
	-- Saved stuff now and return it's done!
	DATA_HANDLING(data_code, Plr):Set(plr_data)
	return true
end

local function LOAD_DATA(Plr)
	if Plr:FindFirstChild("Loading") then
		return "Already Loading!"
	end
	Instance.new("BoolValue", Plr).Name = "Loading"
	if _G["global_data"][Plr.Name] == nil then
		_G["global_data"][Plr.Name] = {}
		for I, INVENTORY_TYPE in pairs(PLAYER_DATA_INFO.INVENTORY_TYPES) do
			_G["global_data"][Plr.Name][INVENTORY_TYPE] = {}
			print("INVENTORY_TYPE CREATED FOR "..Plr.Name.."! ("..INVENTORY_TYPE..")")
		end
	end
	-- Get the player's data
	local plr_data = DATA_HANDLING(data_code, Plr):Get({})
	warn(plr_data)
	-- Load Basic Values.
	for val_name, val_data in pairs(PLAYER_DATA_INFO.SIMPLE_VALS) do
		local val_obj = Plr:FindFirstChild(val_name)
		if val_obj == nil then
			val_obj = Instance.new(val_data["VALUE_TYPE"], Plr)
			val_obj.Name = val_name
		end
		val_obj.Value = plr_data[val_name] or val_data["DEFAULT"]
	end
	-- Load Player Settings.
	Instance.new("Folder", Plr).Name = "Settings"
	for val_name, val_data in pairs(PLAYER_DATA_INFO.SETTINGS_VALUES) do
		local val_obj = Instance.new(val_data["VALUE_TYPE"] or "BoolValue", Plr.Settings)
		val_obj.Name = val_name
		val_obj.Value = plr_data["setting"..val_name] or val_data["DEFAULT"]
	end
	-- Cash Loading
	local plr_cash = Instance.new("NumberValue", ServerStorage.ServerLockedPlayerInfo.PlayerCash)
	plr_cash.Name = Plr.Name
	plr_cash.Value = plr_data["Cash"] or 250000
	-- Load the Player's Inventory!
	local default_inv = {
		[1] = {
			["Amount"] = 3,
		},
		[2] = {
			["Amount"] = 5,
		},
		[16] = {
			["Amount"] = 1,
		},
	}
	_G["global_data"][Plr.Name]["Items"] = plr_data["InvItemSaveData"] or default_inv
	-- Load the Player's Bots!
	for _, item in pairs(RepStorage.Items:GetChildren()) do
		local item_info = require(item.ItemStats)
		if _G["global_data"][Plr.Name]["Items"][item_info.ItemId] == nil then
			_G["global_data"][Plr.Name]["Items"][item_info.ItemId] = {
				["Unlocked"] = false,
				["Amount"] = 0,
			}
		else
			if _G["global_data"][Plr.Name]["Items"][item_info.ItemId]["Amount"] > 0 then
				_G["global_data"][Plr.Name]["Items"][item_info.ItemId]["Unlocked"] = true
			end
		end
	end
	-- Load the Player's Plot Items!
	local plot_data = plr_data["PlotItemPlaced"] or {}
	if plot_data ~= {} then
		plot_data = game.HttpService:JSONDecode(plot_data)
	end
	-- Load the Player's Bots!
	local bot_data = plr_data["BotSaveData"] or {}
	if bot_data ~= {} then
		bot_data = game.HttpService:JSONDecode(bot_data)
	end
	_G["global_data"][Plr.Name]["BotData"] = bot_data
	_G["global_data"][Plr.Name]["LoadedBot"] = plr_data["LoadedBot"] or nil
	--DATA_FUNCTION_HANDLING.LOAD_PLOT(Plr, plot_data)
	-- Leaderstats
	Instance.new("Folder",Plr).Name = "leaderstats"
	local CashLeaderStat = Instance.new("StringValue",Plr.leaderstats)
	CashLeaderStat.Name = "Cash"
	plr_cash.Changed:Connect(function()
		CashLeaderStat.Value = "$"..CASH_LIB.SUFFIX_NUM(plr_cash.Value)
	end)
	CashLeaderStat.Value = "$"..CASH_LIB.SUFFIX_NUM(plr_cash.Value)
	local RebirthLeaderStat = Instance.new("StringValue",Plr.leaderstats)
	RebirthLeaderStat.Name = "Rebirths"
	Plr.Rebirth.Changed:Connect(function()
		RebirthLeaderStat.Value = Plr.Rebirth.Value + 1
	end)
	RebirthLeaderStat.Value = Plr.Rebirth.Value + 1
	-- Loading Completed, create a tag in the player!
	Instance.new("BoolValue", Plr).Name = "DataLoaded"
end

-- Main Functions
local function PLAYER_LEAVING(Plr)
	local SAVED = SAVE_DATA(Plr)
	if SAVED ~= nil then
		-- No need for cash now!
		local CASH_PLR_VAL = ServerStorage.ServerLockedPlayerInfo.PlayerCash:FindFirstChild(Plr.Name)
		if CASH_PLR_VAL then
			CASH_PLR_VAL:Destroy()
		end
		-- Clear stuff from the player when they were in-game now all data has saved!
		MainLib.CLEAR_PLOT(Plr)
		-- Now tell the server it's done!
		warn("CLEARED "..Plr.Name.." INFO SUCCESS!")
	end
end

-- Player Binding for Saving/Loading
Plrs.PlayerRemoving:Connect(PLAYER_LEAVING)
RepStorage.Events.LoadData.OnServerInvoke = LOAD_DATA

-- Keep the game open to save the game if shutdowns are done, this is just a extra layer of saftey ontop of DataStore2's method
game:BindToClose(function()
	-- Hacky to use GetService like this but RunService is only used this one time here so it works.
	if game:GetService("RunService"):IsStudio() then
		-- Just don't run this in-studio or else it will be a long time wait before play test stops when you want it too.
		return false
	end
	local plr_saving = {}
	while task.wait() do
		for _, plr in pairs(Plrs:GetChildren()) do
			if plr_saving[plr] ~= true then
				warn("Keeping "..plr.Name.." in-game till data saves!")
				plr_saving[plr] = true
				local SAVED = SAVE_DATA(plr)
				if SAVED ~= false then
					plr:Kick("Your data has been saved and you've been kicked due to the servers being shutdown!")
				else
					plr_saving[plr] = nil
				end
			end
		end
	end
end)

coroutine.wrap(function()
	-- Autosaving
	while task.wait(60) do
		for _, plr in pairs(Plrs:GetChildren()) do
			SAVE_DATA(plr)
		end
	end
end)()
