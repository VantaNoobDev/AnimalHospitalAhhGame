const ReplicatedStorage = game:GetService("ReplicatedStorage")

const StartDialogue = require(ReplicatedStorage.Network.StartDialogue):Client()
const DialogueComponent = require(script.Parent.Parent.Components.Dialogue)
const ColorEnums = require(ReplicatedStorage.UI:WaitForChild("Enums"):WaitForChild("DialogueEnums"))

const Controller = {}

StartDialogue:On(function(Payload)
	print("Dialogue received: ", Payload.Text)

	local CloneText = Payload.Text
	CloneText = CloneText:gsub("(_%a+_[^_]+_%a+_)", function(Match: string): string
		const ColorName, Text = Match:match("^_(%a+)_(.-)_%a+_$")

		if not ColorName or not Text then
			return Match
		end

		const Color = ColorEnums.Colors[ColorName]

		if not Color then
			return Match
		end

		return string.format(
			'<font color="rgb(%d,%d,%d)">%s</font>',
			math.round(Color.R * 255),
			math.round(Color.G * 255),
			math.round(Color.B * 255),
			Text
		)
	end)
	DialogueComponent.SendText(CloneText)
end)

return Controller
