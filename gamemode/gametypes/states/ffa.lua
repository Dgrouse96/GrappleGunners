GS_FFA = GameState()

function GS_FFA:Enter( FragLimit )
	
	if !FragLimit then FragLimit = 20 end
	self.FragLimit = FragLimit
	
	for k,ply in pairs( player.GetAll() ) do
		
		ply.LockMovement = false
		
	end
	
	if SERVER then
		
		for k,ply in pairs( player.GetAll() ) do
			
			ply:KillSilent()
			ply:Spawn()
			ply:SetFrags( 0 )
			ply:SetDeaths( 0 )
			ply:Freeze( true )
			
		end
		
		timer.Create( "GS_FFA:Start", 2, 1, function()
		
			for k,ply in pairs( player.GetAll() ) do
			
				ply:Freeze( false )
				ply:Give( "grappleshotty" )
				ply:Give( "grapplesniper" )
				
			end
			
			GS_FFA:AddHook( "PlayerDeath", GS_FFA.PlayerDeath )
			GS_FFA:AddHook( "PlayerSpawn", GS_FFA.PlayerSpawn )
			
		end )
		
	end
	
end

function GS_FFA:PlayerDeath( Victim, Inflictor, Attacker )
	
	AddKillAchievemnts( Attacker )
	
	if Attacker:Frags() >= self.FragLimit then
		
		self.Parent:SetState( "EndGame", true, Attacker )
		
	end
	
end

function GS_FFA:PlayerSpawn( ply )
	
	ply:Give( "grappleshotty" )
	ply:Give( "grapplesniper" )
	
end