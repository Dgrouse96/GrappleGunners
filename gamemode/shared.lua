GM.Name = "Grapple Gunners"
GM.Author = "David Grouse"
GM.Email = "dgrouse96@gmail.com"
GM.Website = "dg-collection.weebly.com"

local PLY = FindMetaTable( "Player" )

game.AddDecal( "GG-GroundSlam", "grapplegunners/decals/groundslam" )

function PLY:SetupPlayer()

	-- Speed
	GAMEMODE:SetPlayerSpeed( self, 300, 500 )
	self:SetCrouchedWalkSpeed( 300 )
	self:SetJumpPower( 300 )
		
	-- Remove Ducking
	self:SetViewOffsetDucked( self:GetViewOffset() )
	self:SetHullDuck( self:GetHull() )

end

hook.Add( "SetupPlayer", "Replicate", function( ply ) 
	
	if IsValid( ply ) and ply:IsPlayer() then ply:SetupPlayer() end
	
end )

function SetupAllPlayers()
	
	for k,ply in pairs( player.GetAll() ) do
	
		ply:SetupPlayer()
		
	end
	
end
hook.Add( "InitPostEntity", "SetupAllPlayers", SetupAllPlayers )
hook.Add( "OnReloaded", "SetupAllPlayers", SetupAllPlayers )

function GM:HandlePlayerLanding( ply, vel, onGround )

	return true
	
end

function GM:PlayerNoClip( ply, newstate )

	if ply:IsAdmin() or !newstate then return true end
	return false
	
end