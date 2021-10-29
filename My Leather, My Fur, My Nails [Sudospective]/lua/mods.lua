xero()

PlayerFloatP = {}
KarenWalkP = {}
KarenPopP = {}
KarenFloatP = {}

-- thanks kid
local function getfirstsprite(actor)
	--First, check to see if we are a sprite. (I wish there was a better way...)
	--The second check is to see if we actually have an image file loaded in said sprite.
	--We don't have to check for GetTexture to exist because sprites always have that function.
	if string.find(tostring(actor),  "^Sprite" ) and actor:GetTexture():GetPath() ~= "" then
		--We're a loaded sprite? Alright, then we return what we were given.
		return actor
	elseif not string.find(tostring(actor),  "^table" ) and actor.GetChildren then
		--We're not a sprite? and we have the GetChildren function?
		--Alright, then look through our children.
		for key, curchild in pairs(actor:GetChildren()) do
			local grab = getfirstsprite(curchild)
			--Don't return curchild because it might be an actorframe.
			--Return what we've grabbed instead
			if grab then return grab end
		end
		return nil--There was nothing in the children table...
	else
		--We don't have anything to work from? Alright, we have nothing to give.
		return nil
	end
end

local karenwalk_ap = Def.ActorFrame {
	Name = 'WalkKarens',
	LoadCommand = function(self)
		self:fov(70)
		self:xy(scx, scy)
		self:SetDrawByZPosition(true)
	end,
	Def.BitmapText {
		Name = 'AgreeText',
		Text = 'do a subo hop if u also think player cute',
		Font = 'eurostile _normal',
		InitCommand = function(self)
			self:y(scy * 0.7)
			self:hidden(1)
		end,
	}
}
local karenpop_ap = Def.ActorFrame {
	Name = 'PopKarens',
	LoadCommand = function(self)
		self:fov(70)
		self:xy(scx, scy)
		self:SetDrawByZPosition(true)
	end,
}
local karenfloat_ap = Def.ActorFrame {
	Name = 'FloatKarens',
	LoadCommand = function(self)
		self:fov(70)
		self:xy(scx, scy)
		self:SetDrawByZPosition(true)
	end,
}

for i = 1, 4 do
	local idx = i
	karenwalk_ap[#karenwalk_ap + 1] = Def.ActorProxy {
		Name = 'KarenWalkP['.. idx ..']',
		LoadCommand = function(self)
			self:SetTarget(KarenWalk)
			if idx <= 2 then
				self:x(-120 * idx)
			else
				self:x(120 * (idx - 2))
			end
		end,
	}
end
for i = 1, 50 do
	karenpop_ap[#karenpop_ap + 1] = Def.ActorProxy {
		Name = 'KarenPopP['.. i ..']',
		LoadCommand = function(self)
			self:SetTarget(KarenPop)
		end,
	}
end
for i = 1, 50 do
	local idx = i
	karenfloat_ap[#karenfloat_ap + 1] = Def.ActorProxy {
		Name = 'KarenFloatP['.. idx ..']',
		LoadCommand = function(self)
			self:SetTarget(KarenFloat)
			if idx % 2 == 1 then
				self:x(rand.float(-sw, sw))
				self:y(rand.int(-1, 1, 2) * sw)
			else
				self:x(rand.int(-1, 1, 2) * sh)
				self:y(rand.float(-sh, sh))
			end
			self:z(rand.float(250, -250))
			self:rotationx(rand.float(-360, 360) * 2)
			self:rotationy(rand.float(-360, 360) * 2)
			self:rotationz(rand.float(-360, 360) * 2)
			self:hidden(1)
		end,
	}
end

return Def.ActorFrame {
    LoadCommand = function(self)
        for pn = 1, 2 do
            setupJudgeProxy(PJ[pn], P[pn]:GetChild('Judgment'), pn)
            setupJudgeProxy(PC[pn], P[pn]:GetChild('Combo'), pn)
        end
        for pn = 1, #PP do
            PP[pn]:SetTarget(P[pn])
            P[pn]:hidden(1)
			P[pn]:x(scx)
        end

		self:fov(70)

		LimitAft(ScreenAFT)
		sprite(ScreenSprite)
		aftsprite(ScreenAFT, ScreenSprite)
		aftdiffuse(ScreenSprite, 0)
		ScreenSprite:zoom(1.01)
		
		aft(BloomAFT)
		sprite(BloomSprite)
		aftsprite(BloomAFT, BloomSprite)
		aftdiffuse(BloomSprite, 0)
		BloomSprite:blend('add')

		rand.seed(502)
		
		KarenWalk:rotationz(10)
		KarenPop:rotationz(10)

		func {0, 4, outCirc, sh, scy, function(p)
			WalkKarens:y(p)
			PopKarens:y(p)
		end}
		func {0, 4, outCirc, -128, 0, function(p)
			Welcome:y2(p)
		end}
		func {8, function()
			AgreeText:hidden(0)
		end}

		for beat = 0, 26, 2 do
			func {beat, function()
				KarenWalk:rotationz(-1 * KarenWalk:GetRotationZ())
				KarenPop:rotationz(-1 * KarenPop:GetRotationZ())
			end}
			func {beat, 1, outQuad, 0.11, 0.1, function(p)
				KarenWalk:zoom(p)
				KarenPop:zoom(p)
			end}
			func {beat, 1, bounce, scy * 0.5, scy * 0.45, function(p)
				KarenWalk:y(p)
				KarenPop:y(p)
			end}
			func {beat + 1, 1, outQuad, 0.11, 0.1, function(p)
				KarenWalk:zoom(p)
				KarenPop:zoom(p)
			end}
			func {beat + 1, 1, bounce, scy * 0.5, scy * 0.45, function(p)
				KarenWalk:y(p)
				KarenPop:y(p)
			end}
		end

		local notedata = {
			{16.000,0,1},
			{18.500,2,1},
			{19.000,1,2},
			{20.000,3,1},
			{22.500,2,1},
			{23.000,3,2},
			{24.000,0,1},
			{26.500,2,1},
			{27.000,0,2},
			{28.000,3,1},
			{29.000,3,1},
		}

		for _, t in ipairs(notedata) do
			local beat = t[1]
			local pos = (((t[2]) * rand.int(15, 45, 2)) % 4) + 1
			func {beat, 1, bounce, function(p)
				KarenWalkP[pos]:y2(-scy * 0.35 * p)
			end}
		end

		func {28, 4, inOutCirc, scy, sh, function(p)
			WalkKarens:y(p)
		end}
		
		for beat = 28, 30, 2 do
			func {beat, function()
				KarenWalk:rotationz(-1 * KarenWalk:GetRotationZ())
			end}
			func {beat, 1, outQuad, 0.11, 0.1, function(p)
				KarenWalk:zoom(p)
			end}
			func {beat, 1, bounce, scy * 0.5, scy * 0.45, function(p)
				KarenWalk:y(p)
			end}
			func {beat + 1, 1, outQuad, 0.11, 0.1, function(p)
				KarenWalk:zoom(p)
			end}
			func {beat + 1, 1, bounce, scy * 0.5, scy * 0.45, function(p)
				KarenWalk:y(p)
			end}
		end
		
		func {28, 4, inOutQuad, scy * 0.5, 0, function(p)
			KarenPop:rotationz(0)
			KarenPop:y(p)
		end}

		func {36, function()
			Welcome:SetTexture(Welcome2:GetTexture())
		end}

		func {32, 4, linear, function(p)
			aftdiffuse(BloomSprite, 0.15 * inExpo(p))
			aftdiffuse(ScreenSprite, 0.9 * p)
			KarenPop:zoom(0.1 + (0.35 * inExpo(p)))
			KarenPop:rotationz(10 * inQuad(p))
		end}

		-- It doesn't matter now. Keep going.
		func {36, function()
			for pn = 1, 2 do
				if P[pn] then getfirstsprite(P[pn]:GetChild('Judgment')):SetTexture(Fantastic:GetTexture()) end
			end
		end}
		--[[
		for beat = 36, 227 do
			func {beat, function()
				for pn = 1, 2 do
					if P[pn] then SCREENMAN:GetTopScreen():SetLife(pn - 1, 1) end
				end
			end}
		end
		--]]

		func {36, 1, outExpo, function(p)
			Welcome:diffusealpha(p)
		end}

		func {36, 4, outExpo, 0.45, 0.15, function(p)
			KarenPop:zoom(p)
		end}
		local kx, ky, kz = {}, {}, {}
		local krotx, kroty, krotz = {}, {}, {}
		for i = 1, 50 do
			kx[i], ky[i], kz[i] = rand.float(-sw, sw) * 3, rand.float(-sh, sh) * 3, rand.float(-500, 500) * 3
			krotx[i], kroty[i], krotz[i] = rand.float(-360, 360) * 2, rand.float(-360, 360) * 2, rand.float(-360, 360) * 2
		end
		func {36, 8, linear, function(p)
			for i = 1, 50 do
				KarenPopP[i]:x(kx[i] * p)
				KarenPopP[i]:y(ky[i] * p)
				KarenPopP[i]:z(kz[i] * p)
				KarenPopP[i]:rotationx(krotx[i] * p)
				KarenPopP[i]:rotationy(kroty[i] * p)
				KarenPopP[i]:rotationz(krotz[i] * p)
				KarenPop:diffusealpha(1 - p)
			end
		end}

		local x, y, z = {}, {}, {}
		local rotx, roty, rotz = {}, {}, {}
		for i = 1, 50 do
			local ki = i
			local offset = ki * 4
			local length = 32
			func {32 + offset, function()
				KarenFloatP[ki]:hidden(0)
			end}
			func {32 + offset, length, linear, 1, -1, function(p)
				x[ki], y[ki], z[ki] = (x[ki] or KarenFloatP[ki]:GetX()), (y[ki] or KarenFloatP[ki]:GetY()), (z[ki] or KarenFloatP[ki]:GetZ())
				rotx[ki], roty[ki], rotz[ki] = (rotx[ki] or KarenFloatP[ki]:GetRotationX()), (roty[ki] or KarenFloatP[ki]:GetRotationY()), (rotz[ki] or KarenFloatP[ki]:GetRotationZ())
				KarenFloatP[ki]:x(x[ki] * p)
				KarenFloatP[ki]:y(y[ki] * p)
				KarenFloatP[ki]:rotationx(rotx[ki] * p)
				KarenFloatP[ki]:rotationy(roty[ki] * p)
				KarenFloatP[ki]:rotationz(rotz[ki] * p)
			end}
		end

		func {164, 0.5, outBack, 0, 0.5, function(p)
			KarenBG:diffusealpha(p * 0.5)
			KarenBG:zoom(p)
			KarenBG:wag()
			KarenBG:effectperiod(8)
			KarenBG:effectmagnitude(0, 0, 10)
		end}
		
		func {228, 12, linear, function(p)
			ScreenFade:diffusealpha(p)
		end}
		func {228, function()
			ThankYou:hidden(0)
			ThankYou:cropright(0.52)
		end}
		func {233, function()
			ThankYou:cropright(0)
		end}

		setdefault {2, 'xmod', 100, 'modtimer', 100, 'stealthpastreceptors', 100, 'dizzyholds'}

		ease {32, 4, linear, 50, 'stealth', 1.5, 'xmod'}
		ease {35, 2, inOutExpo, 50, 'drunk', 50, 'wave'}
		set {36, 10, 'stealth'}
		ease {36, 4, flip(outExpo), 50, 'stealth'}

		local xf = -1
		for beat = 36, 220, 8 do
			xf = -xf
			add {beat, 8, bounce, 100 * xf, 'movex', 10 * xf, 'rotationy', -5 * xf, 'rotationz'}
			ease {beat, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 0.5, 0.5, pop, 20, 'stealth'}
			ease {beat + 1, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 1.5, 0.5, pop, 20, 'stealth'}
			ease {beat + 2, 2, flip(outExpo), 100, 'tiny', 150, 'zoomx', 90, 'zoomy'}
			ease {beat + 2.5, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 3, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 4, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 4.5, 0.5, pop, 20, 'stealth'}
			ease {beat + 5.5, 2, flip(outExpo), -75, 'tiny'}
			ease {beat + 6, 2, flip(outExpo), 100, 'tiny', 150, 'zoomx', 90, 'zoomy'}
			ease {beat + 7, 0.5, pop, 20, 'stealth'}
		end

		ease {131, 2, inOutExpo, -50, 'wave'}

		for beat = 132, 160, 4 do
			ease {beat, 4, inOutExpo, 100, 'invert'}
			ease {beat + 2, 4, inOutExpo, 0, 'invert'}
		end

		ease {163, 2, inOutExpo, 200, 'zoomz'}
		ease {164, 4, outElastic, 50, 'tipsy'}

		for beat = 164, 224, 4 do
			add {beat, 4, inOutQuad, 180, 'rotationy', -180 * math.pi/1.8, 'confusionyoffset'}
			--swap {beat, 4, inOutExpo, 'urld'}
			swap {beat, 4, inOutExpo, 'rudl'}
			add {beat + 2, 4, inOutQuad, 180, 'rotationy', -180 * math.pi/1.8, 'confusionyoffset'}
			swap {beat + 2, 4, inOutExpo, 'ldur'}
		end

		ease {177, 1, inOutExpo, 100, 'bumpyx'}
		ease {177.5, 1, inOutExpo, -100, 'bumpyx'}
		ease {178, 1, inOutExpo, 0, 'bumpyx'}
		ease {178.95, 1, pop, -200, 'tiny'}

		ease {193, 1, inOutExpo, 100, 'bumpyx'}
		ease {193.5, 1, inOutExpo, -100, 'bumpyx'}
		ease {194, 1, inOutExpo, 0, 'bumpyx'}
		ease {194.95, 1, pop, -200, 'tiny'}
		
		ease {209, 1, inOutExpo, 100, 'bumpyx'}
		ease {209.5, 1, inOutExpo, -100, 'bumpyx'}
		ease {210, 1, inOutExpo, 0, 'bumpyx'}
		ease {210.95, 1, pop, -200, 'tiny'}
		
		ease {225, 1, inOutExpo, 100, 'bumpyx'}
		ease {225.5, 1, inOutExpo, -100, 'bumpyx'}
		ease {226, 1, inOutExpo, 0, 'bumpyx'}
		ease {226.95, 1, pop, -200, 'tiny'}
		ease {227.5, 0.25, pop, -100, 'tiny'}
		ease {227.75, 0.25, pop, -100, 'tiny'}
		ease {227.5, 0.25, outCirc, 50, 'alternate'}
		ease {227.75, 0.25, outCirc, 0, 'alternate', 50, 'reverse'}
		ease {227.5, 4, outElastic, 50, 'flip'}

		set {228, 0, 'drunk', 0, 'tipsy'}
		ease {228, 12, outQuad, 200, 'tiny'}
		ease {228, 12, outQuad, 500, 'drunk', 500, 'tipsy', 50, 'reverse', 50, 'flip'}

		card {0, 35.5, 'Length and amount of association', 2, '#8830FF'}
		card {36, 227.75, 'is not proportionate', 6, '#808080'}
		card {228, 244, 'to length and amount of appreciation.', 1, '#FF3088'}

    end,

	Def.Quad {
		Name = 'HideEvent',
		InitCommand = function(self)
			self:xy(scx, scy)
			self:SetWidth(sw)
			self:SetHeight(sh)
			self:diffuse(0.6, 0.6, 0.9, 1)
		end,
	},
	Def.Sprite {
		Name = 'KarenBG',
		Texture = 'lua/assets/karen.png',
		InitCommand = function(self)
			self:xy(scx, scy)
			self:zoom(0)
		end,
	},
	Def.ActorFrame {
		Name = 'ScreenRot',
		InitCommand = xero.pivot,
		Def.ActorFrame {
			Name = 'ScreenPos',
			InitCommand = xero.offset,
			Def.ActorFrame {
				Name = 'PlayerFrame',
				Def.Sprite {
					Name = 'Fantastic',
					Texture = 'lua/assets/Judgment label 2x6.png',
					InitCommand = function(self)
						self:hidden(1)
					end,
				},
				Def.ActorProxy { Name = 'PP[1]' },
				Def.ActorProxy { Name = 'PP[2]' },
				Def.ActorProxy { Name = 'PJ[1]' },
				Def.ActorProxy { Name = 'PJ[2]' },
				Def.ActorProxy { Name = 'PC[1]' },
				Def.ActorProxy { Name = 'PC[2]' },
			},
			Def.Sprite {
				Name = 'Welcome',
				Texture = 'lua/assets/welcome.png',
				InitCommand = function(self)
					self:xy(scx, 48)
					self:y2(-128)
					self:wag()
					self:effectmagnitude(0, 0, 2)
				end,
			},
			Def.Sprite {
				Name = 'Welcome2',
				Texture = 'lua/assets/welcome2.png',
				InitCommand = function(self)
					self:hidden(1)
				end,
			},
			Def.ActorFrame {
				Name = 'KarenSprites',
				Def.Sprite {
					Name = 'KarenWalk',
					Texture = 'lua/assets/karen.png',
					InitCommand = function(self)
						self:addy(sh)
						self:zoom(0.1)
						self:hidden(1)
					end,
				},
				Def.Sprite {
					Name = 'KarenPop',
					Texture = 'lua/assets/karen.png',
					InitCommand = function(self)
						self:addy(sh)
						self:zoom(0.1)
						self:hidden(1)
					end,
				},
				Def.Sprite {
					Name = 'KarenFloat',
					Texture = 'lua/assets/karen.png',
					InitCommand = function(self)
						self:zoom(0.1)
						self:hidden(1)
					end,
				},
			},
			karenwalk_ap,
			karenpop_ap,
			karenfloat_ap,
			Def.Sprite { Name = 'ScreenSprite' },
			Def.ActorFrameTexture { Name = 'ScreenAFT' },
			Def.Sprite { Name = 'BloomSprite' },
			Def.ActorFrameTexture { Name = 'BloomAFT' },
		},
	},
	Def.Quad {
		Name = 'ScreenFade',
		InitCommand = function(self)
			self:xy(scx, scy)
			self:SetWidth(sw)
			self:SetHeight(sh)
			self:diffuse(0, 0, 0, 0)
		end,
	},
	Def.BitmapText {
		Name = 'ThankYou',
		Text = 'Thank you for being here.\nYour presence is invaluable.',
		Font = 'eurostile _normal',
		InitCommand = function(self)
			self:xy(scx, scy)
			self:hidden(1)
		end,
	}
}
