local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local PresetsPage = script.Parent.Contents.Presets
local SavedBotsPage = script.Parent.Contents.Pages.SavedBots

local rbxconnection1 = {}
local SelectingPresetFrame = nil

function timeAgoConvert(seconds)
	local seconds = math.floor(seconds)
	local minutes = seconds/60
	local hours = minutes/60
	local days = hours/24
	local years = days/365.25

	days = (years - math.floor(years)) * 365.25
	hours = (days - math.floor(days)) * 24
	minutes = (hours - math.floor(hours)) * 60
	seconds = (minutes - math.floor(minutes)) * 60

	years = math.floor(years)
	days = math.floor(days)
	hours = math.floor(hours)
	minutes = math.floor(minutes)
	seconds = math.floor(seconds)
	
	local time_str = ""
	
	if years > 0 then
		time_str = time_str..tostring(years).." Years "
	end
	if days > 0 then
		time_str = time_str..tostring(days).." Days "
	end
	if hours > 0 then
		time_str = time_str..tostring(hours).." Hours "
	end
	if minutes > 0 then
		time_str = time_str..tostring(minutes).." Minutes "
	end
	if seconds > 0 then
		time_str = time_str..tostring(seconds).." Seconds "
	end
	return "Last Saved: "..time_str.."Ago"
end

function getBotDataFromServer()
	Events.BotComms:FireServer("GetBotData")
	local instruction, data = nil, nil
	while instruction ~= "ReturnedBotData" do
		instruction, data = Events.BotComms.OnClientEvent:Wait()
	end
	return data
end

function undeployButtonClick(bot_frame:Frame)
	print(bot_frame.BotID.Value)
end

function loadButtonClick(bot_frame:Frame)
	Events.BotComms:FireServer("LoadBot", bot_frame.BotID.Value)
end

function saveButtonClick(bot_frame:Frame)
	Events.BotComms:FireServer("SaveBot", bot_frame.BotID.Value)
end

function deleteButtonClick(bot_frame:Frame)
	print(bot_frame.BotID.Value)
	Events.BotComms:FireServer("DeleteBot", bot_frame.BotID.Value)
end

function createButtonClick(frame:Frame)
	print(frame.PresetName.Value)
	Events.BotComms:FireServer("CreateBot", frame.PresetName.Value)
end

function presetButtonClick(frame:Frame)
	print(frame.PresetName.Value)
	script.Parent.Contents.Presets.Visible = not script.Parent.Contents.Presets.Visible
end


function loadBotData(data)
	warn(data)
	if not data then return end
	SelectingPresetFrame = nil
	for i, v: Frame in pairs(SavedBotsPage:GetChildren()) do
		if v:IsA("Frame") then
			if rbxconnection1[v] then
				for i, connection:RBXScriptConnection in pairs(rbxconnection1[v]) do
					connection:Disconnect()
				end
				rbxconnection1[v] = nil
			end
			v:Destroy()
		end
	end
	for i, bot in pairs(data) do
		warn(bot)
		local new_frame = script.BotTemplate:Clone()
		new_frame.Parent = SavedBotsPage
		new_frame.Name = bot["Name"]
		new_frame.Title.Text = bot["Name"]
		new_frame.SavedAgo.Text = timeAgoConvert(tick()-bot["SaveTime"])
		new_frame.BotID.Value = bot["Id"]
		new_frame.Visible = true
		
		if bot["IsDeployed"] then
			new_frame.UnDeploy.Visible = true
			new_frame.Load.Visible = false
			new_frame.Save.Visible = false
		else
			new_frame.UnDeploy.Visible = false
			new_frame.Load.Visible = true
			new_frame.Save.Visible = true
		end
		local connection1 = new_frame.UnDeploy.MouseButton1Click:Connect(function()
			undeployButtonClick(new_frame)
		end)
		local connection2 = new_frame.Load.MouseButton1Click:Connect(function()
			loadButtonClick(new_frame)
		end)
		local connection3 = new_frame.Save.MouseButton1Click:Connect(function()
			saveButtonClick(new_frame)
		end)
		local connection4 = new_frame.Delete.MouseButton1Click:Connect(function()
			deleteButtonClick(new_frame)
		end)
		local bot_connections = {
			["Undeploy"] = connection1,
			["Load"] = connection2,
			["Save"] = connection3,
			["Delete"] = connection4
		}
		rbxconnection1[new_frame] = bot_connections
	end
	if #data < 5 then
		local new_frame = script.CreateTemplate:Clone()
		new_frame.Parent = SavedBotsPage
		
		local connection1 = new_frame.Create.MouseButton1Click:Connect(function()
			createButtonClick(new_frame)
		end)
		local connection2 = new_frame.Preset.MouseButton1Click:Connect(function()
			presetButtonClick(new_frame)
		end)
		local frame_connections = {
			["Create"] = connection1,
			["SelectPreset"] = connection2
		}
		rbxconnection1[new_frame] = frame_connections
		SelectingPresetFrame = new_frame
	end
end

Events.BotComms.OnClientEvent:Connect(function(instruction, data)
	warn(instruction, data)
	if instruction == "BotCreationSuccess" or instruction == "BotDeletionSuccess" then
		loadBotData(data)
	end
end)
script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible then
		local data = getBotDataFromServer()
		warn(data)
		loadBotData(data)
	end
end)

for i, preset:Frame in pairs(script.Parent.Contents.Presets.Pages:GetChildren()) do
	if preset:IsA("Frame") then
		preset.Select.MouseButton1Click:Connect(function()
			if SelectingPresetFrame then
				SelectingPresetFrame.PresetName.Value = preset.Name
			end
		end)
	end
end
