include( "sv_files.lua" )

RunConsoleCommand( "sv_gravity", "400" )

function GM:GetFallDamage( ply, speed )

	return false
	
end

function GM:PlayerSetModel( ply )

	ply:SetModel( "models/Humans/Group01/Male_04.mdl" )
	
end

function GM:PlayerInitialSpawn( ply )
	
	ply:SetupPlayer()
	
end

function GM:PlayerSpawn( ply )
	
	ply:Give( "grappleshotty" )
	self:PlayerSetModel( ply )
	
end