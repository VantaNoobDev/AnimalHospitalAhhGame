--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Data = require(ReplicatedStorage.Shared.Data.Data).client
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const PurchaseClass = require(ReplicatedStorage.Network.PurchaseClass)

const ClassClient = {}

--// State
const ClientTrove = Trove.new()

--// Signals
ClassClient.ClassChanged = Signal.new()
ClassClient.CoinsChanged = Signal.new()
ClassClient.PurchaseFailed = Signal.new()

--// Lifecycle
function ClassClient.Init()
	ClientTrove:Add(Data.classes.Changed(function(Classes, _, ClassId)
		ClassClient.ClassChanged:Fire(ClassId, Classes[ClassId])
	end))
	ClientTrove:Add(Data.coins.Changed(function(Coins)
		ClassClient.CoinsChanged:Fire(Coins)
	end))
end

--// Requests
function ClassClient.RequestPurchase(ClassId: string): boolean?
	local Success, DidPurchase = PurchaseClass:Call(ClassId):Await()
	if not Success or not DidPurchase then
		ClassClient.PurchaseFailed:Fire(ClassId)
		return false
	end
	return true
end

--// Read API
function ClassClient.GetCoins(): number
	return Data.coins()
end

function ClassClient.IsOwned(ClassId: string): boolean
	const Entry = Data.classes[ClassId]()
	return Entry ~= nil and Entry.Owned
end

function ClassClient.GetLevel(ClassId: string): number
	const Entry = Data.classes[ClassId]()
	return if Entry then Entry.Level else 0
end

function ClassClient.GetAllOwned()
	return table.clone(Data.classes())
end

function ClassClient.Destroy()
	ClientTrove:Destroy()
	ClassClient.ClassChanged:Destroy()
	ClassClient.CoinsChanged:Destroy()
	ClassClient.PurchaseFailed:Destroy()
end

return ClassClient
