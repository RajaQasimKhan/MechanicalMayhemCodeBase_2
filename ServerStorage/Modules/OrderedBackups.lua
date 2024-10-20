local DataStoreService = game:GetService("DataStoreService")

local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups

function OrderedBackups:Get()
	local success, value = pcall(function()
		return self.orderedDataStore:GetSortedAsync(false, 1):GetCurrentPage()[1]
	end)

	if not success then
		return false, value
	end

	if value then
		local mostRecentKeyPage = value

		local recentKey = mostRecentKeyPage.value
		self.dataStore2:Debug("most recent key", mostRecentKeyPage)
		self.mostRecentKey = recentKey

		local success, value = pcall(function()
			return self.dataStore:GetAsync(recentKey)
		end)

		if not success then
			return false, value
		end

		return true, value
	else
		self.dataStore2:Debug("no recent key")
		return true, nil
	end
end

function OrderedBackups:Set(value)
	local key = (self.mostRecentKey or 0) + 1

	local success, problem = pcall(function()
		self.dataStore:SetAsync(key, value)
	end)

	if not success then
		return false, problem
	end

	local success, problem = pcall(function()
		self.orderedDataStore:SetAsync(key, key)
	end)

	if not success then
		return false, problem
	end

	self.mostRecentKey = key
	return true
end

function OrderedBackups.new(dataStore2)
	local dataStoreKey = dataStore2.Name .. "/" .. dataStore2.UserId
	local info = {
		dataStore2 = dataStore2,
		dataStore = DataStoreService:GetDataStore(dataStoreKey),
		orderedDataStore = DataStoreService:GetOrderedDataStore(dataStoreKey),
	}
	return setmetatable(info, OrderedBackups)
end

return OrderedBackups
