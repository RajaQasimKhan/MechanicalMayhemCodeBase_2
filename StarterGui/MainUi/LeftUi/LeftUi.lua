local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local PlacementLib = MODULES["PlacementLib"]
	local PLACEMENT = MODULES["Placement"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local PLR_PLOT = Plr.SetPlot.Value
	-- Variables
		-- Booleans
	local DB = true
		-- Functions
	local PLACING = nil

	for I, BUTTON in pairs(script.Parent.PlotButtons:GetChildren()) do
		if BUTTON:IsA("TextButton") then
			BUTTON.MouseButton1Click:Connect(function()
				local MENU = script.Parent.Parent:FindFirstChild(BUTTON.Name)
				if MENU then
					Main.OPEN_MENU(MENU)
				else
					warn(BUTTON.Name.." HASN'T BEEN CREATED YET/DOESN'T EXIST!")
				end
			end)
			if BUTTON:FindFirstChild("Hover") then
				BUTTON.MouseEnter:Connect(function()
					BUTTON.Hover.Visible = true
				end)
				BUTTON.MouseLeave:Connect(function()
					BUTTON.Hover.Visible = false
				end)
				BUTTON.Hover.Visible = false
			end
		end
	end
end

return module
