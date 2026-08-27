--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Data = require(ReplicatedStorage.Shared.Data.Data).server
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const RateLimiter = require(ReplicatedStorage.Shared.Modules.RateLimiter)
const PurchaseClass = require(ReplicatedStorage.Network.PurchaseClass)

const ClassService = {}

--// Types
export type ClassDefinition = {
	read Id: string,
	read Name: string,
	read CostCoins: number,
	read MaxLevel: number,
	read PerkValuesByLevel: { number },
}

--// Class catalog
ClassService.Classes = table.freeze({
	Intern = table.freeze({ Id = "Intern", Name = "Intern", CostCoins = 0, MaxLevel = 1, PerkValuesByLevel = { 0 } }),
	Nurse = table.freeze({
		Id = "Nurse",
		Name = "Nurse",
		CostCoins = 500,
		MaxLevel = 5,
		PerkValuesByLevel = { 0.05, 0.08, 0.11, 0.14, 0.18 },
	}),
	Surgeon = table.freeze({
		Id = "Surgeon",
		Name = "Surgeon",
		CostCoins = 2500,
		MaxLevel = 5,
		PerkValuesByLevel = { 0.10, 0.16, 0.22, 0.28, 0.35 },
	}),
	Secretary = table.freeze({
		Id = "Secretary",
		Name = "Secretary",
		CostCoins = 1200,
		MaxLevel = 5,
		PerkValuesByLevel = { 1, 1, 2, 2, 3 },
	}),
}) :: { [string]: ClassDefinition }

--// State
const Limiter = RateLimiter.new(GameConfig.Security.RemoteBurst, GameConfig.Security.RemoteRefillPerSecond)
const PurchaseLocks: { [Player]: boolean } = setmetatable({}, { __mode = "k" }) :: any

--// Public API
function ClassService.InitPlayer(Player: Player)
	const PlayerData = Data.Service:waitForData(Player)
	if not Player.Parent then
		return
	end
	if GameConfig.Classes.AutoGrantIntern and PlayerData.classes.Intern() == nil then
		PlayerData.classes.Intern({ Owned = true, Level = 1, Exp = 0 })
	end
end

function ClassService.RemovePlayer(Player: Player)
	Limiter:Remove(Player)
	PurchaseLocks[Player] = nil
end

function ClassService.PurchaseClass(Player: Player, ClassId: string): boolean
	if PurchaseLocks[Player] or not Limiter:Allow(Player) then
		return false
	end
	const Definition = ClassService.Classes[ClassId]
	if not Definition then
		return false
	end

	PurchaseLocks[Player] = true
	const Success, Result = pcall(function(): boolean
		const PlayerData = Data.Service:waitForData(Player)
		if not Player.Parent then
			return false
		end
		const Existing = PlayerData.classes[ClassId]()
		if Existing and Existing.Owned and not GameConfig.Classes.AllowRepurchase then
			return false
		end
		const Coins = PlayerData.coins()
		if Coins < Definition.CostCoins then
			return false
		end
		PlayerData.coins(Coins - Definition.CostCoins)
		PlayerData.classes[ClassId]({ Owned = true, Level = 1, Exp = 0 })
		return true
	end)
	PurchaseLocks[Player] = nil

	if not Success then
		warn(`ClassService purchase failed for {Player.Name}: {Result}`)
		return false
	end
	return Result
end

function ClassService.AddExp(Player: Player, ClassId: string, Amount: number)
	if Amount < 0 and not GameConfig.Classes.AllowNegativeExp then
		return
	end
	const Definition = ClassService.Classes[ClassId]
	const PlayerData = Data[Player]
	if not Definition or not PlayerData then
		return
	end
	const Entry = PlayerData.classes[ClassId]()
	if not Entry or not Entry.Owned then
		return
	end

	local Exp = math.max(0, Entry.Exp + Amount)
	local Level = Entry.Level
	while Exp >= GameConfig.Classes.ExpPerLevel and Level < Definition.MaxLevel do
		Exp -= GameConfig.Classes.ExpPerLevel
		Level += 1
	end
	PlayerData.classes[ClassId]({ Owned = true, Level = Level, Exp = Exp })
end

function ClassService.GetPerkValue(Player: Player, ClassId: string): number
	const Definition = ClassService.Classes[ClassId]
	const PlayerData = Data[Player]
	if not Definition or not PlayerData then
		return 0
	end
	const Entry = PlayerData.classes[ClassId]()
	if not Entry or not Entry.Owned then
		return 0
	end
	return Definition.PerkValuesByLevel[Entry.Level] or 0
end

--// Lifecycle
function ClassService.Init()
	PurchaseClass:SetCallback(function(Player: Player, ClassId: string)
		return ClassService.PurchaseClass(Player, ClassId)
	end)
end

function ClassService.Destroy()
	Limiter:Clear()
end

return ClassService
