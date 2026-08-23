--!strict
--!native

-- RichText cannot safely reveal partial tags, so the text is split into tags and characters first.
const function ParseStructure(Text: string)
	const Structure = {}
	local i = 1

	while i <= #Text do
		if Text:sub(i, i) == "<" then
			const TagEnd = Text:find(">", i)
			if TagEnd then
				const Tag = Text:sub(i, TagEnd)
				table.insert(Structure, { type = "tag", content = Tag })
				i = TagEnd + 1
			else
				table.insert(Structure, { type = "char", content = Text:sub(i, i) })
				i = i + 1
			end
		else
			table.insert(Structure, { type = "char", content = Text:sub(i, i) })
			i = i + 1
		end
	end

	return Structure
end

const Typewrite = {}

function Typewrite.Type(TextLabel: TextLabel, Text: string, Speed: number?): RBXScriptSignal
	Speed = Speed or 0.03

	const Finished = Instance.new("BindableEvent")

	task.spawn(function()
		const Structure = ParseStructure(Text)
		local DisplayText = ""
		const OpenTags = {}

		for _, Element in ipairs(Structure) do
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

		Finished:Fire()
		Finished:Destroy()
	end)

	return Finished.Event
end

return Typewrite
