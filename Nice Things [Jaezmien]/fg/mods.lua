--[[
    Jaezmien's Wierd Mod Reader Syntax
    
    -------------------------------------------
    pmods, pmods_offset
    > These are tables that contain the player's current mods
    > You can do: `pmods[1].invert = 100` to apply invert to Player 1
    > Or, `pmods.flip = 100` to apply flip to all players*
    
    * Only in the default pn range
    -------------------------------------------
    redirs
    > This is a table that you can use to create a mod that uses a function
    > For example the `xmod` mod converts regular mod format into the proper XMod format.
    > You can also do the following:
    >   -- Create a redirect that, just applies flip for now
    >   redirs['flip_alternative'] = function(value,pn)
    >       return '*-1 '.. value ..' flip'
    >   end
    >   pmods.flip_alternative = 100 -- Applies `flip_alternative` to all players.
    >
    > There's also the alternative method:
    >   redirs{'mod name', function(value, player_number) (Optional)}

    -------------------------------------------
    ease, ease_offset
    > Eases a mod value to another value
    > Base Format:
    >   ease{ start_beat, length*, ease**, [mods]... }
    >
    > Mods Format:
    >   `new_value (optional), mod_string`. (Can be followed by more mods)
    >   The new value will be determined by the last seen number (default, 0)
    >       `200,' Drunk', 300, 'Tipsy'` will apply 200% Drunk and 300% Tipsy
    >       `100, 'invert', 'flip'` will apply 100% Invert and 100% Flip
    >   There's also optional parameters:
    >       `extra` (Number[]) = Used for extra parameters on specific eases
    >       `offset` (Boolean) = Will modify `pmods_offset` instead of `pmods`
    >       `plr` (Number[2] / Number) = Will call either a specific player or players instead of the default.
    >
    > Like Ky_Dash and Xero's Mod Reader. This returns the table itself, so you can stack call these!
    >
    > `ease_offset` does the same thing as `ease`, but applies the `offset` parameter automatically.
    >
    > Example:
    >   ease
    >   { 0, 360, 'rotationz' } -- Apply 360 rotationz
    >   { 0, 5, linear, 0, 'rotationz', 100, 'drunk' } -- Set rotationz to 0, and drunk to 100 in 5 beats, with linear ease.

    * Optional, will return `0` if not specified. Length is `len` by default. If the value is higher than `start_beat`, it will be treated as `end`
    ** Optional, will return `linear` if not specified. You can also use `ease=`, if you want to for some reason.
    -------------------------------------------
    func
    > `func` does two things:
    >   Perframe, with the format:
    >       { beat_start, beat_end, function }
    >   Message broadcast with the format:
    >       { beat_start, function (string/function) }
    >       `persist` (number/boolean) is optional.
    >           If it's a number, it will run the function if the song started past `beat_start+4` and the beat haven't gotten past the persist number.
    >           If it's a boolean, it will always run the function if the song started past `beat_start+4`.

    -------------------------------------------
    func_ease
    > Does an Exschwasion func_ease
    > Format:
    >   { beat_start, beat_length*, value_min, value_max, function, ease** }
    >   There's also optional parameters:
    >       `extra` (Number[]) = Used for extra parameters on specific eases

    * Length is `len` by default. If the value is higher than `start_beat`, it will be treated as `end`
    ** Optional, will return `linear` if not specified. You can also use `ease=`, if you want to for some reason.
    -------------------------------------------
    Extra stuffs:
        Dont want P1 and P2 to be the default players for some mod lines?
        Use `set_default_pn` to set the new players.
        Format:
            `set_default_pn( min, max ) -- [min - max]`
            `set_default_pn( {min, max} ) -- [min - max]`
            `set_default_pn( max ) -- [1 - max]`
            `set_default_pn() -- [1 - 2]`
            
    Oh! And even though this is in a mod reader environment, any variables created here will be visible in the `melody` env, so you don't have to worry about that.
]]

-- Insert mods here! --
-----------------------
local l, e = "len", "end"

-- i took a long break
-- i have no idea how to make files anymore
-- help

pmods.xmod = 1.75
pmods.dizzyholds = 100
-- pmods.gayholds = -100
-- pmods.spiralholds = 100
pmods.stealthpastreceptors = 100
-- pmods.grain = 5000
pmods.arrowpathdrawsizeback = 50
pmods.drawsizeback = 50
pmods.drawsize = 50
-- pmods.digital = 50
-- pmods.wave = 50

-- pants to lua
local intro_taps = {
	40, 41.5, 42.5,
	44, 45.5, 46.5,
	47.5,
	48, 49.5, 50.5,
	52,
	53.5
}

redirs['dark'] = function( v )
	local a = v<=0 and 0 or (50 + (v/100) * 50)
	return '*-1 '.. a ..' dark'
end
redirs['drop'] = function( v, p )
	mod_plr[p]:SetYSpline(0,-1,v*pmods[p].xmod,0.1,-1)
end
redirs['tappy'] = function(v,pn)
	pmods[pn].alternate = 5 * v
	pmods[pn].reverse = -2 * v
end

local function fork(b,m)
	local m=m or 1
	ease
	{ b, 10, 'arrowpath', 100, 'arrowpathgirth' }{ b, 8, linear, 0, 'arrowpath' }
	{ b, 0, 'square' }
	{ b+1, m*-100, 'square' }
	{ b+2, m*80, 'square' }
	{ b+3, m*-60, 'square' }
	{ b+4, m*40, 'square' }
	{ b+5, m*-20, 'square' }
	{ b+6, m*10, 'square' }
	{ b+7, m*-5, 'square' }
	{ b+8, 0, 'arrowpathgirth', 'square' }
end

-- Intro
do
	ease{ 0, 100, 'dark', 400, 'drawsize' }
	ease{ 8, 36, linear, 0, 'dark', 80, 'stealth' }{ 8, 0, 'drawsize' }

	ease{ 8, 1, 'spiralx', 'spiraly', -98, 'spiralxperiod', 'spiralyperiod', 200, 'spiralxoffset', 'spiralyoffset' }
	ease{ 8, 36, linear, 0, 2000, 'centered2', -2000, 'movey', -1250, 'squareoffset' }

	ease{ 0, 50, 'stealth', 100, 'centered' }{ 0, 3, linear, 100, 'stealth' }
	ease{ 4, 50, 'stealth' }{ 4, 3, linear, 100, 'stealth' }{ 4, 4, linear, 0, 'centered' }

	fork(8)
	fork(16,0.8)
	fork(24,0.6)
	fork(32,0.4)

	for i=24,32,4 do
		ease{ i, -20, 'flip' }{ i, 1, outCubic, 'flip' }
		ease{ i+1, -40, 'mini' }{ i+1, 1, outCubic, 'mini' }
		ease{ i+2.5, -20, 'flip' }{ i+2.5, 0.5, outCubic, 'flip' }
		ease{ i+3, -40, 'mini' }{ i+3, 1, outCubic, 'mini' }
	end

	ease{ 0, -800, 'drop' }{ 0, 8, linear, 0, 'drop' }
	ease{ 36, deg_to_rad(360)*4, 'confusionoffset'}
	ease{ 36, 40, inCubic, 0, 'stealth', 'centered2', 'movey', 'spiralx', 'spiraly', 'confusionoffset', 'square', 'squareoffset', 50, 'drawsize' }
	func{ 36, function()
		mod_plr(function(p,pn)
			local m = pn==2 and 1 or -1
			p:tween( am_bl(4), 'inCubic(%f,0,1,1)' )
			p:x( SCREEN_CENTER_X + 128 * m )
		end)
	end }
end

-- wop
do
	ease{ 40, 100, 'drawsizeback', 'arrowpathdrawsizeback' }{ 53.5, 20, 'drawsizeback' }
	func{40-0.1,function()
		mod_plr(function(p,pn)
			local m = pn==2 and 1 or -1
			p:x( SCREEN_CENTER_X + 128 * m )
		end)
	end,persist=54}

	local function scree(b,m)
		local m=m or 1
		ease
		{ b, 100, 'arrowpath2', 'arrowpath3', plr=1 }{ b, 100, 'arrowpath0', 'arrowpath1', plr=2 }
		{ b+1, 0, 'arrowpath0', 'arrowpath1', 'arrowpath2', 'arrowpath3' }
		{ b+1, 0, 'arrowpath', plr=2 }{ b+1, 100, 'arrowpath', plr=1 }
		{ b+2, 0, 'arrowpath', plr=1 }{ b+2, 50, 'arrowpath', plr=2 }
		{ b+3, 0, 'arrowpath', plr=2 }{ b+3, 20, 'arrowpath', plr=1 }
		{ b+4, 0, 'arrowpath', plr=1 }{ b+4, 10, 'arrowpath', plr=2 }
		{ b+5, 0, 'arrowpath' }
	end
	scree(40)
	scree(48)

	local bap = 0	
	for i,v in pairs( intro_taps ) do
		ease{ v, -50, 'drop' }
		if v ~= intro_taps[#intro_taps] then
			local next = intro_taps[i+1]
			ease{ v, next-v, linear, -50 + 100 * (next-v), 'drop' }
			func_ease{ v, 0.5, 1, 0, function(k) bap=k end, linear }
		else
			ease{ v, 0, 'drop' }
		end
	end
	func{ 40, 53.5, function(b)
		pmods.drunk = math.sin( b * math.pi * 32 ) * bap * 40
	end }
	ease{ 47.5, 0.5, outCubic, 100, 'invert' }{ 48, 0.5, outCubic, 0, 'invert' }

	local t = { 54.5, 55, 55.5, 55.883, 56 }
	for i,v in pairs(t) do
		local a = (i)/(#t)
		func{v,function()
			mod_plr(function(p,pn)
				local m = pn==2 and 1 or -1
				local x = mod_plr_origin[pn][1]
				p:x( math.norm(a,0,1,SCREEN_CENTER_X + 128 * m,x) )
				-- pmods[pn].confusionoffset = deg_to_rad(360) * (1-a)
			end)
		end}
	end
end

-- Chorus 1
local function swag(b)
	mod_bounce( b  , 1, 0,  20, 'rotationy', 'Quint' )
	mod_bounce( b+1, 1, 0, -20, 'rotationy', 'Quint' )
end
local lastrandomarrow = -1 -- sex
local function randomarrow()
	local new_arrow = lastrandomarrow
	while new_arrow == lastrandomarrow do new_arrow = math.random(0,3) end
	lastrandomarrow = new_arrow
	return new_arrow
end
local function eee(b)
	ease{ b, 10, 'tandigital', 'tandigitalz' }{ b, 1, outCubic, 0, 'tandigital', 'tandigitalz' }
end

local chorusHolds = {
	54.5, 55, 55.5, 56,
	58.5, 59, 59.5,
	61.5, 62.5, 63, 64,

	66.5, 67, 67.5,
	70.5, 71, 71.5, 72,
	74.5, 75, 75.5,
	77.5, 78.5, 79, 80,

	82, 82.5, 83, 83.5,
	85, 86, 87, 88
}
local chorusLongHolds = {
	[56]=true,
	[59.5]=true,
	[64]=true,
	[67.5]=true,
	[72]=true,
	[75.5]=true,
	[80]=true,
	[83.5]=true,
	[85]=true,
	[86]=true,
	[87]=true,
}
local chorusPitch = {
	{56, 0},
	{60, -1},
	{64, -0.7},
	{68, -0.3},
	{72, 0},
	{76, -1},
	{80, -0.7},
	{84, -0.3},
	{88, 0},
}
do
	ease{54.5, 100, 'arrowpathgirth', 2500, 'arrowpathgrain', 600, 'bumpyxperiod', -20, 'tandigitalperiod', -60, 'tandigitalzperiod' }
	ease_offset{54.5, 100, 'centered2', -100, 'movey'}
	local whee = 0

	local j = 1
	for v=56,82,4 do
		eee( v )
		eee( v+1.5 )
		eee( v+2.5 )
		if j == -1 then
			eee( v+3.5 )
		end
		j = -j
	end
	eee( 84 )
	eee( 88 )

	local w_m = 1
	local womp = 1
	for i,v in pairs( chorusHolds ) do
		if i == #chorusHolds then
			ease{ v, 4, outElastic, 0, 'drunk' }
		else
			local next = chorusHolds[i+1]
			ease{ v, (next-v)*0.5, outCubic, 50 * w_m, 'drunk' }
			local a = randomarrow()
			ease{ v, 100, 'arrowpath'..a }{ v, next, outCubic, 'arrowpath'..a }
			ease_offset{ v, 20, 'stealth'..a }{ v, next, outCubic, 0, 'stealth'..a }
			if next-v >= 1 then
				func_ease{ v, (next-v)-1, 1, 0, function(k)
					pmods[ 'bumpyx'..a ] = math.sin( GAMESTATE:GetSongBeat() * math.pi * 8 ) * k * 80
				end, linear }
			end
			if chorusLongHolds[v] then
				local add = (v - math.floor(v)) > 0 and 0.5 or 0
				mod_bounce( v, 1+add, 0, womp*200, 'bumpyx', 'Cubic' )
				womp = -womp
			end
		end
		w_m = -w_m
	end

	swag( 57 )
	swag( 65 )
	swag( 73 )
	swag( 81 )

	mod_bounce( 80, 1, 0, 50, 'brake', 'Cubic' )

	func{ chorusHolds[1], chorusHolds[#chorusHolds], function(b)
		pmods_offset.square = math.sin( b * math.pi * 256 ) * whee * 20
	end }

	ease{56-0.5,100,'beat'}{88-0.5,0,'beat'}
	ease{56,4,75,'wave',50,'bumpy'}
	for i=56,87 do
		mod_bounce(i,1,0,-20,'centered','Cubic')
	end

	local mlt = 1
	for _,v in pairs( chorusPitch ) do
		ease{ v[1], 2, outElastic, 40 * v[2], 'movey', extra={1,1} }
		mlt = -mlt
	end

	local tapm = 1
	for i=57,83,2 do
		ease{ i, 2, outElastic, tapm, 'tappy', extra={1.5,0.8} }
		ease{ i, 10, 'stealth', 40*tapm, 'dizzy' }{ i, 2, outCubic, 0, 'stealth', 'dizzy' }
		tapm = -tapm
	end
	ease{ 86.5, tapm, 'tappy' }
	ease{ 87  , -tapm, 'tappy' }
	ease{ 87.5, tapm, 'tappy' }
	ease{ 87.833, -tapm*0.5, 'tappy' }
	ease{ 88  , 0, 'tappy' }
end

-- brake
do
	ease{ 88, 1, linear, 100, 'dark' }
	ease_offset{ 88, 0, 'centered2', 'movey' }
	ease{ 88, 0, 'bumpyxperiod', 'tandigitalperiod', 'tandigitalzperiod', 400, 'tandrunkperiod', 0, 'arrowpathgrain' }
	ease{ 104, 116, linear, 0, 'dark' }
	ease{ 104, 8, linear, 50, 'expand' }{ 108, 8, linear, 0, 'expand' }

	fork(88,0.1)
	fork(88+8,0.8)
	fork(88+16,0.6)
	fork(88+24,0.4)

	local honk = function(v)
		local b = GAMESTATE:GetSongBeat()
		pmods.drunk = math.sin( b * math.pi * 16 ) * 40 * v
		pmods.tandrunk = 1 * v
	end

	func_ease{ 90.5, 0.5, 1, 0, honk, linear }
	ease{ 91, 0.5, outCubic, 100, 'invert' }{ 91.5, 0.5, outCubic, 0, 'invert' }

	ease{ 91.5, 20, 'mini' }{ 91.5, 0.5, outCubic, 'mini' }
	local hecks = {
		95.5,
		103,
		103.5,
		111.5,
		115.5,
	}
	for _,v in pairs( hecks ) do
		ease{ v, 40, 'mini' }{ v, 0.333, outCubic, 'mini' }
		ease{ v+0.333, 80, 'mini' }{ v+0.333, v+1, outCubic, 'mini' }
	end

	local awooga = 1
	for i=92,115,4 do
		local m = "invert"
		ease{ i+1, 0.5, outCubic, 100, m }{ i+1.5, 0.5, outCubic, 0, m }

		func_ease{ i, i+0.5, 1, 0, honk, linear }
		if awooga == 1 and i < 104 and i ~= 92 then
			func_ease{ i+2.5, i+3, 1, 0, honk, linear }
			func_ease{ i+3.5, i+4, 1, 0, honk, linear }
		else
			func_ease{ i+2.5, i+3, 1, 0, honk, linear }
			ease{ i+3, 0.5, outCubic, 100, m }{ i+3.5, 0.5, outCubic, 0, m }
		end
		awooga = -awooga
	end

	func{ 116, function()
		mod_plr(function(p,pn)
			local m = pn==1 and -1 or 1
			p:accelerate( am_bl(4) )
			p:x( SCREEN_CENTER_X + (SCREEN_CENTER_X*0.25) * m )
		end)
	end }
	ease{ 116, 120, inCubic, 50, 'brake' }{ 120, 'brake' }

	local hap = {
		116.5,
		117,
		117.333,
		117.5,
		118.833,
		119,
		119.333,
		119.5,
		119.833,
	}
	for i,v in pairs( hap ) do
		local m = (1 + math.mod(i+1,2)) == 1 and -1 or 1
		ease{ v, 2 * m, 'tappy' }
	end
	ease{ 117.833, -40, 'mini' }{ 117.833, 0.5, outCubic, 0, 'mini' }
	ease{ 118.333, -40, 'mini' }{ 118.333, 0.5, outCubic, 0, 'mini' }
	ease{ 120, 0, 'tappy' }
end

-- wop 2: boog
do
	ease{ 120, 0, 'wave', 'bumpy' }

	-- reuse shit
	old_intro_taps = table.clone( intro_taps )
	for i,v in pairs( intro_taps ) do intro_taps[i] = v+80 end

	func{120-0.1,function()
		mod_plr(function(p,pn)
			local m = pn==2 and 1 or -1
			p:x( SCREEN_CENTER_X + 32 * m )
		end)
		pmods.flip = -50
	end,persist=133.5}
	
	local bap = 0
	local fwomp = 1
	for i,v in pairs( intro_taps ) do
		if v ~= intro_taps[#intro_taps] then
			ease{ v, -50, 'drop' }
			local next = intro_taps[i+1]
			ease{ v, next-v, linear, -50 + 100 * (next-v), 'drop' }
			func_ease{ v, 0.5, 1, 0, function(k) bap=k end, linear }

			local inv,fli=0,0
			local plr=1
			if fwomp==1 or fwomp==2 then inv=200 end
			if fwomp==3 or fwomp==4 then fli=200 end
			if math.mod(fwomp+1,2)==1 then plr=2 end
			ease_offset{ v, 'flip', 'invert', 'stealth' }{ v, inv, 'invert', fli, 'flip', 80, 'stealth', plr=plr }
			fwomp = 1 + math.mod( fwomp , 4 )
		else
			ease{ v, 0, 'drop' }
			ease_offset{ v, 'invert', 'flip', 'stealth' }
		end
	end

	ease{ 127.5, 0.5, outCubic, 200, 'invert', plr=2 }
	ease{ 128, 0, 'invert', plr=2 }{ 128, 200, 'invert', plr=1 }{ 128, 0.5, outCubic, 'invert', plr=1 }

	func{ 120, 133.5, function(b)
		pmods.drunk = math.sin( b * math.pi * 32 ) * bap * 40
	end }
	

	local t = { 134.5, 135, 135.5, 135.883, 136 }
	for i,v in pairs(t) do
		local a = (i)/(#t)
		func{v,function()
			mod_plr(function(p,pn)
				local m = pn==2 and 1 or -1
				local x = mod_plr_origin[pn][1]
				p:x( math.norm(a,0,1,SCREEN_CENTER_X + 32 * m,x) )
				-- pmods[pn].confusionoffset = deg_to_rad(360) * (1-a) * -m
				pmods[pn].flip = -50 * (1-a)
				pmods[pn].invert = 0
			end)
		end}
	end

end

-- car
do
	ease{ 136-0.5, 400, 'beatz' }{ 168-0.5, 'beatz' }
	ease{ 136, 4, outCubic, 10, 'orient' }
	local function swoosh(b)
		func{b+1,function()
			mod_plr(function(p,pn)
				p:accelerate( am_bl(2) )
				p:x( SCREEN_CENTER_X )
				p:rotationz( pn==1 and 20 or -20 )
				p:decelerate( am_bl(2) )
				p:x( mod_plr_origin[3-pn][1] )
				p:rotationz( 0 )
			end)
		end}
		func{b+1+8,function()
			mod_plr(function(p,pn)
				p:accelerate( am_bl(2) )
				p:x( SCREEN_CENTER_X )
				p:rotationz( pn==2 and 20 or -20 )
				p:decelerate( am_bl(2) )
				p:x( mod_plr_origin[pn][1] )
				p:rotationz( 0 )
			end)
		end}
	end
	swoosh(136)
	swoosh(152)

	-- reuse shit
	for i=1,#chorusHolds do chorusHolds[i]=chorusHolds[i]+80 end
	for i=1,#chorusPitch do chorusPitch[i][1]=chorusPitch[i][1]+80 end
	chorusHolds[#chorusHolds]=nil
	chorusPitch[#chorusPitch]=nil

	ease{134.5, 100, 'arrowpathgirth', 2500, 'arrowpathgrain', 600, 'bumpyxperiod', -20, 'tandigitalperiod', -60, 'tandigitalzperiod' }
	ease_offset{134.5, 100, 'centered2', -100, 'movey'}
	ease_offset{168, 0, 'centered2', 0, 'movey'}
	local whee = 0

	local j = 1
	for v=56+80,82+80,4 do
		eee( v )
		eee( v+1.5 )
		eee( v+2.5 )
		if j == -1 then
			eee( v+3.5 )
		end
		j = -j
	end
	eee( 164 )

	local w_m = 1
	local womp = 1
	for i,v in pairs( chorusHolds ) do
		if i == #chorusHolds then
			local len = i == #chorusHolds and 2 or 4
			ease{ v, len, outElastic, 0, 'drunk' }
		else
			local next = chorusHolds[i+1]
			ease{ v, (next-v)*0.5, outCubic, 50 * w_m, 'drunk' }
			local a = randomarrow()
			ease{ v, 100, 'arrowpath'..a }{ v, next, outCubic, 'arrowpath'..a }
			ease_offset{ v, 20, 'stealth'..a }{ v, next, outCubic, 0, 'stealth'..a }
			if next-v >= 1 then
				func_ease{ v, (next-v)-1, 1, 0, function(k)
					pmods[ 'bumpyx'..a ] = math.sin( GAMESTATE:GetSongBeat() * math.pi * 8 ) * k * 80
				end, linear }
			end
			if chorusLongHolds[v-80] then
				local add = (v - math.floor(v)) > 0 and 0.5 or 0
				mod_bounce( v, 1+add, 0, womp*200, 'bumpyx', 'Cubic' )
				womp = -womp
			end
		end
		w_m = -w_m
	end

	swag( 57+80 )
	swag( 65+80 )
	swag( 73+80 )
	swag( 81+80 )

	mod_bounce( 160, 1, 0, 50, 'brake', 'Cubic' )

	func{ chorusHolds[1], chorusHolds[#chorusHolds], function(b)
		pmods_offset.square = math.sin( b * math.pi * 256 ) * whee * 20
	end }

	ease{80+56-0.5,100,'beat'}{88+80-0.5,0,'beat'}
	ease{80+56,4,75,'wave',50,'bumpy'}
	for i=56+80,87+80 do
		mod_bounce(i,1,0,-20,'centered','Cubic')
	end

	local mlt = 1
	for _,v in pairs( chorusPitch ) do
		ease{ v[1], 2, outElastic, 40 * v[2], 'movey', extra={1,1} }
		mlt = -mlt
	end

	for i=136,164,8 do
		-- ease{ i, -400, 'tiny' }{ i, 1, linear, 0, 'tiny' }
		ease{ i+0.5, 2, 'tappy' }
		ease{ i+1.5, -2, 'tappy' }

		ease{ i+2.5, 2, 'tappy' }
		ease{ i+3, -2, 'tappy' }
		ease{ i+3.5, 0, 'tappy' }

		if i<160 then
			ease{ i+4+0.5, 2, 'tappy' }
			ease{ i+4+1.5, -2, 'tappy' }
			ease{ i+4+2.5, 2, 'tappy' }
			ease{ i+4+3, -2, 'tappy' }
			ease{ i+4+3.5, 2, 'tappy' }
			ease{ i+8, 0, 'tappy' }
		end
	end

	mod_bounce( 167, 1, 0, -25, 'rotationx', 'Cubic' )
	mod_bounce( 167, 1, 0, 100, 'drunkz', 'Cubic' )

	ease{168,0,'bumpy','wave','movey'}
end

-- eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
do
	ease{ 168, 100, 'dark', 50, 'stealth', 100000, 'longholds', -100, 'drawsizeback' }
	ease{ 168-0.5, 100, 'halgun', 'hidenoteflash' }

	ease{ 169, 50, 'stealth', plr=1 }{ 169, 100, 'stealth', plr=2 }
	ease{ 170, 60, 'stealth', plr=2 }{ 170, 100, 'stealth', plr=1 }
	ease{ 171, 70, 'stealth', plr=1 }{ 171, 100, 'stealth', plr=2 }
	ease{ 172, 80, 'stealth', plr=2 }{ 172, 100, 'stealth', plr=1 }
	ease{ 173, 90, 'stealth', plr=1 }{ 173, 100, 'stealth', plr=2 }
	ease{ 174, 95, 'stealth', plr=2 }{ 174, 100, 'stealth', plr=1 }
	ease{ 175, 98, 'stealth', plr=1 }{ 175, 100, 'stealth', plr=2 }
end

-- Visual
do

	func{0,function() bg('itg'):diffuse(0,0,0,1) end,persist=8}
	func_ease{8, 36, 0, 1, function(v) bg('itg'):diffuse(v,v,v,1) end, linear}

	local pixel = 1
	local scroll = 0
	local rotate = 0

	local split_amount = 16
	local split_speed = 0
	local split_amount_mult = 0
	local split_rgb_amount = 0

	func{ 0, function()
		split_amount = 17
	end }
	local sex = 1
	for i=0.5,3.5,0.5 do
		func{ i, function()
			split_amount_mult = math.random_float(0.8,1.6) * sex
			sex = -sex
		end }
	end
	func{ 4, function()
		split_amount = 8
		split_amount_mult = 0
	end }
	for i=4.5,6.5,0.5 do
		func{ i, function()
			split_amount_mult = math.random_float(0.4,0.8) * sex
			sex = -sex
		end }
	end
	func{ 8, function()
		split_amount = 0
	end, persist = true }

	func{ 36, function()
		split_amount = 64
		split_amount_mult = 0
	end }
	func_ease{ 36, 40-0.1, 0, 1, function(v)
		split_amount_mult = v
		split_rgb_amount = v * 8
		screen:zoom( 1 + v * 0.1 )
	end, inCubic }
	func{ 53.5, function()
		screen:zoom( 1 )
	end, persist=true }

	func_ease{ 116, 120-0.1, 0, 1, function(v)
		split_amount = 128
		split_amount_mult = v
		split_rgb_amount = v * 8
	end, inCubic }

	-- func_ease{40, 56, 0, 0.005, function(v) scroll=v end, inCubic}
	func{ 36, function() fg('noise'):hidden(0) end }
	func_ease{36, 40-0.1, 0, 1, function(v) pixel=1+(31*v); fg('noise'):diffusealpha(v) end, inCubic}
	func{ 40, function() pixel=16; fg('noise'):hidden(1); split_amount_mult = 0; split_amount = 0; end, persist=true }
	func_ease{ 56, 4, 0, 0.015, function(v) scroll=v end, persist=true }
	func_ease{ 88, 4, 0.015, 0.015/2, function(v)scroll=v;end, linear}
	func{ 116, function() fg('noise'):hidden(0) end }
	func_ease{116, 120-0.1, 0, 1, function(v) pixel=16+(16*v); fg('noise'):diffusealpha(v) end, inCubic}
	func{ 120, function() pixel=16; fg('noise'):hidden(1); split_amount_mult = 0; split_amount = 0; scroll = 0; end, persist=true }
	func_ease{ 136, 4, 0, 0.015, function(v) scroll=v end, persist=true }

	local intap = {}
	for _,v in pairs( old_intro_taps ) do table.insert( intap, v ) end
	for _,v in pairs( intro_taps ) do table.insert( intap, v ) end

	for _, v in pairs( intap ) do
		local b = v == 53.5
		func{ v, function()
			rotate = b and ( 0 ) or ( math.random() + math.random(-4,4) )
		end }
	end

	func{ 53.5, function() pixel = 16 end, persist=true }
	func{ 120, function() pixel = 16 end, persist=true }

	func{ 168, function()
		bg('hide'):hidden(0)
		mod_plr(function(p,pn)
			proxy.get_proxy('P'.. pn ..' Judgment'):hidden( 1 )
			proxy.get_proxy('P'.. pn ..' Combo'):hidden( 1 )
		end)
	end, persist=true }

	update_hooks{'mod update',function()

		aft.get_sprite( 'pixel bg 1' ):zoom( 1 / pixel )
		aft.get_sprite( 'pixel bg 2' ):zoom( pixel )
		bg('itg'):rotationz( rotate )
		bg('itg'):texcoordvelocity( -scroll, 0 )

	end }

	do
		local sprite = aft.get_sprite( 'split' )
		local renderAftSplit = function()
			sprite:hidden(0)

			if split_amount > 0 then
				local amt = split_amount+1
				local fract = 1/amt
				for i=0,amt-fract,1 do

					local b = GAMESTATE:GetSongBeat()
					sprite:cropbottom(i/amt)
					sprite:croptop(1-((i+1)/amt))
					sprite:x2( math.sin((b * math.pi * 64 * split_speed) + i * math.cos(i)) * 60 * split_amount_mult )
					if split_rgb_amount > 0 then
						local a = split_rgb_amount * 10
						sprite:blend( 'add' )

						sprite:x( SCREEN_CENTER_X - a )
						sprite:diffuse( 1, 0, 0, 1 )
						sprite:Draw()

						sprite:x( SCREEN_CENTER_X )
						sprite:diffuse( 0, 1, 0, 1 )
						sprite:Draw()

						sprite:x( SCREEN_CENTER_X + a )
						sprite:diffuse( 0, 0, 1, 1 )
						sprite:Draw()
					else
						sprite:blend( 'normal' )
						sprite:Draw()
					end
	
				end
			else
				sprite:x( SCREEN_CENTER_X )
				sprite:x2( 0 )
				sprite:cropbottom( 0 )
				sprite:croptop( 0 )
				sprite:diffuse( 1, 1, 1, 1 )
				sprite:Draw()
			end

			sprite:hidden(1)
		end
		fg('aftSplitRender'):SetDrawFunction(function()
			local res, err = pcall( renderAftSplit )
			if not res then print( err ) end
		end)
	end

end