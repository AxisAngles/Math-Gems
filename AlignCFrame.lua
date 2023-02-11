-- This will make a given CFrame's axis (localDir) of your
-- choosing point in any direction (globalDir) that you want.
local function alignCFrame(cframe, localDir, globalDir)
	-- define both input vectors in local space
	local u = localDir.unit
	local v = cframe:vectorToObjectSpace(globalDir).unit

	-- D is a quaternion whose rotation is double from u to v:
	local Dim = u:Cross(v)
	local Dre = u:Dot(v)

	-- Taking the square root of a quaternion halves the angle
	-- it represents.
	-- we can take the square root of a quaternion by adding its
	-- magnitude to its real component, and then unitizing.
	-- roblox will unitize this quaternion for us, and the
	-- quaternion's magnitude is 1, so it can look like this:
	local R = CFrame.new(0, 0, 0, Dim.x, Dim.y, Dim.z, Dre + 1)

	-- R is the rotation which will turn our input cframe to
	-- make its localDir align with globalDir
	return cframe*R
end
