local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DabineMessenger")
local Inbox = script.Parent.Inbox
local SendMail = script.Parent.SendMail
local cooldown = false

function createMsg(chat, i)
	local new_frame:Frame
	if chat.SenderId ~= Player.UserId then
		new_frame = script.OtherPerson_Template:Clone()
	else
		new_frame = script.You_Template:Clone()
	end
	new_frame.Name = tostring(i)
	new_frame.Sender.Text = Players:GetNameFromUserIdAsync(chat.SenderId)
	new_frame.Subject.Text = chat.Subject
	new_frame.Msg.Text = chat.Txt
	new_frame.Parent = Inbox.ScrollingFrame
end

function scroll_and_adjust()
	Inbox.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Inbox.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y+1)
	if not Inbox.Visible or Inbox.ScrollingFrame.CanvasPosition.Y == Inbox.ScrollingFrame.AbsoluteCanvasSize.Y then
		Inbox.ScrollingFrame.CanvasPosition = Vector2.new(0, Inbox.ScrollingFrame.AbsoluteCanvasSize.Y)
	end
end

function reloadChats(data)
	for i, f:Frame in pairs(Inbox.ScrollingFrame:GetChildren()) do
		if f:IsA("Frame") then
			f:Destroy()
		end
	end
	for i, chat in pairs(data) do
		createMsg(chat, i)
	end
	scroll_and_adjust()
end

function sendMessage()
	if cooldown then return end
	cooldown = true
	if SendMail.Subject.Text ~= "" and SendMail.ScrollingFrame.TextBox.Text ~= "" then
		if SendMail.Subject.Text:len() + SendMail.ScrollingFrame.TextBox.Text:len() <= 2000 then
			local chat = {["SenderId"] = Player.UserId, ["Subject"] = SendMail.Subject.Text, ["Txt"] = SendMail.ScrollingFrame.TextBox.Text}
			Event:FireServer("send_msg", chat, nil)
			Event.OnClientEvent:Wait()
			SendMail.Subject.Text = ""
			SendMail.ScrollingFrame.TextBox.Text = ""
			createMsg(chat, tick())
			scroll_and_adjust()
			wait(3)
		else
			local orig_color = SendMail.CharCount.TextColor3
			SendMail.CharCount.TextColor3 = Color3.fromRGB(255, 0, 0)
			wait(1)
			SendMail.CharCount.TextColor3 = orig_color
		end
	end
	cooldown = false
end

script.Parent.Toggle.MouseButton1Click:Connect(function()
	if script.Parent.Window.Visible then
		script.Parent.Window.Visible = false
		Inbox.Visible = false
		SendMail.Visible = false
	else
		script.Parent.Window.Visible = true
		Inbox.Visible = false
		SendMail.Visible = false
	end
end)

script.Parent.Window.ScrollingFrame.Inbox.TextButton.MouseButton1Click:Connect(function()
	if script.Parent.Window.Visible then
		Inbox.Visible = not Inbox.Visible
		SendMail.Visible = not SendMail.Visible
	end
end)

Inbox.Close.MouseButton1Click:Connect(function()
	Inbox.Visible = false
	SendMail.Visible = false
end)

script.Parent.Window.Close.MouseButton1Click:Connect(function()
	script.Parent.Window.Visible = false
	Inbox.Visible = false
	SendMail.Visible = false
end)

SendMail.SendButton.MouseButton1Click:Connect(sendMessage)

Event.OnClientEvent:Connect(function(instruction, data)
	if instruction == "refresh" then
		reloadChats(data)
	end
end)

while wait(1) do
	Event:FireServer("get_msgs")
end