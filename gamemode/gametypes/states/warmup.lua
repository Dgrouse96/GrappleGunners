--
-- Simple warmup state, no stat collection
--

-- Setup default vars
GS_Warmup = GameState( { 
	
	StartTime = 0,
	EndTime = 0,
	Length = 0,
	
} )

function GS_Warmup:CountDownEnded()
	
	if self:ParentInPlay() then
		
		self.Parent:DoNextState( true )
		
	end
	
end


function GS_Warmup:CountDown( Seconds )
	
	if !Seconds then Seconds = 5 end
	
	self.StartTime = CurTime()
	self.EndTime = CurTime() + Seconds
	self.Length = Seconds
	
	if SERVER then
		
		SetTimerTime( Seconds )
		timer.Create( "GS_Warmup", Seconds, 1, function() GS_Warmup:CountDownEnded() end )
		
	end
	
end


function GS_Warmup:GetTimeLeft()
	
	return math.Clamp( self.EndTime - CurTime(), 0, self.Length )
	
end


function GS_Warmup:Enter( Seconds )
	
	self:CountDown( Seconds )
	LockMovement( false )
	
	if CLIENT then
		
		SetGameplayHud( HUD_Warmup )
	
	else
	
		self:AddHook( "PlayerInitialSpawn", self.PlayerInitialSpawn )
	
	end
	
end


function GS_Warmup:PlayerInitialSpawn( ply )
	
	SendCurrentTimer( ply )
	
end


function GS_Warmup:Leave()
	
	
	
end