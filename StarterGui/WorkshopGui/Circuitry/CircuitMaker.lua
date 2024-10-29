local module = {}

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
module.Plot = nil
module.Plane = nil

local Components = {

}

local WireMap = {

}

local LineMap = {

}

--[[local Inventory = {
	{"D17 Board", "Board1"},
	{"Small DC Motor", "Motor1"}
}]]

local PinBank = {
	"GND",
	"positive",
	"POW",
	"negative",
	"D",
	"VD",
	"A",
	"UGND",
	"UPOW",
	"ADS"
}

module.SelectedObject = nil

--[[function searchInvByName(name:string)
	for i, item in pairs(Inventory) do
		if item[1] == name then
			return i
		end
	end
end

function searchInvByIdentifier(id:string)
	for i, item in pairs(Inventory) do
		if item[2] == id then
			return i
		end
	end
end

function searchInvByItem(item)
	for i, item2 in pairs(Inventory) do
		if item2 == item then
			return i
		end
	end
end]]

function module.searchCompByName(name:string)
	for i, item in pairs(Components) do
		if item[1] == name then
			return i
		end
	end
end

function module.searchCompByIdentifier(id:string)
	for i, item in pairs(Components) do
		if item[2] == id then
			return i
		end
	end
end

function module.searchCompByItem(item)
	print(Components)
	for i, item2 in pairs(Components) do
		if item[1] == item2[1].."--"..item2[2] then
			return i
		end
	end
end

function module.getType(item)
	local name = item[1]
	print(name)
	if ReplicatedStorage.Boards:FindFirstChild(name) then
		return "board"
	elseif ReplicatedStorage.Items:FindFirstChild(name) then
		return "item"
	end
end

function module.getItemModel(item)
	local model = ReplicatedStorage.ComponentModels:FindFirstChild(item[1])
	if model then
		return model
	end
end

function module.getBoardModel(item)
	local model = ReplicatedStorage.Boards:FindFirstChild(item[1])
	if model then
		return model
	end
end

function module.addComponent(item)
	local obj_type = module.getType(item)
	print(item, obj_type)
	if not obj_type then
		return
	else
		local model:Model = nil
		if obj_type == "item" then
			model = module.getItemModel(item)
		elseif obj_type == "board" then
			model = module.getBoardModel(item)
		end
		if model then
			model = model:Clone()
			if obj_type == "board" then
				model:PivotTo(CFrame.new(module.Plot.ComponentsEditing.SpawnBoardPosition.Position))
			elseif obj_type == "item" then
				model:PivotTo(CFrame.new(module.Plot.ComponentsEditing.SpawnObjectsPosition.Position))
			end
			table.insert(Components, {item[1], item[2], {(module.Plot.SavePositionOrigin.CFrame:Inverse() * model:GetPivot()):components()}})
			print(item[1], item[2])
			model.Parent = module.Plot.ComponentsEditing.Comps
			if obj_type == "item" then
				model.Model.Main.SurfaceGui.TextLabel.Text = item[2]
			elseif obj_type == "board" then
				model.Model.ModelLabel.SurfaceGui.TextLabel.Text = item[1].." - "..item[2]
			end
			model.Name = item[1].."--"..item[2]
		end
	end
end

function module.deleteObject()
	if module.SelectedObject then
		local pos = module.findWireInMap(module.SelectedObject[2].Name)
		if pos then
			table.remove(WireMap, pos)
			table.remove(LineMap, pos)
			if module.SelectedObject[1] ~= "Wire" then
				module.getPlacedObjectModel(module.SelectedObject):Destroy()
				--table.insert(Inventory, module.SelectedObject)
			else
				module.RemoveWire(module.SelectedObject[2])
				module.SelectedObject[2]:Destroy()
				module.SelectedObject = nil
			end

			module.SelectedObject = nil
		end
	end
end

function module.RemoveWire(model)
	local wire = module.findWireInMap(model.Name)
	if wire then
		WireMap[wire] = "EMPTY"
		LineMap[wire] = "EMPTY"
	end
end

function module.getWireFromPart(part)
	if part.Parent.Name == "Wire" then
		return part.Parent
	end
end

function module.getPlacedObjectModel(item)
	print(item)
	for i, obj in pairs(module.Plot.ComponentsEditing.Comps:GetChildren()) do
		if obj.Name == item[1].."--"..item[2] then
			return obj
		end
	end
end

function module.moveObject(direction)
	print(module.SelectedObject)
	if module.SelectedObject then
		if module.SelectedObject[1] == "Wire" then return end
		local pos = module.searchCompByItem(module.SelectedObject)
		print(pos)
		if pos then
			local model:Model = module.SelectedObject[2]
			if model then
				if direction == "x+" then
					local new_cf = CFrame.new(model:GetPivot().Position + Vector3.new(1, 0, 0)) * model:GetPivot().Rotation
					if not isPointInPlane(new_cf.Position, module.Plane) then
						return
					end
					model:PivotTo(new_cf)
				elseif direction == "x-" then
					local new_cf = CFrame.new(model:GetPivot().Position + Vector3.new(-1, 0, 0)) * model:GetPivot().Rotation
					if not isPointInPlane(new_cf.Position, module.Plane) then
						return
					end
					model:PivotTo(new_cf)
				elseif direction == "z+" then
					local new_cf = CFrame.new(model:GetPivot().Position + Vector3.new(0, 0, 1)) * model:GetPivot().Rotation
					if not isPointInPlane(new_cf.Position, module.Plane) then
						return
					end
					model:PivotTo(new_cf)
				elseif direction == "z-" then
					local new_cf = CFrame.new(model:GetPivot().Position + Vector3.new(0, 0, -1)) * model:GetPivot().Rotation
					if not isPointInPlane(new_cf.Position, module.Plane) then
						return
					end
					model:PivotTo(new_cf)
				end
				Components[pos][3] = {(module.Plot.SavePositionOrigin.CFrame:Inverse() * model:GetPivot()):components()}
			end
			
		end
	end
end

function module.PaintWire(color)
	if module.SelectedObject then
		local pos = module.findWireInMap(module.SelectedObject[2].Name)
		if pos then
			if module.SelectedObject[1] ~= "Wire" then
				module.getPlacedObjectModel(module.SelectedObject):Destroy()
				--table.insert(Inventory, module.SelectedObject)
			else
				WireMap[pos]["Color"] = {color.R, color.G, color.B}
				for i, v:Part in pairs(module.SelectedObject[2]:GetChildren()) do
					if v:IsA("Part") then
						v.Color = color
					end
				end
			end
		end
	end
end

function module.rotateObject(direction)
	if module.SelectedObject then
		local pos = module.searchCompByItem(module.SelectedObject)
		if pos then
			local model:Model = module.SelectedObject[2]
			if model then
				if direction == "y+" then
					local new_cf = model:GetPivot() * CFrame.Angles(0, math.rad(90), 0)
					model:PivotTo(new_cf)
				elseif direction == "y-" then
					local new_cf = model:GetPivot() * CFrame.Angles(0, math.rad(-90), 0)
					model:PivotTo(new_cf)
				end
				
				Components[pos][3] = {(module.Plot.SavePositionOrigin.CFrame:Inverse() * model:GetPivot()):components()}
			end
		end
	end
end

function module.isPort(part)
	if part.Name == "GND" then
		return true
	elseif table.find(PinBank,  part.Name:split("-")[1]) then
		return true	
	end
end

function module.createLine(pointA:Vector3, pointB:Vector3, wire)

	local vectorAB:Vector3 = pointB - pointA    -- AO + OB = AB
	local direction = vectorAB.Unit    -- m
	local magnitude = vectorAB.Magnitude    -- l
	local midpoint = pointA + vectorAB/2    --M.P

	local Line = Instance.new("Part", wire)
	Line.Anchored = true
	Line.CanCollide = false
	Line.Size = Vector3.new(0.1, 0.1, magnitude)
	Line:PivotTo(CFrame.lookAt(pointA, pointB))
	Line.Position = midpoint

	return Line
end

function module.addPartToLineMap(p1, p2, index)
	table.insert(LineMap[index], {p1, p2})
	print(LineMap)
end

function module.findWireInMap(name)
	for i, w in pairs(WireMap) do
		if w[5] == name then
			return i
		end
	end
end

function module.createWire(hostPart)
	if not module.isPort(hostPart) then return end
	local wire = Instance.new("Model", module.Plot.ComponentsEditing.Wires)
	wire.Name = "Wire-"..(#WireMap+1)
	wire:SetAttribute("Start", hostPart.Name)
	--wire:SetAttribute("End", nil)
	module.SelectedObject = {"Wire", wire}
	table.insert(WireMap, {hostPart.Name, hostPart.Parent.Parent.Name, nil, nil, wire.Name, ["Color"] = {163, 162, 165}})
	table.insert(LineMap, {})
	return wire
end

function module.setWireEndpoint(part)
	print(module.SelectedObject)
	if module.SelectedObject[1] == "Wire" then
		if module.SelectedObject[2] then
			if part.Parent.Parent.Parent.Name == "Comps" then
				if module.isPort(part) then
					module.SelectedObject[2]:SetAttribute("End", part.Name)
					local index = module.findWireInMap(module.SelectedObject[2].Name)
					if index then
						WireMap[index][3] = part.Name
						WireMap[index][4] = part.Parent.Parent.Name
						print(LineMap)
						local linePart = module.createLine(part.Position, LineMap[index][#LineMap[index]][2], module.SelectedObject[2])
						module.addPartToLineMap(LineMap[index][#LineMap[index]][2], part.Position, index)
						module.SelectedObject = nil
					end
				end
			end
		end
	end
	print("Wire Made")
end

function module.isNewComponent(itemName, itemID)
	if module.Plot.ComponentsEditing.Comps:FindFirstChild(itemName.."--"..itemID) then
		return false
	end
	return true
end

function module.selectObject(part)
	print(part.Name, part.Parent.Name, part.Parent.Parent.Name, part.Parent.Parent.Parent.Name)
	if part.Parent.Parent.Name == "Wires" then
		module.SelectedObject = {"Wire", part.Parent}
		return module.SelectedObject[2].Name
	elseif part.Parent.Parent.Parent.Name == "Comps" then
		module.SelectedObject = {part.Parent.Parent.Name, part.Parent.Parent}
		return module.SelectedObject[1]:split("--")[2]
	elseif part.Parent.Parent.Parent.Parent.Name == "Comps" then
		module.SelectedObject = {part.Parent.Parent.Parent.Name, part.Parent.Parent.Parent}
		return module.SelectedObject[1]:split("--")[2]
	
	end
end

function module.HighlightPorts()
	for i, part in pairs(module.Plot.ComponentsEditing.Comps:GetDescendants()) do
		if part:IsA("BasePart") then
			if module.isPort(part) then
				local BoundingBox = Instance.new("SelectionBox", part)
				BoundingBox.Adornee = part
				BoundingBox.LineThickness = 0.01
				BoundingBox.Color3 = Color3.fromRGB(255, 255, 0)
			end
		end
	end
end

function module.UnHighlighPorts()
	for i, part in pairs(module.Plot.ComponentsEditing.Comps:GetDescendants()) do
		if part:IsA("BasePart") then
			print(part.Name)
			if module.isPort(part) then
				if part:FindFirstChild("SelectionBox") then
					part.SelectionBox:Destroy()
				end
			end
		end
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

function fixComponentPositions()
	for i, item in pairs(Components) do
		local model = module.getPlacedObjectModel(item)
		Components[i][3] = {(module.Plot.SavePositionOrigin.CFrame:Inverse() * model:GetPivot()):components()}
	end
end

ReplicatedStorage.Events.CircuitryHandler.OnClientEvent:Connect(function(ins, data)
	local plot = module.Plot
	if not plot then return end
	if ins == "LoadBotCircuit" then
		local newModel = data[1]
		local newLineMap = data[2]
		local newWireMap = data[3]
		warn(newModel, newLineMap, newWireMap)
		for i, item in pairs(newModel) do
			warn(item)
			module.addComponent(item)
			local targetComp: Model = module.getPlacedObjectModel(item)
			if targetComp then
				-- pivot it
				targetComp:PivotTo(item[3])
				local index = module.searchCompByItem(item)
				if index then
					Components[index][3] = {(module.Plot.SavePositionOrigin.CFrame:Inverse() * targetComp:GetPivot()):components()}
				end
			end
		end
		for i, wire in pairs(newWireMap) do
			print(wire)
			local wireInQuestion = newLineMap[i]
			local targetModel1 = plot.ComponentsEditing.Comps:FindFirstChild(wire[2])
			local wireMade = false
			
			if targetModel1 then
				local hostPart = targetModel1.Model:FindFirstChild(wire[1])
				print(hostPart)
				if hostPart then
					module.createWire(hostPart, plot.ComponentsEditing.Wires)
					wireMade = true
				end
			end
			warn(wireInQuestion)
			for j, line in pairs(wireInQuestion) do
				local pos1 = line[1]
				local pos2 = line[2]
				if plot.ComponentsEditing.Wires:FindFirstChild("Wire-"..i) then
					local newLine = module.createLine(pos1, pos2, plot.ComponentsEditing.Wires:FindFirstChild("Wire-"..i))
					module.addPartToLineMap(pos1, pos2, i)
				end
			end
			
			if wireMade then
				local targetModel2 = plot.ComponentsEditing.Comps:FindFirstChild(wire[4])
				if targetModel2 then
					local endPoint = targetModel2.Model:FindFirstChild(wire[3])
					if endPoint then
						module.setWireEndpoint(endPoint)
					end
				end
			end
		end
	elseif ins == "RequestingUpdatedBotCircuit" then
		local botId = data
		ReplicatedStorage.Events.BotComms:FireServer("UpdateBotCircuit", {botId, {WireMap, Components, LineMap}})
	end
end)

--[[
addComponent({"D17 Board", "Board1"})
addComponent({"Small DC Motor", "Motor1"})

local pointA = Plot.ComponentsEditing.Comps["Small DC Motor--Motor1"].Model["+"].Position
local pointB = Vector3.new(0, 0, 0)
local pointC = Plot.ComponentsEditing.Comps["D17 Board--Board1"].Model["A-3"].Position
print(pointA, pointB, pointC)

local wire = createWire(Plot.ComponentsEditing.Comps["Small DC Motor--Motor1"].Model["+"])

local linePart = createLine(pointA, pointB, wire)
addPartToLineMap(pointA, pointB, 1)
print(LineMap)
setWireEndpoint(Plot.ComponentsEditing.Comps["D17 Board--Board1"].Model["A-3"])

print(Components)
print(LineMap)
print(WireMap)
]]

return module
