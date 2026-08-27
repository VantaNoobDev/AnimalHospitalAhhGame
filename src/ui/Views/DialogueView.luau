--!strict
--!native

--// Dependencies
const Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const LocalPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")
const PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
const Require = require(ReplicatedStorage.Shared.Modules.RequireUtil) :: any
const UI = Require(PlayerGui, { "DialogueUI" }) :: ScreenGui
const Frame = UI:WaitForChild("Frame") :: Frame
const TextLabel = Frame:WaitForChild("TextLabel") :: TextLabel

--// Public API
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
