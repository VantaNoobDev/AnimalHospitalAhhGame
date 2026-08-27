--!strict
--!native

--// Dependencies
const RunService = game:GetService("RunService")
const ServerStorage = game:GetService("ServerStorage")

if not RunService:IsServer() then
	return {}
end

--// Server UI setup
const Dialogue = {}

function Dialogue:Initialize(Player: Player)
	const Template = ServerStorage:WaitForChild("UIs"):WaitForChild("DialogueTemplate") :: ScreenGui

	if Player:FindFirstChildOfClass("PlayerGui") == nil then
		return
	end
	const PlayerGui = Player:FindFirstChildOfClass("PlayerGui")
	if not PlayerGui or PlayerGui:FindFirstChild("DialogueUI") then
		return
	end
	const Clone = Template:Clone()
	Clone.Enabled = false
	Clone.Name = "DialogueUI"
	Clone.Parent = PlayerGui
end

return Dialogue
