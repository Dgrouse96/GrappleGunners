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
			GS_FFA:AddHook( "EntityFireBullets", GS_FFA.EntityFireBullets )
			GS_FFA:AddHook( "PlayerTick", GS_FFA.PlayerTick )

		end )
		
	else
	
		SetGameplayHud( HUD_Gameplay )
		self:AddHook( "PreDrawHalos", self.PreDrawHalos )
		self:AddHook( "NewLeader", self.NewLeader )
		self:AddHook( "NoLeader", self.NoLeader )

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


function GS_FFA:PlayerSpawn( ply )

	ply:Give( "grappleshotty" )
	ply:Give( "grapplesniper" )
	
	-- Spawn Protection
	ply:SetColor( Color( 255,255,255,200 ) )
	ply:SetRenderMode( RENDERMODE_TRANSALPHA ) 
	
	ply.SpawnProtection = {
		time = CurTime(),
		pos = ply:GetPos(),
	}

end


function GS_FFA:PlayerDeath( Victim, Inflictor, Attacker )
	
	-- Stat collection on npcs?... nah.
	if !Victim:IsPlayer() or !Attacker:IsPlayer() then return end
	
	
	-- Give Attacker a kill if they deserve it
	if Victim != Attacker then
	
		S_Kills:Increment( Attacker, "FFA", 1 )
		sendArgs( "KilledPlayer", { Victim }, Attacker )
		
	end
	
	
	-- Death stats
	S_Deaths:Increment( Victim, "FFA", 1 )
	
	
	-- Check if player is ahead by at least 1 and mark them for death
	if self.Parent.SortedPlayers then
			
		local Plys = self.Parent:SortedPlayers()
		if IsValid( Plys[1] ) and IsValid( Plys[2] ) then
		
			if Attacker == Plys[1] and Plys[1]:Frags() > Plys[2]:Frags() then
				
				sendEntity( "NewLeader", Plys[1] )
			
			elseif Plys[1]:Frags() == Plys[2]:Frags() then
			
				sendMessage( "NoLeader" )
				
			end
			
		end
		
	end
	
	
	-- Check if attacker has reached the kill limit
	if Attacker:Frags() >= self.FragLimit then
		
		S_Wins:Increment( Attacker, "FFA", 1 )
		self.Parent:SetState( "EndGame", true )

	end

end


function GS_FFA:EntityTakeDamage( Target, Dmg )
	
	local Attacker = Dmg:GetAttacker()
	
	-- Spawn Protection
	if Target:IsPlayer() and self:CheckSpawnProtection( Target ) then
			
		Dmg:SetDamage( 0 )
		
	end
	
	-- Damage combo stats
	if ( Target:IsPlayer() and Attacker:IsPlayer() ) then
		
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


function GS_FFA:DisableSpawnProtection( ply )
	
	ply.SpawnProtection = nil
	ply:SetColor( Color( 255,255,255,255 ) )
	ply:SetRenderMode( RENDERMODE_NORMAL ) 
		
end


-- True if they are still in spawn protection
function GS_FFA:CheckSpawnProtection( ply )
	
	if ply.SpawnProtection then
		
		if ply.SpawnProtection.pos:Distance( ply:GetPos() ) < 100 then
			
			if CurTime() - ply.SpawnProtection.time < 3 then
				
				return true
				
			end
			
		end
		
	end
	
	return false
	
end


-- Disable spawn protection
function GS_FFA:EntityFireBullets( ply )
	
	if IsValid( ply ) and ply:IsPlayer() and ply.SpawnProtection then
		
		self:DisableSpawnProtection( ply )
		
	end
	
end


function GS_FFA:PlayerTick( ply, mv )
	
	if ply.SpawnProtection then
	
		if !self:CheckSpawnProtection( ply ) then 
		
			self:DisableSpawnProtection( ply ) 
			
		end
		
	end
	
end


-- Make the leader stand out >:D
function GS_FFA:NewLeader( ply )
	
	self.Leader = ply
	
end

function GS_FFA:NoLeader()
	
	self.Leader = nil
	
end

function GS_FFA:PreDrawHalos()
	
	if self.Leader and IsValid( self.Leader ) and self.Leader:Alive() then
		
		halo.Add( {self.Leader}, Color( 50,80,150 ), 3, 3, 2 )
		
	end
	
end