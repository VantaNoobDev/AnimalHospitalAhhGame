--!strict
--!native

--// Balance settings
-- Most gameplay tuning should happen in this file.

const GameConfig = {
	Shift = {
		BaseDuration = 90,
		BasePatientInterval = 8,
		IntervalScalePerShift = 0.92,
		MinimumPatientInterval = 1.5,
		BaseAnomalyChance = 0.15,
		AnomalyChanceScalePerShift = 0.02,
		MaximumAnomalyChance = 0.6,
		StartPatientImmediately = true,
	},

	Sanity = {
		Max = 100,
		WarningThreshold = 40,
		CriticalThreshold = 15,
		BaseDrainPerMinute = 9,
		DrainScalePerShift = 0.03,
		ReplicationInterval = 0.1,
		ReplicationEpsilon = 0.001,
		PassiveDrainEnabled = true,
	},

	Economy = {
		StartingCoins = 1000,
		CorrectCheckInReward = 15,
		SuccessfulTreatmentReward = 35,
	},

	Security = {
		RemoteBurst = 5,
		RemoteRefillPerSecond = 3,
		MaximumIdentifierLength = 64,
	},

	Data = {
		ProfileStoreIndex = "AnimalHospital_PlayerData_v1",
		ProfileKeyPrefix = "PLAYER_",
		UseMockInStudio = true,
	},

	Anomalies = {
		MinTraits = 2,
		MaxTraits = 4,
		RedHerringChance = 0.08,
		RedHerringMaxWeight = 0.35,
	},

	Patients = {
		IdPrefix = "Patient_",
		InitialRoom = "CheckIn",
		RequireCheckInBeforeRoom = true,
		RequireCorrectRoomForTreatment = true,
		AllowMultipleCheckInResolutions = false,
		ClearPatientOnSuccessfulTreatment = true,
		RandomSpecies = true,
	},

	Classes = {
		ExpPerLevel = 100,
		AllowRepurchase = false,
		AllowNegativeExp = false,
		AutoGrantIntern = true,
	},

	Dialogue = {
		InitializationDelay = 1,
		AutoHideDelay = 3,
		TypewriteDelay = 0.03,
	},
}

table.freeze(GameConfig)
table.freeze(GameConfig.Anomalies)
table.freeze(GameConfig.Classes)
table.freeze(GameConfig.Dialogue)
table.freeze(GameConfig.Economy)
table.freeze(GameConfig.Security)
table.freeze(GameConfig.Data)
table.freeze(GameConfig.Patients)
table.freeze(GameConfig.Sanity)
table.freeze(GameConfig.Shift)
return GameConfig
