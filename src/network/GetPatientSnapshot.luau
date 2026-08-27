--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Red = require(ReplicatedStorage.Packages.Red)

--// Contract
return Red.Function("GetPatientSnapshot", function()
	return
end, function(Patients)
	assert(type(Patients) == "table", "GetPatientSnapshot response must be a table")
	for _, Patient in Patients do
		assert(type(Patient) == "table", "Snapshot patient must be a table")
		assert(type(Patient.Id) == "string", "Snapshot patient Id must be a string")
		assert(type(Patient.Species) == "string", "Snapshot patient Species must be a string")
		assert(type(Patient.VisibleTraitDescriptions) == "table", "Snapshot traits must be a table")
	end
	return Patients
end)
