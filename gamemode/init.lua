include( "sv_files.lua" )

RunConsoleCommand( "sv_gravity", "400" )


local PlayerModels = {
	"models/Humans/Group01/Male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/Male_04.mdl",
	"models/Humans/Group01/Male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",

	"models/Humans/Group02/Male_01.mdl",
	"models/Humans/Group02/male_02.mdl",
	"models/Humans/Group02/male_03.mdl",
	"models/Humans/Group02/Male_04.mdl",
	"models/Humans/Group02/Male_05.mdl",
	"models/Humans/Group02/male_06.mdl",
	"models/Humans/Group02/male_07.mdl",
	"models/Humans/Group02/male_08.mdl",
	"models/Humans/Group02/male_09.mdl",

	"models/Humans/Group03/Male_01.mdl",
	"models/Humans/Group03/male_02.mdl",
	"models/Humans/Group03/male_03.mdl",
	"models/Humans/Group03/Male_04.mdl",
	"models/Humans/Group03/Male_05.mdl",
	"models/Humans/Group03/male_06.mdl",
	"models/Humans/Group03/male_07.mdl",
	"models/Humans/Group03/male_08.mdl",
	"models/Humans/Group03/male_09.mdl",

	"models/Humans/Group03m/Male_01.mdl",
	"models/Humans/Group03m/male_02.mdl",
	"models/Humans/Group03m/male_03.mdl",
	"models/Humans/Group03m/Male_04.mdl",
	"models/Humans/Group03m/Male_05.mdl",
	"models/Humans/Group03m/male_06.mdl",
	"models/Humans/Group03m/male_07.mdl",
	"models/Humans/Group03m/male_08.mdl",
	"models/Humans/Group03m/male_09.mdl",
}


function GM:PlayerSetModel( ply )

	ply:SetModel( PlayerModels[ math.random( #PlayerModels ) ] )

end


function GM:GetFallDamage( ply, speed )

	return false

end


function GM:PlayerInitialSpawn( ply )

	
	PlayTime:SetGameType( ply )
	SendMapList( ply )
	UpdateGameType( ply )
	
	ply:SetupPlayer()
	sendEntity( "SetupPlayer", ply, ply )
	
end


function GM:PlayerSpawn( ply )

	self:PlayerSetModel( ply )
	player_manager.SetPlayerClass( ply, "player_default" )
	ply:SetupHands()
	
	ply:SetupPlayer()
	sendEntity( "SetupPlayer", ply, ply )

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


function GM:EntityTakeDamage( Target, Dmg )
	
	local Attacker = Dmg:GetAttacker()
	
	if ( Target:IsPlayer() and Attacker:IsPlayer() ) then
		
		sendArgs( "DealtDamage", { Target, Dmg:GetDamage() }, Attacker )
		sendArgs( "TookDamage", { Attacker, Dmg:GetDamage() }, Target )
		
	end

end