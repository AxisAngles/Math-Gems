-- provides a way of averaging between many values of multiple weights (0, 1)
-- useful when you want to interpolate from an origin value into, not just another value, but multiple other values.

-- mixArithmetic(o, a, 0, b, 0) = o

-- mixArithmetic(o, a, 1, b, 0) = a
-- mixArithmetic(o, a, 0, b, 1) = b

-- mixArithmetic(o, a, 1, b, 1) = (a + b)/2

-- mixArithmetic(o, a, 1/2, b, 1/2) = ((a + b)/2 + o)/2

local function mixArithmetic(origin, ...)
	local totalSum = 0
	local totalVal = 0*origin
	for i = 1, select("#", ...), 2 do
		local val, weight = select(i, ...)
		totalSum += weight
		totalVal += weight*weight*(val - origin)
	end

	if totalSum == 0 then
		return origin
	end

	return totalVal/totalSum + origin
end

-- this is the geometric (mixes in log space) version of the arithmetic mixer.
local function mixGeometric(origin, ...)
	local totalSum = 0
	local totalVal = 1
	for i = 1, select("#", ...), 2 do
		local val, weight = select(i, ...)
		totalSum += weight
		totalVal *= (val/origin)^(weight*weight)
	end

	if totalSum == 0 then
		return origin
	end

	return origin*totalVal^(1/totalSum)
end
