--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Signal = require(ReplicatedStorage.Packages.Signal)
const Trove = require(ReplicatedStorage.Packages.Trove)
const TableUtil = require(ReplicatedStorage.Shared.Modules.TableUtil)
const PatientSpawned = require(ReplicatedStorage.Network.PatientSpawned):Client()
const PatientResolved = require(ReplicatedStorage.Network.PatientResolved):Client()
const AssignRoom = require(ReplicatedStorage.Network.AssignRoom):Client()
const ResolveCheckIn = require(ReplicatedStorage.Network.ResolveCheckIn)
const ApplyTreatment = require(ReplicatedStorage.Network.ApplyTreatment)
const GetPatientSnapshot = require(ReplicatedStorage.Network.GetPatientSnapshot)

const PatientClient = {}

--// State
const ClientTrove = Trove.new()
local Initialized = false

--// Types
export type VisiblePatient = { read Id: string, read Species: string, read VisibleTraitDescriptions: { string } }
const KnownPatients: { [string]: VisiblePatient } = {}

--// Signals
PatientClient.PatientSpawned = Signal.new()
PatientClient.PatientResolved = Signal.new()
PatientClient.CheckInResult = Signal.new()
PatientClient.TreatmentResult = Signal.new()

--// Lifecycle
function PatientClient.Init()
	if Initialized then
		return
	end
	Initialized = true
	ClientTrove:Add(PatientSpawned:On(function(Payload: VisiblePatient)
		KnownPatients[Payload.Id] = Payload
		PatientClient.PatientSpawned:Fire(Payload)
	end))
	ClientTrove:Add(PatientResolved:On(function(PatientId: string)
		KnownPatients[PatientId] = nil
		PatientClient.PatientResolved:Fire(PatientId)
	end))
	local Success, Snapshot = GetPatientSnapshot:Call():Await()
	if Success then
		for _, Payload in Snapshot do
			KnownPatients[Payload.Id] = Payload
		end
	end
end

--// Requests
function PatientClient.RequestCheckIn(PatientId: string, Admitted: boolean): boolean?
	local Success, Correct = ResolveCheckIn:Call(PatientId, Admitted):Await()
	if not Success then
		return nil
	end
	PatientClient.CheckInResult:Fire(PatientId, Correct)
	return Correct
end

function PatientClient.RequestTreatment(PatientId: string, TreatmentId: string): boolean?
	local Success, IsValid = ApplyTreatment:Call(PatientId, TreatmentId):Await()
	if not Success then
		return nil
	end
	PatientClient.TreatmentResult:Fire(PatientId, IsValid)
	return IsValid
end

function PatientClient.RequestRoomAssignment(PatientId: string, Room: string)
	AssignRoom:Fire(PatientId, Room)
end

--// Read API
function PatientClient.GetPatient(PatientId: string): VisiblePatient?
	const Patient = KnownPatients[PatientId]
	return if Patient then TableUtil.DeepCopy(Patient) else nil
end

function PatientClient.GetAllPatients(): { [string]: VisiblePatient }
	return TableUtil.DeepCopy(KnownPatients)
end

function PatientClient.Destroy()
	ClientTrove:Destroy()
	table.clear(KnownPatients)
end

return PatientClient
