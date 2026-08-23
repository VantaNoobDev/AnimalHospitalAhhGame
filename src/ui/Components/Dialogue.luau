--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

const Typewrite = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("Utils"):WaitForChild("Typewrite"))
const View = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("Views"):WaitForChild("DialogueView"))

const Dialogue = {}

function Dialogue.SendText(Line: string)
	const TextLabel = View:GetTextLabel()
	if View:GetStatus() then
		View:Hide()
		TextLabel.Text = ""
		View:Show()
	end
	if not View:GetStatus() then
		View:Show()
	end

	Typewrite.Type(TextLabel, Line, GameConfig.Dialogue.TypewriteDelay):Wait()
	task.delay(GameConfig.Dialogue.AutoHideDelay, function()
		View:Hide()
		TextLabel.Text = ""
	end)
end

return Dialogue
