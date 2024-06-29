local function fromRotationVector(r)
	local l = r.magnitude
	if l < 1e-100 then
		return CFrame.new(0, 0, 0, r.x/2, r.y/2, r.z/2, 1)
	end
	local co = math.cos(l/2)
	local sinc = math.sin(l/2)/l
	return CFrame.new(0, 0, 0, sinc*r.x, sinc*r.y, sinc*r.z, co)
end

-- inverse of moment of inertia, angular momentum, rotation, delta time, optional known energy
-- can also pass energy
-- this is a theoretical look, and is not as good in practice as another method
local function stepRotation(S: CFrame, L: Vector3, C0: CFrame, dt: number, E: number?)
	local p0 = C0.Position
	local R0 = C0.Rotation

	-- as a body freely spins, the angular velocity sits in between the axis the body wants to rotate about
	-- (minor moment of inertia eigenvector) and the axis angular momentum
	-- this causes the body to precess, the angular momentum rotate about the axis of angular momentum
	
	-- in order to simulate this behavior...
	-- we can split up our angular velocity into two angular velocities, one global, u, and one local, v.
	-- the global angular velocity, u, is about L, our angular momentum
	
	-- we know analytically what the angular acceleration is
	-- so we can use this information to compute what the precession angular velocity is (angular velocity about L)
	-- and use the precession velocity and the overall angular velocity to find the secondary axis velocity
	
	local G = R0*S*R0:Inverse()
	local w = G*L -- angular velocity
	local c = L:Cross(w) -- some kind of virtual torque???
	local a = G*c -- this is the angular acceleration
	local u = c:Dot(a)/c:Dot(c)*L -- this is the precession angular velocity (primary)
	local v = w - u -- this is the secondary axis velocity
	
	-- INVARIANTS
	-- L:Dot(w)/2
  -- energy is invariant
  
	-- sign(u:Dot(v))
	-- if u:Dot(v) < 0, v is oscillating about the major inertia eigenvector
	-- if u:Dot(v) > 0, v is oscillating about the minor inertia eigenvector
	-- if u:Dot(v) = 0, v is along the middle inertia eigenvector
	-- if we are spinning really fast, we probably want to rotate about the eigenvector of oscillation because the energy is well bounded

	-- L:Cross(w):Dot(a)/2 - L:Dot(w)/2*w:Dot(w)
	-- Llength * rate of area swept by precessing w - energy * w^2 = const
	
	local R1 = fromRotationVector(dt*u)*fromRotationVector(dt*v)*R0
	local E0 = E or L:Dot(w)/2
	
	-- do some iterations to correct the energy
	for i = 1, 1 do -- iterations
		local w1 = R1:VectorToWorldSpace(S*R1:VectorToObjectSpace(L))
		local E1 = L:Dot(w1)/2
		local r = L:Cross(w1)
		local D = r:Dot(r)
		--E1 + D*t == E0
		local t = (E1 - E0)/D
		R1 = fromRotationVector(t*r)*R1
	end
	--local w1 = R1:VectorToWorldSpace(S*R1:VectorToObjectSpace(L))
	--local E1 = L:Dot(w1)/2
	--print(E0, E1)
	
	return R1 + p0
end
