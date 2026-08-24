--!strict
--!native

return function(Root: Instance, Path: { string }, TimeOut: number?): Instance
	local Current = Root

	for _, Name in Path do
		const Child = Current:WaitForChild(Name, TimeOut or 10)
		assert(Child, `Missing instance "{Name}" under {Current:GetFullName()}`)
		Current = Child
	end

	return Current
end
