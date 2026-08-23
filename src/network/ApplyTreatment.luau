--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("ApplyTreatment", function(PatientId, TreatmentId)
	assert(type(PatientId) == "string", "Expected PatientId to be a string, got " .. typeof(PatientId))
	assert(type(TreatmentId) == "string", "Expected TreatmentId to be a string, got " .. typeof(TreatmentId))

	return PatientId, TreatmentId
end, function(PatientId, TreatmentId)
	if not PatientId or not TreatmentId then
		return
	end
end)
