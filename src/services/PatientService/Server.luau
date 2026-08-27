--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Data = require(ReplicatedStorage.Shared.Data.Data).server
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const ObjectPool = require(ReplicatedStorage.Shared.Modules.ObjectPool)
const RateLimiter = require(ReplicatedStorage.Shared.Modules.RateLimiter)
const Trove = require(ReplicatedStorage.Packages.Trove)
const PatientDefinitions = require(ReplicatedStorage.Shared.Services.PatientService.PatientServiceUtils)
const AnomalyService = require(script.Parent.Parent.AnomalyService.AnomalyServiceServer)

--// Network
const PatientSpawned = require(ReplicatedStorage.Network.PatientSpawned):Server()
const PatientResolved = require(ReplicatedStorage.Network.PatientResolved):Server()
const AssignRoom = require(ReplicatedStorage.Network.AssignRoom):Server()
const ResolveCheckIn = require(ReplicatedStorage.Network.ResolveCheckIn)
const ApplyTreatment = require(ReplicatedStorage.Network.ApplyTreatment)
const GetPatientSnapshot = require(ReplicatedStorage.Network.GetPatientSnapshot)

const PatientService = {}

--// Types
export type ActivePatient = {
	Id: string,
	Template: PatientDefinitions.PatientTemplate,
	IsAnomaly: boolean,
	RolledTraits: { PatientDefinitions.Trait },
	Registered: boolean,
	Treated: boolean,
	AssignedRoom: PatientDefinitions.RoomId,
}

--// State
local ActivePatients: { [string]: ActivePatient } = {}
local NextPatientId = 0
local InteractionEnabled = false
const ServiceTrove = Trove.new()
const Limiter = RateLimiter.new(GameConfig.Security.RemoteBurst, GameConfig.Security.RemoteRefillPerSecond)
const SpeciesList: { PatientDefinitions.PatientTemplate } = {}

for _, Template in PatientDefinitions.Species do
	table.insert(SpeciesList, Template)
end

const PatientPool = ObjectPool.new(function(): ActivePatient
	return {
		Id = "",
		Template = PatientDefinitions.Species.Dog,
		IsAnomaly = false,
		RolledTraits = {},
		Registered = false,
		Treated = false,
		AssignedRoom = "CheckIn",
	}
end, function(Patient: ActivePatient)
	Patient.Id = ""
	Patient.IsAnomaly = false
	table.clear(Patient.RolledTraits)
	Patient.Registered = false
	Patient.Treated = false
	Patient.AssignedRoom = "CheckIn"
end)
PatientPool:Warm(16)

const ValidRooms = table.freeze({ CheckIn = true, GeneralCare = true, OperatingRoom = true, Quarantine = true })
const ValidTreatments =
	table.freeze({ Bandage = true, Splint = true, Antibiotic = true, Sedative = true, Surgery = true })

--// Internal helpers
const function GenerateId(): string
	NextPatientId += 1
	return GameConfig.Patients.IdPrefix .. tostring(NextPatientId)
end

const function IsSafeIdentifier(Value: string): boolean
	return #Value > 0 and #Value <= GameConfig.Security.MaximumIdentifierLength
end

const function CanRequest(Player: Player): boolean
	return InteractionEnabled and Player.Parent ~= nil and Limiter:Allow(Player)
end

--// Public API
function PatientService.SetInteractionEnabled(Enabled: boolean)
	InteractionEnabled = Enabled
end

function PatientService.SpawnPatient(AnomalyChance: number): ActivePatient
	assert(InteractionEnabled, "Patients can only spawn during an active shift")
	const Patient = PatientPool:Acquire()
	const Template = if GameConfig.Patients.RandomSpecies
		then SpeciesList[math.random(1, #SpeciesList)]
		else PatientDefinitions.Species.Dog
	const IsAnomaly = math.random() < math.clamp(AnomalyChance, 0, 1)

	Patient.Id = GenerateId()
	Patient.Template = Template
	Patient.IsAnomaly = IsAnomaly
	Patient.RolledTraits = AnomalyService.RollTraits(IsAnomaly)
	Patient.Registered = false
	Patient.Treated = false
	Patient.AssignedRoom = GameConfig.Patients.InitialRoom :: PatientDefinitions.RoomId
	ActivePatients[Patient.Id] = Patient

	PatientSpawned:FireAll({
		Id = Patient.Id,
		Species = Template.Species,
		VisibleTraitDescriptions = AnomalyService.GetVisibleDescriptions(Patient.RolledTraits),
	})
	return Patient
end

function PatientService.ResolveCheckIn(PatientId: string, PlayerAdmitted: boolean): boolean
	const Patient = ActivePatients[PatientId]
	if not Patient or (Patient.Registered and not GameConfig.Patients.AllowMultipleCheckInResolutions) then
		return false
	end
	Patient.Registered = true
	return (PlayerAdmitted and not Patient.IsAnomaly) or (not PlayerAdmitted and Patient.IsAnomaly)
end

function PatientService.AssignRoom(PatientId: string, Room: PatientDefinitions.RoomId): boolean
	const Patient = ActivePatients[PatientId]
	if not ValidRooms[Room] or not Patient or not Patient.Registered or Patient.Treated then
		return false
	end
	Patient.AssignedRoom = Room
	return Room == Patient.Template.CorrectRoom
end

function PatientService.ApplyTreatment(PatientId: string, TreatmentId: PatientDefinitions.TreatmentId): boolean
	const Patient = ActivePatients[PatientId]
	if not Patient or not Patient.Registered or Patient.Treated then
		return false
	end
	if GameConfig.Patients.RequireCorrectRoomForTreatment and Patient.AssignedRoom ~= Patient.Template.CorrectRoom then
		return false
	end
	const IsValid = table.find(Patient.Template.ValidTreatments, TreatmentId) ~= nil
	if IsValid then
		Patient.Treated = true
		if GameConfig.Patients.ClearPatientOnSuccessfulTreatment then
			task.defer(PatientService.ClearPatient, PatientId)
		end
	end
	return IsValid
end

function PatientService.GetPatient(PatientId: string): ActivePatient?
	return ActivePatients[PatientId]
end

function PatientService.GetVisibleSnapshot()
	const Snapshot = {}
	for _, Patient in ActivePatients do
		table.insert(Snapshot, {
			Id = Patient.Id,
			Species = Patient.Template.Species,
			VisibleTraitDescriptions = AnomalyService.GetVisibleDescriptions(Patient.RolledTraits),
		})
	end
	return Snapshot
end

function PatientService.ClearPatient(PatientId: string)
	const Patient = ActivePatients[PatientId]
	if not Patient then
		return
	end
	ActivePatients[PatientId] = nil
	PatientResolved:FireAll(PatientId)
	PatientPool:Release(Patient)
end

function PatientService.ClearAll()
	const PatientIds = {}
	for PatientId in ActivePatients do
		table.insert(PatientIds, PatientId)
	end
	for _, PatientId in PatientIds do
		PatientService.ClearPatient(PatientId)
	end
end

function PatientService.RemovePlayer(Player: Player)
	Limiter:Remove(Player)
end

--// Remote handlers
function PatientService.Init()
	GetPatientSnapshot:SetCallback(function(Player: Player)
		return if Player.Parent and Limiter:Allow(Player) then PatientService.GetVisibleSnapshot() else {}
	end)

	ResolveCheckIn:SetCallback(function(Player: Player, PatientId: string, PlayerAdmitted: boolean)
		if not CanRequest(Player) or not IsSafeIdentifier(PatientId) then
			return false
		end
		const PlayerData = Data[Player]
		if not PlayerData then
			return false
		end
		const Correct = PatientService.ResolveCheckIn(PatientId, PlayerAdmitted)
		if Correct then
			PlayerData.coins(function(Coins)
				return Coins + GameConfig.Economy.CorrectCheckInReward
			end)
			PlayerData.statistics.correctCheckIns(function(Value)
				return Value + 1
			end)
		end
		return Correct
	end)

	ApplyTreatment:SetCallback(function(Player: Player, PatientId: string, TreatmentId: string)
		if not CanRequest(Player) or not IsSafeIdentifier(PatientId) or not ValidTreatments[TreatmentId] then
			return false
		end
		const PlayerData = Data[Player]
		if not PlayerData then
			return false
		end
		const Treated = PatientService.ApplyTreatment(PatientId, TreatmentId :: PatientDefinitions.TreatmentId)
		if Treated then
			PlayerData.coins(function(Coins)
				return Coins + GameConfig.Economy.SuccessfulTreatmentReward
			end)
			PlayerData.statistics.patientsTreated(function(Value)
				return Value + 1
			end)
		end
		return Treated
	end)

	ServiceTrove:Add(AssignRoom:On(function(Player: Player, PatientId: string, Room: string)
		if CanRequest(Player) and IsSafeIdentifier(PatientId) and ValidRooms[Room] then
			PatientService.AssignRoom(PatientId, Room :: PatientDefinitions.RoomId)
		end
	end))
end

--// Cleanup
function PatientService.Destroy()
	PatientService.ClearAll()
	PatientPool:Destroy()
	Limiter:Clear()
	ServiceTrove:Destroy()
end

return PatientService
