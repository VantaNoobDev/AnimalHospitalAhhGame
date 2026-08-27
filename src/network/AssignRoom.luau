--!strict
--!native

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const ValidRooms = table.freeze({ CheckIn = true, GeneralCare = true, OperatingRoom = true, Quarantine = true })

--// Contract
return Red.Event("AssignRoom", function(PatientId, Room)
	assert(type(PatientId) == "string", "Expected PatientId to be a string, got " .. typeof(PatientId))
	assert(type(Room) == "string", "Expected Room to be a string, got " .. typeof(Room))
	assert(#PatientId > 0 and #PatientId <= GameConfig.Security.MaximumIdentifierLength, "Invalid PatientId length")
	assert(ValidRooms[Room] == true, "Unknown room")

	return PatientId, Room
end)
