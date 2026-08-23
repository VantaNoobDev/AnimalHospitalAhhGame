--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("PurchaseClass", function(ClassId)
	assert(type(ClassId) == "string", "PurchaseClass: ClassId must be a string")

	return ClassId
end, function(ClassId)
	if not ClassId then
		return
	end
end)
