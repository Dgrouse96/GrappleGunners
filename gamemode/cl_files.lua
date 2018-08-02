--
-- Loads client lua
--

local Files = {
	"shared",
	"shared/spheretrace",
	"shared/grapple",
	"shared/grapplelib",
	"shared/datalib",
	
	"data/stats",
	"data/playtime",
	"data/statlist",

	"network/cl_network",
	"client/grapplecable",
	"client/draw",
	"client/fonts",
	"client/widget",
	"client/derma",
	"client/hud",
	
	"client/widgets/energybar",
	"client/widgets/healthbar",
	"client/widgets/shotty_ch",
	"client/widgets/sniper_ch",
	"client/widgets/crosshairs",
	"client/widgets/colourtint",
	"client/widgets/damagenotify",
	"client/widgets/killnotify",
	"client/widgets/timer",
	
	"client/derma/mapvote",
	"client/derma/scoreboard",
	"client/derma/playerstats",
	
	"client/hudlist",

	"data/achievements",
	"data/achievementlist",
	"data/localsettings",
	"client/views",

	"anims/poses",
	"anims/posemaker",
	"anims/posemixer",
	"anims/posestack",

	"gametypes/gamestate",
	"gametypes/gametype",

	"gametypes/states/warmup",
	"gametypes/states/ffa",
	"gametypes/states/endgame",

	"gametypes/gametypes/ffa",
	
	"data/podiums",
	"shared/maps",
}

for k,v in pairs(Files) do

	include( v..".lua" )

end
