local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotifEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Notification")

local function handleTimeoutMode(object:Frame, mode:string, setting:any)
	if mode == "Timer" then
		wait(setting)
		object:Destroy()
	elseif mode == "ContentBased" then
		local character_count = object.Msg.Text:len()
		local wait_time = character_count/7.8
		wait(wait_time + setting)
		object:Destroy()
	end
end

function Main(Type:string, message:any, timeout_mode:string, timeout_setting:any, special:any)
	script.Parent.Enabled = false
	script.Parent.Enabled = true
	if Type == "Notice" then
		local new_message = script.Notice:Clone()
		new_message.Msg.Text = message
		new_message.Parent = script.Parent.Frame
		handleTimeoutMode(new_message, timeout_mode, timeout_setting)
	elseif Type == "Success" then
		local new_message = script.Success:Clone()
		new_message.Msg.Text = message
		new_message.Parent = script.Parent.Frame
		new_message.success:Play()
		handleTimeoutMode(new_message, timeout_mode, timeout_setting)
	elseif Type == "Warning" then
		local new_message = script.Warning:Clone()
		new_message.Msg.Text = message
		new_message.Parent = script.Parent.Frame
		new_message.warning:Play()
		handleTimeoutMode(new_message, timeout_mode, timeout_setting)
	elseif Type == "2ChoicePrompt" then
		warn(message, special)
		local new_message = script["2ChoicePrompt"]:Clone()
		new_message.Msg.Text = message
		new_message.Parent = script.Parent.Prompt
		new_message.warning:Play()
		local connection_yes = new_message.ChoiceYes.MouseButton1Click
		local connection_no = new_message.ChoiceNo.MouseButton1Click
		connection_yes:Once(function()
			NotifEvent:FireServer(special, "YES")
			new_message:Destroy()
		end)
		connection_no:Once(function()
			NotifEvent:FireServer(special, "NO")
			new_message:Destroy()
		end)
	elseif Type == "2ChoiceNotice" then
		warn(message, special)
		local new_message = script["2ChoiceNotice"]:Clone()
		new_message.Msg.Text = message
		new_message.Parent = script.Parent.Prompt
		new_message.warning:Play()
		local connection_yes = new_message.ChoiceYes.MouseButton1Click
		local connection_no = new_message.ChoiceNo.MouseButton1Click
		connection_yes:Once(function()
			NotifEvent:FireServer(special, "YES")
			new_message:Destroy()
		end)
		connection_no:Once(function()
			NotifEvent:FireServer(special, "NO")
			new_message:Destroy()
		end)
	end
end

NotifEvent.OnClientEvent:Connect(Main)
script.Parent.Event.Event:Connect(Main)