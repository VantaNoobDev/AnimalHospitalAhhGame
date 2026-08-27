--!strict

--// Dependencies
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Trove = require(ReplicatedStorage.Packages.Trove)
const StartDialogue = require(ReplicatedStorage.Network.StartDialogue):Client()
const Dialogue = require(script.Parent.Parent.Components.DialogueComponents)
const DialogueMarkup = require(script.Parent.Parent.Utils.DialogueMarkup)

const DialogueController = {}

--// Lifecycle
const ControllerTrove = Trove.new()

function DialogueController.Init()
	ControllerTrove:Add(StartDialogue:On(function(Payload)
		if type(Payload) ~= "table" or type(Payload.Text) ~= "string" then
			return
		end
		Dialogue.SendText(DialogueMarkup.Format(Payload.Text))
	end))
end

function DialogueController.Destroy()
	ControllerTrove:Destroy()
end

return DialogueController
