--!strict
--!native

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)

--// Contract
return Red.Event("ShiftStarted", function(ShiftNumber)
	assert(type(ShiftNumber) == "number", "ShiftStarted: ShiftNumber must be a number")

	return ShiftNumber
end)
