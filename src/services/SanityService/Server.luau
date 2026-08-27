--!strict

--// Dependencies
const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const SanityChangedRemote = require(ReplicatedStorage.Network.SanityChanged):Server()

const SanityService = {}

--// Types
type SanityState = {
	Value: number,
	DrainMultiplier: number,
	LastReplicatedValue: number,
	Draining: boolean,
	DepletionReported: boolean,
}

--// State
const PlayerSanity: { [Player]: SanityState } = setmetatable({}, { __mode = "k" }) :: any
const ServiceTrove = Trove.new()
local ReplicationAccumulator = 0

SanityService.SanityDepleted = Signal.new()
SanityService.SanityChanged = Signal.new()

--// Internal helpers
const function Replicate(Player: Player, State: SanityState)
	State.LastReplicatedValue = State.Value
	SanityChangedRemote:Fire(Player, State.Value)
end

--// Public API
function SanityService.InitPlayer(Player: Player)
	if PlayerSanity[Player] then
		return
	end
	PlayerSanity[Player] = {
		Value = GameConfig.Sanity.Max,
		DrainMultiplier = 1,
		LastReplicatedValue = GameConfig.Sanity.Max,
		Draining = false,
		DepletionReported = false,
	}
	SanityChangedRemote:Fire(Player, GameConfig.Sanity.Max)
end

function SanityService.RemovePlayer(Player: Player)
	PlayerSanity[Player] = nil
end

function SanityService.SetShiftState(Player: Player, Active: boolean, ShiftNumber: number?)
	const State = PlayerSanity[Player]
	if not State then
		return
	end
	State.Draining = Active
	if ShiftNumber then
		State.DrainMultiplier = 1 + ShiftNumber * GameConfig.Sanity.DrainScalePerShift
	end
end

function SanityService.Reset(Player: Player)
	const State = PlayerSanity[Player]
	if not State then
		return
	end
	State.Value = GameConfig.Sanity.Max
	State.DepletionReported = false
	Replicate(Player, State)
end

function SanityService.Restore(Player: Player, Amount: number)
	const State = PlayerSanity[Player]
	if not State or Amount <= 0 then
		return
	end
	State.Value = math.clamp(State.Value + Amount, 0, GameConfig.Sanity.Max)
	if State.Value > 0 then
		State.DepletionReported = false
	end
	SanityService.SanityChanged:Fire(Player, State.Value)
	Replicate(Player, State)
end

function SanityService.Drain(Player: Player, Amount: number)
	const State = PlayerSanity[Player]
	if not State or not State.Draining or Amount <= 0 then
		return
	end
	State.Value = math.clamp(State.Value - Amount, 0, GameConfig.Sanity.Max)
	SanityService.SanityChanged:Fire(Player, State.Value)
	if State.Value <= 0 and not State.DepletionReported then
		State.DepletionReported = true
		State.Draining = false
		SanityService.SanityDepleted:Fire(Player)
	end
end

function SanityService.GetSanity(Player: Player): number
	const State = PlayerSanity[Player]
	return if State then State.Value else 0
end

--// Lifecycle
function SanityService.Init()
	ServiceTrove:Connect(RunService.Heartbeat, function(DeltaTime: number)
		if GameConfig.Sanity.PassiveDrainEnabled then
			for Player, State in PlayerSanity do
				if State.Draining and State.Value > 0 then
					SanityService.Drain(
						Player,
						GameConfig.Sanity.BaseDrainPerMinute / 60 * State.DrainMultiplier * DeltaTime
					)
				end
			end
		end

		ReplicationAccumulator += DeltaTime
		if ReplicationAccumulator < GameConfig.Sanity.ReplicationInterval then
			return
		end
		ReplicationAccumulator = 0
		for Player, State in PlayerSanity do
			if math.abs(State.Value - State.LastReplicatedValue) >= GameConfig.Sanity.ReplicationEpsilon then
				Replicate(Player, State)
			end
		end
	end)
end

function SanityService.Destroy()
	ServiceTrove:Destroy()
	SanityService.SanityDepleted:Destroy()
	SanityService.SanityChanged:Destroy()
	table.clear(PlayerSanity)
end

return SanityService
