local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local CASH_LIB = MODULES["CashLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Tables
	local one_time_handle = {}
		-- Booleans
	local DB = true
		-- Strings
	local CURRENT_TAB = "NO_TAB_ACTIVE_SETUP_TODO"

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Main.CLOSE_MENU(script.Parent)
	end)

	local function toggle_handle(setting_name, toggle_obj)
		local real_setting = Plr.Settings:FindFirstChild(setting_name)
		if real_setting ~= nil then
			-- Rendering of correct active/inactive status.
			real_setting.Changed:Connect(function()
				toggle_obj.ToggleInactive.Visible = not real_setting.Value
				toggle_obj.ToggleActive.Visible = real_setting.Value
			end)
			toggle_obj.ToggleInactive.Visible = not real_setting.Value
			toggle_obj.ToggleActive.Visible = real_setting.Value
			-- Button Clicking
			toggle_obj.ToggleActive.MouseButton1Click:Connect(function()
				RepStorage.Events.UpdateToggle:InvokeServer(setting_name)
			end)
			toggle_obj.ToggleInactive.MouseButton1Click:Connect(function()
				RepStorage.Events.UpdateToggle:InvokeServer(setting_name)
			end)
		else
			warn(setting_name.." doesn't exist for "..Plr.Name.." so it's either failed to load or not been implemented!")
		end
	end

	local function LOAD_PAGE_FUNCTIONS(PAGE)
		if PAGE.Name == "Rebirth" then
			local function GET_INFO_REBIRTH()
				local COST = CASH_LIB.GET_REBIRTH_COST(Plr)
				PAGE.Contents.CostText.Text = "$"..CASH_LIB.SUFFIX_NUM(COST)
				PAGE.Contents.CurrentText.Text = "Rebirth: "..Plr.leaderstats.Rebirths.Value
			end
			GET_INFO_REBIRTH()
			Plr.Rebirth.Changed:Connect(GET_INFO_REBIRTH)
			Plr.leaderstats.Rebirths.Changed:Connect(GET_INFO_REBIRTH)
			PAGE.Contents.Rebirth.MouseButton1Click:Connect(function()
				if DB then
					DB = false
					local SUCCESS = RepStorage.Events.Rebirth:InvokeServer()
					if SUCCESS then
						warn("Rebirth Success!")
					end
					wait(.1)
					DB = true
				end
			end)
		elseif PAGE.Name == "PlotSettings" then
			if one_time_handle[PAGE] ~= true then
				one_time_handle[PAGE] = true
				toggle_handle("MinesActive", PAGE.MinesActive.Toggle)
			end
		else
			warn('No scripting for the page "'..PAGE.Name..'" has been done!')
		end
	end

	local function LOAD_PAGE(PAGE_NAME)
		local PAGE = Main.LOAD_PAGE(script.Parent.Contents.Pages, PAGE_NAME)
		if PAGE then
			if PAGE:FindFirstChild("NoScrolling") then
				script.Parent.Contents.Pages.CanvasSize = UDim2.new(0, 0, 0, 0)
			else
				script.Parent.Contents.Pages.CanvasSize = UDim2.new(0, 0, 0, PAGE.UIListLayout.AbsoluteContentSize.Y+25)
			end
			LOAD_PAGE_FUNCTIONS(PAGE)
			CURRENT_TAB = PAGE.Name
			local VISUAL_NAME = script.Parent.Contents.Sorts:FindFirstChild(PAGE_NAME).Title.Text
			script.Parent.Contents.Title.Text = VISUAL_NAME
		end
	end
	for I, SIMPLE_TAB in pairs(script.Parent.Contents.Sorts:GetChildren()) do
		if SIMPLE_TAB:IsA("TextButton") then
			SIMPLE_TAB.MouseButton1Click:Connect(function()
				LOAD_PAGE(SIMPLE_TAB.Name)
			end)
		end
	end
	script.Parent.MenuObject.Changed:Connect(function()
		if CURRENT_TAB == "NO_TAB_ACTIVE_SETUP_TODO" then
			LOAD_PAGE("SavedBots")
		end
	end)
end

return module
