--!strict
--!native

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const ValidTreatments =
	table.freeze({ Bandage = true, Splint = true, Antibiotic = true, Sedative = true, Surgery = true })

--// Contract
return Red.Function("ApplyTreatment", function(PatientId, TreatmentId)
	assert(type(PatientId) == "string", "Expected PatientId to be a string, got " .. typeof(PatientId))
	assert(type(TreatmentId) == "string", "Expected TreatmentId to be a string, got " .. typeof(TreatmentId))
	assert(#PatientId > 0 and #PatientId <= GameConfig.Security.MaximumIdentifierLength, "Invalid PatientId length")
	assert(ValidTreatments[TreatmentId] == true, "Unknown TreatmentId")

	return PatientId, TreatmentId
end, function(IsValid)
	assert(type(IsValid) == "boolean", "Expected IsValid to be a boolean, got " .. typeof(IsValid))

	return IsValid
end)
