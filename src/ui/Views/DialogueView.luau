--!strict
--!native

local Players = game:GetService("Players")

local LocalPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UI = PlayerGui:WaitForChild("DialogueUI") :: ScreenGui
local Frame = UI:WaitForChild("Frame") :: Frame
local TextLabel = Frame:WaitForChild("TextLabel") :: TextLabel

local DialogueView = {}

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
