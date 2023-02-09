local function getAngleAboutYAxis(R)
	local px, py, pz,
		xx, yx, zx,
		xy, yy, zy,
		xz, yz, zz = R:components()

	return math.atan2(zx - xz, xx + zz)
end

local function getGlobalInputDirection(cameraCFrame, localInputDirection)
	-- First, we find the Y-rotation CFrame nearest to cameraCFrame
	local cameraAngleY = getAngleAboutYAxis(cameraCFrame)
	local yAlignedCameraCFrame = CFrame.Angles(0, cameraAngleY, 0)
	
	-- Then we transform the localInputDirection into global space
	local globalInputDirection = yAlignedCameraCFrame*localInputDirection
	
	return globalInputDirection
end
