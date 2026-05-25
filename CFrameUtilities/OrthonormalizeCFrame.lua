-- This function finds the nearest pure rotation to the matrix M, given as three column vectors.
-- It is better than CFrame:Orthonormalize() because it minimizes drift over time,
-- whereas CFrame:Orthonormalize() merely guarantees that it returns some pure rotation.
local function orthonormalizeRaw(Mx: vector, My: vector, Mz: vector): (vector, vector, vector)
	-- D = S^2 = M^T M, symmetric positive semi-definite, D for double
	local Dxx           = vector.dot(Mx, Mx)
	local Dxy, Dyy      = vector.dot(Mx, My), vector.dot(My, My)
	local Dxz, Dyz, Dzz = vector.dot(Mx, Mz), vector.dot(My, Mz), vector.dot(Mz, Mz)

	-- characteristic polynomial of S^2, l^3 - p2 l^2 + p1 l - p0 = 0
	local p0 = (Dxy*Dyz - Dxz*Dyy)*Dxz + (Dxy*Dxz - Dxx*Dyz)*Dyz + (Dxx*Dyy - Dxy*Dxy)*Dzz
	local p1 = Dxx*Dyy + Dxx*Dzz + Dyy*Dzz - Dxy*Dxy - Dxz*Dxz - Dyz*Dyz
	local p2 = Dxx + Dyy + Dzz

	-- depressed cubic of the elegant form t^3 - 3 p t - 2 q = 0
	local k = p2/3
	local p = -(p1 - k*(2*p2 - 3*k))/3
	local q = -(-p0 + k*(p1 - k*(p2 - k)))/2
	if p <= 0 then -- we have a degenerate triple root case
		local f = math.sqrt(k)
		return Mx/f, My/f, Mz/f
	end

	local r = p*p*p - q*q
	local s = math.sqrt(math.max(0, r))
	local m = 2*math.sqrt(p)

	local t = math.atan2(s, q)/3 -- more accurate than arccos
	-- by construction l0 <= l1 <= l2
	-- mu are the roots of S, the sqrt(D)
	local mu0 = math.sqrt(math.max(0, k - m*math.sin(t + math.pi/6)))
	local mu1 = math.sqrt(math.max(0, k + m*math.sin(t - math.pi/6)))
	local mu2 = math.sqrt(math.max(0, k + m*math.cos(t            )))
	-- but we need to flip the minimum one if det(M) < 0
	-- so that the output rotation has a determinant of 1 (not -1)
	local detM = vector.dot(vector.cross(Mx, My), Mz)
	if detM < 0 then mu0 = -mu0 end

	-- characteristic polynomial of S, m^3 - q2 m^2 + q1 m - q0 = 0
	local q0 = mu0*mu1*mu2
	local q1 = mu0*mu1 + mu0*mu2 + mu1*mu2
	local q2 = mu0 + mu1 + mu2

	-- S is a root of its own characteristic polynomial
	-- S^3 - q2 S^2 + q1 S - q0 = 0
	-- S D - q2 D + q1 S - q0 = 0
	-- S (D + q1) - q2 D - q0 = 0
	-- S = (q2 D + q0) (D + q1)^-1

	-- N = D + q1
	local Nxx           = Dxx + q1
	local Nxy, Nyy      = Dxy, Dyy + q1
	local Nxz, Nyz, Nzz = Dxz, Dyz, Dzz + q1

	-- H = q2 D + q0
	local Hxx           = q2*Dxx + q0
	local Hxy, Hyy      = q2*Dxy, q2*Dyy + q0
	local Hxz, Hyz, Hzz = q2*Dxz, q2*Dyz, q2*Dzz + q0

	-- detH*inv(H)
	local Axx           = Hyy*Hzz - Hyz*Hyz
	local Axy, Ayy      = Hxz*Hyz - Hxy*Hzz, Hxx*Hzz - Hxz*Hxz
	local Axz, Ayz, Azz = Hxy*Hyz - Hxz*Hyy, Hxy*Hxz - Hxx*Hyz, Hxx*Hyy - Hxy*Hxy
	local detH = Hxx*Axx + Hxy*Axy + Hxz*Axz

	-- S^-1
	local Ixx = (Nxx*Axx + Nxy*Axy + Nxz*Axz)/detH
	local Ixy = (Nxx*Axy + Nxy*Ayy + Nxz*Ayz)/detH
	local Iyy = (Nxy*Axy + Nyy*Ayy + Nyz*Ayz)/detH
	local Ixz = (Nxx*Axz + Nxy*Ayz + Nxz*Azz)/detH
	local Iyz = (Nxy*Axz + Nyy*Ayz + Nyz*Azz)/detH
	local Izz = (Nxz*Axz + Nyz*Ayz + Nzz*Azz)/detH

	-- R = M S^-1
	local Rx = Mx*Ixx + My*Ixy + Mz*Ixz
	local Ry = Mx*Ixy + My*Iyy + Mz*Iyz
	local Rz = Mx*Ixz + My*Iyz + Mz*Izz

	return Rx, Ry, Rz
end

local function orthonormalize(C: CFrame): CFrame
	local px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz = components(cframe)
	return CFrame.fromMatrix(
		vector.create(px, py, pz),
		normalizeRaw(
			vector.create(xx, xy, xz),
			vector.create(yx, yy, yz),
			vector.create(zx, zy, zz)))
end

-- If calling this every frame, one only needs to do a single iteration of the orthonormalize routine below:
-- One iteration will exactly resolve errors < 1/1000 to full floating point precision
local function iterateOrthonormalize(C: CFrame): CFrame
	local x, y, z = C.XVector, C.YVector, C.ZVector
	local z_x = vector.cross(z, x)
	local x_y = vector.cross(x, y)
	local y_z = vector.cross(y, z)
	local det = vector.dot(x, y_z)
	return CFrame.fromMatrix(C.Position,
		(x + y_z/det)/2,
		(y + z_x/det)/2,
		(z + x_y/det)/2)
end

-- Old iterative method for normalizing
--[[
local function orthonormalize(C: CFrame, maxIterations: number?): CFrame
	local px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz = C:GetComponents()
	local det = (xz*yx - xx*yz)*zy + (xx*yy - xy*yx)*zz + (xy*yz - xz*yy)*zx
	
	if det < 0 then return CFrame.new(px, py, pz) end

	for i = 1, maxIterations or 10 do
		xx, yx, zx, xy, yy, zy, xz, yz, zz = 
			(xx + (yy*zz - yz*zy)/det)/2, (yx + (xz*zy - xy*zz)/det)/2, (zx + (xy*yz - xz*yy)/det)/2,
			(xy + (yz*zx - yx*zz)/det)/2, (yy + (xx*zz - xz*zx)/det)/2, (zy + (xz*yx - xx*yz)/det)/2,
			(xz + (yx*zy - yy*zx)/det)/2, (yz + (xy*zx - xx*zy)/det)/2, (zz + (xx*yy - xy*yx)/det)/2
		det = (xz*yx - xx*yz)*zy + (xx*yy - xy*yx)*zz + (xy*yz - xz*yy)*zx
		if det < 1.0000001 then break end
	end
	
	return CFrame.new(px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz):Orthonormalize()
end
]]
