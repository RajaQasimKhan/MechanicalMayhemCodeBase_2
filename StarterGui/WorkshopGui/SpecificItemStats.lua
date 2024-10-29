local module = {}

local function_table1 = {}
local function_table2 = {}

local SelectedItem = nil

function_table1["Small DC Motor"] = function(item:Model, frame:Frame)
	local FieldId = frame.FIELD_ID
	local item_stats = item.ItemStats
	FieldId.ID.Text = item_stats.Identifier.Value
end

function_table2["Small DC Motor"] = function(item:Model, frame:Frame)
	if frame.Name == item.Name then
		local item_stats = item.ItemStats
		local FieldId = frame.FIELD_ID
		item_stats.Identifier.Value = FieldId.ID.Text
		game.ReplicatedStorage.Events.ItemIdentifierModification:FireServer(item, item_stats.Identifier.Value)
	end
end

function_table1["D17 Board"] = function(item:Model, frame:Frame)
	local FieldId = frame.FIELD_ID
	local item_stats = item.ItemStats
	FieldId.ID.Text = item_stats.Identifier.Value
end

function_table2["D17 Board"] = function(item:Model, frame:Frame)
	if frame.Name == item.Name then
		local item_stats = item.ItemStats
		local FieldId = frame.FIELD_ID
		item_stats.Identifier.Value = FieldId.ID.Text
		game.ReplicatedStorage.Events.ItemIdentifierModification:FireServer(item, item_stats.Identifier.Value)
	end
end

function_table1["Gyro Sensor"] = function(item:Model, frame:Frame)
	local FieldId = frame.FIELD_ID
	local item_stats = item.ItemStats
	FieldId.ID.Text = item_stats.Identifier.Value
end

function_table2["Gyro Sensor"] = function(item:Model, frame:Frame)
	if frame.Name == item.Name then
		local item_stats = item.ItemStats
		local FieldId = frame.FIELD_ID
		item_stats.Identifier.Value = FieldId.ID.Text
		game.ReplicatedStorage.Events.ItemIdentifierModification:FireServer(item, item_stats.Identifier.Value)
	end
end

function module.DisplayStats(item:Model, frame:Frame)
	if function_table1[item.Name] then
		SelectedItem = item
		function_table1[item.Name](item, frame)
	end
end

function module.SaveStats()
	if not SelectedItem then

	else
		local sf = script.Parent.Parent.Components:FindFirstChild(SelectedItem.Name)
		function_table2[SelectedItem.Name](SelectedItem, sf)
	end
end

return module
