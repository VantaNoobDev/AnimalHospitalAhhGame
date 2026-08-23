--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("ShiftStarted", function(ShiftNumber)
	assert(type(ShiftNumber) == "number", "ShiftStarted: ShiftNumber must be a number")

	return ShiftNumber
end)
