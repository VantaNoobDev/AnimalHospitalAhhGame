--!strict
--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Initializer = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("UI"):WaitForChild("Dialogue"))
local Initialized = false

local StartDialogue = require(ReplicatedStorage.Network.StartDialogue):Server()

local DialogueService = {}

function DialogueService.Start(Player: Player, Text: string)
	if not Initialized then
		Initializer:Initialize(Player)
		Initialized = true
		task.delay(1, function()
			StartDialogue:Fire(Player, { Text = Text })
		end)
	else
		StartDialogue:Fire(Player, { Text = Text })
	end
end

return DialogueService
