--!strict
--!native

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

--// Contract
return Red.Function("ResolveCheckIn", function(PatientId, Admitted)
	assert(type(PatientId) == "string", "PatientId must be a string")
	assert(#PatientId > 0 and #PatientId <= GameConfig.Security.MaximumIdentifierLength, "Invalid PatientId length")
	assert(type(Admitted) == "boolean", "Admitted must be a boolean")

	return PatientId, Admitted
end, function(CorrectDecision)
	assert(
		type(CorrectDecision) == "boolean",
		"Expected CorrectDecision to be a boolean, got " .. typeof(CorrectDecision)
	)

	return CorrectDecision
end)
