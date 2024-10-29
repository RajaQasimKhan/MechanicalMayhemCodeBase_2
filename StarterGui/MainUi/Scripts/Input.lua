local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local InputService = SERVICES["UserInputService"]
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local ItemSelection = MODULES["ItemSelection"]
	local PlacementLib = MODULES["PlacementLib"]
	local PLACEMENT = MODULES["Placement"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	local PLR_PLOT = Plr.SetPlot.Value
	-- Variables
		-- Booleans
	local DB = true
	module.MOUSE_DOWN = false

	InputService.InputBegan:Connect(function(KEY_INPUT, PROCESSED)
		if PROCESSED then
			return false
		end
		-- Safer Mouse Input Detection
		if KEY_INPUT.UserInputType == Enum.UserInputType.MouseButton1 then
			module.MOUSE_DOWN = true
		end
	end)

	InputService.InputEnded:Connect(function(KEY_INPUT, PROCESSED)
		if PROCESSED then
			return false
		end
		-- Safer Mouse Input Detection
		if KEY_INPUT.UserInputType == Enum.UserInputType.MouseButton1 then
			module.MOUSE_DOWN = false
		end
		-- Regular Input
		if KEY_INPUT.KeyCode == Enum.KeyCode.R then
			if PLACEMENT.PLACING_ITEMS then
				PlacementLib.rotate()
			elseif not module.SELECTING_ITEMS and ItemSelection.SELECTED_COUNT > 0 then
				ItemSelection.MOVE_ITEMS()
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.Q then
			if PLACEMENT.PLACING_ITEMS then
				PLACEMENT.DESTROY_PLACING()
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.Z then
			if not module.SELECTING_ITEMS and ItemSelection.SELECTED_COUNT > 0 then
				ItemSelection.WITHDRAW_ITEM()
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.X then
			if not module.SELECTING_ITEMS and ItemSelection.SELECTED_COUNT > 0 then
				ItemSelection.SELL_ITEMS()
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.E then
			if not PLACEMENT.PLACING_ITEMS then
				Main.OPEN_MENU(script.Parent.Parent.Inv)
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.F then
			if not PLACEMENT.PLACING_ITEMS then
				Main.OPEN_MENU(script.Parent.Parent.Shop)
			end
		elseif KEY_INPUT.KeyCode == Enum.KeyCode.C then
			if not module.SELECTING_ITEMS and ItemSelection.SELECTED_COUNT > 0 then
				ItemSelection.BUY_ITEMS()
			elseif not PLACEMENT.PLACING_ITEMS then
				Main.OPEN_MENU(script.Parent.Parent.Options)
			end
		end
	end)
end

return module
