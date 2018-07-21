--
-- Loads client lua
--

local Files = {
	"shared",
	"shared/spheretrace",
	"shared/grapple",
	"shared/grapplelib",
	"shared/datalib",
	
	"network/cl_network",
	"client/grapplecable",
	"client/draw",
	"client/fonts",
	"client/widget",
	"client/hud",
	
	"data/cl_achievements",
	
	"client/widgets/energybar",
	"client/widgets/healthbar",
	
	"client/widgets/shotty_ch",
	"client/widgets/sniper_ch",
	"client/widgets/crosshairs",
	
	"client/huds/gameplayhud",
	
	"anims/poses",
	"anims/posemaker",
	//"anims/poseblender",
	"anims/posemixer",
	"anims/posestack",
	
	"gametypes/gamestate",
	"gametypes/gametype",
		
	"gametypes/states/warmup",
	"gametypes/states/ffa",
	"gametypes/states/endgame",
		
	"gametypes/gametypes/ffa",
	
	"data/podiums",
}

for k,v in pairs(Files) do
	
	include( v..".lua" )
	
end