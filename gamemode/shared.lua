GM.Name = "Grapple Gunners"
GM.Author = "David Grouse"
GM.Email = "dgrouse96@gmail.com"
GM.Website = "dg-collection.weebly.com"

for _, ply in pairs( player.GetAll() ) do

	GAMEMODE:SetPlayerSpeed( ply, 400, 600 )
	ply:SetJumpPower( 300 )
	
end