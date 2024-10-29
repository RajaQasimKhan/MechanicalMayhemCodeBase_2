local module = {}

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
	
	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Main.CLOSE_MENU(script.Parent)
	end)
end

return module
