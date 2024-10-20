local module = {}

function module.LOAD()
	-- Services
	local InputService = game:GetService("UserInputService")
	local RepStorage = game:GetService("ReplicatedStorage")
	local Plrs = game:GetService("Players")
	-- Plr Info
	local Plr = Plrs.LocalPlayer
	-- Variables
		-- Booleans
	local DB = true
	
	local BUTTON_CONNECTION
	BUTTON_CONNECTION = script.Parent.Contents.Main.Load.MouseButton1Click:Connect(function()
		if DB then
			DB = false
			local LOADED_SLOT = RepStorage.Events.LoadData:InvokeServer()
			if LOADED_SLOT == true then
				BUTTON_CONNECTION:Disconnect()
				warn("LOADED DATA SUCCESS!")
			elseif LOADED_SLOT == false then
				warn("LOADED DATA FAILED!")
			end
			wait(.1)
			DB = true
		end
	end)
end

return module
