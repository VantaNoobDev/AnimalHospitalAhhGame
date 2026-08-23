--!strict
--!native

-- Services & Modules --
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)


-- Network Contract --
return Red.Function("ResolveCheckIn", function(PatientId, Admitted)
	assert(type(PatientId) == "string", "PatientId must be a string")
	assert(type(Admitted) == "boolean", "Admitted must be a boolean")

	return PatientId, Admitted
end, function()
	return
end)
