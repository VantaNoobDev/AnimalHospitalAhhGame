--!strict

--// Dependencies
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const ServerScriptService = game:GetService("ServerScriptService")

const Trove = require(ReplicatedStorage.Packages.Trove)
const Services = ServerScriptService.Services
const PatientService = require(Services.PatientService.PatientServiceServer)
const SanityService = require(Services.SanityService.SanityServiceServer)
const ShiftService = require(Services.ShiftService.ShiftServiceServer)
const ClassService = require(Services.ClassService.ClassServiceServer)
const DialogueService = require(Services.DialogueService.DialogueServiceServer)

--// Server lifecycle
const ServerTrove = Trove.new()

PatientService.Init()
SanityService.Init()
ShiftService.Init()
ClassService.Init()

--// Player lifecycle
const function OnPlayerAdded(Player: Player)
	SanityService.InitPlayer(Player)
	ShiftService.OnPlayerAdded(Player)
	task.spawn(ClassService.InitPlayer, Player)
	DialogueService.Start(
		Player,
		"This is an _cs_intro_cs_ for the game. It will explain the _rs_basics_rs_ of how to play and what to do."
	)
end

const function OnPlayerRemoving(Player: Player)
	ClassService.RemovePlayer(Player)
	PatientService.RemovePlayer(Player)
	SanityService.RemovePlayer(Player)
	ShiftService.RemovePlayer(Player)
	DialogueService.RemovePlayer(Player)
end

ServerTrove:Connect(Players.PlayerAdded, OnPlayerAdded)
ServerTrove:Connect(Players.PlayerRemoving, OnPlayerRemoving)
ServerTrove:Connect(RunService.Heartbeat, ShiftService.Tick)

for _, Player in Players:GetPlayers() do
	task.spawn(OnPlayerAdded, Player)
end

--// Game start
ShiftService.StartShift(1)

--// Shutdown
game:BindToClose(function()
	ShiftService.Destroy()
	PatientService.Destroy()
	SanityService.Destroy()
	ClassService.Destroy()
	DialogueService.Destroy()
	ServerTrove:Destroy()
end)
