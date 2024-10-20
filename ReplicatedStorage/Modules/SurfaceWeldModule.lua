local SurfaceWeldModule = {}

--[[
	SurfaceWeld Module
	By: Ethanthegrand (@Ethanthegrand14)
	
	Version: 1.1.0
	
	Last Updated: Monday, 10 January 2022
]]

local ServerScriptService = game:GetService("ServerScriptService")

local Params = OverlapParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude

local Offset = 0.05

local OffsetVectorX = Vector3.new(Offset, -Offset, -Offset)
local OffsetVectorY = Vector3.new(-Offset, Offset, -Offset)
local OffsetVectorZ = Vector3.new(-Offset, -Offset, Offset)

local function CheckIfCanWeld(PartA, PartB)
	if PartA:GetAttribute("NoWeld") or PartB:GetAttribute("NoWeld") then return false end
	for i, Weld in pairs(PartB:GetChildren()) do
		if Weld:IsA("WeldConstraint") then
			if Weld.Part0 == PartA and Weld.Part1 == PartB then
				return false
			elseif Weld.Part0 == PartB and Weld.Part1 == PartA then
				return false
			end
		end
	end
	return true
end

local function CreateWeld(PartA, PartB)
	if CheckIfCanWeld(PartA, PartB) then
		if PartA:GetAttribute("MotorPart") and PartB:GetAttribute("MotorPart") then
			print()
		else
			local Weld = Instance.new("WeldConstraint")
			Weld.Part1 = PartA
			Weld.Part0 = PartB
			Weld.Parent = PartA
		end
	end
end

local function SurfaceWeldPart(Part)
	if Part:IsA("BasePart") then
		print(Part.Name)
		
		Params.FilterDescendantsInstances = {Part}

		local PartsX = workspace:GetPartBoundsInBox(Part.CFrame, Part.Size + OffsetVectorX, Params)
		local PartsY = workspace:GetPartBoundsInBox(Part.CFrame, Part.Size + OffsetVectorY, Params)
		local PartsZ = workspace:GetPartBoundsInBox(Part.CFrame, Part.Size + OffsetVectorZ, Params)
		
		print(PartsX, PartsY, PartsZ)
		
		
		for i, PartToWeldToX in pairs(PartsX) do
			CreateWeld(Part, PartToWeldToX)
		end

		for i, PartToWeldToY in pairs(PartsY) do
			CreateWeld(Part, PartToWeldToY)
		end

		for i, PartToWeldToZ in pairs(PartsZ) do
			CreateWeld(Part, PartToWeldToZ)
		end
	end
end


function SurfaceWeldModule.WeldPart(Part: BasePart)
	SurfaceWeldPart(Part)
end

function SurfaceWeldModule.WeldModel(Model: Model)
	for i, Part in pairs(Model:GetDescendants()) do
		SurfaceWeldPart(Part)
	end
end

function SurfaceWeldModule.WeldParts(DescendantsParts)
	for i, Part in DescendantsParts do
		SurfaceWeldPart(Part)
	end
end

return SurfaceWeldModule