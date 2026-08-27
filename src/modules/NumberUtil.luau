--!strict

const NumberUtil = {}

--// Validation
function NumberUtil.IsFinite(Value: number): boolean
	return Value == Value and Value > -math.huge and Value < math.huge
end

--// Formatting helpers
function NumberUtil.RoundTo(Value: number, DecimalPlaces: number): number
	const Scale = 10 ^ DecimalPlaces
	return math.round(Value * Scale) / Scale
end

return table.freeze(NumberUtil)
