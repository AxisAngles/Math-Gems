-- https://math.stackexchange.com/q/4950960
local ie = math.exp(-1)
local convergeLambertW

-- solves x e^x = z
local function lambertW(z: number): (number?, number?)
	if z < -ie then -- no solutions
		return
	elseif z == -ie then
		return -1
	elseif z < -0.25 then -- arbitrary
		local g = math.sqrt(-2 - 2*math.log(-z))
		return -- approximations start from z = -1/e
			convergeLambertW(z, -1 - g - g*g/3),
			convergeLambertW(z, -1 + g - g*g/3)
	elseif z < 0 then -- two solutions
		return
			convergeLambertW(z, -2),
			convergeLambertW(z, z/(z + 1))
	elseif z == 0 then
		return -1/0, 0 -- debating whether to return infinity or not.
	else -- one solution
		return convergeLambertW(z, z/(z + 1))
	end
end

function convergeLambertW(z: number, x: number): number
	for i = 1, 3 do
		local r = (z + z/x)/(1 + math.log(z/x))
		local s = math.log(r)
		-- separate newton iteration with only fundmental operations
		x = (s*s*r + z)/((s + 1)*r)
	end
	return x
end

return lambertW
