local module = {}

module.ParserIndex = {}

module.ParserIndex["Small DC Motor"] = function(item:Model)
	local d = {}
	local item_stats = require(item.ItemStats)
	d["Identifier"] = item_stats.Identifier
	return d
end


return module
