--!strict

const TableUtil = {}

--// Copies
function TableUtil.DeepCopy<T>(Value: T): T
	if type(Value) ~= "table" then
		return Value
	end

	const Result = {}
	for Key, Child in Value :: any do
		(Result :: any)[TableUtil.DeepCopy(Key)] = TableUtil.DeepCopy(Child)
	end

	return Result :: T
end

--// Inspection
function TableUtil.Count(Dictionary: { [any]: any }): number
	local Count = 0
	for _ in Dictionary do
		Count += 1
	end
	return Count
end

return table.freeze(TableUtil)
