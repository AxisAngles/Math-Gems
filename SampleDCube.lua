-- https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/#GeneralizingGoldenRatio

--[[
Used to generate a sequence of d-dimensional points which fill/pack a space as efficiently as possible
This means that the next point, sampleDCube(d, n + 1), always fills the largest gap left by the previous points in the sequence

replace
	z0, z1, z2, z3 = math.random(), math.random(), math.random(), math.random()
with
	z0, z1, z2, z3 = sampleDCube(4, i)
]]

local ln2 = math.log(2)
local function computePhiD(d)
	-- order 2 asymptotic continued fraction (worth 3 newton iterations)
	-- 3 newton method iterations (fast convergence)
	-- final slower but numerically stable iteration (fix last bits)
	local x = 1 + 2*ln2/(1 + 2*d - ln2)
	local xd = x^d; x = (d*x*xd + 1)/((d + 1)*xd - 1)
	local xd = x^d; x = (d*x*xd + 1)/((d + 1)*xd - 1)
	local xd = x^d; x = (d*x*xd + 1)/((d + 1)*xd - 1)
	return (1 + x)^(1/(1 + d))
end

local phiCache = {}
local function getPhiD(d)
	phiCache[d] = 1/computePhiD(d)
	return phiCache[d]
end

local mem = {}
local function sampleDCube(d, n)
	local phi = phiCache[d] or getPhiD(d)
	local a = 1
	for i = 1, d do
		a *= phi
		mem[i] = (a*n + 1/2)%1
	end
	return unpack(mem, 1, d)
end
