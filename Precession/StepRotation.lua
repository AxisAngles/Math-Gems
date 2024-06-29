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
local function stepRotation(S: CFrame, L: Vector3, R0: CFrame, dt: number, E: number?)
	local w0 = R0:VectorToWorldSpace(S*R0:VectorToObjectSpace(L))
	local E0 = E or L:Dot(w0)/2
	
	-- half step 0 (~ Rh0 = R0 + dt/2*getW(R0))
	local Rh0 = fromRotationVector(dt/2*w0)*R0
	local wh0 = Rh0:VectorToWorldSpace(S*Rh0:VectorToObjectSpace(L))
	local Eh0 = L:Dot(wh0)/2
	
	-- half step 1 (an approximation of ~ R0 = Rh1 - dt/2*getW(Rh1))
	local Rh1 = fromRotationVector(dt/2*wh0)*R0
	local wh1 = Rh1:VectorToWorldSpace(S*Rh1:VectorToObjectSpace(L))
	local Eh1 = L:Dot(wh1)/2
	
	-- combine the angular velocities at the half step to approximate the angular velocity through the whole step
	local wh = ((Eh1 - E0)*wh0 + (E0 - Eh0)*wh1)/(Eh1 - Eh0)

	local R1 = fromRotationVector(dt*wh)*R0
	
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

	return R1
end
