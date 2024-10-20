local Plot = script.Parent.Parent.Parent.Parent.Parent

local Screen = script.Parent
local Selector = Screen.Parent


local GreenPP = Selector.Green.ProximityPrompt
local BluePP = Selector.Blue.ProximityPrompt

local ColorBlue = Color3.fromRGB(4, 175, 236)
local ColorGreen = Color3.fromRGB(75, 151, 75)
local Walls = {Selector.Parent.Wall1, Selector.Parent.Wall2}

local CurrentColor = Selector.ColorSet

GreenPP.Triggered:Connect(function(plr)
	if plr.Name == Plot.Owner.Value then
		if not (CurrentColor.Value == "G") then
			CurrentColor.Value = "G"
			for i,v in ipairs(Walls) do
				v.Color = ColorGreen
			end
		end
	end
end)

BluePP.Triggered:Connect(function(plr)
	if plr.Name == Plot.Owner.Value then
		if not (CurrentColor.Value == "B") then
			CurrentColor.Value = "B"
			for i,v in ipairs(Walls) do
				v.Color = ColorBlue
			end
		end
	end
end)