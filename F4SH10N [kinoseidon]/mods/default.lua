-- hello, i'm kino. i'm porting it so kid doesn't have to.

local _ENV = _ENV
local _G = _G

local env = setmetatable({FUCK_EXE = false}, {__index = _G})
local init, err

do
	local songDir = GAMESTATE:GetCurrentSong():GetSongDir()

	_ENV = env
	init, err = loadfile(songDir .. "mods/mods.lua", "t", env)
	if not init then error(err) end

	_ENV = _G
	if setfenv then setfenv(init, env) end
end

return Def.ActorFrame {
	InitCommand = function(self)
		env.foreground = self
		init()
	end,
	Def.Actor {
		Name = "I may be sleeping, but I preserve the world.",
		InitCommand = function(self) self:sleep(9e9) end
	},
	Def.Quad {Name = "Q"}
}
