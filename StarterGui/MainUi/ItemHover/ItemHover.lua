local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local MainLib = MODULES["MainLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Camera = workspace.CurrentCamera
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true

	script.Parent.Visible = false

	script.Parent.ButtonHovering.Changed:Connect(function()
		local BUTTON = script.Parent.ButtonHovering.Value
		if BUTTON ~= nil then
			local REAL_ITEM = RepStorage.Items:FindFirstChild(BUTTON:GetAttribute("ITEM_NAME"))
			local ITEM_INFO = require(REAL_ITEM.ItemStats)
			local TIER_NAME, TIER_INFO = MainLib.GET_ITEM_TIER_INFO(REAL_ITEM.Name)
			script.Parent.ItemTier.TextColor3 = TIER_INFO["TIER_COLOR"]
			script.Parent.ItemTier.Text = TIER_NAME
			script.Parent.ItemName.Text = REAL_ITEM.Name
			script.Parent.ItemDesc.Text = ITEM_INFO.Description
			script.Parent.ItemCreators.Text = "Creators: "
			for I, CREATOR in pairs(ITEM_INFO.Creators) do
				script.Parent.ItemCreators.Text = script.Parent.ItemCreators.Text..CREATOR
				if I > 0 and I < #ITEM_INFO.Creators then
					script.Parent.ItemCreators.Text = script.Parent.ItemCreators.Text..", "
				end
			end
			script.Parent.Visible = true
		else
			script.Parent.Visible = false
		end
	end)

	function module.UPDATE_HOVER()
		if script.Parent.Visible then
			local BUTTON_HOVER = #script.Parent.Parent.Values.OpenedMenus:GetChildren() > 0
			if not BUTTON_HOVER then
				script.Parent.Bar2.Visible = false
				script.Parent.Bar3.Visible = false
				script.Parent.ItemDesc.Visible = false
				script.Parent.ItemCreators.Visible = false
				script.Parent.Bar.Position = UDim2.new(0, 0, 0.562, 0)
				script.Parent.ItemName.Size = UDim2.new(0.923, 0, 0.522, 0)
				script.Parent.ItemTier.Size = UDim2.new(0.667, 0, 0.436, 0)
				script.Parent.ItemTier.Position = UDim2.new(0.027, 0, 0.562, 0)
				script.Parent.UISizeConstraint.MaxSize = Vector2.new(250, 50)
			else
				script.Parent.Bar2.Visible = true
				script.Parent.Bar3.Visible = true
				script.Parent.ItemDesc.Visible = true
				script.Parent.ItemCreators.Visible = true
				script.Parent.Bar.Position = UDim2.new(0, 0, 0.242, 0)
				script.Parent.ItemName.Size = UDim2.new(0.667, 0, 0.202, 0)
				script.Parent.ItemTier.Size = UDim2.new(0.667, 0, 0.14, 0)
				script.Parent.ItemTier.Position = UDim2.new(0.027, 0, 0.248, 0)
				script.Parent.UISizeConstraint.MaxSize = Vector2.new(300, 150)
			end
			local MOUSE_X = Mouse.X + 25
			local MOUSE_Y = Mouse.Y + 15
			if Mouse.X > Camera.ViewportSize.X/2 then
				MOUSE_X = Mouse.X - script.Parent.AbsoluteSize.X - 15
			end
			if Mouse.Y > Camera.ViewportSize.Y/1.3 then
				MOUSE_Y = Mouse.Y - script.Parent.AbsoluteSize.Y - 15
			end
			script.Parent.Position = UDim2.new(0, MOUSE_X, 0, MOUSE_Y)
		end
	end
end

return module
