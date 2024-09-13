-- Returns the angle which describes how much CFrame R is rotated solely about the given axis
local function getAngleAboutAxis(R, axis)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	local x, y, z = axis.x, axis.y, axis.z
	local axisLen = axis.magnitude

	local cosAngle = (y*y + z*z)*xx + (x*x + z*z)*yy + (x*x + y*y)*zz
		 - y*z*(yz + zy) - z*x*(zx + xz) - x*y*(xy + yx)
	local sinAngle = axisLen*(x*(yz - zy) + y*(zx - xz) + z*(xy - yx))

	return math.atan2(sinAngle, cosAngle)
end
