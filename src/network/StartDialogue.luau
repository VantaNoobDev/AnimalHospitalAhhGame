local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("StartDialogue", function(Payload)
	assert(type(Payload) == "table", "Expected dialogue payload to be a table")
	assert(type(Payload.Text) == "string", "Expected Payload.Text to be a string")

	return Payload
end)
