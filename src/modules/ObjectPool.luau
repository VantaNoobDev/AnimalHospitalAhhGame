--!strict

--// Types
export type ObjectPool<T> = {
	Acquire: (self: ObjectPool<T>) -> T,
	Release: (self: ObjectPool<T>, Object: T) -> (),
	Warm: (self: ObjectPool<T>, Count: number) -> (),
	AvailableCount: (self: ObjectPool<T>) -> number,
	Destroy: (self: ObjectPool<T>) -> (),
}

--// Constructor
const ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new<T>(Factory: () -> T, Reset: ((T) -> ())?, Destroy: ((T) -> ())?): ObjectPool<T>
	return setmetatable({
		_factory = Factory,
		_reset = Reset,
		_destroy = Destroy,
		_available = {},
		_inPool = {},
		_destroyed = false,
	}, ObjectPool) :: any
end

--// Pool operations
function ObjectPool:Acquire()
	assert(not self._destroyed, "Cannot acquire from a destroyed ObjectPool")
	const Object = table.remove(self._available)
	if Object ~= nil then
		self._inPool[Object] = nil
		return Object
	end
	return self._factory()
end

function ObjectPool:Release(Object)
	assert(not self._destroyed, "Cannot release into a destroyed ObjectPool")
	assert(not self._inPool[Object], "Object was released twice")
	if self._reset then
		self._reset(Object)
	end
	self._inPool[Object] = true
	table.insert(self._available, Object)
end

function ObjectPool:Warm(Count: number)
	for _ = 1, math.max(0, math.floor(Count)) do
		self:Release(self._factory())
	end
end

function ObjectPool:AvailableCount(): number
	return #self._available
end

--// Cleanup
function ObjectPool:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	if self._destroy then
		for _, Object in self._available do
			self._destroy(Object)
		end
	end
	table.clear(self._available)
	table.clear(self._inPool)
end

return table.freeze(ObjectPool)
