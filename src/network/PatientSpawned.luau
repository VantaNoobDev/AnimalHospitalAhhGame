--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

-- Types --
type PayloadType = {
	Id: string,
	Species: string,
	VisibleTraitDescriptions: { string },
}

return Red.Event("PatientSpawned", function(Payload: any)
	assert(type(Payload) == "table", "Expected Payload to be a table, got " .. typeof(Payload))
	assert(type(Payload.Id) == "string", "Expected Payload.Id to be a string, got " .. typeof(Payload.Id))
	assert(
		type(Payload.Species) == "string",
		"Expected Payload.Species to be a string, got " .. typeof(Payload.Species)
	)
	assert(
		type(Payload.VisibleTraitDescriptions) == "table",
		"Expected Payload.VisibleTraitDescriptions to be a table, got " .. typeof(Payload.VisibleTraitDescriptions)
	)

	return Payload
end)
