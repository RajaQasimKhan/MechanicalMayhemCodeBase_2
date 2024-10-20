local f = script.Parent.Parent.Background.Console.ScrollingFrame
local ls = script.Parent.Parent.Editor.SideScroll

local module = {}

function module.MakeOutput(v, bold:boolean, color:Color3)
	warn(v)
	local n = script.P:Clone()
	n.TextLabel.TextColor3 = color

	n.TextLabel.FontFace.Bold = bold
	
	n.TextLabel.Text = tostring(v)
	n.Parent = f
end

function module.MakeLineStatus(v, line, bold:boolean, color:Color3)
	warn(v)
	local n = script.LS:Clone()
	n.TextColor3 = color
	n.FontFace.Bold = bold

	n.Text = "< "..tostring(line).." : ERROR"
	n.Parent = ls
	if not v then return end
	module.MakeOutput("line-"..tostring(line).. " : "..v, true, color)
end

function module.MakeBlankLineStatus()
	local n = script.LS:Clone()
	n.Text = ""
	n.Parent = ls
end

function module.TableToString(t)
	local s = "{"
	for i, v in pairs(t) do
		local e = ""
		if typeof(v) == "table" then
			e = module.TableToString(v)
		elseif tostring(v) then
			e = v
		
		end
		e = tostring(e)
		s = s..tostring(i).." = "..e..", "
	end
	s = s.."}"
	return s
end

function module.OutputTable(t, bold:boolean, color:Color3)
	warn(t)
	if typeof(t) == "table" then
		local s = module.TableToString(t)
		if s then
			s = "line-"..script.Parent.Line.Value.." : "..s
			module.MakeOutput(s, bold, color)
		end
	end
end


return module
