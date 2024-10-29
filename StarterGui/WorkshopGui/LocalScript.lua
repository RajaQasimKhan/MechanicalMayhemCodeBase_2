local PlrGUI = script.Parent.Parent

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local SpecificItemStats = require(script.SpecificItemStats)

local MouseStates = {
	Button1 = false,
	Button2 = false
}

Mouse.Button1Down:Connect(function()
	MouseStates.Button1 = true
end)

Mouse.Button2Down:Connect(function()
	MouseStates.Button2 = true
end)

Mouse.Button1Up:Connect(function()
	MouseStates.Button1 = false
end)

Mouse.Button2Up:Connect(function()
	MouseStates.Button2 = false
end)

function GetItemFromHitbox(Hitbox:Part)
	if Hitbox.Parent:FindFirstChild("ItemStats") then
		return Hitbox.Parent
	end
end

function DisplayStatsForItem(item:Model)
	local item_stats = require(item.ItemStats)
	if item_stats.ComponentType then
		if script.Parent.Components:FindFirstChild(item.Name) then
			for i, f in pairs(script.Parent.Components:GetChildren()) do
				f.Visible = false
			end
			script.Parent.Components:FindFirstChild(item.Name).Visible = true
			SpecificItemStats.DisplayStats(item, script.Parent.Components:FindFirstChild(item.Name))
		end
	end
end

function GetEquippedBot()
	-- Request the server to get the details of the equipped bot and then return it or nil
	ReplicatedStorage.Events.ScriptingHandler:FireServer("RequestingEquippedBotData")
	local instruction, data = ReplicatedStorage.Events.ScriptingHandler.OnClientEvent:Wait()
	repeat
		if instruction == "EquippedBotData" then
			return data
		end
		instruction, data = ReplicatedStorage.Events.ScriptingHandler.OnClientEvent:Wait()
	until false
end

function EnableComponentsUI()
	PlrGUI.MainUi.Enabled = false
	PlrGUI.WorkshopGUI.Enabled = true
	for i, f in pairs(PlrGUI.WorkshopGUI:GetChildren()) do
		if f:IsA("Frame") then
			f.Visible = false
		end
	end
	script.Parent.Components.Visible = true
	
	local Plot = Player.SetPlot.Value
	for i, v in pairs(Plot.PlacedItems:GetChildren()) do
		local hitbox = v.Hitbox
		if hitbox then
			if require(v.ItemStats).ComponentType then
				local selectionBox = Instance.new("SelectionBox", hitbox)
				selectionBox.Adornee = hitbox
				selectionBox.LineThickness = 0.01
			end
		end
	end
end

function EnableCircuitUI()
	PlrGUI.MainUi.Enabled = false
	PlrGUI.WorkshopGUI.Enabled = true
	for i, f in pairs(PlrGUI.WorkshopGUI:GetChildren()) do
		if f:IsA("Frame") then
			f.Visible = false
		end
	end
	script.Parent.Circuitry.Visible = true
	
	local Plot = Player.SetPlot.Value
end

function EnableScriptingUI()
	PlrGUI.MainUi.Enabled = false
	PlrGUI.WorkshopGUI.Enabled = true
	for i, f in pairs(PlrGUI.WorkshopGUI:GetChildren()) do
		if f:IsA("Frame") then
			f.Visible = false
		end
	end
	
	PlrGUI.IDE.Enabled = true
	
	-- now load the scripts etc
	local currentBot = GetEquippedBot()
	if currentBot then
		local currentScript = currentBot["Script-1"]
		local content = currentScript["Text"]
		if not content then
			content = [[
# STYLY v1, Adapted Version 1.1.2, by dab676767

DEF Message : STRING
ASSIGN Message : "Hello World"

OUTPUT_VAR : Message
			]]
		end
		PlrGUI.IDE.Editor.ScrollingFrame.TextBox.Text = content
		
		-- TODO[[Add-A-Saving-Method-For-The-Script]] --
	end
end

ReplicatedStorage.Events.UIComms.OnClientEvent:Connect(function(data)
	if data == "EnableComponentsUI" then
		EnableComponentsUI()
	elseif data == "EnableCircuitUI" then
		EnableCircuitUI()
	elseif data == "EnableScriptingUI" then
		EnableScriptingUI()
	end
end)

RunService.Heartbeat:Connect(function()
	if script.Parent.Enabled and script.Parent.Components.Visible then
		if MouseStates.Button1 == true then
			local Target = Mouse.Target
			if Target:IsA("BasePart") then
				if Target.Name == "Hitbox" then
					local item = GetItemFromHitbox(Target)
					if item then
						DisplayStatsForItem(item)
					end
				end
			end
		end
	end
end)

for i, f in pairs(script.Parent.Components:GetChildren()) do
	if f:IsA("Frame") then
		if f:FindFirstChild("Close") then
			f.Close.MouseButton1Click:Connect(function()
				f.Visible = false
				script.Parent.Components.SelectionPrompt.Visible = true
			end)
		end
	end
end

while wait() do
	if script.Parent.Enabled and script.Parent.Components.Visible then
		SpecificItemStats.SaveStats()
	end
end