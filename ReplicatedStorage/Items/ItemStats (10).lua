local module = {}

module.ItemId = 13
module.TierId = 1
module.Description = "A small DC motor. Can be directly connected to a processor."
module.ThumbnailId = "rbxassetid://7435970470"
module.Cost = 200
module.CostType = "Cash"
module.ItemType = "ProcessorTab"
module.TabItem = "Processor"

module.ComponentType = "Output"
module.SpecificType = "Motor"
module.Identifier = tostring(tick())
module.Pins = {
	"+",
	"-"
}

module.CameraPosition = Vector3.new(0, 3, 3)
module.CameraOrientation = Vector3.new(-45, 0, 0)

module.ConveyorSpeed = 0
module.Multiplier = 0
module.Addition = 0
module.DropWorth = 0
module.DropSize = 0
module.DropSpeed = 0

module.MinSpeed = -16
module.MaxSpeed = 16
module.MaxRotation = math.rad(360)


module.Creators = {"dab676767"}
module.SpecialTags = {
	
}

return module
