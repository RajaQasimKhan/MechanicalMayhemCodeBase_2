-- Services
local RepStorage = game:GetService("ReplicatedStorage")

if workspace:FindFirstChild("Items") then
	workspace.Items.Parent = RepStorage
end

for I, ITEM in pairs(RepStorage.Items:GetChildren()) do
	local ITEM_INFO = require(ITEM.ItemStats)
	for E, ITEM_PART in pairs(ITEM:GetDescendants()) do
		if ITEM_PART.Name == "Conv" and ITEM_PART:IsA("BasePart") then
			local CONV_SPEED = Instance.new("NumberValue", ITEM_PART)
			CONV_SPEED.Name = "ConvVelo"
			CONV_SPEED.Value = ITEM_INFO.ConveyorSpeed
		elseif ITEM_PART:IsA("Script") then
			ITEM_PART.Disabled = true
		end
		if E%50 == 0 then
			wait()
		end
	end
	ITEM.PrimaryPart = ITEM.Hitbox
	ITEM.PrimaryPart.Transparency = 1
	ITEM.PrimaryPart.Color = Color3.fromRGB(107, 173, 176)
	ITEM.PrimaryPart.Material = Enum.Material.Neon
	if I%175 == 0 then
		wait()
	end
end
