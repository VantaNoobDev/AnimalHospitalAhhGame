--!strict

--// Dependencies
const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

--// Saved-data types
export type ClassEntry = {
	Owned: boolean,
	Level: number,
	Exp: number,
}

export type PlayerData = {
	schemaVersion: number,
	coins: number,
	classes: { [string]: ClassEntry },
	statistics: {
		patientsTreated: number,
		correctCheckIns: number,
		shiftsCompleted: number,
	},
}

--// Default profile
const Template: PlayerData = {
	schemaVersion = 1,
	coins = GameConfig.Economy.StartingCoins,
	classes = {},
	statistics = {
		patientsTreated = 0,
		correctCheckIns = 0,
		shiftsCompleted = 0,
	},
}

const Data = DataServiceTyped({
	template = Template,
	profileStoreIndex = GameConfig.Data.ProfileStoreIndex,
	profileStoreDataPrefix = GameConfig.Data.ProfileKeyPrefix,
	useMock = RunService:IsStudio() and GameConfig.Data.UseMockInStudio,
})

--// Profile migration
if RunService:IsServer() then
	function Data.server.Service:onPlayerInit(_Player: Player, PlayerData: PlayerData)
		PlayerData.schemaVersion = 1
		PlayerData.coins = math.max(0, PlayerData.coins)
		PlayerData.classes = PlayerData.classes or {}
		PlayerData.statistics = PlayerData.statistics or table.clone(Template.statistics)
	end
end

return Data
