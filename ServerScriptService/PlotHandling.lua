-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local Plrs = game:GetService("Players")
-- Modules
local Enums = require(RepStorage.Modules.CustomEnums)
local MainLib = require(RepStorage.Modules.MainLib)

for I, PLOT in pairs(workspace.Plots:GetChildren()) do
	PLOT.Owner.Value = "Empty Plot"
	for I, MISC_FOLDER_NAME in pairs(Enums.Arrays.MISC_PLOT_FOLDERS) do
		local FOLDER = Instance.new("Folder", PLOT.MiscInfo)
		FOLDER.Name = MISC_FOLDER_NAME
	end
	PLOT.BasePlot.Touched:Connect(function(ORE)
		if ORE:FindFirstChild("Cash") then
			ORE:Destroy()
		end
	end)
end

local function SPAWN_PLAYER(Plr)
	Plr.Character:WaitForChild("HumanoidRootPart")
	local REAL_PLOT = Plr.SetPlot.Value
	for I=1, 5 do
		-- Loop the player spawning position for a plot cause not looping it doesn't work :/
		Plr.Character:WaitForChild("HumanoidRootPart")
		Plr.Character.HumanoidRootPart.CFrame = CFrame.new(REAL_PLOT.Workshop.SpawnPart.Position+Vector3.new(0, Enums.Nums.SPAWN_REG_HEIGHT, 0))
		wait()
	end
end

local function PLR_ADDED(Plr)
	local PLOT_INFO = Instance.new("ObjectValue", Plr)
	PLOT_INFO.Name = "SetPlot"
	PLOT_INFO.Value = MainLib.SET_PLOT(Plr)
	-- Plot Setup
	PLOT_INFO.Value.Owner.Value = Plr.Name
	-- Player Spawning
	Plr.CharacterAdded:Connect(function()
		SPAWN_PLAYER(Plr)
	end)
end


Plrs.PlayerAdded:Connect(PLR_ADDED)
