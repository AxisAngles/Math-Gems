-- Gives a true inverse of the rotation part of S
local function inverse(S)
	local _, _, _, xx, yx, zx, xy, yy, zy, xz, yz, zz = S:components()
	local det = xz*(yx*zy - yy*zx) + xy*(yz*zx - yx*zz) + xx*(yy*zz - yz*zy)
	return CFrame.new(0, 0, 0,
		(yy*zz - yz*zy)/det, (yz*zx - yx*zz)/det, (yx*zy - yy*zx)/det,
		(xz*zy - xy*zz)/det, (xx*zz - xz*zx)/det, (xy*zx - xx*zy)/det,
		(xy*yz - xz*yy)/det, (xz*yx - xx*yz)/det, (xx*yy - xy*yx)/det)
end
