--
-- When players play FFA
--

GS_FFA = GameState()
GS_FFA.Completors = {}

function GS_FFA:Enter( FragLimit )

	if !FragLimit then FragLimit = 20 end
	self.FragLimit = FragLimit

	LockMovement( false )
	
	-- People eligable for game completed stat
	self.Completors = table.Copy( player.GetAll() )

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
			GS_FFA:AddHook( "EntityTakeDamage", GS_FFA.EntityTakeDamage )

		end )
		
	else
	
		SetGameplayHud( HUD_Gameplay )

	end

end


function GS_FFA:Leave()
	
	if CLIENT then return end
	
	for k,v in pairs( player.GetAll() ) do
		
		if table.HasValue( self.Completors, v ) or table.HasValue( self.Parent:TopThree() or {}, v ) then
			
			S_Completed:Increment( v, "FFA", 1 )
			
		end
		
	end
	
end


function GS_FFA:PlayerDeath( Victim, Inflictor, Attacker )
	
	if !Victim:IsPlayer() or !Attacker:IsPlayer() then return end
	
	if Victim != Attacker then
	
		S_Kills:Increment( Attacker, "FFA", 1 )
		sendArgs( "KilledPlayer", { Victim }, Attacker )
		
	end
	
	S_Deaths:Increment( Victim, "FFA", 1 )

	if Attacker:Frags() >= self.FragLimit then
		
		S_Wins:Increment( Attacker, "FFA", 1 )
		self.Parent:SetState( "EndGame", true )

	end

end


function GS_FFA:EntityTakeDamage( Target, Dmg )
	
	local Attacker = Dmg:GetAttacker()
	
	if ( Target:IsPlayer() and Attacker:IsPlayer() ) then
		
		-- Damage Combos
		if !Attacker.DamageCombo then Attacker.DamageCombo = 0 end
		Attacker.DamageCombo = Attacker.DamageCombo + Dmg:GetDamage()
		
		timer.Remove( Attacker:SteamID64() )
		timer.Create( Attacker:SteamID64(), 4, 1, function() 
			
			if Attacker.DamageCombo then
			
				S_DamageCombo:TestCombo( Attacker, math.floor( Attacker.DamageCombo ) )
				Attacker.DamageCombo = 0
				
			end
			
		end )
		
	end
	
end


function GS_FFA:PlayerSpawn( ply )

	ply:Give( "grappleshotty" )
	ply:Give( "grapplesniper" )

end
