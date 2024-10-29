local module = {}

function module.LOAD(MODULE_INFO)
	-- Basic Needs
	local MODULES = MODULE_INFO["MODULES"]
	local SERVICES = MODULE_INFO["SERVICES"]
	-- Services
	local RepStorage = SERVICES["ReplicatedStorage"]
	local Plrs = SERVICES["Players"]
	-- Functions
	local random = Random.new()

	script.Parent.MessageTemplate.Visible = false
	function module.message_render(message_type, message_data)
		local message_type = message_type or "screen"
		local message_text, message_color = message_data["message"], message_data["message_color"] or Color3.fromRGB(255, 255, 255)
		if message_type == "screen" then
			local message_menu = script.Parent.MessageTemplate:Clone()
			message_menu.Message.TextColor3 = message_color
			message_menu.Message.Text = message_text
			message_menu.Size = UDim2.new(0, message_menu.Message.TextBounds.X, 0, message_menu.Message.TextBounds.Y)
			local X_BOUNDS = string.len(message_text)*(message_menu.Message.TextSize/1.53)
			local Y_BOUNDS = 50 --	MESSAGE_MENU.AbsoluteSize.Y
			message_menu.Size = UDim2.new(0, 0, 0, 0)
			message_menu.Visible = true
			message_menu.Parent = script.Parent
			message_menu:TweenSize(UDim2.new(0, X_BOUNDS+30, 0, Y_BOUNDS), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .85)
			wait(5)
			message_menu:TweenSize(UDim2.new(0, 0, 0, Y_BOUNDS), .3)
			wait(.3)
			message_menu:Destroy()
		elseif message_type == "visual" then
			local message_part = message_data["visual_part"]
			local message_menu = script.Parent.Parent.VisualMessage:Clone()
			message_menu.Parent = script
			message_menu.Message.Text = message_text
			message_menu.Message.TextColor3 = message_color
			local rand_offset = Vector3.new(random:NextNumber(-message_part.Size.X, message_part.Size.X), 4.5+random:NextNumber(0, message_part.Size.Y), random:NextNumber(-message_part.Size.Z, message_part.Size.Z))
			message_menu.StudsOffsetWorldSpace = rand_offset
			message_menu.Adornee = message_part
			message_menu.Enabled = true
			task.wait(message_data["message_time"] or random:NextNumber(2, 4))
			message_menu:Destroy()
		end
	end
	RepStorage.Events.MessageClient.OnClientEvent:Connect(module.message_render)
end

return module
