local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local PlacementMenu = MODULES["PlacementMenu"]
	local PlacementLib = MODULES["PlacementLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local PLR_PLOT = Plr.SetPlot.Value
	-- Variables
		-- Arrays
	local CURRENT_PLACING = {}
		-- Booleans
	local DB = true
	module.PLACING_ITEMS = false
		-- Functions
	local PLACING = nil
	
	function module.DESTROY_PLACING()
		if PLACING == nil then
			return
		end
		for I, OLD_ITEM in pairs(CURRENT_PLACING) do
			OLD_ITEM:Destroy()
		end
		PLACING:DISABLE_PLACING()
		module.PLACING_ITEMS = false
		PLACING = nil
		PlacementMenu.UNLOAD_MENU()
	end

	function module.BEGIN_PLACING(ITEMS_PLACING, MOVING_ITEMS)
		local MOVING_ITEMS = MOVING_ITEMS or false
		module.DESTROY_PLACING()
		-- Close all menus
		for I, CLOSE_MENU in pairs(script.Parent.Parent:GetDescendants()) do	-- Close all open menus
			if CLOSE_MENU:FindFirstChild("MenuObject") then
				Main.CLOSE_MENU(CLOSE_MENU)
			end
		end
		PLACING = PlacementLib.new(PLR_PLOT.BasePlot, PLR_PLOT.PlacedItems)
		PLACING:ENABLE_PLACING(ITEMS_PLACING, MOVING_ITEMS)
		for I, ITEM in pairs(ITEMS_PLACING) do
			for O, THING in pairs(ITEM:GetDescendants()) do
				if THING:IsA("BasePart") then
					if THING.Transparency < .4 then
						THING.Transparency = .4
					end
					THING.Color = Color3.fromRGB(181, 226, 255)
					THING.Anchored = true
					THING.CanCollide = false
				end
				if O%50 == 0 then
					wait()
				end
			end
			ITEM.Hitbox.Color = Color3.fromRGB(151, 179, 255)
			ITEM.Hitbox.Transparency = .65
			ITEM.Parent = PLR_PLOT.PlacingItems
		end
		CURRENT_PLACING = ITEMS_PLACING
		module.PLACING_ITEMS = true
		PlacementMenu.LOAD_MENU()
		return true
	end

	function module.PLACE_ITEM()
		if module.PLACING_ITEMS and not PlacementLib.COLLIDING_ITEMS(PLR_PLOT.PlacedItems) then
			-- Create a local backup of how CURRENT_PLACING currently is and load the items info
			local PLACING_BACKUP = PLR_PLOT.PlacingItems:GetChildren()
			local PLACING_ITEMS_INFO = {}
			for I, ITEM_PLACED in pairs(PLACING_BACKUP) do
				local ITEM_POS = ITEM_PLACED.PrimaryPart.CFrame
				if PlacementLib.ANIMATED_PLACEMENT then
					ITEM_POS = ITEM_PLACED.Snapbox.CFrame
				end
				PLACING_ITEMS_INFO[#PLACING_ITEMS_INFO+1] = {
					["ITEM_LOCATION"] = ITEM_POS,
					["ITEM_NAME"] = ITEM_PLACED.Name,
				}
			end
			-- Place the items!
			local PLACED_ITEMS_DONE = RepStorage.Events.PlaceItem:InvokeServer(PLR_PLOT.PlacedItems, PLACING_ITEMS_INFO)
			if PLACED_ITEMS_DONE then
				warn("ITEMS PLACED SUCCESS!")
				return true
			else
				warn("ITEMS PLACED FAILED!")
			end
		end
		return false
	end
end

return module
