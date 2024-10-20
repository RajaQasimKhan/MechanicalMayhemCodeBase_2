local module = {}

module.ItemId = 17
module.TierId = 1
module.Description = "A small gyro sensor that measures rotation."
module.ThumbnailId = "rbxassetid://7435970470"
module.Cost = 325
module.CostType = "Cash"
module.ItemType = "ProcessorTab"
module.TabItem = "Processor"

module.CameraPosition = Vector3.new(0, 2, 2)
module.CameraOrientation = Vector3.new(-45, 0, 0)

module.ComponentType = "Sensor"
module.SpecificType = "Gyro"
module.Identifier = tostring(tick())

module.ConveyorSpeed = 0
module.Multiplier = 0
module.Addition = 0
module.DropWorth = 0
module.DropSize = 0
module.DropSpeed = 0

module.Creators = {"dab676767"}
module.SpecialTags = {
	
}

return module
