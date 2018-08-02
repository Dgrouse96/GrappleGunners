--
-- Misc server-side functions
--

local CurrentLength = 0
local CurrentStartTime = 0

function SetTimerTime( Length, StartTime, ply, DontSetCurrent )

	if !StartTime then StartTime = CurTime() end
	sendArgs( "SetTimerTime", { Length, StartTime }, ply )
	
	if !DontSetCurrent then
		
		CurrentLength = Length
		CurrentStartTime = StartTime
		
	end
	
end

function SendCurrentTimer( ply )
	
	if CurrentLength == 0 then return end
	sendArgs( "SetTimerTime", { CurrentLength, CurrentStartTime }, ply )
	
end

function ClearCurrentTimer()
	
	CurrentLength = 0
	CurrentStartTime = 0
	
end