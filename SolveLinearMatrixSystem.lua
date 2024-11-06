--[[
solves for x in M*x = y
converts M into identity matrix
converts y into x

	M = {
		{M00, M01, M02, ...n},
		{M10, M11, M12, ...n},
		{M20, M21, M22, ...n},
		...n
	}

	x = {
		{x00, x01, x02, ...m},
		{x00, x01, x02, ...m},
		{x00, x01, x02, ...m},
		...n
	}

performs gaussian elimination
attempts to find the largest element each step, and swaps rows and columns
(so it is not fast, but error should be pretty low)
]]
function solveLinearSystem(M: {{number}}, y: {{any}})
	--column swaps need to go here
	local swaps = {}
	local d = #y[1]
	local n = #M

	for dag = 1, n do
		local largestI
		local largestJ
		local largestValue = 0
		for i = dag, n do
			for j = 1, n do
				local value = math.abs(M[i][j])
				if value > largestValue then
					largestValue = value
					largestI = i
					largestJ = j
				end
			end
		end
		if not (largestI and largestJ) then
			--error("singular matrix")
			break
		end

		-- swap the rows
		M[dag], M[largestI] = M[largestI], M[dag]
		y[dag], y[largestI] = y[largestI], y[dag]
		-- swap the cols
		swaps[dag] = largestJ
		--swaps[dag], swaps[largestJ] = swaps[largestJ], swaps[dag]
		for row = 1, n do
			local R = M[row]
			R[dag], R[largestJ] = R[largestJ], R[dag]
		end

		-- unitize the row
		local R = M[dag]
		local v = R[dag] -- should be largestValue
		for col = dag, n do
			R[col] /= v
		end
		for col = 1, d do
			y[dag][col] /= v
		end

		-- subtract from other rows
		for row = 1, n do
			local S = M[row]
			local u = S[dag]
			if row == dag then
				continue
			end
			for col = dag, n do
				S[col] -= u*R[col]
			end
			for col = 1, d do
				y[row][col] -= u*y[dag][col]
			end
		end
	end

	for i = #swaps, 1, -1 do
		local swap = swaps[i]
		y[i], y[swap] = y[swap], y[i]
	end
end
