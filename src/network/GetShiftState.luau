--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Red = require(ReplicatedStorage.Packages.Red)

--// Contract
return Red.Function("GetShiftState", function()
	return
end, function(Payload)
	assert(type(Payload) == "table", "GetShiftState response must be a table")
	assert(type(Payload.Number) == "number", "GetShiftState.Number must be a number")
	assert(type(Payload.TimeRemaining) == "number", "GetShiftState.TimeRemaining must be a number")
	assert(type(Payload.Active) == "boolean", "GetShiftState.Active must be a boolean")
	return Payload
end)
