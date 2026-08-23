--!strict
--!native

const ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	Typewrite.Type(TextLabel, Line, 0.04):Wait()
	task.delay(1.5, function()
		View:Hide()
		TextLabel.Text = ""
	end)
end

return Dialogue
