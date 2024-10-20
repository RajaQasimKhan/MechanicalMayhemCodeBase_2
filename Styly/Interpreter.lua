local Modules = script.Parent

local Commands = require(Modules.Commands)
local ErrorHandler = require(Modules.ErrorHandler)

local module = {}

module.State = false
module.ExecRate = 10

local c = 0

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

function module.Run(line_st)
	
	ErrorHandler.CreateBlank()
	local txt = script.Parent.Parent.Editor.ScrollingFrame.TextBox.Text

	local lines = txt:split("\n")

	local Code = {}
	
	local i = line_st

	while i <= #lines and module.State do
		print(i)
		local l = lines[i]
		l = ClearString(l)
		Modules.Line.Value = i

		if l:sub(1, 1) ~= "#" then
			if l ~= "" then
				local s, r = pcall(function()
					return Commands.ExecuteCommand(l)
				end)
				print(r)
				if not r then
					ErrorHandler.CreateError("0x00", Modules.Line.Value)
					break
				end
				if r[1] == "excJMP--@INTERPRETER" then
					local l_n = r[2]
					if l_n >= 0 and math.floor(l_n) == l_n and l_n <= #lines then
						i = l_n - 1
					end
				elseif r[1] == "excJMPIF--@INTERPRETER" then
					if r[2][1] then
						local l_n = r[2][2]
						if l_n >= 0 and math.floor(l_n) == l_n and l_n <= #lines then
							i = l_n - 1
						end
					end			
				end
				
				if not r[1] then
					ErrorHandler.CreateError(r[2], Modules.Line.Value)
					break
				else
					ErrorHandler.CreateBlank()
				end

			else
				ErrorHandler.CreateBlank()
			end
		else
			ErrorHandler.CreateBlank()
		end
		i += 1
		c += 1
		if c == module.ExecRate then
			task.wait()
			c = 0
		end
	end
end

return module
