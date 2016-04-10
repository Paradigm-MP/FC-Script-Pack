function math.round(n, i)
	local m = 10^(i or 0)
	return math.floor(n * m + 0.5) / m
end
