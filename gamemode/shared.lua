GM.Name = "Grapple Gunners"
GM.Author = "David Grouse"
GM.Email = "dgrouse96@gmail.com"
GM.Website = "dg-collection.weebly.com"

game.AddDecal( "GG-GroundSlam", "grapplegunners/decals/groundslam" )

for _, ply in pairs( player.GetAll() ) do

	-- Speed
	GAMEMODE:SetPlayerSpeed( ply, 300, 500 )
	ply:SetCrouchedWalkSpeed( 300 )
	ply:SetJumpPower( 300 )
	
	-- Remove Ducking
	ply:SetViewOffsetDucked( ply:GetViewOffset() )
	ply:SetHullDuck( ply:GetHull() )
end

function GM:HandlePlayerLanding( ply, vel, onGround )

	return true
	
end