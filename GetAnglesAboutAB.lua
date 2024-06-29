-- takes CFrame R, Vector3 a, Vector3 b
-- returns angles s and t
-- such that fromAxisAngle(a, s)*fromAxisAngle(b, t) is as close to R as possible.

-- the resulting error angle will be
-- anglebetween(a, v) - anglebetween(a, b)
local function getAnglesAboutAB(R, a, b)
	local u = R:VectorToObjectSpace(a)
	local v = R:VectorToWorldSpace(b)
	local c = a:Cross(b)
	
	local kSinA = c:Dot(v)*a.magnitude
	local kCosA = c:Dot(a:Cross(v))

	local kSinB = c:Dot(u)*b.magnitude
	local kCosB = c:Dot(u:Cross(b))

	return
		math.atan2(kSinA, kCosA),
		math.atan2(kSinB, kCosB)
end
