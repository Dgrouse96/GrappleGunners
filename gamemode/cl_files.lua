--
-- Loads client lua
--

local Files = {
	"shared",
	"shared/spheretrace",
	"shared/grapple",
	"shared/grapplelib",
	
	"network/cl_network",
	"client/grapplecable",
	"client/draw",
	"client/fonts",
	"client/widget",
	"client/hud",
	
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
}

for k,v in pairs(Files) do
	
	include( v..".lua" )
	
end