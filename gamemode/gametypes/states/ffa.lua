-- Kill existing FFA state
if GS_FFA then

    GS_FFA:Kill()
    GS_FFA = nil
	
end

GS_FFA = GameState()

function GS_FFA:Enter()
	
	print( "WE FITIN" )
	
end