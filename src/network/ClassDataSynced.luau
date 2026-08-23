--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("ClassDataSynced", function(FullData)
	assert(type(FullData) == "table", "Expected FullData to be a table, got " .. typeof(FullData))

	return FullData
end)
