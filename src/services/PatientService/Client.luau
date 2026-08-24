--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.Signal)

-- Red networking --
const PatientSpawned = require(ReplicatedStorage.Network.PatientSpawned):Client()
const PatientResolved = require(ReplicatedStorage.Network.PatientResolved):Client()
const AssignRoom = require(ReplicatedStorage.Network.AssignRoom):Client()
const ResolveCheckIn = require(ReplicatedStorage.Network.ResolveCheckIn)
const ApplyTreatment = require(ReplicatedStorage.Network.ApplyTreatment)

const PatientClient = {}

-- Types --
export type VisiblePatient = {
	read Id: string,
	read Species: string,
	read VisibleTraitDescriptions: { string },
}

-- States --
const KnownPatients: { [string]: VisiblePatient } = {}

PatientClient.PatientSpawned = Signal.new()
PatientClient.PatientResolved = Signal.new()
PatientClient.CheckInResult = Signal.new()
PatientClient.TreatmentResult = Signal.new()

-- Incoming from server --
const function OnPatientSpawned(Payload: VisiblePatient)
	KnownPatients[Payload.Id] = Payload

	PatientClient.PatientSpawned:Fire(Payload)
end

const function OnPatientResolved(PatientId: string)
	KnownPatients[PatientId] = nil

	PatientClient.PatientResolved:Fire(PatientId)
end

PatientSpawned:On(OnPatientSpawned)
PatientResolved:On(OnPatientResolved)

-- Outgoing requests --
function PatientClient.RequestCheckIn(PatientId: string, Admitted: boolean)
	local CallSuccess = ResolveCheckIn:Call(PatientId, Admitted):Await()
	assert(CallSuccess, "Failed to resolve check-in for patient " .. PatientId)

	PatientClient.CheckInResult:Fire(PatientId)
end

function PatientClient.RequestRoomAssignment(PatientId: string, Room: string)
	AssignRoom:Fire(PatientId, Room)
end

function PatientClient.RequestTreatment(PatientId: string, TreatmentId: string)
	local CallSuccess = ApplyTreatment:Call(PatientId, TreatmentId):Await()
	assert(CallSuccess, "Failed to apply treatment for patient " .. PatientId)

	PatientClient.TreatmentResult:Fire(PatientId)
end

-- Reads --
function PatientClient.GetPatient(PatientId: string): VisiblePatient?
	return table.clone(KnownPatients[PatientId])
end

function PatientClient.GetAllPatients(): {
	[string]: VisiblePatient,
}
	return table.clone(KnownPatients)
end

return PatientClient
