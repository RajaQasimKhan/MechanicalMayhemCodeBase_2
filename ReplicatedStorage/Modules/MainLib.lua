local PlotFloorRange = {1, 16}
local PlotFloorInc = 1

local Stages = {
	"BUILDING",
	"COMPONENTS",
	"CIRCUITS",
	"SCRIPTING",
	"DEPLOY"
}

-- Services
local RepStorage = game:GetService("ReplicatedStorage")
-- Modules
local ITEM_HANDLING = require(RepStorage.Modules.ItemHandler)
local TIER_HANDLER = require(RepStorage.Modules.TierHandler)
local SURFACE_WELD = require(RepStorage.Modules.SurfaceWeldModule)
local BOT_HANDLER = require(RepStorage.Modules.BotHandler)

-- MainLib
local module = {}

function module.SET_PLOT(Plr)
	-- Variables
	-- Arrays
	local OPEN_PLOTS = {}
	-- Objects
	local PLOTS = workspace.Plots
	-- Get the Open Plots
	for I, PLOT in pairs(PLOTS:GetChildren()) do
		if PLOT.Owner.Value == "Empty Plot" then
			OPEN_PLOTS[#OPEN_PLOTS+1] = PLOT
		end
	end
	-- Choose a random plot if there is more than one, if not then return that one plot's name.
	if #OPEN_PLOTS == 1 then
		return OPEN_PLOTS[1]
	else
		return OPEN_PLOTS[math.random(1, #OPEN_PLOTS)]
	end
end

function module.MOVE_BUILD_PLATFORM(Plr, current_floor: number, inc: number)
	local REAL_PLOT = Plr.SetPlot.Value
	if REAL_PLOT.Owner.Value == Plr.Name then
		if current_floor + inc >= PlotFloorRange[1] and current_floor + inc <= PlotFloorRange[2] then
			REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value = current_floor + inc
			REAL_PLOT.BuildingPlatform:PivotTo(CFrame.new(REAL_PLOT.BuildingPlatform:GetPivot().Position + Vector3.new(0, inc * PlotFloorInc, 0)))
			REAL_PLOT.BasePlot.Position += Vector3.new(0, inc * PlotFloorInc, 0)
		end
	end
end

function module.DEPLOY_BOT(Plr, Plot)
	warn("DEPLOYING ROBOT")
	local PlacedItems = Plot.PlacedItems
	local BotModel = Instance.new("Model")
	BotModel.Name = "Bot"..tostring(#Plot.Deployed_Bots:GetChildren()+1)
	for i,v in pairs(PlacedItems:GetChildren()) do
		v.Parent = BotModel
	end
	for i, p in pairs(BotModel:GetDescendants()) do
		if p.Name == "Hitbox" then
			p:Destroy()
		end
		if p:IsA("BasePart") then
			p.Anchored = false
		end
	end
	BotModel.Parent = Plot.Deployed_Bots
	SURFACE_WELD.WeldModel(BotModel)
	RepStorage.Events.ScriptRun:FireClient(Plr, "START")
end

function module.SCRIPT_BOT(Plr)
	RepStorage.Events.UIComms:FireClient(Plr, "EnableScriptingUI")
end

function module.CIRCUIT(Plr)
	RepStorage.Events.UIComms:FireClient(Plr, "EnableCircuitUI")
end

function module.COMPONENTS(Plr, Plot)
	RepStorage.Events.UIComms:FireClient(Plr, "EnableComponentsUI")
end

function module.CHANGE_STAGE(Plr, new_stage:number)
	print(Plr, new_stage)
	local REAL_PLOT = Plr.SetPlot.Value
	if REAL_PLOT.Owner.Value == Plr.Name then
		if new_stage >= 1 and new_stage <= #Stages then
			if Stages[new_stage] == "DEPLOY" then
				module.DEPLOY_BOT(Plr, REAL_PLOT)
			elseif Stages[new_stage] == "COMPONENTS" then
				module.COMPONENTS(Plr, REAL_PLOT)
			elseif Stages[new_stage] == "SCRIPTING" then
				module.SCRIPT_BOT(Plr)
			elseif Stages[new_stage] == "CIRCUITS" then
				module.CIRCUIT(Plr)			
			end
		end
	end
end

function module.CLEAR_PLOT(Plr)
	-- Objects
	local PLOTS = workspace.Plots
	local REAL_PLOT = Plr.SetPlot.Value
	-- Reset platform
	module.MOVE_BUILD_PLATFORM(Plr, REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value, -REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value + 1)
	REAL_PLOT.Workshop.BotDesignRoom.BuildPlatformControls.Floor.Value = 1
	-- Clear the owner of the plot
	REAL_PLOT.Owner.Value = "Empty Plot"
	-- Clear Placed Items
	REAL_PLOT.PlacedItems:ClearAllChildren()
	-- Clear Misc Info (Ores etc.)
	for I, MISC_INFO in pairs(REAL_PLOT.MiscInfo:GetChildren()) do
		MISC_INFO:ClearAllChildren()
	end
	
	-- Now it's done, tell the game it's cleared!
	warn(Plr.Name.." PLOT HAS BEEN CLEARED, SUCCESS!")
end

function module.ITEM_FROM_ID(ITEM_ID)
	for I, ITEM in pairs(RepStorage.Items:GetChildren()) do
		if require(ITEM.ItemStats).ItemId == ITEM_ID then
			return ITEM
		end
	end
end

function module.GET_ITEM_TIER_INFO(ITEM_NAME)
	local REAL_ITEM = RepStorage.Items:FindFirstChild(ITEM_NAME)
	local ITEM_INFO = require(REAL_ITEM.ItemStats)
	local ITEM_TIER_ID = ITEM_HANDLING.GET_REAL_TIER(ITEM_INFO)
	for TIER_NAME, TIER_DATA in pairs(TIER_HANDLER.ITEM_TIERS) do
		if TIER_DATA["TIER_ID"] == ITEM_TIER_ID then
			return TIER_NAME, TIER_DATA
		end
	end 
end

RepStorage.Events.PlotFloorhandler.Event:Connect(module.MOVE_BUILD_PLATFORM)
RepStorage.Events.StageHandler.Event:Connect(module.CHANGE_STAGE)


return module
