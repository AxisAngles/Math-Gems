-- By eev1993 & AxisAngle
--This is an "improvement" on AxisAngle's solve function.
--Commentary will be given.
local err = 1e-6
@native
local function solve(a, b, c, d, e)
	if not a then
		return
	elseif -err < a and a < err then
		return solve(b, c, d, e)
	end
	if e then
		--y^4 + p y^2 + q y + r = 0, x = y + k
		local k = -b/(4*a)
		local p = (c + k*(3*b + 6*a*k))/a
		local q = (d + k*(2*c + k*(3*b + 4*a*k)))/a
		local r = (e + k*(d + k*(c + k*(b + a*k))))/a

        --[[
            The problem with the original code was that the method for biquadratic checking was inneficient.
            Instead of solving the resolvent cubic first and checking if the non-negative root is 0, one can check if q = 0 or not (this is implied because the resolvent cubic z^3 + 2pz^2 + (p^2-4r)z - q^2 has 0 as its root when q = 0)
        ]]
		if -err < q and q < err then
			--Another issue with the old code was that it was missing two other roots for the biquadratic.
			local f0, f1 = solve(1, p, r)
			if not f1 or f1 < 0 then
				return
			elseif f0 < 0 then -- we were missing this split case - AxisAngle
				local g1 = math.sqrt(f1)
				return k - g1, k + g1
			else
				local g0, g1 = math.sqrt(f0), math.sqrt(f1)
				return k - g1, k - g0, k + g0, k + g1
			end
		end

		--z will always be positive (easily proven via IVT or Vieta's theorem).
		local z1, z2, z3 = solve(1, 2*p, p*p - 4*r, -q*q)
		local z = z3 or z1
		local w = math.sqrt(z)

		local r1, r2 = solve(1, w, (z + p - q/w)/2)
		local r3, r4 = solve(1, -w, (z + p + q/w)/2)

		if r1 and r3 then
			return k + r1, k + r2, k + r3, k + r4
		elseif r1 then
			return k + r1, k + r2
		elseif r3 then
			return k + r3, k + r4
		end
	elseif d then
		--y^3 - 3yp - 2q = 0, x = y + k
		local k = -b/(3*a)
		local p = -(c + k*(2*b + 3*a*k))/(3*a)
		local q = -(d + k*(c + k*(b + a*k)))/(2*a)
		local r = q*q - p*p*p
		local s = math.sqrt(math.abs(r))

		if r > 0 then
			local t = q + s
			local u = q - s
			--Stupid lua
			t = t < 0 and -(-t)^(1/3) or t^(1/3)
			u = u < 0 and -(-u)^(1/3) or u^(1/3)

			--The reason I'm not doing k + s + p/s is because of the case when s = 0.
			return k + t + u
		else
			--Stupid signed 0 bullshit
			local t = math.atan2(s, q)/3
			local m = 2*math.sqrt(p)
			--pi/6 = 0.5235987755982988
			--This is coded such that it returns from the smallest to biggest root.
			--This is because -sin(t+pi/6) < sin(t-pi/6) < cos(t) for t \in [0,pi/3].
			--atan2(y, x) has a range [-pi, pi]. That means atan2((-r)^0.5, q)/3 has a range [-pi/3, pi/3]. But because (-r)^0.5 >= 0, it's either in the first or second quadrant, which means the range becomes [0,pi/3].
			return k - m*math.sin(t + 0.5235987755982988), k + m*math.sin(t - 0.5235987755982988), k + m*math.cos(t)
		end
	elseif c then
		local k = -b/(2*a)
		local p = k*k - c/a
		if p < 0 then
			return
		else
			local q = math.sqrt(p)
			return k - q, k + q
		end
	elseif b then
		return -b/a
	end
end






-- here is separated out solve code for performance.
--!native

-- By eev1993 & AxisAngle
local err = 1e-6

local function solve1(a: number, b: number): number
	return -b/a
end

local function solve2(a: number, b: number, c: number): (number?, number?)
	local k = -b/(2*a)
	local p = k*k - c/a
	if p < 0 then
		return
	else
		local q = math.sqrt(p)
		return k - q, k + q
	end
end

local function solve3(a: number, b: number, c: number, d: number): (number?, number?, number?)
	local k = -b/(3*a)
	local p = -(c + k*(2*b + 3*a*k))/(3*a)
	local q = -(d + k*(c + k*(b + a*k)))/(2*a)
	local r = q*q - p*p*p
	local s = math.sqrt(math.abs(r))

	if r > 0 then
		local t = q + s
		local u = q - s
		t = t < 0 and -(-t)^(1/3) or t^(1/3)
		u = u < 0 and -(-u)^(1/3) or u^(1/3)
		return k + t + u
	else
		local t = math.atan2(s, q)/3
		local m = 2*math.sqrt(p)
		return k - m*math.sin(t + math.pi/6), k + m*math.sin(t - math.pi/6), k + m*math.cos(t)
	end
end

local function solve4(a: number, b: number, c: number, d: number, e: number)
	local k = -b/(4*a)
	local p = (c + k*(3*b + 6*a*k))/a
	local q = (d + k*(2*c + k*(3*b + 4*a*k)))/a
	local r = (e + k*(d + k*(c + k*(b + a*k))))/a

	if -err < q and q < err then
		-- Biquadratic case: solve y^2 + p*y + r = 0 for y, then take sqrt
		-- Inline solve2(1, p, r)
		local K = -p/2
		local P = K*K - r
		
		if P < 0 then
			return
		end
		
		local Q = math.sqrt(P)
		local f0 = K - Q
		local f1 = K + Q
		
		if f1 < 0 then
			return
		elseif f0 < 0 then
			local g1 = math.sqrt(f1)
			return k - g1, k + g1
		else
			local g0, g1 = math.sqrt(f0), math.sqrt(f1)
			return k - g1, k - g0, k + g0, k + g1
		end
	end

	local z do
		local B = 2*p
		local C = p*p - 4*r
		local D = -q*q

		local K = -B/3
		local P = -(C + K*(2*B + 3*K))/3
		local Q = -(D + K*(C + K*(B + K)))/2
		local disc = Q*Q - P*P*P

		if disc > 0 then
			local s = math.sqrt(disc)
			local t = Q + s
			local u = Q - s
			t = t < 0 and -(-t)^(1/3) or t^(1/3)
			u = u < 0 and -(-u)^(1/3) or u^(1/3)
			z = K + t + u
		else
			local s = math.sqrt(-disc)
			local t = math.atan2(s, Q)/3
			local m = 2*math.sqrt(P)
			z = K + m*math.cos(t)
		end
	end

	local w = math.sqrt(z)

	local c1 = (z + p - q/w)/2
	local K1 = -w/2
	local P1 = K1*K1 - c1
	
	local c2 = (z + p + q/w)/2
	local K2 = w/2
	local P2 = K2*K2 - c2

	if P1 < 0 and P2 < 0 then
		return
	elseif P1 < 0 then
		local Q2 = math.sqrt(P2)
		return k + K2 - Q2, k + K2 + Q2
	elseif P2 < 0 then
		local Q1 = math.sqrt(P1)
		return k + K1 - Q1, k + K1 + Q1
	else
		local Q1 = math.sqrt(P1)
		local Q2 = math.sqrt(P2)
		return k + K1 - Q1, k + K1 + Q1, k + K2 - Q2, k + K2 + Q2
	end
end

local function solve(a, b, c, d, e)
	if -err < a and a < err then
		return solve(b, c, d, e)
	end

	if     e then return solve4(a, b, c, d, e)
	elseif d then return solve3(a, b, c, d)
	elseif c then return solve2(a, b, c)
	elseif b then return solve1(a, b)
	else          return
	end
end
