local Globals = require(script.Parent.Globals)
local BotHandler = require(game:GetService("ReplicatedStorage").Modules.BotHandler)

local module = {}

function module.NUMBER()
	local obj = {
		["Val"] = 0,
		["Type"] = "NUMBER"
	}
	
	function obj.new(v)
		v = v[1]
		if typeof(v) ~= "number" then
			return {false, "1x40"}
		end
		obj.Val = v
		return {true, obj}
	end

	return {true, obj}
end

function module.TO_NUMBER(value)
	value = value[1]
	if typeof(value) == "boolean" then
		if value then
			return {true, 1}
		else
			return {true, 0}
		end
	elseif typeof(value) == "string" then
		if tonumber(value) then
			return {true, tonumber(value)}
		else
			return {false, "1x42"}
		end
	elseif typeof(value) == "number" then
		return value
	end
	return {false, "1x41"}
end

function module.EVAL(p)
	local v1 = p[1]
	local v2 = p[3]
	local op = p[2]

	print(v1, op, v2)
	
	if typeof(v1) ~= "number" and typeof(v2) ~= "number" then
		return {false, "1x40"}
	end

	if v1 and v2 and op then
		--[[if Globals.Globals[v1] and Globals.Globals[v2] then
			if Globals.Globals[v1].Type == Globals.Globals[v2].Type then]]
		if op == "+" then
			return {true, v1 + v2}
		elseif op == "-" then
			return {true, v1 - v2}
		elseif op == "/" then
			return {true, v1 / v2}
		elseif op == "*" then
			return {true, v1 * v2}
		elseif op == "%" then
			return {true, v1 % v2}
		elseif op == "//" then
			return {true, v1 // v2}
		elseif op == "^" then
			return {true, v1 ^ v2}
		else
			return {false, "3x32"}
		end
			--[[else
				return {false, "1x40"}
			end]]
		--[[else
			return {false, "2x19"}
		end]]
	else
		return {false, "1x41"}
	end
end

function module.STRING()
	local obj = {
		["Val"] = "",
		["Type"] = "STRING"
	}
	
	function obj.LENGTH()
		print(obj.Val)
		local success, response = pcall(function()
			return obj.Val:len()
		end)
		if success then
			return {success, response}
		else
			return {success, "1x40"}
		end
	end
	
	function obj.SUB_STRING(p)
		local st = tonumber(p[1])
		local n = tonumber(p[2])
		warn(st, n)
		if st <= 0 or n <= 0 then
			return {false, "1x37"}
		end
		if not obj.LENGTH()[1] then return {false, "0x00"} end
		if obj.LENGTH()[2] <= 0 then
			return {false, "1x39"}
		end
		if obj.LENGTH()[2] < (st+n-1) then
			return {false, "1x38"}
		end
		local success, response = pcall(function()
			return obj.Val:sub(st, st+n-1)
		end)
		return {success, response}
	end
	
	function obj.SPLIT(s)
		s = s[1]
		print(s)
		if typeof(s) ~= "string" then
			return {false, "1x40"}
		end
		local success, response = pcall(function()
			local split = obj.Val:split(s)
			return {true, split}
		end)
		return response
	end
	
	function obj.LOWER(s)
		s = s[1]
		if typeof(s) ~= "string" then
			return {false, "1x40"}
		end
		return {true, s:lower()}
	end
	
	function obj.UPPER(s)
		s = s[1]
		if typeof(s) ~= "string" then
			return {false, "1x40"}
		end
		return {true, s:upper()}
	end
	
	function obj.new(v)
		v = v[1]
		if typeof(v) ~= "string" then
			return {false, "1x40"}
		end
		obj.Val = v
		return {true, obj}
	end
	
	return {true, obj}
end

function module.TO_STRING(value)
	value = value[1]
	if typeof(value) == "boolean" then
		if value then
			return {true, "TRUE"}
		else
			return {true, "FALSE"}
		end
	elseif typeof(value) == "string" then
		return {true, value}
	elseif typeof(value) == "number" then
		return {true, tostring(value)}
	end
	return {false, "1x41"}
end

function module.JOIN_STRINGS(v)
	local s1, s2 = v[1], v[2]
	if not(s1 and s2) then
		return {false, "1x41"}
	elseif typeof(s1) ~= "string" or typeof(s2) ~= "string" then
		return {false, "1x40"}
	end
	return {true, s1..s2}
end

function module.BOOLEAN()
	local obj = {
		["Val"] = false,
		["Type"] = "BOOLEAN"
	}
	
	function obj.new(v)
		v = v[1]
		if typeof(v) ~= "boolean" then
			return {false, "1x40"}
		end
		obj.Val = v
		return {true, obj}
	end
	return {true, obj}
end

function module.TO_BOOLEAN(value)
	value = value[1]
	if typeof(value) == "boolean" then
		return {true, value}
	elseif typeof(value) == "string" then
		if value == "TRUE" then
			return {true, true}
		elseif value == "FALSE" then
			return {true, false}
		else
			return {false, "1x36"}
		end
	elseif typeof(value) == "number" then
		return {true, tostring(value)}
	end
	return {false, "1x41"}
end

function module.COMPARE(p)
	local v1 = p[1]
	local v2 = p[3]
	local op = p[2]
	
	print(v1, op, v2)
	
	if v1 and v2 and op then
		--[[if Globals.Globals[v1] and Globals.Globals[v2] then
			if Globals.Globals[v1].Type == Globals.Globals[v2].Type then]]
				if op == ">" then
					return {true, v1 > v2}
				elseif op == "<>" then
					return {true, v1 ~= v2}
				elseif op == "<" then
					return {true, v1 < v2}
				elseif op == "<=" then
					return {true, v1 <= v2}
				elseif op == ">=" then
					return {true, v1 >= v2}
				elseif op == "=" then
					return {true, v1 == v2}
				elseif op == "AND" then
					return {true, v1 and v2}
				elseif op == "OR" then
					return {true, v1 or v2}
				elseif op == "XOR" then
					local res = (not v1 and v2) or (v1 and not v2)				
					return {true, res}
				else
					return {false, "3x32"}
				end
			--[[else
				return {false, "1x40"}
			end]]
		--[[else
			return {false, "2x19"}
		end]]
	else
		return {false, "1x41"}
	end
end

function module.NOT(val)
	local v1 = val[1]
	print(v1)
	
	if typeof(v1) == "boolean" then
		return {true, not v1}
	end
	return {false, "1x40"}
end

function module.VECTOR3()
	local obj = {
		["Val"] = Vector3.new(0,0,0),
		["Type"] = "VECTOR3"
	}
	
	function obj.X()
		return {true, obj.Val.X}
	end
	
	function obj.Y()
		return {true, obj.Val.Y}
	end
	
	function obj.Z()
		return {true, obj.Val.Z}
	end
	
	function obj.Magnitude()
		return {true, obj.Val.Magnitude}
	end
	
	function obj.Unit()
		return {true, obj.Val.Unit}
	end
	
	function obj.new(p)
		local x, y, z = p[1], p[2], p[3]
		if typeof(x) ~= "number" or typeof(y) ~= "number" or typeof(z) ~= "number" then
			return {false, "1x40"}
		end
		obj.Val = Vector3.new(x, y, z)
		return {true, obj}
	end
	
	return {true, obj}
end

function module.VECTOR2()
	local obj = {
		["Val"] = Vector2.new(0,0),
		["Type"] = "VECTOR2"
	}
	
	function obj.X()
		return {true, obj.Val.X}
	end

	function obj.Y()
		return {true, obj.Val.Y}
	end

	function obj.Magnitude()
		return {true, obj.Val.Magnitude}
	end

	function obj.Unit()
		return {true, obj.Val.Unit}
	end

	function obj.new(p)
		local x, y = p[1], p[2]
		if typeof(x) ~= "number" or typeof(y) ~= "number" then
			return {false, "1x40"}
		end
		obj.Val = Vector2.new(x, y)
		return {true, obj}
	end
	return {true, obj}
end

function module.LOOKAT(p)
	--Returns a Vector3 that points from v1 to v2
	local v1 = p[1]
	local v2 = p[2]
	if (typeof(v1) == "Vector3" or typeof(v1) == "Vector2") and (typeof(v2) == "Vector3" or typeof(v2) == "Vector2") then
		return {true, (v2.Unit - v1.Unit)}
	else
		return {false, "1x40"}
	end
end

function module.RotationVector(p)
	--Returns the Vector corresponding to the rotation in radians required for v1 to have the same direction as v2
	local v1 = p[1]
	local v2 = p[2]
	if (typeof(v1) == "Vector3" and typeof(v2) == "Vector3") then
		local delta:Vector3 = (v2 - v1).Unit
		local rotation = Vector3.new()
		return {true, }
	else
		return {false, "1x40"}
	end
end

function module.COLOR3()
	local obj = {
		["Val"] = Color3.fromRGB(0, 0, 0),
		["Type"] = "COLOR3"
	}
	
	function obj.R()
		return {true, obj.Val.R}
	end
	
	function obj.G()
		return {true, obj.Val.G}
	end
	
	function obj.B()
		return {true, obj.Val.B}
	end
	
	function obj.new(p)
		local r, g, b = p[1], p[2], p[3]
		if typeof(r) ~= "number" or typeof(g) ~= "number" or typeof(b) ~= "number" then
			return {false, "1x40"}
		end
		if r > 255 or g > 255 or b > 255 or r < 0 or g < 0 or b < 0 then
			return {false, "1x35"}
		end
		obj.Val = Color3.fromRGB(r, g, b)
		return {true, obj}
	end
	
	return {true, obj}
end

function module.TABLE()
	local obj = {
		["Val"] = {},
		["Type"] = "TABLE"
	}
	
	function obj.LENGTH()
		return {true, #obj.Val}
	end
	
	function obj.FIND(val)
		val = val[1]
		for i, v in pairs(obj.Val) do
			if v == val then
				return {true, i}
			end
		end
		return {true, nil}
	end
	
	function obj.REMOVE(index)
		index = index[1]
		if typeof(index) ~= "number" and typeof(index) ~= "string" then
			return {false, "1x40"}
		end
		if obj.Val[index] then
			table.remove(obj.Val, index)
			return {true, obj}
		end
		return {false, "1x34"}
	end
	
	function obj.new(v)
		v = v[1]
		if typeof(v) == "table" then
			obj.Val = v
			return {true, obj}
		else
			return {false, "1x40"}
		end
	end
	
	function obj.INTERPRETER_ONLY_new(v)
		if typeof(v) == "table" then
			obj.Val = v
			return {true, obj}
		else
			return {false, "1x40"}
		end
	end
	
	function obj.GET(v)
		local i = v[1]
		if typeof(i) == "string" or typeof(i) == "number" then
			return {true, obj.Val[i]}
		end
	end
	
	function obj.SET(v)
		local i = v[1]
		local val = v[2]
		if typeof(i) == "string" or typeof(i) == "number" then
			obj.Val[i] = val
			return {true, nil}
		end
	end
	
	return {true, obj}
end

function module.Interpreter()
	local obj = {}
	
	function obj.POSITION()
		return {true, {Val = script.Parent.Line.Value}}
	end
	
	return {true, obj}
end

function module.Math()
	local obj = {}
	
	function obj.SIN(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.sin(value)}}
	end
	
	function obj.ASIN(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		if value < -1 or value > 1 then return {false, "4x88"} end
		return {true, {Val = math.asin(value)}}
	end
	
	function obj.COS(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.cos(value)}}
	end

	function obj.ACOS(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		if value < -1 or value > 1 then return {false, "4x88"} end
		return {true, {Val = math.acos(value)}}
	end
	
	function obj.TAN(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		if (math.abs(value) % (math.pi/2) == 0) and not (math.abs(value) % (math.pi) == 0) then return {false, "4x88"} end
		return {true, {Val = math.tan(value)}}
	end

	function obj.ATAN(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.atan(value)}}
	end
	
	function obj.ATAN_2(p)
		local v1, v2 = p[1], p[2]
		if not v1 and not v2 then return {false, "4x89"} end
		if typeof(v1) ~= "number" or typeof(v2) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.atan2(v1, v2)}}
	end
	
	function obj.DIV(p)
		local v1, v2 = p[1], p[2]
		if not v1 and not v2 then return {false, "4x89"} end
		if typeof(v1) ~= "number" or typeof(v2) ~= "number" then return {false, "1x40"} end
		return {true, {Val = v1 // v2}}
	end
	
	function obj.MOD(p)
		local v1, v2 = p[1], p[2]
		if not v1 and not v2 then return {false, "4x89"} end
		if typeof(v1) ~= "number" or typeof(v2) ~= "number" then return {false, "1x40"} end
		return {true, {Val = v1 % v2}}
	end
	
	function obj.LOG(p)
		local v1, v2 = p[1], p[2]
		if not v1 and not v2 then return {false, "4x89"} end
		if typeof(v1) ~= "number" or typeof(v2) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.log(v1, v2)}}
	end
	
	function obj.PI(p)
		return {true, {Val = math.pi}}
	end
	
	function obj.E(p)
		return {true, {Val = math.exp(1)}}
	end
	
	function obj.RAND(p)
		local v1, v2 = p[1], p[2]
		if not v1 and not v2 then return {false, "4x89"} end
		if typeof(v1) ~= "number" or typeof(v2) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.random(v1, v2)}}
	end
	
	function obj.RAD(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.rad(value)}}
	end
	
	function obj.DEG(p)
		local value = p[1]
		if not value then return {false, "4x89"} end
		if typeof(value) ~= "number" then return {false, "1x40"} end
		return {true, {Val = math.deg(value)}}
	end
	
	return {true, obj}
end

function module.Pathfinder()
	local obj = {}
	
end

function module.LABEL(p)
	local v = p[1]
	print(p)
	if typeof(v) == "string" then
		print(FindComment(v))
		if FindComment(v) then
			return {true, FindComment(v)}
		else
			return {false, "4x87"}
		end
	else
		return {false, "1x40"}
	end
end

function FindComment(c)
	local txt = script.Parent.Parent.Editor.ScrollingFrame.TextBox.Text:split("\n")
	for i, line in pairs(txt) do
		if line:sub(1, 1) == "#" then
			if line == c then
				return i
			end
		end
	end
	return nil
end

function module.Bot()
	print("Creating Bot For Player")
	local bot = BotHandler.CreateBotForScripting(game.Players.LocalPlayer)
	
	local obj = {}
	function obj.Set(Params) -- D-# ports
		print(Params)
		local PortId = Params[1]
		if typeof(PortId) ~= "string" then
			return {false, "4x90"}
		end
		local newState = Params[2] -- 0 or 1
		if typeof(newState) ~= "number" then
			return {false, "4x90"}
		end
		if PortId:split("-")[1] ~= "D" then
			return {false, "9999x15"}
		end
		if newState == 0 or newState == 1 then
			bot.SET(PortId, newState)
			return {true, nil}
		else
			return {false, "9999x15"}
		end
		
	end
	
	function obj.SetTo(Params) -- VD-# ports
		local PortId = Params[1]
		if typeof(PortId) ~= "string" then
			return {false, "4x90"}
		end
		local newState = Params[2] -- 0 or 1
		if typeof(newState) ~= "number" then
			return {false, "4x90"}
		end
		if PortId:split("-")[1] ~= "D" then
			return {false, "9999x15"}
		end
		if newState >= -1 and newState <= 1 then
			bot.SET(PortId, newState)
			return {true, nil}
		else
			return {false, "9999x15"}
		end
	end
	
	function obj.ReadGyro(Params) -- A-# ports
		local PortId = Params[1]
		if typeof(PortId) ~= "string" then
			return {false, "4x90"}
		end
		if PortId:split("-")[1] ~= "A" then
			return {false, "9999x15"}
		end
		local success, response = pcall(function()
			return bot.GET_GYRO(PortId)
		end)
		if success then
			return {success, {Val = response}}
		else
			return {false, "9999x15"}
		end
	end
	return {true, obj}
end


return module
