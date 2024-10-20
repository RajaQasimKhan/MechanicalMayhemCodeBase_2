local index = require(script.s)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local module = {}

function module.PowerMotor(motor:Model, Velocity:number)
	print(Velocity)
	local item = motor
	local item_stats = require(item.ItemStats)
	if item_stats.SpecificType == "Motor" then
		if Velocity >= item_stats.MinSpeed and Velocity <= item_stats.MaxSpeed then
			local connection = item.Model.MotorPart
			connection.HingeConstraint.AngularVelocity = Velocity
		end
	end
end

function module.PowerLight(light: Model, value: number)
	local item = light
	local item_stats = require(item.ItemStats)
	if item_stats.SpecificType == "Light" then
		local bulb: Instance = item.Model.LightPart
		local l = bulb:FindFirstChildWhichIsA("Light")
		if l then
			l.Brightness = value
		end
	end
end

function module.SetComponent(component, value: number)
	local comp: Instance = component
	
	local item = comp
	if item then
		local item_stats = require(item.ItemStats)
		print(item_stats.SpecificType)
		if item_stats.SpecificType == "Motor" then
			local CalculatedVelocity = item_stats.MaxSpeed * value
			module.PowerMotor(item, CalculatedVelocity)
			
		elseif item_stats.SpecificType == "Light" then
			local CalculatedBrightness = item_stats.MaxBrightness * math.abs(value)
			module.PowerLight(item, CalculatedBrightness)
		end
	end
end

function module.GetComponent(component, type_)
	local comp: Instance = component
	local item: Model = comp
	if item then
		local item_stats = require(item.ItemStats)
		if item_stats.SpecificType == type_ and type_ == 'gyro' then
			return item.Hitbox.Rotation
		end
	end
	return nil
end

function module.GetComponentByName(bot, compID)
	print(compID)
	local CurrentPlot = bot.plot
	print(CurrentPlot)
	if not CurrentPlot then return end
	for i, item in pairs(CurrentPlot.Deployed_Bots.Bot1:GetChildren()) do
		if item:FindFirstChild("ItemStats") then
			local itemStats = item.ItemStats
			if itemStats:FindFirstChild("Identifier") then
				print(item.Name, itemStats.Identifier.Value)
				if item.Name.."--"..itemStats.Identifier.Value == compID then
					return item
				end
			end
		end
	end
	return
end

function module.GetComponentsAtPort(bot, portName)
	local comps = {}
	local wiring = bot.CurrentBot["Circuit"]["Wiring"]
	for i, wire in pairs(wiring) do
		print(wire)
		if wire[1] == portName then
			if wire[4] then
				local compInstance = module.GetComponentByName(bot, wire[4])
				if compInstance then
					print(compInstance)
					table.insert(comps, {compInstance, wire[3]}) -- Table of {Instance, string}
				end
			end
		elseif wire[3] == portName then
			if wire[2] then
				local compInstance = module.GetComponentByName(bot, wire[2])
				if compInstance then
					print(compInstance)
					table.insert(comps, {compInstance, wire[1]}) -- Table of {Instance, string}
				end
			end
		
		end
	end
	-- returns a table containing components connected to the port
	return comps
end

function module.Set(bot, portName: string, value: number)
	print(bot, portName, value)
	if value >= -1 and value <= 1 then
		local components = module.GetComponentsAtPort(bot, portName)
		if #components > 0 then
			for i, comp in pairs(components) do
				print(comp)
				module.SetComponent(comp[1], value)
			end
		end
	end
end

function module.Get(bot, portName: string, compName: string)
	print(bot, portName, compName)
	local components = module.GetComponentsAtPort(bot, portName)
	if #components == 1 then
		local comp = components[1]
		print(comp)
		return module.GetComponent(comp[1], compName)
	end
end

function module.RequestDataFromServer(plr:Player)
	game.ReplicatedStorage.Events.ScriptingHandler:FireServer("RequestingEquippedBotData")
	local ins, data = game.ReplicatedStorage.Events.ScriptingHandler.OnClientEvent:Wait()
	return data
end

function module.CreateBotForScripting(plr)
	local bot = {}
	bot.CurrentBot = module.RequestDataFromServer(Player)
	bot.plot = plr.SetPlot.Value
	bot.SET = function(port, value)
		print(port, value)
		module.Set(bot, port, value)
	end
	bot.GET_GYRO = function(port)
		print(port)
		return module.Get(bot, port, 'gryo') or Vector3.new(0, 0, 0)
	end
	return bot
end

return module
