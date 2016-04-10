class 'CalcMaxExp'
function CalcMaxExp:__init()

end
function CalcMaxExp:Calculate(level)
	return (level * 40) + math.pow(level, 2.8)
end
CalcMaxExp = CalcMaxExp()