xero()
function drop(t)
	local beat = t[1]
	local len = t[2]
	local step = t[3]
	local speedmod = t[4]
	for i = beat, beat + len, step do
		add
			{i, step, linear, speedmod * step * 100, 'centered2', plr = t.plr}
			{i + step, 0, instant, -speedmod * step * 100, 'centered2', plr = t.plr}
	end
end
return Def.Actor {}
