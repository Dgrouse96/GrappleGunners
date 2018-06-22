local MAT_Cable = Material('cable/new_cable_lit')

local function DrawGrapple()
	
	render.SetMaterial( MAT_Cable )
	
	for _,ply in pairs( player.GetAll() ) do
		
		local GL = ply.GrappleLocation
		
		if ply:Alive() and GL then
			
			local Pos = Vector()
			
			if ply == LocalPlayer() then
				
				local M = Matrix()
				M:Rotate( ply:EyeAngles() )
				M:Translate( Vector( 10, 10, -40 ) )
				Pos = ply:EyePos() + M:GetTranslation()
				
			else
			
				local Hand = ply:GetBoneMatrix( 16 )
				
				if Hand then
					Hand:Translate( Vector( 2.5, -1.2, 1 ) )
					Pos = Hand:GetTranslation()
				end
				
			end

			render.DrawBeam( Pos, GL, 2, 0, 1, Color(10,10,10) )
			
		else
		
			ply.GrappleLocation = nil
			
		end
		
	end
	
end
hook.Add( "PostDrawTranslucentRenderables", "DrawGrapple", DrawGrapple )


function NewGrappleLocation( T )
	
	T.ply.GrappleLocation = T.pos
	
end
hook.Add( "GrappleLocation", "NewGrappleLocation", NewGrappleLocation )


function RemoveGrapple( ply )

	ply.GrappleLocation = nil

end
hook.Add( "RemoveGrapple", "RemoveGrapple", RemoveGrapple )