-- Kill existing FFA state
if GS_EndGame then

    GS_EndGame:Kill()
    GS_EndGame = nil
	
end

GS_EndGame = GameState()

function GS_EndGame:Enter( Winner )
	
	for k,ply in pairs( player.GetAll() ) do
	
		ply.LockMovement = true
		ply.LockMovementPos = ply:GetPos()
		
	end
	
end