--!strict
--!native

--// Dependencies
const ParseStructure = require(script.Parent:WaitForChild("ParseStructure"))

const Typewrite = {}

--// State
const ActiveTokens: { [TextLabel]: {} } = setmetatable({}, { __mode = "k" }) :: any

--// Public API
function Typewrite.Type(TextLabel: TextLabel, Text: string, Speed: number?): RBXScriptSignal
	Speed = Speed or 0.03

	const Finished = Instance.new("BindableEvent")
	const Token = {}
	ActiveTokens[TextLabel] = Token

	task.spawn(function()
		const Structure = ParseStructure(Text)
		local DisplayText = ""
		const OpenTags = {}

		for _, Element in ipairs(Structure) do
			if ActiveTokens[TextLabel] ~= Token or not TextLabel.Parent then
				Finished:Fire()
				Finished:Destroy()
				return
			end
			if Element.type == "tag" then
				if Element.content:sub(2, 2) == "/" then
					table.remove(OpenTags)
				else
					table.insert(OpenTags, Element.content)
				end
				DisplayText ..= Element.content
				TextLabel.Text = DisplayText
			else
				DisplayText ..= Element.content
				local TempText = DisplayText
				-- Temporarily close active tags while the next character is being revealed.
				for _ = #OpenTags, 1, -1 do
					TempText ..= "</font>"
				end

				TextLabel.Text = TempText
				task.wait(Speed)
			end
		end

		TextLabel.Text = DisplayText
		if ActiveTokens[TextLabel] == Token then
			ActiveTokens[TextLabel] = nil
		end

		Finished:Fire()
		Finished:Destroy()
	end)

	return Finished.Event
end

function Typewrite.Cancel(TextLabel: TextLabel)
	ActiveTokens[TextLabel] = nil
end

return Typewrite
