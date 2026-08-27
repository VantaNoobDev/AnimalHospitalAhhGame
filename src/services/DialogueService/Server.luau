--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const Trove = require(ReplicatedStorage.Packages.Trove)
const Initializer = require(ReplicatedStorage.UI.UI.Dialogue)
const StartDialogue = require(ReplicatedStorage.Network.StartDialogue):Server()

const DialogueService = {}

--// State
const PlayerTroves: { [Player]: any } = setmetatable({}, { __mode = "k" }) :: any

--// Public API
function DialogueService.Start(Player: Player, Text: string)
	DialogueService.RemovePlayer(Player)
	const PlayerTrove = Trove.new()
	PlayerTroves[Player] = PlayerTrove
	if not Player.Parent then
		return
	end
	(Initializer :: any):Initialize(Player)
	PlayerTrove:Add(task.delay(GameConfig.Dialogue.InitializationDelay, function()
		if Player.Parent and PlayerTroves[Player] == PlayerTrove then
			StartDialogue:Fire(Player, { Text = Text })
		end
	end))
end

function DialogueService.RemovePlayer(Player: Player)
	const PlayerTrove = PlayerTroves[Player]
	if PlayerTrove then
		PlayerTrove:Destroy()
		PlayerTroves[Player] = nil
	end
end

--// Cleanup
function DialogueService.Destroy()
	for Player in PlayerTroves do
		DialogueService.RemovePlayer(Player)
	end
end

return DialogueService
