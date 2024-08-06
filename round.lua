-- rounds to nearest interval on
-- ..., o - i, o, o + i, i + 2i, ...
local function round(x, i, o)
	i = i or 1
	o = o or 0
	return (x + i/2 - o)//i*i + o
end
