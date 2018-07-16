--
-- Simple warmup state, no stat collection
--


-- Kill existing Warmup
if GS_Warmup then

    GS_Warmup:Kill()
    GS_Warmup = nil
	
end

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
	
		timer.Create( "GS_Warmup", Seconds, 1, function() GS_Warmup:CountDownEnded() end )
		
	end
	
end


function GS_Warmup:GetTimeLeft()
	
	return math.Clamp( self.EndTime - CurTime(), 0, self.Length )
	
end


function GS_Warmup:Enter( Seconds )
	
	self:CountDown( Seconds )
	
end

function GS_Warmup:Leave()
	
	
	
end