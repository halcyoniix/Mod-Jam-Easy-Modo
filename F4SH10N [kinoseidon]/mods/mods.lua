local _ENV = _ENV

do
    local _loadfile = loadfile
    function loadfile(f)
        local f, err = _loadfile(f)
        if not f then error(err) end
        setfenv(f, _ENV)
        return f
    end
end

for _, k in ipairs {"abs", "acos", "asin", "atan", "ceil", "cos", "deg", "exp", "floor", "log", "min", "max", "pi", "rad", "sin", "sqrt", "tan"} do
    _ENV[k] = math[k]
end
for k in pairs(string) do _ENV[k] = string[k] end

MAX_PN = 2

sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y

hr = sh / 480
wr = sw / 640
sdwr = sw / sh * 0.75

metrics = {
    notefieldtop = THEME:GetMetric('Player', 'ReceptorArrowsYStandard');
    notefieldbottom = THEME:GetMetric('Player', 'ReceptorArrowsYReverse');
    drawdistancefront = THEME:GetMetric('Player', FUCK_EXE and 'StopDrawingAtPixels' or 'DrawDistanceBeforeTargetsPixels');
    drawdistanceback = THEME:GetMetric('Player', FUCK_EXE and 'StartDrawingAtPixels' or 'DrawDistanceAfterTargetsPixels');
}

function scalefov(fov)
    return 360 / pi * atan(tan(pi / 360 * fov) * sdwr)
end

function rand(t)
    return math.abs(math.sin(632459.86 * t) * 1023341.55 + 0.32957) % 1
end

if FUCK_EXE then
    yes = 1
    no = 0
else
    yes = true
    no = false
end

do
    local tween_names = {"linear"}

    local tween_shapes = {
        "quad",
        "cubic",
        "quart",
        "quint",
        "sine",
        "expo",
        "circle",
        "elastic",
        "back",
        "bounce",
    }

    local tween_types = {"in", "out", "inout", "outin"}

    for _, shape in ipairs(tween_shapes) do
        for __, type in ipairs(tween_types) do
            table.insert(tween_names, type .. shape)
        end
    end

    if not FUCK_EXE and Tweens then
        for _, name in ipairs(tween_names) do
            if Tweens[name] then
                _ENV[name] = Tweens[name]
            end
        end
    else
        function linear(t) return t end
        function inquad(t) return t * t end
        function outquad(t) return t * (2 - t) end
        function incubic(t) return t * t * t end
        function outcubic(t) return 1 - (1 - t) ^ 3 end
        function inquart(t) return t ^ 4 end
        function outquart(t) return 1 - (1 - t) ^ 4 end
        function inquint(t) return t ^ 5 end
        function outquint(t) return 1 - (1 - t) ^ 5 end
        function insine(t) return 1 - cos(t * (pi * 0.5)) end
        function outsine(t) return sin(t * (pi * 0.5)) end
        function inoutsine(t) return sin(t * (pi * 0.5)) ^ 2 end
        function inexpo(t) return 1000 ^ (t - 1) - 0.001 end
        function outexpo(t) return 1.001 - 1000 ^ -t end
        function incircle(t) return 1 - sqrt(1 - t * t) end
        function outcircle(t) return sqrt(-t * t + 2 * t) end
        function inelastic(t, a, p) p, a, t = p or 0.3, a or 1, t - 1 return -(a * pow(2, 10 * t) * sin((t - (p / (2 * pi) * asin(1 / a))) * (2 * pi) / p)) end -- amplitude, period
        function outelastic(t, a, p) p, a = p or 0.3, a or 1 return a * pow(2, -10 * t) * sin((t - (p / (2 * pi) * asin(1 / a))) * (2 * pi) / p) + 1 end
        function outback(t, s) s = s or 1.70158 return ((t - 1) * (t - 1) * ((s + 1) * (t - 1) + s) + 1) end -- sping
        function inback(t, s) s = s or 1.70158 return t * t * ((s + 1) * t - s) end
        function outbounce(t) if t < 1 / 2.75 then return 7.5625 * t * t elseif t < 2 / 2.75 then t = t - 1.5 / 2.75 return 7.5625 * t * t + 0.75 elseif t < 2.5 / 2.75 then t = t - 2.25 / 2.75 return 7.5625 * t * t + 0.9375 else t = t - 2.625 / 2.75 return 7.5625 * t * t + 0.984375 end end
        function inbounce(t) return 1 - outbounce(1 - t) end

        for _, e in ipairs(tween_shapes) do
            local inease, outease = _ENV["in" .. e], _ENV["out" .. e]
            if not _ENV['inout' .. e] then
                _ENV['inout' .. e] = function(t, a, p) return t < 0.5 and (inease(t * 2, a, p) * 0.5) or (outease(t * 2 - 1, a, p) * 0.5 + 0.5) end
            end
            _ENV['outin' .. e] = function(t, a, p) return t < 0.5 and (outease(t * 2, a, p) * 0.5) or (inease(t * 2 - 1, a, p) * 0.5 + 0.5) end
        end
    end

    incirc = incircle
    outcirc = outcircle
    inoutcirc = inoutcircle
    outincirc = outincircle

    function bounce(t) return 4 * t * (1 - t) end
    function tri(t) return 1 - abs(2 * t - 1) end
    function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
    function tap(t) return 3.5 * t * t * sqrt(1 - t) end
    function pulse(t) return t < 0.5 and tap(t * 2) or -pop(t * 2 - 1) end
    function spike(t) return exp(-10 * abs(2 * t - 1)) end
    function inverse(t) return t * t * (1 - t) * (1 - t) / (0.5 - t) end
    function square(t) return t >= 1 and 0 or 1 end
    function invsquare(t) return t >= 1 and 1 or 0 end
    function sawtooth(t) return t * square(t) end
    function smoothstep(t) return 3 * t ^ 2 - 2 * t ^ 3 end
    function smootherstep(t) return t ^ 5 * (5 * t * (t * (7 * t * (2 * t - 9) + 108) - 84) + 126) end
    function smootheststep(t) return t ^ 7 * 1716 + 7 * t ^ 8 * (2 * t * (3 * t * (t * (11 * t * (2 * t - 13) + 390) - 572) + 1430) - 1287) end
end

orig = {}
P = {}
J = {}
C = {}
NF = {}
function init()
    screen = SCREENMAN:GetTopScreen()
    for pn = 1, MAX_PN do
        P[pn] = screen:GetChild("PlayerP" .. pn)
        if P[pn] then
            NF[pn] = P[pn]:GetChild "NoteField"
            J[pn] = P[pn]:GetChild "Judgment"
            C[pn] = P[pn]:GetChild "Combo"
            orig[pn] = {
                P = {
                    x = P[pn]:GetX();
                    y = P[pn]:GetY();
                };
                NF = {
                    x = NF[pn]:GetX();
                    y = NF[pn]:GetY();
                };
            }

            P[pn]:fov(scalefov(45))

            if FUCK_EXE then
                J[pn]:x2(orig[pn].P.x)
                J[pn]:y2(orig[pn].P.y)
                C[pn]:x2(orig[pn].P.x)
                C[pn]:y2(orig[pn].P.y)
            else
                if P[pn]:GetNumWrapperStates() == 0 then P[pn]:AddWrapperState() end
                if NF[pn]:GetNumWrapperStates() == 0 then NF[pn]:AddWrapperState() end
                if J[pn]:GetNumWrapperStates() == 0 then J[pn]:AddWrapperState() end
                if C[pn]:GetNumWrapperStates() == 0 then C[pn]:AddWrapperState() end

                NF[pn] = NF[pn]:GetWrapperState(1)

                P[pn]:rotafterzoom(false)
                NF[pn]:rotafterzoom(false)

                P[pn]:GetWrapperState(1):fov(scalefov(45))

                local jw = J[pn]:GetWrapperState(1)
                local cw = C[pn]:GetWrapperState(1)

                jw:zoom(hr)
                cw:zoom(hr)
                jw:xy(orig[pn].P.x, orig[pn].P.y)
                cw:xy(orig[pn].P.x, orig[pn].P.y)
            end
        end
    end

    Q = foreground:GetChild "Q"
end

function hidethings(table)
	for i,v in ipairs(table) do
		if screen:GetChild(v) then
			screen:GetChild(v):visible(no)
		end
	end
end

do -- spellcards
	spellcard = setmetatable({}, {__call = function(self, card) table.insert(spellcard, card) return spellcard end})
	local function colour(c)
		if type(c) == 'string' then
			local hex = {} string.gsub(c, '[a-f0-9][0-9a-f]', function(c) table.insert(hex, tonumber(c, 16)) return hex end)
			return colour(hex)
		end
		return c[1] / 255, c[2] / 255, c[3] / 255, (c[4] or 1)
	end
    if FUCK_EXE then
    	spellcard.send = function()
    		local cards = spellcard
    		if #cards == 0 then return false end
    		local song = GAMESTATE:GetCurrentSong()
    		local difficulty = (GAMESTATE:GetCurrentSteps(0) or GAMESTATE:GetCurrentSteps(1)):GetDifficulty() + 1
    		song:SetNumSpellCards(#cards)

    		for i, card in ipairs(cards) do
    			local name = type(card[3]) == 'table' and tostring(card[3][difficulty]) or tostring(card[3])
    			local color = (type(card[5]) == 'table' and type(card[5][1]) == 'table' and card[5][difficulty]) or card[5]
    			local difficulty = type(card[4]) == 'table' and card[4][difficulty] or card[4]

    			song:SetSpellCardTiming(i - 1, card[1], card[2])
    			song:SetSpellCardName(i - 1, name)
    			song:SetSpellCardDifficulty(i - 1, difficulty)
    			song:SetSpellCardColor(i - 1, colour(color))
    		end
    	end
    else
        -- TODO: wait for sections in OutFox
        spellcard.send = function() end
    end
end


function range(begin, len, sustain)
    if beat < begin then
    elseif beat < begin + len then a = (beat - begin) / len return a
    elseif beat < begin + len + (sustain or 0) then a = 1 return 1
    end
end

function rangesus(begin, len, sustain)
    if beat < begin then
    elseif beat < begin + len then a = (beat - begin) / len return a
    elseif oldbeat < begin + len + (sustain or 0) then a = 1 return 1
    end
end

function once(b)
    return beat >= b and oldbeat < b
end

function mix(a, b, x)
    return a * (1 - x) + b * x
end

function ease(begin, len, f)
    local t = (beat - begin) / len
    if t < 0 then return 0 end
    if t >= 1 then return 1 end
    return f(t)
end

-- function m(amt, mod, pn)
--     if mod == "xmod" then
--         GAMESTATE:ApplyModifiers("*-1 " .. amt .. "x", pn)
--     else
--         GAMESTATE:ApplyModifiers("*-1 " .. (amt * 100) .. " " .. mod, pn)
--     end
--     return m
-- end

if FUCK_EXE then
    function setmod(str, pn)
        return GAMESTATE:ApplyModifiers(str, pn)
    end
else
    poptions = {}
    for pn = 1, MAX_PN do
        poptions[pn] = GAMESTATE:GetPlayerState(pn - 1):GetPlayerOptions('ModsLevel_Song')
    end

    function setmod(str, pn)
        if not pn then
            for pn = 1, MAX_PN do setmod(str, pn) end
            return
        end
        return poptions[pn]:FromString(str)
    end
end

m = setmetatable(
    {
        xmod = function(amt, pn)
            return "*-1 " .. string.format("%.6f", amt) .. "x", pn
        end;
        cmod = function(amt, pn)
            return "*-1 c" .. string.format("%.6f", amt), pn
        end;
        apply = function(m)
            for pn = 1, MAX_PN do
                if m[pn] then
                    setmod(table.concat(m[pn], ","), pn)
                end
                m[pn] = nil
            end
        end;
    },
    {
        __call = function (m, amt, mod, pn)
            if not pn then
                for pn = 1, MAX_PN do
                    m(amt, mod, pn)
                end
            else
                local modstr
                if m[mod] then
                    modstr = m[mod](amt, pn)
                else
                    modstr = "*-1 " .. string.format("%.6f", amt * 100) .. " " .. mod
                end

                if m[pn] == nil then
                    m[pn] = {modstr}
                else
                    table.insert(m[pn], modstr)
                end
            end
            return m
        end
    }
)

column_offset = FUCK_EXE and -1 or 0
function column(mod, col)
    return mod .. (col + column_offset)
end
function ndcolumn(mod, col)
    return mod .. col
end

function mini(x, pn)
    if pn then
        m(x, "mini", pn)
        if not FUCK_EXE then
            NF[pn]:zoomz(1 / (1 + x * -0.5))
        end
    else
        m(x, "mini")
        if not FUCK_EXE then
            local counterzoom = 1 / (1 + x * -0.5)
            for _pn = 1, MAX_PN do
                NF[_pn]:zoomz(counterzoom)
            end
        end
    end
end

if FUCK_EXE then
    function m.dark(amt, pn)
        return "*-1 " .. string.format("%.6f", amt * 50 + 50) .. " dark"
    end
end


function x(x) target:x(x) end function y(y) target:y(y) end function z(z) target:z(z) end
function xy(x, y) target:xy(x, y) end function xyz(x, y, z) target:xyz(x, y, z) end
function w(w) target:SetWidth(w) end
function h(h) target:SetHeight(h) end
function wh(_w, _h) w(_w) h(_h or _w) end
function xywh(x, y, w, h) xy(x, y) wh(w, h)  end
function rotx(rx) target:rotationx(rx) end function roty(ry) target:rotationy(ry) end function rotz(rz) target:rotationz(rz) end function rotxyz(rx, ry, rz) rotx(rx) roty(ry) rotz(rz) end
function skewx(sx) target:skewx(sx) end function skewy(st) target:skewy(st) end function skewxy(sx, sy) skewx(sx) skewy(sy) end
function visible(n) target:visible(n) end
function draw() target:Draw() end
function zoom(z) target:zoom(z) target:zoomz(z) end
function zoomx(x) target:zoomx(x) end function zoomy(y) target:zoomy(y) end function zoomz(z) target:zoomz(z) end
function zoomxy(x, y) zoomx(x) zoomy(y or x) end function zoomxyz(x, y) zoomx(x) zoomy(y) zoomz(z) end
function rgb(r, g, b, a) target:diffuse(r / 255, g / 255, b / 255, a or 1) end
function halign(x) target:halign(x) end function valign(y) target:valign(y) end
function align(x, y) target:align(x, y) end
function alpha(a) target:diffusealpha(a) end
function hex(c) colour = {} gsub(c, '[a-f0-9][0-9a-f]', function(c) table.insert(colour, tonumber(c, 16)) return '' end) rgb(colour[1], colour[2], colour[3], (colour[4] or 255) / 255) end

fourswaps = {{0, 0}, {0, 1}, {1, 0}, {1, -1}}
fourswaps_columns = {
    {1, 2, 3, 4},
    {2, 1, 4, 3},
    {4, 3, 2, 1},
    {3, 4, 1, 2}
}



notedata = {}

if FUCK_EXE then
    notetype = {
        tap = 1;
        hold = 2;
        roll = 4;
        mine = "M";
    }
else
    notetype = {
        tap = "TapNoteType_Tap";
        hold = "TapNoteSubType_Hold";
        roll = "TapNoteSubType_Roll";
        mine = "TapNoteType_Mine";
    }
end

unpack = table.unpack or unpack

function initnotedata()
    local function column(n) return n + column_offset end

    notedata.introbass = {
        addcolumn = {
            [notetype.tap] = 0 - column_offset - 3.5;
            [notetype.mine] = 2 - column_offset - 3.5;
        };
        {0.000, column(4), notetype.mine};
        {1.000, column(3), notetype.mine};
        {1.750, column(1), notetype.tap};
        {2.500, column(1), notetype.tap};
        {3.500, column(1), notetype.tap};
        {4.000, column(4), notetype.mine};
        {4.500, column(4), notetype.mine};
        {5.000, column(3), notetype.mine};
        {5.750, column(1), notetype.tap};
        {6.500, column(1), notetype.tap};
        {7.500, column(1), notetype.tap};
        {8.000, column(4), notetype.mine};
        {9.000, column(3), notetype.mine};
        {9.750, column(1), notetype.tap};
        {10.500, column(1), notetype.tap};
        {11.500, column(1), notetype.tap};
        {12.000, column(4), notetype.tap};
        {12.500, column(4), notetype.tap};
        {13.000, column(3), notetype.tap};
        {13.250, column(2), notetype.tap};
        {13.750, column(1), notetype.tap};
        {14.500, column(1), notetype.tap};
        {15.250, column(1), notetype.tap};
        {15.750, column(1), notetype.tap};
        {16.000, column(4), notetype.mine};
        {17.000, column(3), notetype.mine};
        {17.750, column(1), notetype.tap};
        {18.500, column(1), notetype.tap};
        {19.500, column(1), notetype.tap};
        {20.000, column(4), notetype.mine};
        {20.500, column(4), notetype.mine};
        {21.000, column(3), notetype.mine};
        {21.750, column(1), notetype.tap};
        {22.500, column(1), notetype.tap};
        {23.500, column(1), notetype.tap};
        {24.000, column(4), notetype.mine};
        {25.000, column(3), notetype.mine};
        {25.750, column(1), notetype.tap};
        {26.500, column(1), notetype.tap};
        {27.500, column(1), notetype.tap};
        {28.000, column(4), notetype.tap};
        {28.500, column(4), notetype.tap};
        {29.000, column(3), notetype.tap};
        {29.250, column(2), notetype.tap};
        {29.750, column(1), notetype.tap};
        {30.500, column(1), notetype.tap};
    }
    notedata.introbuildup = {
        {32.000,column(4),notetype.tap},
        {34.000,column(2),notetype.tap},
    	{36.000,column(3),notetype.tap},
    	{38.000,column(1),notetype.tap},
    	{40.000,column(4),notetype.tap},
    	{41.000,column(3),notetype.tap},
    	{42.000,column(2),notetype.tap},
    	{43.000,column(1),notetype.tap},
    	{44.000,column(4),notetype.tap},
    }
    notedata.b112 = {
        {112.000, column(4), notetype.hold, length = 2.000};
        {114.000, column(3), notetype.hold, length = 1.500};
        {115.500, column(2), notetype.hold, length = 4.500};
        {120.000, column(1), notetype.hold, length = 2.000};
        {122.000, column(3), notetype.hold, length = 1.500};
        {123.500, column(2), notetype.hold, length = 2.000};
        {125.500, column(4), notetype.hold, length = 2.500};
        {128.000, column(1), notetype.hold, length = 2.000};
        {130.000, column(2), notetype.hold, length = 1.500};
        {131.500, column(3), notetype.hold, length = 4.500};
        {136.000, column(4), notetype.hold, length = 2.000};
        {138.000, column(2), notetype.hold, length = 1.500};
        {139.500, column(3), notetype.hold, length = 2.000};
        {141.500, column(1), notetype.hold, length = 2.500};
    }
    notedata.plucks = {
        {0.313, column(1), notetype.tap};
        {0.500, column(3), notetype.tap};
        {1.000, column(1), notetype.tap};
        {1.500, column(2), notetype.tap};
        {2.000, column(4), notetype.tap};
        {2.813, column(3), notetype.tap};
        {3.313, column(1), notetype.tap};
        {3.500, column(2), notetype.tap};
        {3.813, column(3), notetype.tap};
        {4.313, column(4), notetype.tap};
        {4.500, column(1), notetype.tap};
        {5.000, column(2), notetype.tap};
        {5.500, column(3), notetype.tap};
        {6.000, column(4), notetype.tap};
        {6.813, column(3), notetype.tap};
        {7.313, column(1), notetype.tap};
        {7.500, column(2), notetype.tap};
        {7.813, column(3), notetype.tap};
        {8.313, column(1), notetype.tap};
        {8.500, column(3), notetype.tap};
        {9.000, column(1), notetype.tap};
        {9.500, column(2), notetype.tap};
        {10.000, column(4), notetype.tap};
        {10.813, column(3), notetype.tap};
        {11.313, column(2), notetype.tap};
        {11.500, column(1), notetype.tap};
        {11.813, column(3), notetype.tap};
        {12.313, column(4), notetype.tap};
        {12.500, column(1), notetype.tap};
        {13.000, column(2), notetype.tap};
        {13.500, column(3), notetype.tap};
        {14.000, column(4), notetype.tap};
        {14.500, column(1), notetype.tap};
        {14.813, column(4), notetype.tap};
        {15.313, column(2), notetype.tap};
        {15.500, column(1), notetype.tap};
        {15.813, column(3), notetype.tap};
        {16.313, column(1), notetype.tap};
        {16.500, column(3), notetype.tap};
        {17.000, column(1), notetype.tap};
        {17.500, column(2), notetype.tap};
        {18.000, column(4), notetype.tap};
        {18.813, column(3), notetype.tap};
        {19.313, column(1), notetype.tap};
        {19.500, column(2), notetype.tap};
        {19.813, column(3), notetype.tap};
        {20.313, column(4), notetype.tap};
        {20.500, column(1), notetype.tap};
        {21.000, column(2), notetype.tap};
        {21.500, column(3), notetype.tap};
        {22.000, column(4), notetype.tap};
        {22.813, column(3), notetype.tap};
        {23.313, column(1), notetype.tap};
        {23.500, column(2), notetype.tap};
        {23.813, column(3), notetype.tap};
        {24.313, column(1), notetype.tap};
        {24.500, column(3), notetype.tap};
        {25.000, column(1), notetype.tap};
        {25.500, column(2), notetype.tap};
        {26.000, column(4), notetype.tap};
        {26.813, column(3), notetype.tap};
        {27.313, column(2), notetype.tap};
        {27.500, column(1), notetype.tap};
        {27.813, column(3), notetype.tap};
        {28.313, column(4), notetype.tap};
        {28.500, column(1), notetype.tap};
        {29.000, column(2), notetype.tap};
        {29.313, column(3), notetype.tap};
        {29.813, column(4), notetype.tap};
        {30.313, column(1), notetype.tap};
        {30.813, column(3), notetype.tap};
        {31.313, column(2), notetype.tap};
        {31.500, column(1), notetype.tap};
        {31.813, column(3), notetype.tap};
    }
end



-- i don't know how to rate spellcards please forgive me
spellcard
{16, 32, "bump it up", 5, "#333333"}
{32, 44, "speen", 6, "#999999"}
{48, 112, "PROF3SS10N", 9, "#ff0000"}
{112, 144, "Unknown modifier: attenuatex", 6, "#000000"}
{144, 160, "zoomer going zoomies", 4, "#666666"}
{160, 174, "speeny", 5, "#666666"}
{176, 208, "sinewave road", 7, "#ff6600"}
{208, 240, "dual helix", 8, "#ffcc00"}
.send()

do
    local tbl_hiddenregions = {
        {
            {41, 41.1}, {43, 43.1}
        };
        {
            {32, 40.1}, {42, 42.1}, {44, 44.1}
        };
    }
    function hiddenregions()
        for pn, regions in ipairs(tbl_hiddenregions) do
            if FUCK_EXE then
                P[pn]:SetHiddenRegions(regions)
            else
                P[pn]:GetChild("NoteField"):AddHiddenRegions(regions)
            end
        end
    end
end

aliases = {}
function alias(nitgname, outfoxname)
    aliases[nitgname] = FUCK_EXE and nitgname or outfoxname
end

alias("attenuate", "attenuatex")
alias("hideholds", "stealthholds")
alias("modtimer", "modtimersong")
alias("arrowpath", "notepath")
alias("arrowpathdrawsize", "notepathdrawsize")
alias("arrowpathdrawsizeback", "notepathdrawsizeback")
aliases.centeredpath = FUCK_EXE and "centered2" or "centeredpath"

-- ------------------- --
-- : mods start here : --
-- ------------------- --

function InitMods()
    setmod("clearall")
    m(2.25, "xmod")(1, "overhead")(1, aliases.modtimer)(1, "stealthtype")(1, "dizzyholds")
    if FUCK_EXE then
        m(-1, "spiralholds")
    else
        for pn = 1, MAX_PN do
            local nf = P[pn]:GetChild "NoteField"
            nf:SetHoldLengthUsesBeats(true)
            nf:SetHoldsOrientToTravelDir(true)
        end
    end

    if not FUCK_EXE then
        m(1, "tinyusesminicalc")
    end
end

function Mods()
    if rangesus(-1, 1) then
        for pn = 1, MAX_PN do
            P[pn]:x(mix(orig[pn].P.x, scx, ease(-1, 1, inquad)))
        end
    end

    if once(0) then
        m(1, "dark", 2)
        m(1, "sudden")(1.5, "suddenoffset")
        hiddenregions()
    end

    if rangesus(0, 48) then
        for col = 1, 4 do
            if rangesus(7.5 + (col - 1) / 6, 4) then
                m((inquad(1 - a)) * -4 * pi, column("confusionoffset", col))
            end
        end
        if rangesus(16, 15) then
            local t = inquad(a)
            local v = ease(30, 1, inquad)
            m(mix(2.25, 0.22, a), "xmod")(a * (1 - v), "brake")(a, "centered")(t * 20, "bumpy")(a * 0.25, "flip")
            m(mix(1, 8, t), "sudden")(mix(1.5, -0.97, a), "suddenoffset")(v * -0.95, "drawsize")(-a, "drawsizeback")
        end
        if rangesus(30, 1) then
            mini(inquad(a) * 1.5)
        end
        if rangesus(31, 1) then
            m(mix(0.22, 0.125, outquad(a)), "xmod")(a * pi, "dizzy")
            for pn = 1, MAX_PN do
                P[pn]:rotationz(bounce(a) * -45)
            end
        end
        if once(32) then
            m(pi, "confusionoffset", 2)
        end
        if rangesus(32, 12) then
            for pn = 1, MAX_PN do
                P[pn]:rotationz(a * 12 * 180)
            end
        end
        if once(44) then
            m(0, "confusionoffset", 2)
        end
        if rangesus(44, 3) then
            m(0.125 * outquad(a), "xmod")(pi * (1 - a), "dizzy")(1 - a, "stealth")
        end
        if rangesus(47, 1) then
            m(inquad(a), "wave")
        end
    end

    if once(47.5) then m(2, "beat")(-0.9, "beatperiod")(19, "drunkperiod") end
    if once(79.5) then m(0, "beat") end
    if once(80.5) then m(-2, "beat") end
    if rangesus(95.5, 8) then
        m(-2 * floor(cos(floor(min(beat, 103.5) + 0.5) * pi * 0.5) + 0.5), "beat")
    end
    if once(108.5) then m(0, "beat") end

    if rangesus(48, 64) then
        local r = ease(48, 31, linear) * 31
        r = r + (ease(79, 2, linear) - ease(79, 2, inquad)) * 2
        r = r + ease(81, 31, linear) * -31
        local mag = ease(48, 4, outquad) * 3
        mag = mag + ease(108, 4, inquad) * -3
        for pn = 1, MAX_PN do
            P[pn]:rotationx(math.cos(r * pi/2) * mag)
            P[pn]:rotationy(math.sin(r * pi/2) * mag)
        end

        if rangesus(62.5, 1.5) then
            local tiny = bounce(a) * -9
            -- m(tiny, column("tinyx", 3))(tiny, column("tinyy", 3))(bounce(a) * -4, column("movey", 3))
            -- m(square(a), column("stealth", 3), 2)(square(a), column("dark", 3), 2)
            m(tiny, "tinyy")
        end
        if rangesus(80, 1) then m(a * 0.5, "drunk") end

        for i = 1, 8 do
            if rangesus((i - 1) + 72, 1) then
                m(pop(a) * 0.25, "brake")
                local from, to = fourswaps[(i - 1) % 4 + 1], fourswaps[i % 4 + 1]
                m(mix(from[1], to[1], outquart(a)) * 0.5 + 0.25, "flip")(mix(from[2], to[2], outquart(a)) * 0.5, "invert")
            end
        end

        if rangesus(96, 12) then m(a * 0.75, "brake")(1 - a, "wave") end
    end

    if rangesus(108, 4) then
        local t = inquad(1 - a)
        mini(t * 1.5)
        m(t * 0.5, "reverse")(t * 0.25, "flip")(t * 20, "bumpy")(t * 0.5, "drunk")(0, "drunkperiod")
        m(mix(2.25, 0.5, a), "xmod")(t * 0.75, "brake")(0, "centered")(0, "sudden")(0, "suddenoffset")
        m(a * -16, aliases.attenuate)(0, "drawsize")(0, "drawsizeback")
    end

    if rangesus(112, 32) then
        local b = min(beat - 112, 32)
        local rev = b % 16.0 < 8 and 1 or -1
        local y = b % 8.0 / 2 * rev

        if rangesus(142, 1) then
            rev = mix(rev, 1, inquad(a))
            y = y * outquad(1 - a)
        elseif rangesus(143, 1) then
            rev = 1
            y = bounce(a) * 0.5
        end

        if FUCK_EXE then
            m(y, "movey")
        else
            for pn = 1, MAX_PN do
                NF[pn]:y(y * 64)
            end
        end
        m(0.5 + rev * -0.5, "reverse")

        if rangesus(128, 4) then m(outquart(a) * 2, "bumpy") end
        if rangesus(135, 2) then m((1 - tri(a)) * 2, "bumpy") end

        for i, note in ipairs(notedata.b112) do
            if i <= 7 and rangesus(note[1], note.length) then
                local t = sawtooth(a)
                m(t, "stealth")(t, "dark")
            end
        end

        if rangesus(128, 16) then
            local stealth = 0
            if rangesus(128, 1) then stealth = 1 - a end
            if rangesus(135, 2) then stealth = tri(a) end

            local stealthholds = square(a) * (stealth * (FUCK_EXE and 0.1 or -0.9) + 0.9)

            m(stealth, "stealth")
            m(stealthholds, aliases.hideholds)
        end

        if rangesus(142, 1) then
            local t = inquad(a)
            local q = 1 - t
            m(q * -16, aliases.attenuate)(q * 2, "bumpy")
        end

        if rangesus(143, 1) then m(mix(0.5, 2, outquad(a)), "xmod") end

        for b = 119, 135, 8 do
            if rangesus(b, 2) then
                local rot = (inoutsine(a) - invsquare(a * 2)) * 180
                for pn = 1, MAX_PN do
                    P[pn]:rotationy(rot)
                end
            end
        end
    end

    if rangesus(112, 34) then
        for _, note in ipairs(notedata.plucks) do
            if rangesus(112 + note[1], 2) then
                local column = note[2]
                local t = inquart(1 - a)
                m(t * 0.5, ndcolumn("bumpyy", note[2]))
                m(inquad(1 - a) * 2, ndcolumn("bumpyyoffset", note[2]))
            end
        end
    end

    -- if once(144) then
    --     m(0.9, aliases.hideholds, 1)
    -- end

    if rangesus(144, 32) then
        local xmod = 2
        local minimult = (ease(144, 28, linear) - ease(172, 4, inoutquart)) * 1.5 + 1
        m(2 - minimult * 2, "mini")(xmod / minimult, "xmod")
        if FUCK_EXE then
            m(minimult, "zoomz")
        end

        if once(160) then
            for pn = 1, 2 do
                if FUCK_EXE then
                    P[pn]:SetFarDist(64000 * hr)
                else
                    P[pn]:fardistz(64000 * hr)
                    P[pn]:GetWrapperState(1):fardistz(64000 * hr)
                end
            end
        end

        do
            local t = min(beat, 168) % 1
            local y = (t - incirc(inquart(t))) * 2

            if rangesus(160, 8) then
                local q = inoutsine(a)
                y = y * (1 - q)
                m(q, "centered")
            end

            if rangesus(172, 4) then
                t = outquad(a)
                y = y - t * 2
                m(-t * 1.5, "reverse")(t * (1024 / metrics.drawdistancefront - 1), "drawsize")
                m(t * 1024 / metrics.drawdistancefront - 1, aliases.arrowpathdrawsize)

                t = inoutsine(a)
                for pn = 1, 2 do
                    local mul = (1.5 - pn) * 2
                    m(t * 4 * 32 / 40 * mul, "bumpyx", pn)(t * mul * 0.5, "drunkz", pn)
                end
                m(t, "flip", 2)(t * 0.9, "stealth", 2)(t * 0.8, "dark", 2)
                m((-16 + 8 * inquad(a)) / pi, "bumpyxoffset")
            end

            if once(172) then
                local bumpyperiod = 32 / pi - 1
                m(0.5, aliases.arrowpath)(-1, aliases.arrowpathdrawsizeback)
                m(bumpyperiod, "bumpyperiod")(bumpyperiod, "bumpyxperiod")
                m(1, "drunkzspeed")(6, "drunkzspacing")(-0.5, "drunkzperiod")
                m(FUCK_EXE and ((64 + (64 * 7)) / (60 * pi)) - 1 or 7, "squareperiod")
            end

            y = y / minimult
            for col = 1, 4 do
                m(y, column("movey", col))
            end
        end

        local r = (ease(160, 8, inquad) * 4 + ease(168, 4, linear) * 4 + ease(172, 4, outquart) * 1 + ease(172, 2, inoutsine) * 7 / 24) % 1
        if FUCK_EXE then
            m(r * 3.6, "rotationx")
        else
            for pn = 1, 2 do
                NF[pn]:rotationx(r * 360)
            end
        end
        m(-r * pi * 2, "confusionxoffset")
    end

    if rangesus(176, 64) then
        local reversemul = 4 + ease(207, 2, outback) * 12
        local t = a * 128

        local flipflop = ease(191, 2, smootheststep) - ease(206, 2, smootheststep)
        if range(223, 17) then
            flipflop = flipflop + ease(223, 2, smootheststep) - ease(231, 2, smootheststep)
        end

        local flopflip = 1 - flipflop
        if range(234.5, 2, 3.5) then
            flopflip = flopflip - smootheststep(a)
        end

        local fadeout = ease(239, 1, linear)
        local fadeout2 = ease(236, 4, linear)

        if rangesus(207, 2) then
            local t = outback(a)
            for pn = 1, 2 do
                local mul = (1.5 - pn) * 2
                m(t * 4 * 32 / 40 * mul, "bumpy", pn)
            end
        end

        if rangesus(235.5, 4.5) then
            local t = 1 - smoothstep(a)
            local amt = t * 4 * 32 / 40
            m((1 - a) * 5, aliases.arrowpath)
            for pn = 1, 2 do
                local mul = (1.5 - pn) * 2
                m(amt * mul, "bumpyx", pn)(amt * mul, "bumpy", pn)(t * 0.5 * mul, "drunkz", pn)
                P[pn]:zoomx(1.1 / (1.1 - inquart(fadeout)) * hr)
            end
        end

        do
            local mul = -1
            for b = 204, 207 do
                if rangesus(b, 1) then
                    local drunkz = (0.5 - outquart(a) + pop(a) * 2) * mul
                    for pn = 1, 2 do
                        m(drunkz * (pn - 1.5) * 2, "drunkz", pn)
                    end
                end
                mul = -mul
            end
        end

        if rangesus(206, 1) then
            local r = (105 + inquad(a) * -15) / 360
            if FUCK_EXE then
                m(r * 3.6, "rotationx")
            else
                for pn = 1, 2 do
                    NF[pn]:rotationx(r * 360)
                end
            end
            m(-r * pi * 2, "confusionxoffset")
        end

        local y = -2 - t * reversemul
        m(0.5 + reversemul * -0.5, "reverse")(t, aliases.centeredpath)
        for col = 1, 4 do
            m(y, column("movey", col))
        end

        m(flipflop, "flip", 1)(flopflip, "flip", 2)
        m(flipflop * 0.9 + fadeout, "stealth", 1)(flopflip * 0.9 + fadeout, "stealth", 2)
        m(flipflop * 0.8 + fadeout2, "dark", 1)(flopflip * 0.8 + fadeout2, "dark", 2)
    end
end



function Draw()
    local draw_players = true

    target = Q
    zoom(1)
    rotxyz(0, 0, 0)

    if range(-1, 1) then
        xywh(scx, scy, sw * 0.5 * inquad(a), sh)
        hex "#333333"
        target:halign(0) x(0) draw()
        target:halign(1) x(sw) draw()
        target:halign(0.5)
    elseif beat >= 0 then
        xyz(scx, scy, 0)
        hex "#000000"
        if range(0, 48) then
            hex "#333333"
        end
        if range(48, 64) then
            hex "#999999"
        end
        if beat >= 176 then
            hex "#666666"
        end
        wh(sw, sh)
        draw()
    end

    if range(32, 16) then
        for i, note in ipairs(notedata.introbuildup) do
            if range(note[1], 2, 2) then
                wh(sw, sh)
                local gray = mix(51, 153, i / 9)
                zoomy(outquart(a))
                rgb(gray, gray, gray)
                draw()
            end
        end

        wh(50 * hr)
        for i, note in ipairs(notedata.introbuildup) do
            if range(note[1], 4) then
                local m = 1
                zoom(1 - a)
                for j = 1, 16 do
                    local seed = i * 147 + j * 16 + 239
                    xy(scx + (rand(seed) + rand(seed + 1) - 1) * 480 * hr, scy + (sh * 0.5 - (bounce(a) * 512 - a * rand(seed + 2) * 512 - rand(seed + 3) * 256) * hr) * m)
                    rotz(rand(seed + 4) * 90 + (rand(seed + 5) - 0.5) * a * 180)
                    rgb(204, 51 + rand(seed + 6) * 153, 51)
                    draw()
                    m = -m
                end
            end
        end
    end
    wh(sw, sh)
    zoom(1)

    hex "#666666"
    skewx(-0.25)
    if range(0, 34) then
        for _, v in ipairs(notedata.introbass) do
            if range(v[1], 1) then
                x(scx + (v[2] + notedata.introbass.addcolumn[v[3]]) * 96 * hr)
                w(96 * inquad(1 - a) * hr)
                draw()
            end
        end
    end
    skewx(0)

    if range(44, 68) then
        wh(16 * hr)
        local fadein = ease(44, 4, linear)
        local fadein_q = outquad(fadein)
        local t = (8 + ease(48, 64, linear) * -4) * 32
        for i = floor(t) + 32, ceil(t), -1 do
            local t = (i - t) / 32
            local seed = i * 24 + 155
            local r = sqrt(rand(seed) + 0.1) * 64 * hr * (1 - inverse(fadein ^ (1 + rand(seed + 2) * 3) * 0.5 + 0.5))
            local q = rand(seed + 1) * pi * 2
            xyz(scx + r * cos(q), scy + r * sin(q), mix(700, -1000, t) * hr)
            rotz(rand(seed + 3) * 90 + t * (rand(seed + 4) - 0.5) * 720 + (1 - fadein_q) * (rand(seed + 5) - 0.5) * 360)
            local gray = mix(102, 204, square(rand(seed + 7) * 2))
            local colormix = linear(1 - min((beat - floor(rand(seed + 6) * 4)) % 4, 1)) * (beat >= 48 and 1 or 0)
            rgb(
                mix(gray, 255, colormix),
                mix(gray, floor(rand(seed + 8) * 256), colormix),
                mix(gray, 0, colormix),
                min(tri(t) * 8, 1)
            )
            draw()
        end

        if range(72, 12) then
            wh(8 * hr, 2000 * hr) z(-800 * hr) rotxyz(90, 0, 0) valign(1)
            target:fadebottom(1)
            for i = 0, 7 do
                local b = i + 72
                if range(b, 2) then
                    local fadein = ease(b, 0.5, outquad)
                    local fadeout = ease(b + 1, 0.5, linear)
                    local width = 8 * ease(b, 1, outquad) * hr
                    local r = 16 * hr
                    for j = 1, 8 do
                        local seed = (i * 8 + j) * 4.0
                        local q = rand(seed + 1)
                        local qq = q * pi * 2
                        local x, y = scx + r * cos(qq), scy + r * sin(qq)
                        xy(x, y)
                        roty(q * 360 + 90)
                        w(8 * fadein * hr)
                        target:croptop(1 - fadein) target:cropbottom(fadeout)
                        rgb(255, rand(seed + 2) * 255, 0)
                        draw()
                    end
                end
            end
            z(0) rotxyz(0, 0, 0) align(0.5, 0.5)
            target:croptop(0) target:cropbottom(0) target:fadebottom(0)
        end

        if range(108, 4) then
            xyz(scx, scy, 0)
            wh(sw, sh)
            rotz(0)
            hex "#000000"
            alpha(a)
            draw()
        end
    end

    if range(112, 36) then
        wh(256 * hr)
        for i, note in ipairs(notedata.b112) do
            local b, len = note[1], note.length
            if range(b, 4) then
                for j = 1, 16 do
                    local seed = (i * 16 + j) * 11 + 27
                    local gray = 64 + floor(rand(seed + 2) * 128)
                    xy(scx + (rand(seed) - 0.5) * sh * 2, scy + (rand(seed + 1) - 0.5) * sh)
                    rgb(gray, gray, gray, (1 - a) * 0.5)
                    rotz(rand(seed + 4) * 360 + (inoutcirc(rand(seed + 5)) - 0.5) * a * 90)
                    zoom((rand(seed + 3) * 0.5 + 0.5) * (1 - a ^ 4))
                    draw()
                end
            end
        end
        zoom(1)
        rotz(0)

        wh(32 * hr)
        for i, note in ipairs(notedata.plucks) do
            if range(112 + note[1], 4) then
                local seed = i * 37 + 123
                local x, y = scx + (rand(seed) - 0.5) * 512 * hr, scy + (rand(seed + 1) - 0.5) * sh * 0.5 + inquad(a) * 128 * hr
                zoom(1 - a)
                for j = 1, 4 do
                    local seed1 = seed + 5 + (j - 1) * 7
                    local q = rand(seed1) * pi * 2
                    local r = 128 * j * a * hr
                    xy(x + cos(q) * r, y + sin(q) * r)
                    rgb(255, floor(rand(seed1 + 3) * 256), 0)
                    draw()
                end
            end
        end
    end

    xyz(scx, scy, 0)
    wh(sw, sh / 3)
    rotz(0)
    hex "#666666"
    if range(172, 4) then
        for i = 0, 2 do
            if range(172 + i, 2, 2) then
                y(scy + (i - 1) * sh / 3)
                zoomx(outquart(a))
                draw()
            end
        end
    end
    zoomx(1)

    if range(174, 66) then
        wh(sw * 2.5 * ease(174, 2, linear) * (1 - ease(235.5, 4.5, outquad)), 64 + hr)
        local t = (8 + ease(176, 64, linear) * -2) * 16
        local r = -60
        local r_rad = rad(r)
        local c, s = cos(r_rad), sin(r_rad)
        rotx(r)
        for i = ceil(t), floor(t) + 16 do
            local t = (i - t) / 16
            local seed = i * 19 + 17
            local y = mix(-1000, 1048, t) * hr
            local z = 64 * hr
            y, z = y * c + z * s, z * c - y * s
            xyz(scx, scy + y, z)
            local colormix = linear(1 - min((beat + i) % 2, 1)) * (beat < 225 and 1 or 0)
            rgb(
                mix(153, 255, colormix),
                mix(153, floor(rand(seed + 8) * 256), colormix),
                mix(153, 0, colormix),
                min(tri(t) * 8, 1)
            )
            draw()
        end
        rotx(0)
    end

    if range(239, 1, 256) then
        xyz(scx, scy, 0)
        wh(sw * inquart(a), sh)
        hex "#000000"
        draw()
    end

    if draw_players then
        for pn = 1, MAX_PN do
            P[pn]:visible(yes)
            P[pn]:Draw()
            P[pn]:visible(no)
        end
    end

    for pn = 1, MAX_PN do
        J[pn]:visible(yes)
        C[pn]:visible(yes)
        J[pn]:Draw()
        C[pn]:Draw()
        J[pn]:visible(no)
        C[pn]:visible(no)
    end
end

function OnCommand(self)
    beat = -9e9
    second = -9e9

    oldbeat = -9e9
    oldsecond = -9e9

    self:fov(scalefov(45))
    init()
    initnotedata()
    InitMods()

    self:queuecommand "Ready"
end

function ReadyCommand(self)
    for pn = 1, MAX_PN do
        P[pn]:visible(no)
    end

    self:SetUpdateFunction(Update)
    self:SetDrawFunction(Draw)
end

function Update(self)
    oldbeat = beat
    oldsecond = second

    beat = GAMESTATE:GetSongBeat()
    if FUCK_EXE then
        second = GAMESTATE:GetSongTime()
    else
        second = GAMESTATE:GetCurMusicSeconds()
    end

    if second > oldsecond then
        if once(0) then
            hidethings {
                "BPMDisplay", "LifeFrame", "ScoreFrame", "Overlay", "Underlay", "StageDisplay", "SongTitle",
        		"ScoreP1", "ScoreP2", "LifeP1", "LifeP2", "SongMeterDisplayP1", "SongMeterDisplayP2",
                "StepsDisplayP1", "StepsDisplayP2", "LifeMeterBarP1", "LifeMeterBarP2",
                "SongBackground" -- we're not using the background layer anyway :)
            }
        end
        Mods()
        m:apply()
    else
        beat = oldbeat
        second = oldsecond
    end
end

foreground:addcommand(FUCK_EXE and (not GAMESTATE:IsEditMode()) and "ScreenReady" or "On", OnCommand)
foreground:addcommand("Ready", ReadyCommand)
