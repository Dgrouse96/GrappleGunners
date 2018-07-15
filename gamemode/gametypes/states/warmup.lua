-- Kill existing Warmup
if GS_Warmup then

    GS_Warmup:Kill()
    GS_Warmup = nil
	
end

GS_Warmup = GameState()

function GS_Warmup:CountDownEnded()
	
	if self:ParentInPlay() then
		
		self.Parent:DoNextState()
		
	end
	
end

function GS_Warmup:CountDown( Seconds )
	
	timer.Create( "GS_Warmup", Seconds, 1, function() GS_Warmup:CountDownEnded() end )
	
end

function GS_Warmup:Enter( Seconds )
	
	print( "ASS", Seconds )
	self:CountDown( Seconds )
	
end

function GS_Warmup:Leave()
	
	
	
end