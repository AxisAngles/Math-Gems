-- Returns the quaternion purely rotated about the given axis
-- who is closest to the given quaternion, Q.

-- WARNING: Does not unitize the resulting quaternion!
local function projectQuaternion(Q, axis)
	-- Project the quaternion's imaginary part onto the given axis
	-- That is, we find the point on the axis closest to Q.im
	return {
		re = Q.re;
		im = axis:Dot(Q.im)/axis:Dot(axis)*axis;
	}
end
