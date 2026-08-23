--!strict
--!native

const Player = game:GetService("Players").LocalPlayer
const PlayerGui = Player:WaitForChild("PlayerGui")

const function GetUI(): ScreenGui
	return PlayerGui:WaitForChild("DialogueUI") :: ScreenGui
end

local DialogueView = {}

function DialogueView.Show()
	local UI = GetUI()
	UI.Enabled = true
end

function DialogueView.Hide()
	local UI = GetUI()
	UI.Enabled = false
end

function DialogueView.GetStatus()
	local UI = GetUI()
	return UI.Enabled
end

function DialogueView.GetTextLabel()
	local UI = GetUI()
	return UI:WaitForChild("Frame"):WaitForChild("TextLabel") :: TextLabel
end

return DialogueView
