local Globals = require(script.Parent.Globals)
local Enums = require(script.Parent.Enums)
local ExpressionHandler = require(script.Parent.ExpressionHandler)
local Output = require(script.Parent["I/O_Control"])

local module = {}

module.Exec = {}

module.Commands = {}

function module.ExecuteCommand(line:string)
	local data = line:split(" ")
	if data[1] == "JUMP" or data[1] == "JUMPIF" then
		local parse = module.Commands[data[1]](line)
		local response = module.Exec[data[1]](parse)
		print(response)
		if not response then
			return {false, "0x00"}
		elseif not response[1] then
			return response
		end
		
		if response[2] == "excJMP--@INTERPRETER" or response[2] == "excJMPIF--@INTERPRETER" then
			return {response[2], response[3]}
		end
		return {false, 0x00}
	end
	if module.Commands[data[1]] then
		local parse = module.Commands[data[1]](line)
		return module.Exec[data[1]](parse)
	else
		return {false, "2x21"}
	end
end

function ClearString(s:string)
	local s, r = pcall(function()
	for i = 1, s:len() do
		local c = s:sub(i, i)
		if c == " " then
			s = s:sub(2, s:len())
		else
			break
		end
	end
	
	for i = s:len(), 1, -1 do
		local c = s:sub(i, i)
		if c == " " then
			s = s:sub(1, s:len()-1)
		else
			break
		end
	end
	
	return s
	end)
	return r
end

function getExpressionInBrackets(expression)
	local currentStartIndex = 1
	local currentEndIndex = 0
	local nestedCount = 0

	-- Loop through each character
	for i = 1, #expression do
		local char = string.sub(expression, i, i)

		-- Handle opening brackets
		if char == "{" then
			if nestedCount == 0 then
				currentStartIndex = i
			end
			nestedCount += 1
		elseif char == "}" then
			nestedCount -= 1
			if nestedCount == 0 then
				currentEndIndex = i
				break -- Exit loop once outer brackets are found
			end
		end
	end

	-- Check if brackets were found and extract expression
	if currentStartIndex > 0 and currentEndIndex > currentStartIndex then
		return string.sub(expression, currentStartIndex + 1, currentEndIndex - 1)
	else
		return nil
	end
end

local function getExpressionInSpeechMarks(text)
	-- Check if there are even any quotes
	if string.find(text, '"') == nil then
		return nil -- No quotes found, return nil
	end

	-- Find the starting and ending positions of the first quote pair
	local startPos = string.find(text, '"') + 1
	local endPos = string.find(text, '"', startPos) - 1

	-- Check if there's a closing quote
	if endPos == nil then
		return nil -- Unmatched opening quote, return nil
	end

	-- Extract the substring between quotes
	return string.sub(text, startPos, endPos)
end


--DEF
function module.Commands.DEF(line:string)
	local p1 = line:split(":")
	local TYPE, NAME = nil, nil
	TYPE = ClearString(p1[2])
	NAME = p1[1]:split(" ")
	NAME = ClearString(NAME[2])
	return {NAME, TYPE}
end

function module.Exec.DEF(data)
	if not data[1] then
		return {false, "2x20"}
	end
	if not Enums[data[2]] then
		return {false, "2x20"}
	end
	
	local success, response = pcall(function()
		return Globals.Add(data[1], Enums[data[2]]()[2])
	end)
	return {success, response}
end


--GLOBAL
function module.Commands.GLOBAL(line:string)
	local p1 = line:split(":")
	local TYPE, NAME = nil, nil
	TYPE = ClearString(p1[2])
	NAME = p1[1]:split(" ")
	NAME = ClearString(NAME[2])
	return {NAME, TYPE}
end

function module.Exec.GLOBAL(data)
	if not data[1] then
		return {false, "2x20"}
	end
	if not Enums[data[2]] then
		return {false, "2x20"}
	end

	local success, response = pcall(function()
		return Globals.Add(data[1], Enums[data[2]]()[2])
	end)
	return {success, response}
end


--ASSIGN
function module.Commands.ASSIGN(line:string)
	local p1 = line:split(":")
	local NewVal, NAME = nil, nil
	NewVal = ClearString(p1[2])
	NAME = p1[1]:split(" ")
	NAME = ClearString(NAME[2])
	return {NAME, NewVal}
end

function module.Exec.ASSIGN(data)
	print(data)
	if not data[1] then
		return {false, "2x20"}
	end
	if not data[2] then
		return {false, "2x20"}
	end
	if not Globals.Globals[data[1]] then
		return {false, "2x19"}
	end
	
	print(data)
	
	if data[2]:split("..")[2] then
		local result = module.CALL(data)
		warn(result)
		if not result then return {false, "0x00"} end
		if result[1] then
			print(Globals.Globals[data[1]])
			Globals.Globals[data[1]].Val = result[2]
			warn(Globals.Globals[data[1]].Val)
			return {true, nil}
		else
			return {false, result[2]}
		end
	elseif data[2]:split("{")[2] then
		local result = module.CALL(data)
		print(result)
		if not result then return {false, "0x00"} end
		if result[1] then
			Globals.Globals[data[1]].Val = result[2]
			return {true, nil}
		else
			return {false, result[2]}
		end
	
	end
	
	if Globals.Globals[data[1]].Type == "NUMBER" then
		local result = ExpressionHandler.Evaluate(data[2])
		print(result)
		if result[1] then
			Globals.Globals[data[1]].Val = tonumber(result[2])
			return {true, nil}
		else
			return {false, result[2]}
		end
	elseif Globals.Globals[data[1]].Type == "BOOLEAN" then
		data[2] = ClearString(data[2])
		if data[2] == "TRUE" then
			Globals.Globals[data[1]].Val = true
		elseif data[2] == "FALSE" then
			Globals.Globals[data[1]].Val = false
		else
			return {false, "2x19"}
		end
	elseif Globals.Globals[data[1]].Type == "STRING" then
		local s = data[2]
		if Globals.Globals[s] then
			if Globals.Globals[s].Type == "STRING" then
				Globals.Globals[data[1]].Val = Globals.Globals[s].Val
				return {true, nil}
			end
		end
		s = getExpressionInSpeechMarks(s)
		if not s then
			return {false, "2x20"}
		end
		Globals.Globals[data[1]].Val = s
	elseif Globals.Globals[data[1]].Type == "TABLE" then
		local s = data[2]
	
	end
	
	return {true, nil}
end


--OUTPUT
function module.Commands.OUTPUT_VAR(line:string)
	local p1 = line:split(":")
	local NAME = ClearString(p1[2])
	return {NAME}
end

function module.Exec.OUTPUT_VAR(data)
	if not data then
		return {false, "1x41"}
	end
	
	if Globals.Globals[data[1]] then
		if Globals.Globals[data[1]].Type == "NUMBER" or Globals.Globals[data[1]].Type == "STRING" then
			local s = "line-"..tostring(script.Parent.Line.Value).." : "..tostring(Globals.Globals[data[1]].Val)
			Output.MakeOutput(s, false, Color3.fromRGB(0, 0, 0))
			return {true, nil}
			
		elseif Globals.Globals[data[1]].Type == "BOOLEAN" then
			if Globals.Globals[data[1]].Val then
				local s = "line-"..tostring(script.Parent.Line.Value).." : ".."TRUE"
				Output.MakeOutput(s, false, Color3.fromRGB(0, 0, 0))
				return {true, nil}
			else
				local s = "line-"..tostring(script.Parent.Line.Value).." : ".."FALSE"
				Output.MakeOutput(s, false, Color3.fromRGB(0, 0, 0))
				return {true, nil}
			end
			
		elseif Globals.Globals[data[1]].Type == "TABLE" then
			Output.OutputTable(Globals.Globals[data[1]].Val, false, Color3.fromRGB(0, 0, 0))
			return {true, nil}
		end
		
		
	else
		print(data)
		return {false, "2x19"}
	end
end


--JUMP
function module.Commands.JUMP(line:string)
	local p1 = line:split(":")
	local LABEL = ClearString(p1[2])
	return {true, LABEL}
end

function module.Exec.JUMP(data)
	print(data)
	local n = tonumber(data[2])
	if data[2]:split("..")[2] then
		local result = module.CALL(data)
		if not result then return {false, "0x00"} end
		if result[1] then
			n = result[2]
		else
			return {false, result[2]}
		end
	elseif data[2]:split("{")[2] then
		local result = module.CALL(data)
		print(result)
		if not result then return {false, "0x00"} end
		if result[1] then
			n = result[2]
		else
			return {false, result[2]}
		end

	end

	if Globals.Globals[data[2]] then
		if Globals.Globals[data[2]].Type == "NUMBER" then
			local result = ExpressionHandler.Evaluate(data[2])
			if result[1] then
				n = tonumber(result[2])
			else
				return {false, result[2]}
			end
		end
	end
	
	if typeof(n) == "number" then
		return {true, "excJMP--@INTERPRETER", n}
	end
	return {false, "1x41"}
end


--JUMPIF
function module.Commands.JUMPIF(line:string)
	local p1 = line:split(":")
	local var_name = p1[1]:split(" ")
	if not var_name[2] then
		return {false, "2x20"}
	end
	
	var_name = ClearString(var_name[2])
	local destination = ClearString(p1[2])
	return {var_name, destination}
end

function module.Exec.JUMPIF(data)
	print(data)
	local n = tonumber(data[2])
	local condition = false
	if data[2]:split("..")[2] then
		local result = module.CALL(data)
		if not result then return {false, "0x00"} end
		if result[1] then
			n = result[2]
		else
			return {false, result[2]}
		end
	elseif data[2]:split("{")[2] then
		local result = module.CALL(data)
		print(result)
		if not result then return {false, "0x00"} end
		if result[1] then
			n = result[2]
		else
			return {false, result[2]}
		end

	end

	if Globals.Globals[data[2]] then
		if Globals.Globals[data[2]].Type == "NUMBER" then
			local result = ExpressionHandler.Evaluate(data[2])
			if result[1] then
				n = tonumber(result[2])
			else
				return {false, result[2]}
			end
		end
	end
	
	if Globals.Globals[data[1]] then
		print(Globals.Globals[data[1]])
		if Globals.Globals[data[1]].Type == "BOOLEAN" then
			if Globals.Globals[data[1]].Val then
				condition = true
			else
				condition = false
			end
		end
	end
	
	if data[1] == "TRUE" then
		condition = true
	elseif data[1] == "FALSE" then
		condition = false
	
	end
	
	print(condition, n)

	if typeof(n) == "number" and typeof(condition) == "boolean" then
		return {true, "excJMPIF--@INTERPRETER", {condition, n}}
	end
	return {false, "1x41"}
end


-- WAIT
function module.Commands.WAIT(line:string)
	local data = line:split(":")
	return data
end

function module.Exec.WAIT(data)
	local t = data[2]
	if not t then 
		return {false, "2x20"}
	end
	
	t = ClearString(t)
	if tonumber(t) then
		wait(tonumber(t))
		return {true, nil}
	end
	
	if Globals.Globals[t] then
		if Globals.Globals[t].Type == "NUMBER" then
			wait(Globals.Globals[t].Val)
			return {true, nil}
		end
	end
	
	return {false, "0x00"}
end


-- CALL
function module.Commands.CALL(l)
	local p1 = l:split(":")
	local var_name = p1[2]
	var_name = ClearString(var_name)
	return {true, "CALL "..var_name}
end

function module.Exec.CALL(d)
	return module.CALL(d)
end

function module.CALL(data)
	print(data)
	
	if data[2]:split(" ")[1] == "CALL" then
		local f = data[2]:split(" ")
		if f[2]:split("..")[2] then
			local t = f[2]:split("..")[1]
			local m = f[2]:split("..")[2]:split("{")[1]
			print(t, m)
			if Globals.Globals[t] then
				if Globals.Globals[t][m] then
					local params = getExpressionInBrackets(data[2])
					if params then
						local ps = params:split(",")
						if not(#ps == 1 and ps[1] == "") then
							for i, param in pairs(ps) do
								param = ClearString(param)
								local v = Globals.Globals[param]
								if v then
									ps[i] = v.Val
								elseif tonumber(param) then
									ps[i] = tonumber(param)
								elseif getExpressionInSpeechMarks(param) then
									ps[i] = getExpressionInSpeechMarks(param)							
								else
									return {false, "0x00"}
								end
							end
						end
						local result = Globals.Globals[t][m](ps)
						print(Globals.Globals, result)
						return result
					else
						return {false, "2x20"}
					end
				else
					return {false, "2x18"}
				end
				
			elseif Enums[t] then
				if Enums[t]()[2][m] then
					local params = getExpressionInBrackets(data[2])
					print(params)
					if params then
						local ps = params:split(",")
						if not(#ps == 1 and ps[1] == "") then
							for i, param in pairs(ps) do
								param = ClearString(param)
								local v = Globals.Globals[param]
								if v then
									ps[i] = v.Val
								elseif tonumber(param) then
									ps[i] = tonumber(param)
								elseif getExpressionInSpeechMarks(param) then
									ps[i] = getExpressionInSpeechMarks(param)	
								else
									return {false, "0x00"}
								end
							end
						end
						local result = Enums[t]()[2][m](ps)[2].Val
						return {true, result}
					else
						return {false, "2x20"}
					end
				end
			
			end
			
		else
			local m = f[2]:split("{")[1]
			if Globals.Globals[m] then
				if Globals.Globals[m] then
					local params = getExpressionInBrackets(data[2])
					if params then
						local ps = params:split(",")
						if not(#ps == 1 and ps[1] == "") then
							for i, param in pairs(ps) do
								param = ClearString(param)
								local v = Globals.Globals[param]
								if v then
									ps[i] = v.Val
								elseif tonumber(param) then
									ps[i] = tonumber(param)
								elseif getExpressionInSpeechMarks(param) then
									ps[i] = getExpressionInSpeechMarks(param)							
								else
									return {false, "0x00"}
								end
							end
						end
						local result = Globals.Globals[m](ps)
						return result
					else
						return {false, "2x20"}
					end
				else
					return {false, "2x18"}
				end

			elseif Enums[m] then
				--if Enums[m]()[2] then
				local params = getExpressionInBrackets(data[2])
				print(params, data[2])
					if params then
						local ps = params:split(",")
						if not(#ps == 1 and ps[1] == "") then
							for i, param in pairs(ps) do
								param = ClearString(param)
								local v = Globals.Globals[param]
								if v then
									ps[i] = v.Val
								elseif tonumber(param) then
									ps[i] = tonumber(param)
								elseif getExpressionInSpeechMarks(param) then
									ps[i] = getExpressionInSpeechMarks(param)	
								else
									return {false, "0x00"}
								end
							end
						end
					local result = Enums[m](ps)
					print(result)
					return result
					else
						return {false, "2x20"}
					end
				--end

			end
		end
	end
end



return module
