--
-- Loads shared lua and resources
--

local Files = {
	["server"] = {
		"network/sv_network",
	},
	["client"] = {
		"cl_init",
		"cl_files",
		"network/cl_network",
		"client/grapplecable",
		"client/draw",
		"client/widget",
		"client/hud",
		
		"client/widgets/energybar",
		"client/widgets/crosshair",
	
		"client/huds/gameplayhud",
		
		"anims/posemaker",
		"anims/poseblender",
	},
	["shared"] = {
		"shared",
		"shared/spheretrace",
		"shared/grapple",
		"shared/grapplelib",
	}
}

print( "========== Grapple Gunners Server ==========\n" )

for k,v in pairs(Files) do

	if k == "server" then
	
		print( " - Server - " )
		
		for i,f in pairs(v) do
		
			include( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	elseif k == "client" then
	
		print( " - Client - " )
		
		for i,f in pairs(v) do
		
			AddCSLuaFile( f..".lua" )
			print( "    "..f )
			
		end
		
		print( "" )
		
	elseif k == "shared" then
	
		print( " - Shared - " )
		
		for i,f in pairs(v) do
		
			include( f..".lua" )
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