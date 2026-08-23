--!strict
--!native

-- Services & Modules --
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PatientDefinitions = require(ReplicatedStorage.Shared.Services.PatientService.PatientServiceUtils)

const AnomalyDetectionService = {}

-- Configuration --
const MIN_ANOMALY_TRAITS: number = 2
const MAX_ANOMALY_TRAITS: number = 4
const RED_HERRING_CHANCE: number = 0.08

-- Private API --
const function ShuffledTraitPool(): { PatientDefinitions.Trait }
	const Pool = table.clone(PatientDefinitions.Traits)

	for Index = #Pool, 2, -1 do
		const SwapIndex = math.random(1, Index)

		Pool[Index], Pool[SwapIndex] = Pool[SwapIndex], Pool[Index]
	end

	return Pool
end

-- Public API --
function AnomalyDetectionService.RollTraits(IsAnomaly: boolean): { PatientDefinitions.Trait }
	const Pool = ShuffledTraitPool()

	if IsAnomaly then
		const Count = math.random(MIN_ANOMALY_TRAITS, MAX_ANOMALY_TRAITS)

		const Rolled: { PatientDefinitions.Trait } = {}

		for Index = 1, math.min(Count, #Pool) do
			table.insert(Rolled, Pool[Index])
		end

		return Rolled
	end

	if math.random() < RED_HERRING_CHANCE then
		const LowWeightPool: { PatientDefinitions.Trait } = {}

		for _, TraitData in Pool do
			if TraitData.Weight <= 0.35 then
				table.insert(LowWeightPool, TraitData)
			end
		end

		if #LowWeightPool > 0 then
			return {
				LowWeightPool[math.random(1, #LowWeightPool)],
			}
		end
	end

	return {}
end

function AnomalyDetectionService.GetVisibleDescriptions(Traits: { PatientDefinitions.Trait }): { string }
	const Descriptions: { string } = {}

	for _, TraitData in Traits do
		table.insert(Descriptions, TraitData.Description)
	end

	return Descriptions
end

function AnomalyDetectionService.GetSuspicionScore(Traits: { PatientDefinitions.Trait }): number
	local Total: number = 0

	for _, TraitData in Traits do
		Total += TraitData.Weight
	end

	return math.min(Total, 1)
end

return AnomalyDetectionService
