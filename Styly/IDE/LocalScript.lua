local Modules = script.Parent["Stilys - v1"]

local Commands = require(Modules.Commands)
local ErrorHandler = require(Modules.ErrorHandler)
local Interpreter = require(Modules.Interpreter)

local RunButtonSettings = {
	["START"] = {
		Color = Color3.fromRGB(0, 170, 0),
		Text = "RUN"
	},
	["STOP"] = {
		Color = Color3.fromRGB(170, 0, 0),
		Text = "END"
	}
}

local IsRunning = false

function ClearStuff()
	for i,v in pairs(script.Parent.Editor.SideScroll:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
end

function Change()
	script.Parent.Background.Run.Text = RunButtonSettings.START.Text
	script.Parent.Background.Run.TextColor3 = RunButtonSettings.START.Color
end

function Run()
	ClearStuff()
	local StartPos = script.Parent.InterpreterSettings.ScrollingFrame.StartExecution.TextBox.Text
	print(StartPos)
	if not tonumber(StartPos) then
		ErrorHandler.CreateError("2x21", 0)
		IsRunning = false
		Change()
		return
	end
	if tonumber(StartPos) > #script.Parent.Editor.ScrollingFrame.TextBox.Text:split("\n") then
		ErrorHandler.CreateError("1x38", 0)
		IsRunning = false
		Change()
		return
	end
	if tonumber(StartPos) <= 0 then
		ErrorHandler.CreateError("1x38", 0)
		IsRunning = false
		Change()
		return
	end
	if not(math.floor(tonumber(StartPos)) == tonumber(StartPos)) then
		ErrorHandler.CreateError("4x90", 0)
		Change()
		IsRunning = false
		return
	end
	
	local ExecRate = script.Parent.InterpreterSettings.ScrollingFrame.ExecutionInterval.TextBox.Text
	print(ExecRate)
	if not tonumber(ExecRate) then
		ErrorHandler.CreateError("2x21", 0)
		IsRunning = false
		Change()
		return
	end
	if tonumber(ExecRate) <= 0 then
		ErrorHandler.CreateError("1x38", 0)
		IsRunning = false
		Change()
		return
	end
	if not(math.floor(tonumber(ExecRate)) == tonumber(ExecRate)) then
		ErrorHandler.CreateError("4x90", 0)
		Change()
		IsRunning = false
		return
	end
	ExecRate = tonumber(ExecRate)
	Interpreter.ExecRate = ExecRate
	Interpreter.State = true
	Interpreter.Run(tonumber(StartPos))
	IsRunning = false
	Interpreter.State = false
	script.Parent.Background.Run.Text = RunButtonSettings.START.Text
	script.Parent.Background.Run.TextColor3 = RunButtonSettings.START.Color
end

script.Parent.Background.Run.MouseButton1Click:Connect(function()
	if not IsRunning then
		IsRunning = true
		script.Parent.Background.Run.Text = RunButtonSettings.STOP.Text
		script.Parent.Background.Run.TextColor3 = RunButtonSettings.STOP.Color
		Run()
	else
		Interpreter.State = false
	end
end)

script.Parent.Background.InterpreterSettings.MouseButton1Click:Connect(function()
	if not IsRunning then
		script.Parent.InterpreterSettings.Visible = not script.Parent.InterpreterSettings.Visible
	end
end)

script.Parent.Background.ClearOutput.MouseButton1Click:Connect(function()
	for i,v in pairs(script.Parent.Background.Console.ScrollingFrame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	ClearStuff()
end)

script.Parent.Background.Save.MouseButton1Click:Connect(function()
	if not IsRunning then
		game.ReplicatedStorage.Events.ScriptingHandler:FireServer("SaveScriptChanges", script.Parent.Editor.ScrollingFrame.TextBox.Text)
	end
end)

script.Parent.Background.Close.MouseButton1Click:Connect(function()
	if not IsRunning then
		game.ReplicatedStorage.Events.ScriptingHandler:FireServer("SaveScriptChanges", script.Parent.Editor.ScrollingFrame.TextBox.Text)
		script.Parent.Enabled = false
		script.Parent.Parent.MainUi.Enabled = true
	end
end)

script.Parent.Background.Docs.MouseButton1Click:Connect(function()
	script.Parent.Docs.Visible = not script.Parent.Docs.Visible
end)

game.ReplicatedStorage.Events.ScriptRun.OnClientEvent:Connect(function(ins)
	if ins == "START" then
		Run()
	else
		Interpreter.State = false
	end
end)

while wait() do
	if script.Parent.InterpreterSettings.Visible then
		script.Parent.Editor.ScrollingFrame.TextBox.TextEditable = false
	else
		script.Parent.Editor.ScrollingFrame.TextBox.TextEditable = true
	end
	
	if script.Parent.Docs.Visible then
		script.Parent.Editor.Visible = false
		script.Parent.InterpreterSettings.Visible = false
	else
		script.Parent.Editor.Visible = true
	end
end