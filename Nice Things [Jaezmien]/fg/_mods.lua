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

pmods.xmod = 1.5
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
	{ b+1, m*100, 'square' }
	{ b+2, m*-80, 'square' }
	{ b+3, m*60, 'square' }
	{ b+4, m*-40, 'square' }
	{ b+5, m*20, 'square' }
	{ b+6, m*-10, 'square' }
	{ b+7, m*5, 'square' }
	{ b+8, 0, 'arrowpathgirth', 'square' }
end

-- Intro
-- Intro
do

	ease{ 0, 100, 'dark' }
	ease{ 8, 24, inOutCubic, 0, 'dark' }

	GAMESTATE:ForceSmoothLines( 0 )
	ease{ 0, 1600, 'arrowpathgirth' }
	ease{ 0, 100, 'arrowpath0' }{ 0, 3, outCubic, 0, 'arrowpath0' }
	
	local dig = 1
	for i=0.5, 3, 0.5 do
		-- ease{ i, 200 * dig, 'square', i * 100, 'squareoffset' }
		dig = -dig
	end
	
	ease{ 4, 100, 'arrowpath1', 50, 'stealth' }{ 4, 3, outCubic, 0, 'arrowpath1', 100, 'stealth' }
	ease{ 4, 400, 'drawsize', 'arrowpathdrawsize' }	
	func_ease{ 4, 8, 1, 0, function(v)
		mod_plr(function(p)
			p:SetYSpline(0,-1,-v*100*8,0.1,-1)
			p:SetYSpline(1,-1,-v*100*8,0.1,-1)
		end)
	end }

	for i=4.5, 8, 0.5 do
		-- ease{ i, 200 * dig, 'square', i * 100, 'squareoffset' }
		dig = -dig
	end

	ease{ 8, 100, 'arrowpath2' }{ 8, 3, outCubic, 0, 'arrowpath2' }
	ease{ 16, 100, 'arrowpath3' }{ 16, 3, outCubic, 0, 'arrowpath3' }

	ease{ 8, 24, inOutSine, 20, 'stealth' }
	-- ease{ 36, 12000, 'tandrunkperiod' }{ 36, 40, inCubic, 100, 'tandrunk' }
	
end

-- build (up)
do
	ease{ 40, 0, 'stealth' }

	for i,v in pairs( intro_taps ) do
		ease{ v, 0, 'drop', 'rotationx' }
		if v ~= intro_taps[#intro_taps] then
			local next = intro_taps[i+1]
			ease{ v, next-v, linear, 100 * (next-v), 'drop' }
			ease{ v, math.random(-45,45), 'rotationx' }
		end
	end

	ease{ 47.5, 0.5, outCubic, 100, 'invert' }{ 48, 0.5, outCubic, 0, 'invert' }
	ease{ 52, 100, 'sudden', 25, 'suddenoffset' }{ 53.5, 0, 'sudden', 'suddenoffset' }
	ease{ 53.25, 100, 'hidenoteflash' }{ 53.75, 0, 'hidenoteflash' }

	ease{ 53.5, 100, 'dark0', 'dark1', 'dark2', 'dark3', 90, 'stealth0', 'stealth1', 'stealth2', 'stealth3' }
	ease{ 54.5, 0, 'dark0', 'stealth0' }{ 55, 0, 'dark1', 'stealth1' }{ 55.5, 0, 'dark2', 'stealth2' }{ 55.833, 0, 'dark3', 'stealth3' }
end

-- chore
do
	ease{ 56-0.5, 50, 'beat' }{ 56, 2, outCubic, 100, 'wave', 100, 'bumpy', 10, 'dizzy', 1000, 'parabolaz' }
	ease{ 88-0.5, 0, 'beat' }

	-- local tip = 1
	-- pmods.drunkspacing = 250
	-- for i=56, 85, 1 do
	-- 	ease{ i, -50, 'tinyx', 25, 'tinyy' }{ i, 4, outElastic, 0, 'tinyx', 'tinyy', 'drunk' }{ i, 4, outElastic, 50 * tip, 'drunk', extra={1.5,1}}
	-- 	tip = -tip
	-- end

	local pitch = {
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
	local mlt = 1
	for _,v in pairs( pitch ) do
		-- ease{ v[1], 25, 'tinyx', -25, 'tinyy' }{ v[1], 2, outElastic, 40 * v[2], 'movey', 0, 'tinyx', 'tinyy', extra={1,1} }
		ease{ v[1], 4, 40 * mlt, 'drunk' }
		mlt = -mlt
	end
end

-- reeeeeeeeeeeeeeeeee
do
	-- ease{ 88, 100, 'tornado', 'tornadoz'}
	-- ease{ 88, 104, linear, 1000, 'centered2', -1000, 'movey'}
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
	func{ 56, function() scroll = 0.015 end, persist=true }
	func_ease{ 88, 4, 0.015, 0.015/2, function(v)scroll=v;end, linear}
	func{ 116, function() fg('noise'):hidden(0) end }
	func_ease{116, 120-0.1, 0, 1, function(v) pixel=16+(16*v); fg('noise'):diffusealpha(v) end, inCubic}
	func{ 120, function() pixel=16; fg('noise'):hidden(1); split_amount_mult = 0; split_amount = 0; scroll = 0; end, persist=true }
	func{ 136, function() scroll = 0.015 end, persist=true }

	local intap = {}
	-- for _,v in pairs( old_intro_taps ) do table.insert( intap, v ) end
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