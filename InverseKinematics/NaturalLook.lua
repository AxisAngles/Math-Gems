-- for looking around naturally

-- cos(t)*c + sin(t)*s
-- returns t0 and t1 such that the magnitudes are minimized and maximised
local function getMajorEllipseAngles(c, s)
	local co = c:Dot(c) - s:Dot(s)
	local si = 2*c:Dot(s)
	local minAngle = math.atan2(-si, -co)/2
	local maxAngle = math.atan2( si,  co)/2
	return minAngle, maxAngle
end

-- makes local a direction face in b direction with approximately minimized stress
-- stress matrix looks kind of like a moment of inertia matrix
-- stress scales proportional to sin(theta/2) instead of theta
local function getLookCFrame(I, a, b)
	local u = a.unit
	local v = b.unit
	
	local Cr = u:Dot(v) + 1
	local Ci = u:Cross(v)
	
	local Sr = -Ci:Dot(v)
	local Si = Cr*v - Ci:Cross(v)

	local c = I*Ci
	local s = I*Si
		
	local t = getMajorEllipseAngles(c, s)
	
	local co = math.cos(t)
	local si = math.sin(t)
	local Rr = co*Cr + si*Sr
	local Ri = co*Ci + si*Si
	
	return CFrame.new(0, 0, 0, Ri.x, Ri.y, Ri.z, Rr)
end
