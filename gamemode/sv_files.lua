--
-- Loads shared lua and resources
--

local Files = {

	[1] = { -- Pre Server
		"network/sv_network",
	},
	
	[2] = { -- Shared
		"shared",
		"shared/spheretrace",
		"shared/grapple",
		"shared/grapplelib",
		"shared/datalib",
		
		"gametypes/gamestate",
		"gametypes/gametype",
		
		"gametypes/states/warmup",
		"gametypes/states/ffa",
		"gametypes/states/endgame",
		
		"gametypes/gametypes/ffa",
	},
	
	[3] = { -- Server
		"data/sv_achievements",
		"data/achievementlist",
		"data/podiums",
	},
	
	[4] = { -- Client
		"cl_init",
		"cl_files",
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
	},
}

print( "========== Grapple Gunners Server ==========\n" )

for k,v in ipairs(Files) do

	if k == 1 then
	
		print( " - Pre Server - " )
		
		for i,f in pairs(v) do
		
			include( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	elseif k == 2 then
	
		print( " - Shared - " )
		
		for i,f in pairs(v) do
		
			include( f..".lua" )
			AddCSLuaFile( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	end
	
	if k == 3 then
	
		print( " - Server - " )
		
		for i,f in pairs(v) do
		
			include( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	elseif k == 4 then
	
		print( " - Client - " )
		
		for i,f in pairs(v) do
		
			AddCSLuaFile( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	end
	
end

print( "============================================" )

local Resources = {
	
}

for k,v in pairs(Resources) do
	
	resource.AddFile( v )
	
end