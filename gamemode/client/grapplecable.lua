-- Client Grappling FX

function NewGrappleLocation( T )
	
	T.ply.GrappleLocation = T.pos
	
	local effectdata = EffectData()
	effectdata:SetEntity( T.ply )
	
	util.Effect( "grapplecable", effectdata )
	
end
hook.Add( "GrappleLocation", "NewGrappleLocation", NewGrappleLocation )


function RemoveGrapple( ply )
	
	ply.GrappleLocation = nil

end
hook.Add( "RemoveGrapple", "RemoveGrapple", RemoveGrapple )