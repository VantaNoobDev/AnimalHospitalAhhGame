--!strict
--!native

const Players = game:GetService("Players")

const LocalPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")
const PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
const UI = PlayerGui:WaitForChild("DialogueUI") :: ScreenGui
const Frame = UI:WaitForChild("Frame") :: Frame
const TextLabel = Frame:WaitForChild("TextLabel") :: TextLabel

const DialogueView = {}

function DialogueView.Show()
	UI.Enabled = true
end

function DialogueView.Hide()
	UI.Enabled = false
end

function DialogueView.IsVisible(): boolean
	return UI.Enabled
end

function DialogueView.SetText(Text: string)
	TextLabel.Text = Text
end

function DialogueView.Clear()
	TextLabel.Text = ""
end

function DialogueView.GetTextLabel(): TextLabel
	return TextLabel
end

return DialogueView
