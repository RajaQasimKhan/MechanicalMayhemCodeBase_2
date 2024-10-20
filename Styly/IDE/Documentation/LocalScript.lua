local UI = script.Parent.Parent
local CloseButton = script.Parent.Close
local ScrollingFrame = script.Parent.ScrollingFrame
local Starter = ScrollingFrame.Page_Starter

function PatchUi()
	for i, v in pairs(ScrollingFrame:GetDescendants()) do
		if not v:GetAttribute("CanEditText") then
			if v:IsA("TextBox") then
				v.TextEditable = false
			end
		end
	end
end

function MakeAllUiInvisible()
	for i, frame in pairs(ScrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end
end

script.Parent.Close.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.Editor.Visible = true
end)

for i, button in pairs(Starter:GetChildren()) do
	if button:IsA("GuiButton") then
		button.MouseButton1Click:Connect(function()
			MakeAllUiInvisible()
			ScrollingFrame:FindFirstChild(button.Name).Visible = true
			ScrollingFrame:FindFirstChild(button.Name).Close.MouseButton1Click:Once(function()
				MakeAllUiInvisible()
				Starter.Visible = true
			end)
		end)
	end
end

PatchUi()