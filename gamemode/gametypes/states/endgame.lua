GS_EndGame = GameState()

function GS_EndGame:Enter( Winner )
	
	if SERVER then
		
		for k,ply in pairs( player.GetAll() ) do
		
			ply:Freeze( true )
			ply:StripWeapons()
			
		end
		
		-- Saftey net
		timer.Simple( 35, function()
			
			PrintMessage( HUD_PRINTTALK, "Error! Report this to me asap, auto fixing..." )
			MapList:ChoseAndSendMaps()
			
		end )
		
		
		-- Send them to their locked movement pos
		self:AddHook( "PlayerSpawn", self.PlayerSpawn )
		
		-- Don't send new client's any old timers
		ClearCurrentTimer()
		self:AddHook( "PlayerInitialSpawn", self.PlayerInitialSpawn )
		
		
		-- Setup podium
		self.Podium = SpawnPodium()
		
		if !self.Podium then MapList:ChoseAndSendMaps() return end
		
		timer.Simple( 2, function()
			
			if !self.Parent or !self.Parent.TopThree then
				
				MapList:ChoseAndSendMaps()
				return
				
			end
			
			for k,ply in pairs( self.Parent:TopThree() ) do
				
				ply:Freeze( false )
				ply:Spawn()
				
				-- Go to podium
				local Pos, Ang = self.Podium:GetWinPos( k )
				ply:SetPos( Pos )
				ply:SetAngles( Ang )

				LockMovement( true, ply )
				
				if k == 1 then
					
					ply:Give( "grappleshotty" )
					ply:Give( "grapplesniper" )
					
				end
				
			end
			
			self.Podium:CameraAnim()
			
			timer.Simple( 10, function()
				
				MapList:ChoseAndSendMaps()
				
			end )
			
			
		end )
		
	else
		
		Widget_Timer.Length = 0
		SetGameplayHud( HUD_GameOver )
		
	end
	
end


function GS_EndGame:PlayerSpawn( ply )
	
	if ply.MovementLocked and ply.MovementLockedPos then
		
		ply:SetPos( ply.MovementLockedPos )
		
	end
	
end


function GS_EndGame:PlayerInitialSpawn( ply )
	
	SendCurrentTimer( ply )
	
end