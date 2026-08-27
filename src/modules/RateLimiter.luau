--!strict

--// Types
export type RateLimiter = {
	Allow: (self: RateLimiter, Key: any, Cost: number?) -> boolean,
	Remove: (self: RateLimiter, Key: any) -> (),
	Clear: (self: RateLimiter) -> (),
}

type Bucket = { Tokens: number, UpdatedAt: number }

--// Constructor
const RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(Capacity: number, RefillPerSecond: number): RateLimiter
	assert(Capacity > 0, "Capacity must be positive")
	assert(RefillPerSecond > 0, "RefillPerSecond must be positive")

	return setmetatable({
		_capacity = Capacity,
		_refillPerSecond = RefillPerSecond,
		_buckets = {},
	}, RateLimiter) :: any
end

--// Bucket operations
function RateLimiter:Allow(Key: any, Cost: number?): boolean
	const ActualCost = Cost or 1
	const Now = os.clock()
	local Bucket: Bucket? = self._buckets[Key]

	if not Bucket then
		Bucket = { Tokens = self._capacity, UpdatedAt = Now }
		self._buckets[Key] = Bucket
	else
		const Elapsed = Now - Bucket.UpdatedAt
		Bucket.Tokens = math.min(self._capacity, Bucket.Tokens + Elapsed * self._refillPerSecond)
		Bucket.UpdatedAt = Now
	end

	if Bucket.Tokens < ActualCost then
		return false
	end

	Bucket.Tokens -= ActualCost
	return true
end

function RateLimiter:Remove(Key: any)
	self._buckets[Key] = nil
end

function RateLimiter:Clear()
	table.clear(self._buckets)
end

return table.freeze(RateLimiter)
