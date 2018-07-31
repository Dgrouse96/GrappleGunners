GS_EndGame = GameState()

function GS_EndGame:Enter( Winner )
	
	if SERVER then
		
		for k,ply in pairs( player.GetAll() ) do
		
			ply:Freeze( true )
			ply:StripWeapons()
			
		end
		
		self.Podium = SpawnPodium()
		
		if !self.Podium then MapList:ChoseAndSendMaps() return end
		
		timer.Simple( 2, function()
			
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
		
		SetGameplayHud( HUD_GameOver )
		
	end
	
end