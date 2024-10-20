local Plr = game:GetService("Players").LocalPlayer
script.Parent.Parent:WaitForChild("MainUi")
local CHILD_ADDED_CONNECTION

local function DETECT_LOADED(CHILD_ADDED)
	if CHILD_ADDED and CHILD_ADDED.Name ~= "DataLoaded" then
		return
	end
	if Plr:FindFirstChild("DataLoaded") then
		warn("Data Loaded, MainUi loading!")
		script.Parent.Parent.MainUi.Enabled = true
		script.Parent.Parent.MainUi.Scripts.ModuleLoader.Disabled = false
		CHILD_ADDED_CONNECTION:Disconnect() -- saves memory
		script.Parent:Destroy()
	else
		warn("Data Not Loaded, MainUi not loading!")
		script.Parent.Parent.MainUi.Scripts.ModuleLoader.Disabled = true
		script.Parent.Parent.MainUi.Enabled = false
		require(script.Parent.LoadModule).LOAD()
		script.Parent.Contents.Visible = true
	end
end
DETECT_LOADED()
CHILD_ADDED_CONNECTION = Plr.ChildAdded:Connect(DETECT_LOADED)
