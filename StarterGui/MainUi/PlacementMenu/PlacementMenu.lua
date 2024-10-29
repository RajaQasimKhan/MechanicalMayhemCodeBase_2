local module = {}

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

local function PosAnim(GuiElement, PosEnd, Time)		-- Gui Pos Animation
	tween(GuiElement, {"Position"}, PosEnd, Time)
end

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true
	
	function module.LOAD_MENU()
		if not script.Parent.Visible then
			script.Parent.Position = UDim2.new(.5, 0, 1.207, 0)
		end
		script.Parent.Visible = true
		PosAnim(script.Parent, UDim2.new(.5, 0, .983, 0), .3)
	end

	function module.UNLOAD_MENU()
		if script.Parent.Visible then
			script.Parent.Position = UDim2.new(.5, 0, .983, 0)
		end
		PosAnim(script.Parent, UDim2.new(.5, 0, 1.207, 0), .3)
		wait(.3)
		script.Parent.Visible = false
	end
end

return module
