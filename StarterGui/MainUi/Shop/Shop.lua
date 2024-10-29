local module = {}

local function TWEEN_MODEL(ITEM, ITEM_INFO, ITEM_BUTTON)
	
	for i,v in pairs(ITEM_BUTTON.ViewportFrame.WorldModel:GetChildren()) do
		if v:IsA("Model") then
			v:Destroy()
		end
	end
	
	local model = ITEM:Clone()
	model.Parent = ITEM_BUTTON.ViewportFrame.WorldModel
	model:PivotTo(CFrame.new(Vector3.new(0, 0, 0)))
	model.PrimaryPart = model.Hitbox
	if not ITEM_BUTTON.ViewportFrame.WorldModel:FindFirstChild("Camera") then
		local cam = Instance.new("Camera", ITEM_BUTTON.ViewportFrame.WorldModel)
		cam.CFrame = CFrame.new(ITEM_INFO.CameraPosition, model:GetPivot().Position)
		ITEM_BUTTON.ViewportFrame.CurrentCamera = cam
	end
	
	--ITEM_BUTTON.ViewportFrame.WorldModel.Camera.CFrame.Orientation = ITEM_INFO.CameraOrientation

	-- TWEEN STUFF

	local rotationAngle = math.rad(180)-- 360 degrees in radians

	-- Get the part's current CFrame
	local originalCFrame = ITEM_BUTTON.ViewportFrame.WorldModel[ITEM.Name]:GetPivot()

	-- Create a new CFrame for rotation around Z-axis
	local rotationCFrame = CFrame.fromEulerAnglesXYZ(0, math.pi, 0)

	-- Combine the CFrames to get the final rotated CFrame
	local finalCFrame = originalCFrame * rotationCFrame

	for i,v in pairs(model.Model:GetDescendants()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			local weld = Instance.new("WeldConstraint", model.PrimaryPart)
			weld.Part1 = v
			weld.Part0 = model.PrimaryPart
			v.Anchored = false
		end
	end


	local tween = game:GetService("TweenService"):Create(ITEM_BUTTON.ViewportFrame.WorldModel[ITEM.Name].PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {CFrame = finalCFrame})
	tween:Play()
end

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Modules
	local PLACEMENT = MODULES["Placement"]
	local CASH_LIB = MODULES["CashLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true
		-- Integers
	local AMOUNT = tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.Text) or tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.PlaceholderText)
	local CURRENT_COST = 0
		-- String
	local CURRENT_TAB = "AllTab"
	local LAST_TAB
		-- Objects
	local SELECTED_ITEM

	script.Parent.Contents.SelectedFrame.Visible = false
	script.Parent.Contents.Items.TemplateItem.Visible = false

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Main.CLOSE_MENU(script.Parent)
	end)

	local function SEARCH_ITEM(ITEM_BUTTON, ITEM_INFO)
		local CAN_SHOW = true
		if string.len(script.Parent.Contents.Top.SearchBar.Text) > 0 then
			script.Parent.Contents.Top.SearchBar.Clear.Visible = true
			if not string.find(string.lower(ITEM_BUTTON:GetAttribute("ITEM_NAME")), string.lower(script.Parent.Contents.Top.SearchBar.Text)) then
				CAN_SHOW = false
			end
		else
			script.Parent.Contents.Top.SearchBar.Clear.Visible = false
			CAN_SHOW = true
		end
		if CAN_SHOW and CURRENT_TAB ~= "AllTab" then
			if CURRENT_TAB ~= ITEM_INFO.ItemType then
				CAN_SHOW = false
			end
		elseif CAN_SHOW and CURRENT_TAB == "AllTab" then
			if script.Parent.Contents.Top.Sorts:FindFirstChild(ITEM_INFO.ItemType) == nil then
				CAN_SHOW = false
			end
		end
		return CAN_SHOW
	end

	local function BUY_ITEM()
		local ITEM_INFO = require(SELECTED_ITEM.ItemStats)
		AMOUNT = tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.Text) or tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.PlaceholderText)
		local ITEM_BOUGHT = RepStorage.Events.BuyItem:InvokeServer(ITEM_INFO.ItemId, math.floor(AMOUNT))
		if ITEM_BOUGHT then
			print("Success Buy!")
		else
			print("Failed Buy!")
		end
	end

	script.Parent.Contents.SelectedFrame.Buy.MouseButton1Click:Connect(function()
		if DB then
			DB = false
			BUY_ITEM()
			wait(.1)
			DB = true
		end
	end)

	script.Parent.Contents.SelectedFrame.Cancel.MouseButton1Click:Connect(function()
		if DB then
			DB = false
			SELECTED_ITEM = nil
			script.Parent.Contents.SelectedFrame.Visible = false
			wait(.1)
			DB = true
		end
	end)
	
	local function LOAD_SHOP()
		if LAST_TAB ~= CURRENT_TAB then
			LAST_TAB = CURRENT_TAB
			SELECTED_ITEM = nil
			script.Parent.Contents.SelectedFrame.Visible = false
		end
		
		
		for I, ITEM in pairs(RepStorage.Items:GetChildren()) do
			local ITEM_INFO = require(ITEM.ItemStats)
			local ITEM_BUTTON = script.Parent.Contents.Items:FindFirstChild("Item"..ITEM_INFO.ItemId)
			if ITEM_BUTTON == nil then
				ITEM_BUTTON = script.Parent.Contents.Items.TemplateItem:Clone()
				ITEM_BUTTON.LayoutOrder = -ITEM_INFO.ItemId
				ITEM_BUTTON.Name = "Item"..ITEM_INFO.ItemId
				ITEM_BUTTON.Parent = script.Parent.Contents.Items
			end
			ITEM_BUTTON.CashNum.Text = "$"..CASH_LIB.SUFFIX_NUM(ITEM_INFO.Cost)
			ITEM_BUTTON.LayoutOrder = ITEM_INFO.Cost
			--ITEM_BUTTON.Image = ITEM_INFO.ThumbnailId
			
			TWEEN_MODEL(ITEM, ITEM_INFO, ITEM_BUTTON)
			
			ITEM_BUTTON:SetAttribute("ITEM_NAME", ITEM.Name)
			ITEM_BUTTON.Visible = SEARCH_ITEM(ITEM_BUTTON, ITEM_INFO)
			ITEM_BUTTON.MouseButton1Click:Connect(function()
				if DB then
					DB = false
					SELECTED_ITEM = ITEM
					CURRENT_COST = ITEM_INFO.Cost
					AMOUNT = tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.Text) or tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.PlaceholderText)
					TWEEN_MODEL(ITEM, ITEM_INFO, script.Parent.Contents.SelectedFrame.ItemIcon)
					script.Parent.Contents.SelectedFrame.ItemDesc.Text = ITEM_INFO.Description
					script.Parent.Contents.SelectedFrame.ItemName.Text = ITEM_BUTTON:GetAttribute("ITEM_NAME")
					script.Parent.Contents.SelectedFrame.Buy.Text = "$"..CASH_LIB.SUFFIX_NUM(ITEM_INFO.Cost*math.floor(AMOUNT))
					script.Parent.Contents.SelectedFrame.Visible = true
					wait(.1)
					DB = true
				end
			end)
			ITEM_BUTTON.MouseEnter:Connect(function()
				script.Parent.Parent.ItemHover.ButtonHovering.Value = ITEM_BUTTON
			end)
			ITEM_BUTTON.MouseLeave:Connect(function()
				if script.Parent.Parent.ItemHover.ButtonHovering.Value == ITEM_BUTTON then		-- So the hover doesn't hide if the mouse is already on a different button.
					script.Parent.Parent.ItemHover.ButtonHovering.Value = nil
				end
			end)
		end
		script.Parent.Contents.Top.Title.Text = script.Parent.Contents.Top.Sorts:FindFirstChild(CURRENT_TAB).Title.Text
		script.Parent.Contents.Items.CanvasSize = UDim2.new(0, 0, 0, script.Parent.Contents.Items.UIGridLayout.AbsoluteContentSize.Y + 25)
	end
	script.Parent.MenuObject.Changed:Connect(LOAD_SHOP)
	script.Parent.Contents.Top.SearchBar:GetPropertyChangedSignal("Text"):Connect(LOAD_SHOP)
	script.Parent.Contents.Top.SearchBar.Clear.MouseButton1Click:Connect(function()
		script.Parent.Contents.Top.SearchBar.Text = ""
	end)
	script.Parent.Contents.SelectedFrame.Amount.Amount:GetPropertyChangedSignal("Text"):Connect(function()
		AMOUNT = tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.Text) or tonumber(script.Parent.Contents.SelectedFrame.Amount.Amount.PlaceholderText)
		if AMOUNT < 1 then
			AMOUNT = 1
			script.Parent.Contents.SelectedFrame.Amount.Amount.Text = ""
		elseif AMOUNT > 99 then
			AMOUNT = 99
			script.Parent.Contents.SelectedFrame.Amount.Amount.Text = "99"
		end
		script.Parent.Contents.SelectedFrame.Buy.Text = "$"..CASH_LIB.SUFFIX_NUM(CURRENT_COST*math.floor(AMOUNT))
	end)
	for I, TAB in pairs(script.Parent.Contents.Top.Sorts:GetChildren()) do
		if TAB:IsA("TextButton") then
			TAB.MouseButton1Click:Connect(function()
				CURRENT_TAB = TAB.Name
				LOAD_SHOP()
			end)
		end
	end
end

return module
