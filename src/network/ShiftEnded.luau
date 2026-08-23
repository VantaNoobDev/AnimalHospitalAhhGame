--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("ShiftEnded", function(ShiftNumber, Survived)
	assert(type(ShiftNumber) == "number", "ShiftNumber must be a number")
	assert(type(Survived) == "boolean", "Survived must be a boolean")

	return ShiftNumber, Survived
end)
