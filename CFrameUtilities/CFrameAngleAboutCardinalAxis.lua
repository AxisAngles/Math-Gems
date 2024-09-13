-- The following functions take a CFrame as the first argument
-- They return the angle which describes how far CFrame R is rotated about the given axis

local function getAngleAboutXAxis(R)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	return math.atan2(yz - zy, yy + zz)
end

local function getAngleAboutYAxis(R)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	return math.atan2(zx - xz, xx + zz)
end

local function getAngleAboutZAxis(R)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	return math.atan2(xy - yx, xx + yy)
end
