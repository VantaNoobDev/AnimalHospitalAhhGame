--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
const Initializer = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("UI"):WaitForChild("Dialogue"))

const StartDialogue = require(ReplicatedStorage.Network.StartDialogue):Server()

const DialogueService = {}

-- Weak keys prevent departed players from being retained by this service state.
const InitializedPlayers: { [Player]: boolean } = setmetatable({}, { __mode = "k" }) :: { [Player]: boolean }

function DialogueService.Start(Player: Player, Text: string)
	if not InitializedPlayers[Player] then
		Initializer:Initialize(Player)
		InitializedPlayers[Player] = true
	end

	-- Give the cloned LocalScript/UI a chance to initialize before sending its first event.
	task.delay(GameConfig.Dialogue.InitializationDelay, function()
		if Player.Parent then
			StartDialogue:Fire(Player, { Text = Text })
		end
	end)
end

function DialogueService.RemovePlayer(Player: Player)
	InitializedPlayers[Player] = nil
end

return DialogueService
