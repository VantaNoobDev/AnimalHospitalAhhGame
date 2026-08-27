--!strict
--!native

--// Types
export type StructureElement = {
	type: "tag" | "char",
	content: string,
}

--// Parser
-- RichText is split into complete tags and individual visible characters.
return function(Text: string): { StructureElement }
	local Structure: { StructureElement } = {}
	local i = 1

	while i <= #Text do
		if Text:sub(i, i) == "<" then
			const TagEnd = Text:find(">", i)
			if TagEnd then
				const Tag = Text:sub(i, TagEnd)
				table.insert(Structure, { type = "tag", content = Tag } :: StructureElement)
				i = TagEnd + 1
			else
				table.insert(Structure, { type = "char", content = Text:sub(i, i) } :: StructureElement)
				i = i + 1
			end
		else
			table.insert(Structure, { type = "char", content = Text:sub(i, i) } :: StructureElement)
			i = i + 1
		end
	end

	return Structure
end
