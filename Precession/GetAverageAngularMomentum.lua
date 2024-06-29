local function getPerpMatrix(a)
	local ax, ay, az = a.x, a.y, a.z
	return CFrame.new(0, 0, 0,
		 0 , -az,  ay,
		 az,  0 , -ax,
		-ay,  ax,  0 )
end

local function getParaMatrix(a)
	local ax, ay, az = a.x, a.y, a.z
	return CFrame.new(0, 0, 0,
		 ay*ay + az*az, -ax*ay, -ax*az,
		-ax*ay,  ax*ax + az*az, -ay*az,
		-ax*az, -ay*az,  ax*ax + ay*ay)
end

-- takes moment of inertia I
-- initial CFrame, C0
-- initial angular velocity, w
-- secondary axis of oscillation (local to C0), a
-- returns an angular momentum, L, which is invariant to starting rotation about axis a
-- used for approximating a precession from initial conditions.
local function getAverageL(I, C0, w, a)
	a = a.unit
	local R0 = C0.Rotation
	local As = getPerpMatrix(a)
	local Ac = getParaMatrix(a)
	local r = R0:inverse()*w
	
	return R0*(Ac*I*Ac*r*3/2 - Ac*I*r - As*I*As*r/2 - I*Ac*r + I*r)
end
