-- this code, just like code which takes an ordered set of points and returns the area contained,
-- returns the amount of uniform ambient light blocked by a polygon defined by an ordered set of points

-- returns area covered by triangle 0, a, b
-- returns values from 0 to pi
local function shadedCross(
	nx, ny, nz, -- normal (make sure it is unit length)
	ax, ay, az, -- vector a of the line segment
	bx, by, bz  -- vector b of the line segment
)
	-- compute a cross b
	local cx = ay*bz - az*by
	local cy = az*bx - ax*bz
	local cz = ax*by - ay*bx
	-- sine is proportional to the length of the a cross b, 2*area swept from a to b
	-- cosine is proportional to a dot b
	-- det tells us the area seen from the perspective of the normal
	local sin = math.sqrt(cx*cx + cy*cy + cz*cz)
	local cos = ax*bx + ay*by + az*bz
	local det = cx*nx + cy*ny + cz*nz
	print(sin, cos, det)
	if sin == 0 then return 0 end
	return det/(2*sin)*math.atan2(sin, cos)
end

-- counterclockwise is positive area
-- clockwise is negative area
local function computePolygonShade(norm, points)
	local nx, ny, nz = norm[1], norm[2], norm[3]
	local sum = 0
	local lastPoint = points[#points]
	local ax, ay, az = lastPoint[1], lastPoint[2], lastPoint[3]
	for i, point in next, points do
		local bx, by, bz = point[1], point[2], point[3]
		sum = sum + shadedCross(
			nx, ny, nz,
			ax, ay, az,
			bx, by, bz
		)
		ax, ay, az = bx, by, bz
	end

	return sum/math.pi
end
