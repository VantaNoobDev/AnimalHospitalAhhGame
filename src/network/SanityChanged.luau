--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("SanityChanged", function(NewValue)
	assert(type(NewValue) == "number", "SanityChanged event expects a number as the new value")
	assert(NewValue >= 0, "SanityChanged event expects a value between 0 and 100")
	assert(NewValue <= 100, "SanityChanged event expects a value between 0 and 100")

	return NewValue
end)
