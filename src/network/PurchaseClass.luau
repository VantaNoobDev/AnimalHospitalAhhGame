--!strict
--!native

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Red = require(ReplicatedStorage.Packages.Red)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

--// Contract
return Red.Function("PurchaseClass", function(ClassId)
	assert(type(ClassId) == "string", "PurchaseClass: ClassId must be a string")
	assert(
		#ClassId > 0 and #ClassId <= GameConfig.Security.MaximumIdentifierLength,
		"PurchaseClass: invalid ClassId length"
	)

	return ClassId
end, function(DidPurchase)
	assert(type(DidPurchase) == "boolean", "PurchaseClass response must be a boolean")
	return DidPurchase
end)
