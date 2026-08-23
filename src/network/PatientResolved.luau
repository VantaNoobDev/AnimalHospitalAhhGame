--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("PatientResolved", function(PatientId)
	assert(type(PatientId) == "string", "Expected PatientId to be a string, got " .. typeof(PatientId))

	return PatientId
end)
