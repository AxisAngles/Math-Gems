-- This function takes an iterative approach to finding the nearest pure rotation to the given CFrame, C.
-- It is better than CFrame:Orthonormalize() because it minimizes drift over time,
-- whereas CFrame:Orthonormalize() merely guarantees that it returns some pure rotation.

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

-- If calling this every frame, one only needs to do a single iteration of the orthonormalize routine below:
-- One iteration will exactly resolve errors < 1/1000 to full floating point precision
local function iterateOrthonormalize(C: CFrame): CFrame
	local px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz = C:GetComponents()
	local det = (xz*yx - xx*yz)*zy + (xx*yy - xy*yx)*zz + (xy*yz - xz*yy)*zx
	return CFrame.new(px, py, pz,
		(xx + (yy*zz - yz*zy)/det)/2, (yx + (xz*zy - xy*zz)/det)/2, (zx + (xy*yz - xz*yy)/det)/2,
		(xy + (yz*zx - yx*zz)/det)/2, (yy + (xx*zz - xz*zx)/det)/2, (zy + (xz*yx - xx*yz)/det)/2,
		(xz + (yx*zy - yy*zx)/det)/2, (yz + (xy*zx - xx*zy)/det)/2, (zz + (xx*yy - xy*yx)/det)/2)
end
