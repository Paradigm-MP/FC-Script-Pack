oldunpack = table.unpack

function table.unpack(thing)
	if thing == nil then
		return
	else
		return oldunpack(thing)
	end
end