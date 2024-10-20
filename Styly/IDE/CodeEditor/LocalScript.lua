local e, s, n = script.Parent.ScrollingFrame, script.Parent.SideScroll, script.Parent.LineNums

local IO = require(script.Parent.Parent["Stilys - v1"]["I/O_Control"])
local prev = e.TextBox.Text



function RefreshLineNums()
	local line_count = #(e.TextBox.Text:split("\n"))
	
	n.TextBox.Text = ""
	
	local t = ""
	
	for i = 1, line_count-1 do
		t = t..tostring(i).."\n"
	end
	t = t..tostring(line_count)
	
	n.TextBox.Text = t
end

e:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	s.CanvasPosition = Vector2.new(0, e.CanvasPosition.Y)
	n.CanvasPosition = Vector2.new(0, e.CanvasPosition.Y)
end)

while wait() do
	RefreshLineNums()
end
