-- returns the intersection of planes
local function solve3(n0, p0, n1, p1, n2, p2, r)
	local d0 = n0:Dot(p0) + r*n0.Magnitude
	local d1 = n1:Dot(p1) + r*n1.Magnitude
	local d2 = n2:Dot(p2) + r*n2.Magnitude

	local n0_n1 = n0:Cross(n1)

	local det = n2:Dot(n0_n1)
	if math.abs(det) < 1e-4 then return end

	local x = (d0*n1:Cross(n2) + d1*n2:Cross(n0) + d2*n0:Cross(n1))/det

	return x
end

-- takes a list of Vector3 vertices, a numer padRadius, and a camera object
-- returns the position that the camera needs to translate to
-- in order to have all vertices visible to the camera
local function fitCameraToVerts(verts, padRadius, camera)
	local fov = camera.FieldOfView
	local R = camera.CFrame.Rotation
	local l = R.LookVector
	local pixelSize = camera.ViewportSize
	local slopeYZ = math.tan(math.rad(fov)/2)
	local slopeXZ = slopeYZ*pixelSize.X/pixelSize.Y
	
	local normPX = R*Vector3.new( 1,  0, slopeXZ)
	local normNX = R*Vector3.new(-1,  0, slopeXZ)
	local normPY = R*Vector3.new( 0,  1, slopeYZ)
	local normNY = R*Vector3.new( 0, -1, slopeYZ)


	local dotPX = -1/0
	local dotNX = -1/0
	local dotPY = -1/0
	local dotNY = -1/0

	local posPX
	local posNX
	local posPY
	local posNY
	
	for i, vert in next, verts do
		local dPX = normPX:Dot(vert)
		local dNX = normNX:Dot(vert)
		local dPY = normPY:Dot(vert)
		local dNY = normNY:Dot(vert)
		if dPX > dotPX then
			dotPX = dPX
			posPX = vert
		end
		if dNX > dotNX then
			dotNX = dNX
			posNX = vert
		end
		if dPY > dotPY then
			dotPY = dPY
			posPY = vert
		end
		if dNY > dotNY then
			dotNY = dNY
			posNY = vert
		end
	end

	local pointNXPYNY = solve3(normNX, posNX, normPY, posPY, normNY, posNY, padRadius)
	local pointPXPYNY = solve3(normPX, posPX, normPY, posPY, normNY, posNY, padRadius)
	local pointPXNXNY = solve3(normPX, posPX, normNX, posNX, normNY, posNY, padRadius)
	local pointPXNXPY = solve3(normPX, posPX, normNX, posNX, normPY, posPY, padRadius)
	
	local point0 = (pointNXPYNY + pointPXPYNY)/2
	local point1 = (pointPXNXNY + pointPXNXPY)/2
	
	if point0:Dot(l) < point1:Dot(l) then
		return point0
	else
		return point1
	end
end
