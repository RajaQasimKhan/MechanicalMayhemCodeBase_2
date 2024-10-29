local module = {}

function module.SELECT_ITEM()
	warn("ItemSelection.SELECT_ITEM() HASN'T LOADED YET!")
end

function module.ITEM_DETECT()
	warn("ItemSelection.ITEM_DETECT() HASN'T LOADED YET!")
end

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local InputService = SERVICES["UserInputService"]
	local RepStorage = SERVICES["ReplicatedStorage"]
	local RunService = SERVICES["RunService"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local ITEM_HOVER = MODULES["ItemHover"]
	local PLACEMENT = MODULES["Placement"]
	local MainLib = MODULES["MainLib"]
	local INPUT = MODULES["Input"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	local PLR_PLOT = Plr.SetPlot.Value
	-- Variables
		-- Booleans
	local DB = true
	module.SELECTING_ITEMS = false
		-- Arrays
	local SELECTED_ITEMS = {}
		-- Integers
	module.SELECTED_COUNT = 0
		-- Objects
	local CURRENT_HOVER = nil

	script.Parent.Parent.ItemSelection.Enabled = false
	script.Parent.Parent.ItemSelection.Adornee = nil

	local function UPDATE_SELECTED_INFO()
		if module.SELECTED_COUNT == 1 then
			for I, ITEM_INFO in pairs(SELECTED_ITEMS) do
				script.Parent.Parent.ItemSelection.Selected.ItemName.Text = ITEM_INFO.Name
				local TIER_NAME, TIER_INFO = MainLib.GET_ITEM_TIER_INFO(ITEM_INFO.Name)
				script.Parent.Parent.ItemSelection.Selected.ItemTier.Text = TIER_NAME
				script.Parent.Parent.ItemSelection.Selected.ItemTier.TextColor3 = TIER_INFO["TIER_COLOR"]
			end
		else
			script.Parent.Parent.ItemSelection.Selected.ItemName.Text = "Multi-Select"
			script.Parent.Parent.ItemSelection.Selected.ItemTier.TextColor3 = Color3.fromRGB(140, 140, 140)
			script.Parent.Parent.ItemSelection.Selected.ItemTier.Text = "Item Count: "..module.SELECTED_COUNT
		end
	end

	function module.SELECT_ITEM(ITEM)
		if script.Parent.Parent.Enabled == false then return end
		module.SELECTING_ITEMS = true
		script.Parent.Parent.ItemSelection.Size = UDim2.new(0, 200, 0, 60)
		for I, ITEM in pairs(SELECTED_ITEMS) do
			ITEM:SetAttribute("SELECTED", true)
			if ITEM:FindFirstChild("Hitbox") then
				ITEM.Hitbox.Transparency = .6
			end
		end
		if SELECTED_ITEMS[ITEM] ~= ITEM then
			SELECTED_ITEMS[ITEM] = ITEM
			if ITEM:FindFirstChild("Hitbox") then
				ITEM.Hitbox.Transparency = .6
				module.SELECTED_COUNT += 1
				script.Parent.Parent.ItemSelection.Enabled = true
				script.Parent.Parent.ItemSelection.Adornee = ITEM.Hitbox
			end
			UPDATE_SELECTED_INFO()
		end
		script.Parent.Parent.ItemHover.Visible = false
	end

	function module.UNSELECT_ITEMS()
		for I, ITEM in pairs(SELECTED_ITEMS) do
			ITEM:SetAttribute("SELECTED", nil)
			if ITEM:FindFirstChild("Hitbox") then
				ITEM.Hitbox.Transparency = 1
			end
			SELECTED_ITEMS[ITEM] = nil
		end
		module.SELECTED_COUNT = 0
		SELECTED_ITEMS = {}
		script.Parent.Parent.ItemSelection.Enabled = false
		script.Parent.Parent.ItemSelection.Adornee = nil
	end

	local function CLEAR_HOVER(ITEM)
		local ITEM = ITEM or nil
		local CURRENT_HOVER_BACKUP = CURRENT_HOVER
		if CURRENT_HOVER ~= ITEM then
			script.Parent.Parent.ItemHover.Visible = false
			if CURRENT_HOVER_BACKUP ~= nil and not CURRENT_HOVER_BACKUP:GetAttribute("SELECTED") then
				if CURRENT_HOVER_BACKUP:FindFirstChild("Hitbox") then
					CURRENT_HOVER_BACKUP.Hitbox.Transparency = 1
				end
				if CURRENT_HOVER == CURRENT_HOVER_BACKUP then
					CURRENT_HOVER = nil
				end
			end
		end
	end

	local function HOVER_ITEM(ITEM)
		-- Clear hovering items
		if CURRENT_HOVER ~= nil then
			CLEAR_HOVER(ITEM)
		end
		if ITEM ~= nil and SELECTED_ITEMS[ITEM] ~= ITEM then
			-- Set the item to be a item that is being hovered
			if CURRENT_HOVER ~= ITEM then
				CURRENT_HOVER = ITEM
				if ITEM:FindFirstChild("Hitbox") then
					ITEM.Hitbox.Transparency = .85
				end
			end
			ITEM_HOVER.UPDATE_HOVER()
			script.Parent.Parent.ItemHover.Visible = true
			local TIER_NAME, TIER_INFO = MainLib.GET_ITEM_TIER_INFO(ITEM.Name)
			script.Parent.Parent.ItemHover.ItemTier.TextColor3 = TIER_INFO["TIER_COLOR"]
			script.Parent.Parent.ItemHover.ItemTier.Text = TIER_NAME
			script.Parent.Parent.ItemHover.ItemName.Text = ITEM.Name
		end
	end
	
	local function FINALIZE_SELECTING()
		module.SELECTING_ITEMS = false
		if module.SELECTED_COUNT > 0 then
			script.Parent.Parent.ItemSelection.Size = UDim2.new(0, 200, 0, 300)
			script.Parent.Parent.ItemSelection.Selected.Buttons.Visible = true
			UPDATE_SELECTED_INFO()
		end
	end
	
	function module.ITEM_DETECT()
		if PLACEMENT.PLACING_ITEMS then		-- Big no no for item selection :)
			CLEAR_HOVER()
			return
		end
		if #script.Parent.Parent.Values.OpenedMenus:GetChildren() > 0 then		-- No item selection if a menu is open (Prevents bugs with the hovering of items.)
			CLEAR_HOVER()
			return
		end
		local ITEM_CAST_POINT
		if Mouse and InputService.MouseEnabled then
			ITEM_CAST_POINT = Vector2.new(Mouse.X, Mouse.Y + 36)
		else
			local CAM_SIZE = workspace.CurrentCamera.ViewportSize
			ITEM_CAST_POINT = Vector2.new(math.floor(CAM_SIZE.X/2),math.floor(CAM_SIZE.Y/3))
		end
		local CAM_RAY = workspace.CurrentCamera:ViewportPointToRay(ITEM_CAST_POINT.X, ITEM_CAST_POINT.Y)
		local SELECTION_RAY = Ray.new(CAM_RAY.Origin, CAM_RAY.Direction * 1000)
		if PLR_PLOT ~= nil then
			local ITEM_HOVERING = workspace:FindPartOnRayWithWhitelist(SELECTION_RAY, PLR_PLOT.PlacedItems:GetChildren())
			if ITEM_HOVERING and ITEM_HOVERING.Parent:FindFirstChild("ItemStats") then		-- We check for ItemStats because the hitbox part might not be called "Hitbox" for some reason or there could be a different part type that is not the Hitbox
				HOVER_ITEM(ITEM_HOVERING.Parent)
				if INPUT.MOUSE_DOWN then
					if not module.SELECTING_ITEMS then		-- Wipe previously selected items
						module.UNSELECT_ITEMS()
					end
					script.Parent.Parent.ItemSelection.Selected.Buttons.Visible = false
					module.SELECT_ITEM(ITEM_HOVERING.Parent)
				else
					FINALIZE_SELECTING()
				end
			else
				if not INPUT.MOUSE_DOWN then
					FINALIZE_SELECTING()
				elseif INPUT.MOUSE_DOWN and script.Parent.Parent.ItemSelection.Adornee ~= nil and not module.SELECTING_ITEMS then
					module.UNSELECT_ITEMS()
				end
				CLEAR_HOVER(nil)
			end
		end
	end
	

	function module.BUY_ITEMS()
		if DB then
			DB = false
			local BUYING = {}
			for I, ITEM in pairs(SELECTED_ITEMS) do
				BUYING[#BUYING+1] = require(ITEM.ItemStats).ItemId
			end
			local BUY_ITEMS = RepStorage.Events.BuyItem:InvokeServer(BUYING)
			if BUY_ITEMS then
				module.UNSELECT_ITEMS()
				SELECTED_ITEMS = {}
			end
			wait(.2)
			DB = true
		end
	end


	function module.SELL_ITEMS()
		if DB then
			DB = false
			local SELLING = {}
			for I, ITEM in pairs(SELECTED_ITEMS) do
				SELLING[#SELLING+1] = ITEM
			end
			local SELL_ITEMS = RepStorage.Events.SellItem:InvokeServer(SELLING)
			if SELL_ITEMS then
				module.UNSELECT_ITEMS()
				SELECTED_ITEMS = {}
			end
			wait(.2)
			DB = true
		end
	end

	function module.MOVE_ITEMS()
		if DB then
			DB = false
			local MOVING = {}
			for I, ITEM in pairs(SELECTED_ITEMS) do
				MOVING[#MOVING+1] = ITEM:Clone()
			end
			local PLACING_STARTED = PLACEMENT.BEGIN_PLACING(MOVING, true)
			if PLACING_STARTED then
				local WITHDRAWING = {}
				for I, ITEM in pairs(SELECTED_ITEMS) do
					WITHDRAWING[#WITHDRAWING+1] = ITEM
				end
				RepStorage.Events.WithdrawItems:InvokeServer(WITHDRAWING)
				module.UNSELECT_ITEMS()
				SELECTED_ITEMS = {}
			end
			wait(.2)
			DB = true
		end
	end

	function module.WITHDRAW_ITEM()
		if DB then
			DB = false
			local WITHDRAWING = {}
			for I, ITEM in pairs(SELECTED_ITEMS) do
				WITHDRAWING[#WITHDRAWING+1] = ITEM
			end
			local WITHDRAW_ITEMS = RepStorage.Events.WithdrawItems:InvokeServer(WITHDRAWING)
			if WITHDRAW_ITEMS then
				module.UNSELECT_ITEMS()
				SELECTED_ITEMS = {}
			end
			wait(.2)
			DB = true
		end
	end

	script.Parent.Parent.ItemSelection.Selected.Buttons.Withdraw.MouseButton1Click:Connect(function()
		module.WITHDRAW_ITEM()
	end)

	script.Parent.Parent.ItemSelection.Selected.Buttons.Move.MouseButton1Click:Connect(function()
		module.MOVE_ITEMS()
	end)
	
	script.Parent.Parent.ItemSelection.Selected.Buttons.Buy.MouseButton1Click:Connect(function()
		module.BUY_ITEMS()
	end)

	script.Parent.Parent.ItemSelection.Selected.Buttons.Sell.MouseButton1Click:Connect(function()
		module.SELL_ITEMS()
	end)
end

return module
