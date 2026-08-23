--!strict
--!native

-- Services & Modules --
const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.Signal) :: any

-- Red networking --
const SanityChanged = require(ReplicatedStorage.Network.SanityChanged):Server()

const SanityService = {}

-- Configuration --
const MAX_SANITY: number = 100
const BASE_DRAIN_PER_MINUTE: number = 9
const DRAIN_SCALE_PER_SHIFT: number = 0.03

-- Types --
type SanityState = {
	Value: number,
	DrainMultiplier: number,
}

-- States --
const PlayerSanity: {
	[Player]: SanityState,
} = setmetatable({}, { __mode = "k" }) :: { [Player]: SanityState }

SanityService.SanityDepleted = Signal.new()
SanityService.SanityChanged = Signal.new()

-- Private API --
const function ClampSanity(Value: number): number
	return math.clamp(Value, 0, MAX_SANITY)
end

-- Public API --
function SanityService.InitPlayer(Player: Player)
	PlayerSanity[Player] = {
		Value = MAX_SANITY,
		DrainMultiplier = 1,
	}
	SanityChanged:Fire(Player, MAX_SANITY)
end

function SanityService.RemovePlayer(Player: Player)
	PlayerSanity[Player] = nil
end

function SanityService.SetShiftDrainScale(Player: Player, ShiftNumber: number)
	const State = PlayerSanity[Player]

	if not State then
		return
	end

	State.DrainMultiplier = 1 + (ShiftNumber * DRAIN_SCALE_PER_SHIFT)
end

function SanityService.Restore(Player: Player, Amount: number)
	const State = PlayerSanity[Player]

	if not State then
		return
	end

	State.Value = ClampSanity(State.Value + Amount)

	SanityService.SanityChanged:Fire(Player, State.Value)

	SanityChanged:Fire(Player, State.Value)
end

function SanityService.Drain(Player: Player, Amount: number)
	const State = PlayerSanity[Player]

	if not State then
		return
	end

	State.Value = ClampSanity(State.Value - Amount)

	SanityService.SanityChanged:Fire(Player, State.Value)

	SanityChanged:Fire(Player, State.Value)

	if State.Value <= 0 then
		SanityService.SanityDepleted:Fire(Player)
	end
end

function SanityService.GetSanity(Player: Player): number
	const State = PlayerSanity[Player]

	return if State then State.Value else 0
end

-- Passive sanity loss --

RunService.Heartbeat:Connect(function(DeltaTime: number)
	for Player, State in PlayerSanity do
		if State.Value > 0 then
			SanityService.Drain(Player, BASE_DRAIN_PER_MINUTE / 60 * State.DrainMultiplier * DeltaTime)
		end
	end
end)

Players.PlayerAdded:Connect(SanityService.InitPlayer)

Players.PlayerRemoving:Connect(SanityService.RemovePlayer)

return SanityService
