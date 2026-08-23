--!strict
--!native

const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const Services = game:GetService("ServerScriptService").Services

const PatientService = require(Services:WaitForChild("PatientService"):WaitForChild("PatientServiceServer"))
const SanityService = require(Services:WaitForChild("SanityService"):WaitForChild("SanityServiceServer"))
const ShiftService = require(Services:WaitForChild("ShiftService"):WaitForChild("ShiftServiceServer"))
const AnomalyService = require(Services:WaitForChild("AnomalyService"):WaitForChild("AnomalyServiceServer"))
const ClassService = require(Services:WaitForChild("ClassService"):WaitForChild("ClassServiceServer"))
const DialogueService = require(Services:WaitForChild("DialogueService"):WaitForChild("DialogueServiceServer"))

assert(PatientService, "PatientService not found")
assert(SanityService, "SanityService not found")
assert(ShiftService, "ShiftService not found")
assert(AnomalyService, "AnomalyService not found")
assert(ClassService, "ClassService not found")
assert(DialogueService, "DialogueService not found")

const function OnPlayerAdded(Player: Player)
	ClassService.InitPlayer(Player)
	SanityService.InitPlayer(Player)
	task.delay(10, function()
		DialogueService.Start(
			Player,
			"This is an _cs_intro_ce_ for the game. It will explain the _rs_basics_re_ of how to play and what to do."
		)
	end)
end

const function OnPlayerRemoving(Player: Player)
	ClassService.RemovePlayer(Player)
	SanityService.RemovePlayer(Player)
end

for _, Player in Players:GetPlayers() do
	OnPlayerAdded(Player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

RunService.Heartbeat:Connect(function(DeltaTime: number)
	ShiftService.Tick(DeltaTime)
end)

ShiftService.StartShift(1)
