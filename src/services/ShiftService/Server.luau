--!strict

--// Dependencies
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Data = require(ReplicatedStorage.Shared.Data.Data).server
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const RateLimiter = require(ReplicatedStorage.Shared.Modules.RateLimiter)
const PatientService = require(script.Parent.Parent.PatientService.PatientServiceServer)
const SanityService = require(script.Parent.Parent.SanityService.SanityServiceServer)
const ShiftStartedRemote = require(ReplicatedStorage.Network.ShiftStarted):Server()
const ShiftEndedRemote = require(ReplicatedStorage.Network.ShiftEnded):Server()
const GetShiftState = require(ReplicatedStorage.Network.GetShiftState)

const ShiftService = {}

--// Types
type ShiftState = { Number: number, Active: boolean, TimeRemaining: number, NextSpawnIn: number }
export type ReadOnlyShiftState = {
	read Number: number,
	read Active: boolean,
	read TimeRemaining: number,
	read NextSpawnIn: number,
}

--// State
local CurrentShift: ShiftState? = nil
const ServiceTrove = Trove.new()
const SyncLimiter = RateLimiter.new(GameConfig.Security.RemoteBurst, GameConfig.Security.RemoteRefillPerSecond)
ShiftService.ShiftStarted = Signal.new()
ShiftService.ShiftEnded = Signal.new()

--// Internal helpers
const function GetPatientInterval(ShiftNumber: number): number
	return math.max(
		GameConfig.Shift.MinimumPatientInterval,
		GameConfig.Shift.BasePatientInterval * GameConfig.Shift.IntervalScalePerShift ^ ShiftNumber
	)
end

const function GetAnomalyChance(ShiftNumber: number): number
	return math.min(
		GameConfig.Shift.BaseAnomalyChance + ShiftNumber * GameConfig.Shift.AnomalyChanceScalePerShift,
		GameConfig.Shift.MaximumAnomalyChance
	)
end

const function EndShift(Survived: boolean)
	const Shift = CurrentShift
	if not Shift or not Shift.Active then
		return
	end
	Shift.Active = false
	PatientService.SetInteractionEnabled(false)
	PatientService.ClearAll()
	for _, Player in Players:GetPlayers() do
		SanityService.SetShiftState(Player, false)
		if Survived and Data[Player] then
			Data[Player].statistics.shiftsCompleted(function(Value)
				return Value + 1
			end)
		end
	end
	ShiftService.ShiftEnded:Fire(Shift.Number, Survived)
	ShiftEndedRemote:FireAll(Shift.Number, Survived)
	CurrentShift = nil
end

--// Public API
function ShiftService.StartShift(ShiftNumber: number): boolean
	if CurrentShift and CurrentShift.Active then
		return false
	end
	if ShiftNumber < 1 or ShiftNumber % 1 ~= 0 then
		return false
	end

	CurrentShift = {
		Number = ShiftNumber,
		Active = true,
		TimeRemaining = GameConfig.Shift.BaseDuration,
		NextSpawnIn = if GameConfig.Shift.StartPatientImmediately then 0 else GetPatientInterval(ShiftNumber),
	}
	PatientService.SetInteractionEnabled(true)
	for _, Player in Players:GetPlayers() do
		SanityService.Reset(Player)
		SanityService.SetShiftState(Player, true, ShiftNumber)
	end
	ShiftService.ShiftStarted:Fire(ShiftNumber)
	ShiftStartedRemote:FireAll(ShiftNumber)
	return true
end

function ShiftService.OnPlayerAdded(Player: Player)
	const Shift = CurrentShift
	if Shift and Shift.Active then
		SanityService.SetShiftState(Player, true, Shift.Number)
		ShiftStartedRemote:Fire(Player, Shift.Number)
	end
end

function ShiftService.RemovePlayer(Player: Player)
	SyncLimiter:Remove(Player)
end

function ShiftService.Tick(DeltaTime: number)
	const Shift = CurrentShift
	if not Shift or not Shift.Active then
		return
	end
	Shift.TimeRemaining -= DeltaTime
	Shift.NextSpawnIn -= DeltaTime
	if Shift.TimeRemaining <= 0 then
		EndShift(true)
		return
	end
	if Shift.NextSpawnIn <= 0 then
		PatientService.SpawnPatient(GetAnomalyChance(Shift.Number))
		Shift.NextSpawnIn += GetPatientInterval(Shift.Number)
	end
end

function ShiftService.FailShift()
	EndShift(false)
end

function ShiftService.GetCurrentShift(): ReadOnlyShiftState?
	return CurrentShift
end

--// Lifecycle
function ShiftService.Init()
	GetShiftState:SetCallback(function(Player: Player)
		if not Player.Parent or not SyncLimiter:Allow(Player) then
			return { Number = 0, TimeRemaining = 0, Active = false }
		end
		const Shift = CurrentShift
		return if Shift
			then {
				Number = Shift.Number,
				TimeRemaining = math.max(0, Shift.TimeRemaining),
				Active = Shift.Active,
			}
			else { Number = 0, TimeRemaining = 0, Active = false }
	end)
	ServiceTrove:Add(SanityService.SanityDepleted:Connect(function()
		if CurrentShift and CurrentShift.Active then
			ShiftService.FailShift()
		end
	end))
end

function ShiftService.Destroy()
	if CurrentShift then
		EndShift(false)
	end
	ServiceTrove:Destroy()
	SyncLimiter:Clear()
	ShiftService.ShiftStarted:Destroy()
	ShiftService.ShiftEnded:Destroy()
end

return ShiftService
