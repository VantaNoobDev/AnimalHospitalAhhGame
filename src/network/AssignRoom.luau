--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("AssignRoom", function(PatientId, Room)
	assert(type(PatientId) == "string", "Expected PatientId to be a string, got " .. typeof(PatientId))
	assert(type(Room) == "string", "Expected Room to be a string, got " .. typeof(Room))

	return PatientId, Room
end)
