local function tween(Object, Properties, Value, Time, Style, Direction)
	Style = Style or Enum.EasingStyle.Quad
	Direction = Direction or Enum.EasingDirection.Out

	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Direction
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end

local function FadeAnim(GuiElement, FadeEnd, Time)
	tween(GuiElement, {"BackgroundTransparency"}, FadeEnd, Time)
end

local function TextFadeAnim(GuiElement, FadeEnd, Time)
	tween(GuiElement, {"TextTransparency"}, FadeEnd, Time)
end

-- Prevents petty Bugs
game.ReplicatedStorage:WaitForChild("Items")
-- Variables
	-- Integers
local COMPLETED_MODULES = 0
	-- Arrays
local LIBS = {	-- List of Libs
	game.ReplicatedStorage.Modules.PlacementLib,
	game.ReplicatedStorage.Modules.MainLib,
	game.ReplicatedStorage.Modules.CashLib,
}
local MODULES_LOAD = {}
local GOT_SERVICES = {}
local SERVICES = {	-- List of Services
	"ReplicatedStorage",
	"UserInputService",
	"RunService",
	"Players",
}
script.Parent.Parent.ModulesLoading.Progress.Text = "Loading Modules: 0/100%"
script.Parent.Parent.ModulesLoading.Progress.TextStrokeTransparency = 1
script.Parent.Parent.ModulesLoading.Visible = true
TextFadeAnim(script.Parent.Parent.ModulesLoading.Progress, 0, .2)
wait(.2)	-- Just incase the player hasn't yet loaded there data

local function ADD_MODULE(MOD)
	-- Simply adds the module if it's valid to be added to the array of modules
	local REQUIRED_MOD = require(MOD)
	MODULES_LOAD[MOD.Name] = REQUIRED_MOD
end

local function MODULE_LOAD()
	-- Start off by letting the player know it's started in the output and get the tick it starts
	local LOADED_START_TICK = tick()
	warn("STARTED LOADING MODULES!")
	-- Now we can Get Services modules can use.
	for I, SERVICE in pairs(SERVICES) do
	--	print("Service - "..SERVICE)
		GOT_SERVICES[SERVICE] = game:GetService(SERVICE)
	end
	-- Then we can get from this menu and libs to load
	for I, MOD in pairs(script.Parent.Parent:GetDescendants()) do
		if MOD:IsA("ModuleScript") then
			ADD_MODULE(MOD)
		end
	end
	for I, LIB in pairs(LIBS) do
		if LIB:IsA("ModuleScript") then
			ADD_MODULE(LIB)
		end
	end
	-- Load the modules
	for NAME_MOD, LOAD_MOD in pairs(MODULES_LOAD) do
		if LOAD_MOD["LOAD"] then
			-- Actually load this module now
			local MODULE_INFO = {
				["MODULES"] = MODULES_LOAD,
				["SERVICES"] = GOT_SERVICES,
			}
			-- Get if it loaded without error, if so warn the error in the output
			local COMPLETED, ERROR = pcall(LOAD_MOD.LOAD, MODULE_INFO)
			COMPLETED_MODULES += 1
			if COMPLETED then
				warn("LOADED "..NAME_MOD.." MODULE, SUCCESS!")
			else
				warn("ERROR LOADING "..NAME_MOD.."!")
				warn(NAME_MOD.." ERROR - "..ERROR)
			end
			script.Parent.Parent.ModulesLoading.Progress.Text = "Loading Modules: "..#MODULES_LOAD/COMPLETED_MODULES.."/100%"
		end
	end
	wait(.015)
	warn("LOADED MODULES IN "..tick()-LOADED_START_TICK.."s!")
	script.Parent.Parent.ModulesLoading.Progress.Text = "Loading Completed!"
	wait(.75)
	FadeAnim(script.Parent.Parent.ModulesLoading, 1, .3)
	FadeAnim(script.Parent.Parent.ModulesLoading.TopBlock, 1, .3)
	TextFadeAnim(script.Parent.Parent.ModulesLoading.Progress, 1, .3)
	wait(.305)
	script.Parent.Parent.ModulesLoading.Visible = false
end
MODULE_LOAD()
