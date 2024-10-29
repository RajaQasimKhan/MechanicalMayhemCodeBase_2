while not game:GetService("Players").LocalPlayer:FindFirstChild("SetPlot") do wait() end
while game.Players.LocalPlayer.SetPlot.Value == nil do wait() end
local CircuitMaker = require(script.CircuitMaker)
CircuitMaker.Plot = game.Players.LocalPlayer.SetPlot.Value

local y = CircuitMaker.Plot.ComponentsEditing:WaitForChild("SpawnObjectsPosition").Position.Y - 0.1
local plane
local rot:Vector3 = CircuitMaker.Plot.ComponentsEditing.CamPos.Rotation

local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()

local making_wire = false
local eye_state = false
local event = nil

local mode = ""

local zoom_inc = 1
local zoom_max = 3
local zoom_min = -8
local cam_bounds = {
	["X"] = {-5, 10},
	["Z"] = {-2, 8}
}
local current_camPos = {
	["X"] = 0,
	["Z"] = 0
}
local pos_inc = 1
local current_zoom = 0


script.Parent.Confirm.MouseButton1Click:Connect(function()
	--Send data to server
end)

script.Parent.Delete.MouseButton1Click:Connect(function()
	print(CircuitMaker.SelectedObject)
	if CircuitMaker.SelectedObject and not script.IsWiring.Value then
		if CircuitMaker.SelectedObject[1] == "Wire" then
			CircuitMaker.deleteObject()
		end
	end
end)

function adjustZoom(direction)
	if not script.Parent.Parent.Visible then return end
	if current_zoom + direction <= zoom_max and current_zoom + direction >= zoom_min then
		current_zoom += direction
		local position = workspace.CurrentCamera.CFrame.Position
		position = Vector3.new(position.X, position.Y + zoom_inc * direction, position.Z)
		workspace.CurrentCamera.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
	end
end

function moveCam(direction)
	if not script.Parent.Parent.Visible then return end
	if direction == "z+" then
		if current_camPos.Z + pos_inc <= cam_bounds.Z[2] then
			current_camPos.Z += pos_inc
			local position = workspace.CurrentCamera.CFrame.Position
			position = Vector3.new(position.X, position.Y, position.Z + pos_inc)
			workspace.CurrentCamera.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
	elseif direction == "z-" then
		if current_camPos.Z - pos_inc >= cam_bounds.Z[1] then
			current_camPos.Z -= pos_inc
			local position = workspace.CurrentCamera.CFrame.Position
			position = Vector3.new(position.X, position.Y, position.Z - pos_inc)
			workspace.CurrentCamera.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
	elseif direction == "x+" then
		if current_camPos.X + pos_inc <= cam_bounds.X[2] then
			current_camPos.X += pos_inc
			local position = workspace.CurrentCamera.CFrame.Position
			position = Vector3.new(position.X + pos_inc, position.Y, position.Z)
			workspace.CurrentCamera.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
	elseif direction == "x-" then
		if current_camPos.X - pos_inc >= cam_bounds.X[1] then
			current_camPos.X -= pos_inc
			local position = workspace.CurrentCamera.CFrame.Position
			position = Vector3.new(position.X - pos_inc, position.Y, position.Z)
			workspace.CurrentCamera.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
	end
end

function toggleEyeState()
	eye_state = not eye_state
	if eye_state then
		script.Parent.PortsVisible.Off.Visible = false
		script.Parent.PortsVisible.On.Visible = true
		CircuitMaker.HighlightPorts()
	else
		script.Parent.PortsVisible.Off.Visible = true
		script.Parent.PortsVisible.On.Visible = false
		CircuitMaker.UnHighlighPorts()
	end
end

function isPointInPlane(point, plane)
	print(point, plane)
	if point.X >= plane.X[1] and point.X <= plane.X[2] then
		if point.Z >= plane.Z[1] and point.Z <= plane.Z[2] then
			return true
		end
	end
end

function createPlaneFromPart(part:Part)
	local plane = {
		["X"] = {},
		["Z"] = {}
	}
	local x1, x2, z1, z2 = (part.Position.X - part.Size.X/2), (part.Position.X + part.Size.X/2), (part.Position.Z - part.Size.Y/2), (part.Position.Z + part.Size.Y/2)
	plane.X = {x1, x2}
	plane.Z = {z1, z2}
	return plane
end

function loadObjects()
	if not script.Parent.Parent.Visible or not script.Parent.Parent.Parent.Enabled then return end
	local PlacedItems = CircuitMaker.Plot.PlacedItems
	for i, item in pairs(PlacedItems:GetChildren()) do
		local item_stats = require(item.ItemStats)
		if item_stats.ComponentType and CircuitMaker.isNewComponent(item.Name, item.ItemStats.Identifier.Value) then
			print(item.Name, item.ItemStats.Identifier.Value)
			CircuitMaker.addComponent({item.Name, item.ItemStats.Identifier.Value})
		end
	end
	local CE = CircuitMaker.Plot.ComponentsEditing
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = CE.CamPos.CFrame
	CE.CamPos.Parent = script
	CE.SpawnBoardPosition.Parent = script
	CE.SpawnObjectsPosition.Parent = script
	CE.Plane.Parent = script
end

function clearObjects()
	local Comps, Wires = CircuitMaker.Plot.ComponentsEditing.Comps, CircuitMaker.Plot.ComponentsEditing.Wires
	for i, v in pairs(Comps) do
		v:Destroy()
	end
	for i, v in pairs(Wires) do
		v:Destroy()
	end
end

function makeTempLine(pos1:Vector3, pos2:Vector3)
	local temp = Instance.new("Model", workspace)
	local part:Part = CircuitMaker.createLine(pos1, pos2, temp)
	return temp
end

function getMousePointOnPlane()
	local pos = Mouse.Hit.Position
	return Vector3.new(pos.X, y, pos.Z)
end

script.Parent.ZoomIn.MouseButton1Click:Connect(function()
	adjustZoom(-1)
end)

script.Parent.ZoomOut.MouseButton1Click:Connect(function()
	adjustZoom(1)
end)

script.Parent["x+"].MouseButton1Click:Connect(function()
	moveCam("x+")
end)
script.Parent["x-"].MouseButton1Click:Connect(function()
	moveCam("x-")
end)

script.Parent["z+"].MouseButton1Click:Connect(function()
	moveCam("z+")
end)

script.Parent["z-"].MouseButton1Click:Connect(function()
	moveCam("z-")
end)


script.Parent.PortsVisible.MouseButton1Click:Connect(function()
	warn(script.Parent.Parent.Visible)
	if not script.Parent.Parent.Visible then return end
	toggleEyeState()
end)

script.Parent.Move.MouseButton1Click:Connect(function()
	if not script.Parent.Parent.Visible then return end
	script.Parent.Parent.RotateTool.Visible = false
	script.Parent.Parent.ColorTool.Visible = false
	script.Parent.Parent.MoveTool.Visible = not script.Parent.Parent.MoveTool.Visible
	if script.Parent.Parent.MoveTool.Visible then
		mode = "move"
	else
		mode = ""
	end
	script.Parent.Mode.Text = "Mode: "..mode
end)

script.Parent.Rotate.MouseButton1Click:Connect(function()
	if not script.Parent.Parent.Visible then return end
	script.Parent.Parent.MoveTool.Visible = false
	script.Parent.Parent.ColorTool.Visible = false
	script.Parent.Parent.RotateTool.Visible = not script.Parent.Parent.RotateTool.Visible
	if script.Parent.Parent.RotateTool.Visible then
		mode = "rotate"
	else
		mode = ""
	end
	script.Parent.Mode.Text = "Mode: "..mode
end)

script.Parent.EditColor.MouseButton1Click:Connect(function()
	if not script.Parent.Parent.Visible then return end
	script.Parent.Parent.RotateTool.Visible = false
	script.Parent.Parent.MoveTool.Visible = false
	script.Parent.Parent.ColorTool.Visible = not script.Parent.Parent.ColorTool.Visible
	if script.Parent.Parent.ColorTool.Visible then
		mode = "color selection"
	else
		mode = ""
	end
	script.Parent.Mode.Text = "Mode: "..mode
end)


local deb1 = false
script.Parent.Confirm.MouseButton1Click:Connect(function()
	-- unset camera angle, and show saving screen to player
	if not deb1 then
		deb1 = true
		workspace.CurrentCamera.CameraSubject = character.Humanoid
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.CFrame = character.Head.CFrame
		
		script.Parent.Parent.Visible = false
		script.Parent.Parent.Parent.Enabled = false
		
		script.Parent.Parent.Parent.Parent.MainUi.Enabled = true
		script.Parent.Parent.Parent.Parent.Notifications.Event:Fire("Warning", "Please save all changes from the menu.", "ContentBased", 3)
		deb1 = false
	end
end)

script.Parent.Paint.MouseButton1Click:Connect(function()
	if CircuitMaker.SelectedObject and not script.IsWiring.Value then
		if CircuitMaker.SelectedObject[1] == "Wire" then
			CircuitMaker.PaintWire(script.Parent.Paint.ImageLabel.ImageColor3)
		end
	end
end)

for i, v in pairs(script.Parent.Parent.MoveTool:GetChildren()) do
	if v:IsA("GuiButton") then
		v.MouseButton1Click:Connect(function()
			if mode	== "move" and script.Parent.Parent.Visible then
				print(v.Name)
				CircuitMaker.moveObject(v.Name)
			end
		end)
	end
end

for i, v in pairs(script.Parent.Parent.RotateTool:GetChildren()) do
	if v:IsA("GuiButton") then
		v.MouseButton1Click:Connect(function()
			if mode	== "rotate" and script.Parent.Parent.Visible then
				CircuitMaker.rotateObject(v.Name)
			end
		end)
	end
end

local debounce = false
Mouse.Button1Down:Connect(function()
	if debounce then return end
	debounce = true
	if script.Parent.Parent.Visible then
		local Target = Mouse.Target
		if Target then
			if Target:IsA("BasePart") then
				if Target:IsDescendantOf(CircuitMaker.Plot) then
					if CircuitMaker.isPort(Target) and not script.IsWiring.Value then
						script.IsWiring.Value = true
						MakeWire(Target)
						debounce = false
						event = nil
					else
						local result = CircuitMaker.selectObject(Target)
						if result then
							script.Parent.Selected.Text = "Selected: "..result
						end
					end
				end
			end
		end
	end
	
	debounce = false
end)

function snapToPort(position)
	local new = Instance.new("Part", workspace)
	new.Anchored = true
	new.Transparency = 1
	new.CanCollide = true
	new.Position = position
	new.Size = Vector3.new(0.2, 0.2, 0.2)
	local touching_parts = workspace:GetPartsInPart(new)
	print(touching_parts)
	local mag_1 = 0
	local part_1 = nil
	for i, part:Part in pairs(touching_parts) do
		print(part_1, mag_1)
		if CircuitMaker.isPort(part) then
			local mag = (part.Position - position).Magnitude
			if mag < mag_1 or mag_1 == 0 then
				mag_1 = mag
				part_1 = part
			end
		end
	end
	new:Destroy()
	return part_1
end

function MakeWire(part:Part)
	local wire = CircuitMaker.createWire(part)
	local p1 = part.Position
	local p2 = getMousePointOnPlane()
	
	CircuitMaker.addPartToLineMap(p1, p1, CircuitMaker.findWireInMap(wire.Name))
	
	event = Mouse.Button1Down:Connect(function()
		local Target = Mouse.Target
		if Target and script.Parent.Parent.Visible then
			if Target:IsA("BasePart") then
				local snap = snapToPort(p2)
				print(Target, snap)
				if snap and snap ~= part then
					CircuitMaker.setWireEndpoint(Target)
					script.IsWiring.Value = false
					event:Disconnect()
				elseif isPointInPlane(p2, plane) then
					CircuitMaker.createLine(p1, p2, wire)
					CircuitMaker.addPartToLineMap(p1, p2, CircuitMaker.findWireInMap(wire.Name))
					p1 = p2
					p2 = getMousePointOnPlane()
				end
			end
		end
	end)
	
	while script.IsWiring.Value do
		local temp = makeTempLine(p1, p2)
		wait()
		temp:Destroy()
		p2 = getMousePointOnPlane()
	end
	return
end

script.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Parent.Visible then 
		loadObjects()
	end
end)

plane = createPlaneFromPart(CircuitMaker.Plot.ComponentsEditing:WaitForChild("Plane"))
CircuitMaker.Plane = plane