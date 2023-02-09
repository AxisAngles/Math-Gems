-- There are 4 basis Quaternion rotations: 1, I, J, K
-- 1: 0 degree rotation
-- I: 180 degrees about X axis
-- J: 180 degrees about Y axis
-- K: 180 degrees about Z axis

-- A quaternion is a linear combination of these bases:
-- W*1 + X*I + Y*J + Z*K

-- We generally want to work with unit quaternions, that is,
-- when magnitude(W, X, Y, Z) = 1

local function cframeToQuaternion(R)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	local W, X, Y, Z

	-- All the following compute a quaternion representing the
	-- same rotation, though magnitudes will vary
	if yy > -zz and zz > -xx and xx > -yy then
		-- This is most accurate when R is closest to the 1 quaternion
		W, X, Y, Z = 1 + xx + yy + zz, yz - zy, zx - xz, xy - yx
	elseif xx > yy and xx > zz then
		-- This is most accurate when R is closest to the I quaternion
		W, X, Y, Z = yz - zy, 1 + xx - yy - zz, xy + yx, xz + zx
	elseif yy > zz then
		-- This is most accurate when R is closest to the J quaternion
		W, X, Y, Z = zx - xz, xy + yx, 1 - xx + yy - zz, yz + zy
	else
		-- This is most accurate when R is closest to the K quaternion
		W, X, Y, Z = xy - yx, xz + zx, yz + zy, 1 - xx - yy + zz
	end

	-- a quaternion should generally be unit length, so we unitize:
	local k = math.sqrt(W*W + X*X + Y*Y + Z*Z)
	return W/k, X/k, Y/k, Z/k
end
