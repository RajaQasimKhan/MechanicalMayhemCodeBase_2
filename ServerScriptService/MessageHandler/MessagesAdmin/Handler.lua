local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DabineMessenger")
local Inbox = script.Parent.Inbox
local SendMail = script.Parent.SendMail
local AdminStuff = script.Parent.AdminStuff
local cooldown = false

local connections = {}

function timeAgoConvert(seconds)
	local seconds = math.floor(seconds)
	local minutes = seconds/60
	local hours = minutes/60
	local days = hours/24
	local years = days/365.25

	days = (years - math.floor(years)) * 365.25
	hours = (days - math.floor(days)) * 24
	minutes = (hours - math.floor(hours)) * 60
	seconds = (minutes - math.floor(minutes)) * 60

	years = math.floor(years)
	days = math.floor(days)
	hours = math.floor(hours)
	minutes = math.floor(minutes)
	seconds = math.floor(seconds)

	local time_str = ""

	if years > 0 then
		time_str = time_str..tostring(years).." Years "
	end
	if days > 0 then
		time_str = time_str..tostring(days).." Days "
	end
	if hours > 0 then
		time_str = time_str..tostring(hours).." Hours "
	end
	if minutes > 0 then
		time_str = time_str..tostring(minutes).." Minutes "
	end
	if seconds > 0 then
		time_str = time_str..tostring(seconds).." Seconds "
	end
	return "Sent: "..time_str.."Ago"
end

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

function selectPlayerChat(frame:Frame)
	if not tonumber(frame.Name) then return end
	script.Parent.ConnectedUser.Value = tonumber(frame.Name)
	Event:FireServer("UpdateSelectedUser", script.Parent.ConnectedUser.Value)
	script.Parent.Inbox.MessageSource.Text = "Connected User: "..frame.UserId.Text
end

function deletePlayerChat(frame:Frame)
	
end

function reloadAdminStuff(data)
	for i, c in pairs(connections) do
		c["DEL"]:Disconnect()
		c["SEL"]:Disconnect()
	end
	connections = {}
	for i, v in pairs(AdminStuff.ScrollingFrame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	for i, v in pairs(data) do
		local UserId = i
		local new_frame = script.PlayerMessageOverview:Clone()
		new_frame.Name = tostring(UserId)
		new_frame.Subject.Text = timeAgoConvert(tick()-v)
		new_frame.Parent = AdminStuff.ScrollingFrame
		local n = Players:GetNameFromUserIdAsync(UserId)
		if n then
			new_frame.UserId.Text = n
		end
		local connection_sel = new_frame.Select.MouseButton1Click:Connect(function()
			selectPlayerChat(new_frame)
		end)
		local connection_del = new_frame.Delete.MouseButton1Click:Connect(function()
			deletePlayerChat(new_frame)
		end)
		table.insert(connections, {["SEL"] = connection_sel, ["DEL"] = connection_del})
	end
end

function sendMessage()
	if cooldown then return end
	cooldown = true
	if not Players:GetNameFromUserIdAsync(script.Parent.ConnectedUser.Value) then return end
	if SendMail.Subject.Text ~= "" and SendMail.ScrollingFrame.TextBox.Text ~= "" then
		if SendMail.Subject.Text:len() + SendMail.ScrollingFrame.TextBox.Text:len() <= 2000 then
			local chat = {["SenderId"] = Player.UserId, ["Subject"] = SendMail.Subject.Text, ["Txt"] = SendMail.ScrollingFrame.TextBox.Text}
			Event:FireServer("send_msg", chat, script.Parent.ConnectedUser.Value)
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

script.Parent.Window.ScrollingFrame.AdminStuff.TextButton.MouseButton1Click:Connect(function()
	if script.Parent.Window.Visible then
		AdminStuff.Visible = not AdminStuff.Visible
	end
end)

AdminStuff.Close.MouseButton1Click:Connect(function()
	AdminStuff.Visible = false
end)

Inbox.Close.MouseButton1Click:Connect(function()
	Inbox.Visible = false
	SendMail.Visible = false
end)

script.Parent.Window.Close.MouseButton1Click:Connect(function()
	script.Parent.Window.Visible = false
	Inbox.Visible = false
	SendMail.Visible = false
	AdminStuff.Visible = false
end)

SendMail.SendButton.MouseButton1Click:Connect(sendMessage)

Event.OnClientEvent:Connect(function(instruction, data)
	if instruction == "refresh" then
		if data[1] == script.Parent.ConnectedUser.Value then
			reloadChats(data[2])
		end
	elseif instruction == "reload_admin_stuff" then
		reloadAdminStuff(data)
	end
end)

while wait(5) do
	Event:FireServer("get_admin_stuff")
end