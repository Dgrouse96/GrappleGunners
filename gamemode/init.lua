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
	
	self:PlayerSetModel( ply )
	
	
	player_manager.SetPlayerClass( ply, "player_default" )
	ply:SetupHands()
	
end

function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	
	if ( info ) then
	
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
		
	end

end


--
-- Version
--

local Version = GData( "version" )

hook.Add( "OnReloaded", "VersionUpdate", function()

	
	local NewVersion = IncrementVersion( Version:GetData()[1] )
	Version:Input( 1, NewVersion )
	Version:Save()
	
end )

print( "GRAPPLE GUNNERS VERSION: " .. Version:GetData()[1] )