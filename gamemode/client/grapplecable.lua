local MAT_Cable = Material('cable/new_cable_lit')

local function DrawGrapple()
	
	render.SetMaterial( MAT_Cable )
	
	for _,ply in pairs( player.GetAll() ) do
	
		local GL = ply.GrappleLocation
		
		if GL then
		
			render.DrawBeam( ply:GetPos(), GL, 3, 0, 1, Color(10,10,10) )
		
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