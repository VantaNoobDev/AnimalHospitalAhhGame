--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("ResolveCheckIn", function(PatientId, Admitted)
	assert(type(PatientId) == "string", "PatientId must be a string")
	assert(type(Admitted) == "boolean", "Admitted must be a boolean")

	return PatientId, Admitted
end, function(PatientId, Admitted)
	if not PatientId or not Admitted then
		return
	end
end)
