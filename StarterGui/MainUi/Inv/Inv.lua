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
	local rotationCFrame = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), rotationAngle)

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
	local MainLib = MODULES["MainLib"]
	local Main = MODULES["Main"]
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	local Mouse = Plr:GetMouse()
	-- Variables
		-- Booleans
	local DB = true
	-- Strings
	local CURRENT_ITEM_FILTER = "All"	
		-- Misc
	local INV

	script.Parent.Contents.Items.TemplateItem.Visible = false
	script.Parent.Contents.Top.Sorts.ExtraSorts.Visible = false

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Main.CLOSE_MENU(script.Parent)
	end)

	script.Parent.Contents.Top.Sorts.More.MouseButton1Click:Connect(function()
		script.Parent.Contents.Top.Sorts.ExtraSorts.Sorts.CanvasSize = UDim2.new(0, 0, 0, script.Parent.Contents.Top.Sorts.ExtraSorts.Sorts.UIListLayout.AbsoluteContentSize.Y+25)
		script.Parent.Contents.Top.Sorts.ExtraSorts.Visible = true
	end)

	local function GET_ORDER(ITEM, ITEM_INFO)
		local TIER_NAME, TIER_INFO = MainLib.GET_ITEM_TIER_INFO(ITEM.Name)
		if Plr.InvSort.Value == "Newest" then
			return -ITEM_INFO.ItemId
		elseif Plr.InvSort.Value == "Tier" then
			return -TIER_INFO["TIER_ID"]
		elseif Plr.InvSort.Value == "Oldest" then
			return ITEM_INFO.ItemId
		end
	end

	local function SEARCH_ITEM(ITEM_BUTTON, ITEM_INFO)
		-- Do the clear button checks for if it should show or not
		if string.len(script.Parent.Contents.Top.SearchBar.Text) > 0 then
			script.Parent.Contents.Top.SearchBar.Clear.Visible = true
		else
			script.Parent.Contents.Top.SearchBar.Clear.Visible = false
		end
		-- Now check if the player has the item.
		if INV[ITEM_BUTTON:GetAttribute("ITEM_ID")].Amount > 0 then
			local CAN_SHOW = true
			-- The player does, now can it show?
			if string.len(script.Parent.Contents.Top.SearchBar.Text) > 0 then
				if not string.find(string.lower(ITEM_BUTTON:GetAttribute("ITEM_NAME")), string.lower(script.Parent.Contents.Top.SearchBar.Text)) then
					CAN_SHOW = false
				end
			end
			if CURRENT_ITEM_FILTER ~= "All" and CAN_SHOW == true then
				CAN_SHOW = ITEM_INFO.TabItem == CURRENT_ITEM_FILTER
			end
			return CAN_SHOW
		end
		return false
	end

	local function LOAD_INV()
		INV = RepStorage.Events.GetInventoryType:InvokeServer("Items")
		for I, ITEM in pairs(RepStorage.Items:GetChildren()) do
			local ITEM_INFO = require(ITEM.ItemStats)
			local ITEM_BUTTON = script.Parent.Contents.Items:FindFirstChild("Item"..ITEM_INFO.ItemId)
			if ITEM_BUTTON == nil then
				ITEM_BUTTON = script.Parent.Contents.Items.TemplateItem:Clone()
				ITEM_BUTTON.Name = "Item"..ITEM_INFO.ItemId
				ITEM_BUTTON.Parent = script.Parent.Contents.Items
				-- Button Handling.
				ITEM_BUTTON.MouseButton1Click:Connect(function()
					if DB then
						DB = false
						local ITEMS_PLACING = {ITEM:Clone()}
						PLACEMENT.BEGIN_PLACING(ITEMS_PLACING)
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
			ITEM_BUTTON.LayoutOrder = GET_ORDER(ITEM, ITEM_INFO)
				--ITEM_BUTTON.Image = ITEM_INFO.ThumbnailId
			
			TWEEN_MODEL(ITEM, ITEM_INFO, ITEM_BUTTON)
			
			ITEM_BUTTON:SetAttribute("ITEM_NAME", ITEM.Name)
			ITEM_BUTTON:SetAttribute("ITEM_ID", ITEM_INFO.ItemId)
			ITEM_BUTTON.ItemAmount.Text = "x"..INV[ITEM_BUTTON:GetAttribute("ITEM_ID")].Amount
			ITEM_BUTTON.Visible = SEARCH_ITEM(ITEM_BUTTON, ITEM_INFO)
		end
		script.Parent.Contents.Items.CanvasSize = UDim2.new(0, 0, 0, script.Parent.Contents.Items.UIGridLayout.AbsoluteContentSize.Y + 25)
	end
	script.Parent.MenuObject.Changed:Connect(LOAD_INV)
	RepStorage.Events.InventoryUpdate.OnClientEvent:Connect(LOAD_INV)
	script.Parent.Contents.Top.SearchBar:GetPropertyChangedSignal("Text"):Connect(LOAD_INV)
	script.Parent.Contents.Top.SearchBar.Clear.MouseButton1Click:Connect(function()
		script.Parent.Contents.Top.SearchBar.Text = ""
	end)
	for I, SORT_SIMPLE in pairs(script.Parent.Contents.Top.Sorts.Main:GetChildren()) do
		if SORT_SIMPLE:IsA("TextButton") then
			SORT_SIMPLE.MouseButton1Click:Connect(function()
				if DB then
					DB = false
					local SORT_UPDATED = RepStorage.Events.UpdateStorting:InvokeServer("InvSort", SORT_SIMPLE.Name)
					if SORT_UPDATED then
						LOAD_INV()
					end
					wait(.1)
					DB = true
				end
			end)
		end
	end
	for I, SORT_ADV in pairs(script.Parent.Contents.Top.Sorts.ExtraSorts.Sorts:GetChildren()) do
		if SORT_ADV:IsA("TextButton") then
			SORT_ADV.MouseButton1Click:Connect(function()
				if DB then
					DB = false
					script.Parent.Contents.Top.Sorts.ExtraSorts.Visible = false
					CURRENT_ITEM_FILTER = SORT_ADV.Name
					LOAD_INV()
					wait(.1)
					DB = true
				end
			end)
		end
	end
end

return module
