--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const SanityChangedRemote = require(ReplicatedStorage.Network.SanityChanged):Client()

const SanityClient = {}

--// State
const ClientTrove = Trove.new()
local CurrentSanity = GameConfig.Sanity.Max
local WasInWarning = false
local WasInCritical = false
local WasDepleted = false

--// Signals
SanityClient.SanityChanged = Signal.new()
SanityClient.EnteredWarning = Signal.new()
SanityClient.EnteredCritical = Signal.new()
SanityClient.Depleted = Signal.new()

--// Lifecycle
function SanityClient.Init()
	ClientTrove:Add(SanityChangedRemote:On(function(NewValue: number)
		CurrentSanity = NewValue
		const InWarning = NewValue <= GameConfig.Sanity.WarningThreshold
		const InCritical = NewValue <= GameConfig.Sanity.CriticalThreshold
		const IsDepleted = NewValue <= 0
		SanityClient.SanityChanged:Fire(NewValue, NewValue / GameConfig.Sanity.Max)
		if InWarning and not WasInWarning then
			SanityClient.EnteredWarning:Fire()
		end
		if InCritical and not WasInCritical then
			SanityClient.EnteredCritical:Fire()
		end
		if IsDepleted and not WasDepleted then
			SanityClient.Depleted:Fire()
		end
		WasInWarning = InWarning
		WasInCritical = InCritical
		WasDepleted = IsDepleted
	end))
end

--// Read API
function SanityClient.GetSanity(): number
	return CurrentSanity
end
function SanityClient.GetNormalized(): number
	return CurrentSanity / GameConfig.Sanity.Max
end
function SanityClient.Destroy()
	ClientTrove:Destroy()
end

return SanityClient
