-- Kill existing FFA state
if GS_FFA then

    GS_FFA:Kill()
    GS_FFA = nil
	
end

GS_FFA = GameState()

function GS_FFA:Enter()
	
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
				
			end
			
		end )
		
	end
	
end