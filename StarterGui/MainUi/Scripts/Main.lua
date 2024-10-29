local module = {}

function module.CLOSE_MENU()
	warn("Main.CLOSE_MENU() HASN'T LOADED YET!")
end

function module.OPEN_MENU()
	warn("Main.OPEN_MENU() HASN'T LOADED YET!")
end

function module.LOAD_PAGE()
	warn("Main.LOAD_PAGE() HASN'T LOADED YET!")
end

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local RunService = SERVICES["RunService"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local ITEM_SELECTION = MODULES["ItemSelection"]
	local ITEM_HOVER = MODULES["ItemHover"]
	local PLACEMENT = MODULES["Placement"]
	local INPUT = MODULES["Input"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true

	-- Menu Opening/Closing Handling
	function module.CLOSE_MENU(MENU_OBJ)
		if script.Parent.Parent.ItemHover.ButtonHovering.Value ~= nil and script.Parent.Parent.ItemHover.ButtonHovering.Value:IsDescendantOf(MENU_OBJ) then
			script.Parent.Parent.ItemHover.Visible = false
		end
		local MENU_OPENED = script.Parent.Parent.Values.OpenedMenus:FindFirstChild(MENU_OBJ.Name)
		if MENU_OPENED then
			MENU_OPENED:Destroy()
			MENU_OBJ.Visible = false
			MENU_OBJ.MenuObject.Value = false
		end
	end

	for I, CLOSE_MENU in pairs(script.Parent.Parent:GetDescendants()) do	-- Close all open menus
		if CLOSE_MENU:FindFirstChild("MenuObject") then
			CLOSE_MENU.MenuObject.Value = false
			CLOSE_MENU.Visible = false
		end
	end

	function module.OPEN_MENU(MENU_OBJ)
		ITEM_SELECTION.UNSELECT_ITEMS()		-- Wipe the selected items before anything.
		local MENU_OPENED = script.Parent.Parent.Values.OpenedMenus:FindFirstChild(MENU_OBJ.Name)
		if MENU_OPENED then
			module.CLOSE_MENU(MENU_OBJ)
		else
			for I, OPENED in pairs(script.Parent.Parent.Values.OpenedMenus:GetChildren()) do
				if OPENED.Name == "Inv" and MENU_OBJ.Name == "Shop" then
					-- Do Nothing
				elseif OPENED.Name == "Shop" and MENU_OBJ.Name == "Inv" then
					-- Do Nothing
				else
					module.CLOSE_MENU(OPENED.Value)
				end
			end
			local OPENED_TAG = Instance.new("ObjectValue", script.Parent.Parent.Values.OpenedMenus)
			OPENED_TAG.Name = MENU_OBJ.Name
			OPENED_TAG.Value = MENU_OBJ
			MENU_OBJ.MenuObject.Value = true
			MENU_OBJ.Visible = true
		end
	end

	function module.LOAD_PAGE(PAGES, PAGE_NAME)
		local REAL_PAGE = nil
		for I, PAGE in pairs(PAGES:GetChildren()) do
			if PAGE:IsA("Frame") then
				if PAGE.Name == PAGE_NAME then
					PAGE.Visible = true
					REAL_PAGE = PAGE
				else
					PAGE.Visible = false
				end
			end
		end
		if REAL_PAGE == nil then
			warn(PAGE_NAME.." DOESN'T EXIST!")
		end
		return REAL_PAGE
	end

	-- Frame Update Stuff
	RunService.RenderStepped:Connect(function()
		-- Process pretty much all the Frame-Update stuff here for performance reasons.
		ITEM_HOVER.UPDATE_HOVER()
		ITEM_SELECTION.ITEM_DETECT()
		if INPUT.MOUSE_DOWN then
			if PLACEMENT.PLACING_ITEMS  then
				if DB then
					DB = false
					PLACEMENT.PLACE_ITEM()
					wait(.05)
					DB = true
				end
			end
		end
	end)
end

return module
