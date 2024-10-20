local Plot = script.Parent.Parent.Parent.Parent.Parent

local Screen = script.Parent
local Selector = Screen.Parent


local UpPP = Selector.Up.ProximityPrompt
local DownPP = Selector.Down.ProximityPrompt
local FloorNumber = Selector.Floor

local Debounce = false

UpPP.Triggered:Connect(function(plr)
	if plr.Name == Plot.Owner.Value then
		if not Debounce then
			Debounce = true
			game.ReplicatedStorage.Events.PlotFloorhandler:Fire(plr, FloorNumber.Value, 1)
			task.wait(0.2)
			Debounce = false
		end
	end
end)

DownPP.Triggered:Connect(function(plr)
	if plr.Name == Plot.Owner.Value then
		if not Debounce then
			Debounce = true
			game.ReplicatedStorage.Events.PlotFloorhandler:Fire(plr, FloorNumber.Value, -1)
			task.wait(0.5)
			Debounce = false
		end
	end
end)

FloorNumber.Changed:Connect(function()
	Screen.SurfaceGui.Count.TextLabel.Text = tostring(FloorNumber.Value)
end)