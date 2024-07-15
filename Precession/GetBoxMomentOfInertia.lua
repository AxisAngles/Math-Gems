local function getBoxMomentOfInertia(size, density)
	local x, y, z = size.x, size.y, size.z
	local m = density*x*y*z
	return CFrame.new(0, 0, 0,
		m*(y*y + z*z)/12, 0, 0,
		0, m*(x*x + z*z)/12, 0,
		0, 0, m*(x*x + y*y)/12)
end
