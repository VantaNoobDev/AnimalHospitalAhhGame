--!strict

--// Dependencies
const RunService = game:GetService("RunService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const ShiftStartedRemote = require(ReplicatedStorage.Network.ShiftStarted):Client()
const ShiftEndedRemote = require(ReplicatedStorage.Network.ShiftEnded):Client()
const GetShiftState = require(ReplicatedStorage.Network.GetShiftState)

const ShiftClient = {}

--// State
const ClientTrove = Trove.new()
const State = { Number = 0, TimeRemaining = 0, Active = false }

--// Signals
ShiftClient.ShiftStarted = Signal.new()
ShiftClient.ShiftEnded = Signal.new()
ShiftClient.TimeUpdated = Signal.new()

--// Lifecycle
function ShiftClient.Init()
	ClientTrove:Add(ShiftStartedRemote:On(function(ShiftNumber: number)
		State.Number = ShiftNumber
		State.TimeRemaining = GameConfig.Shift.BaseDuration
		State.Active = true
		ShiftClient.ShiftStarted:Fire(ShiftNumber)
	end))
	ClientTrove:Add(ShiftEndedRemote:On(function(ShiftNumber: number, Survived: boolean)
		State.Active = false
		State.TimeRemaining = 0
		ShiftClient.ShiftEnded:Fire(ShiftNumber, Survived)
	end))
	ClientTrove:Connect(RunService.RenderStepped, function(DeltaTime: number)
		if State.Active then
			State.TimeRemaining = math.max(0, State.TimeRemaining - DeltaTime)
			ShiftClient.TimeUpdated:Fire(State.TimeRemaining)
		end
	end)
	local Success, Snapshot = GetShiftState:Call():Await()
	if Success then
		State.Number = Snapshot.Number
		State.TimeRemaining = Snapshot.TimeRemaining
		State.Active = Snapshot.Active
	end
end

--// Read API
function ShiftClient.GetShiftNumber(): number
	return State.Number
end
function ShiftClient.GetTimeRemaining(): number
	return State.TimeRemaining
end
function ShiftClient.IsActive(): boolean
	return State.Active
end
function ShiftClient.Destroy()
	ClientTrove:Destroy()
end

return ShiftClient
