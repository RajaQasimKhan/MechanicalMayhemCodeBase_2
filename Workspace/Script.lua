local Plot = script.Parent.Parent.Parent.Parent.Parent

local Screen = script.Parent
local Selector = Screen.Parent


local NextPP = Selector.Next.ProximityPrompt
local BackPP = Selector.Back.ProximityPrompt

local Stage = Selector.Stage

local Stages = {
	"BUILDING",
	"COMPONENTS",
	"CIRCUITS",
	"SCRIPTING",
	"DEPLOY"
}

NextPP.Triggered:Connect(function(plr)
	if Plot.Owner.Value == plr.Name then
		if Stage.Value >= #Stages then
			Stage.Value = #Stages
		else
			Stage.Value += 1
		end
		game.ReplicatedStorage.Events.StageHandler:Fire(plr, Stage.Value)
	end
end)

BackPP.Triggered:Connect(function(plr)
	if Plot.Owner.Value == plr.Name then
		if Stage.Value <= 1 then
			Stage.Value = 1
		else
			Stage.Value -= 1
		end
		game.ReplicatedStorage.Events.StageHandler:Fire(plr, Stage.Value)
	end
end)

Stage:GetPropertyChangedSignal("Value"):Connect(function()
	Screen.SurfaceGui.Stage.TextLabel.Text = tostring(Stages[Stage.Value])
end)