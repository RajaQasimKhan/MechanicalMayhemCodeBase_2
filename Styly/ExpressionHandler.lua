local math_eval = require(script.Parent.MathEvaluator)
local Globals = require(script.Parent.Globals)

local module = {}

function FindInString(s:string, c)
	if s:len() <= 0 then
		return nil
	end
	for i = 1, s:len() do
		if s:sub(i, i) == c then
			return i
		end
	end
	return nil
end

function module.GetExpressionType(expression:string)
	if FindInString(expression, "<") or FindInString(expression, ">") or FindInString("!") or FindInString("=") then
		return "boolean"
	end
	if FindInString(expression, "+") or FindInString(expression, "/") or FindInString(expression, "*") or FindInString(expression, "^") or FindInString(expression, "-") then
		return "math"
	end
	if FindInString(expression, "&") then
		return "string"
	end
end

function getExpressionInBrackets(expression)
	local currentStartIndex = 1
	local currentEndIndex = 0
	local nestedCount = 0

	-- Loop through each character
	for i = 1, #expression do
		local char = string.sub(expression, i, i)

		-- Handle opening brackets
		if char == "(" then
			if nestedCount == 0 then
				currentStartIndex = i
			end
			nestedCount += 1
		elseif char == ")" then
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

function getExpressionsAroundBrackets(expression)
	local currentStartIndex = 1
	local currentEndIndex = 0
	local nestedCount = 0

	-- Loop through each character
	for i = 1, #expression do
		local char = string.sub(expression, i, i)

		-- Handle opening brackets
		if char == "(" then
			if nestedCount == 0 then
				currentStartIndex = i
			end
			nestedCount += 1
		elseif char == ")" then
			nestedCount -= 1
			if nestedCount == 0 then
				currentEndIndex = i
				break -- Exit loop once outer brackets are found
			end
		end
	end

	-- Check if brackets were found and extract expressions
	if currentStartIndex > 0 and currentEndIndex > currentStartIndex then
		local leftExpression = string.sub(expression, 1, currentStartIndex - 1)
		local rightExpression = string.sub(expression, currentEndIndex + 1)
		return leftExpression, rightExpression
	else
		return nil, nil
	end
end

function ClearString(s:string)
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
end

function SoftEvaluate(e:string)
	return math_eval(e, math_eval.RDParser)
end

function ReplaceVars(e:string)
	local new_exp = ""
	e = " "..e.." "
	local ref_nums = {}
	for i = 2, e:len()-1 do
		for v = i, e:len()-1 do
			local var = e:sub(i, v)
			if Globals.Globals[var] then
				print(var)
				if (e:sub(i-1, i-1):lower() >= "a" and e:sub(i-1, i-1):lower() <= "z") --[[or (e:sub(i+1, i+1):lower() >= "a" and e:sub(i+1, i+1):lower() <= "z")]] then

				else
					if (e:sub(v+1, v+1):lower() >= "a" and e:sub(v+1, v+1):lower() <= "z") --[[or (e:sub(v+1, v+1):lower() >= "a" and e:sub(v+1, v+1):lower() <= "z")]] then
						
					else
						table.insert(ref_nums, {i, v, Globals.Globals[var]})
					end
				end
				
			end
		end
	end
	
	if #ref_nums == 0 then return e end
	
	print(e)
	
	for i, v in pairs(ref_nums) do
		local st = v[1]
		local ed = v[2]
		local val = v[3].Val
		print(st, ed, val)
		
		local l = e:sub(1, st-1)
		warn(l)
		for i = 1, ed-st + tostring(val):len() - 1 do
			l = " "..l
		end
		local r = e:sub(ed+1, e:len())
		warn(r)
		e = l..val..r
		print(e, e:len())
	end
	
	return e
end

function module.Evaluate(exp:string)  -- "1 + 1 < 2 + (2 - 1)"
	local s, r = pcall(function()
		exp = ReplaceVars(exp)
		print(exp)
		local in_brackets = getExpressionInBrackets(exp)
		local l, r = getExpressionsAroundBrackets(exp)
		local v = nil

		if in_brackets then
			v = module.Evaluate(in_brackets)
		elseif v then
			return SoftEvaluate(l..v..r)
		end
	
		return SoftEvaluate(exp)
	end)
	
	if s then
		return {s, r}
	else
		return {s, "0x00", r}
	end
end

return module
