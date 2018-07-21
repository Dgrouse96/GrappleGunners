-- Client Grappling FX

function NewGrappleLocation( T )

	if !IsFirstTimePredicted() then return end
	
	T.ply.GrappleLocation = T.pos
	
	local effectdata = EffectData()
	effectdata:SetEntity( T.ply )
	
	util.Effect( "grapplecable", effectdata )
	
end
hook.Add( "GrappleLocation", "NewGrappleLocation", NewGrappleLocation )


function RemoveGrapple( ply )
	
	if !IsFirstTimePredicted() then return end
	ply.GrappleLocation = nil

end
hook.Add( "RemoveGrapple", "RemoveGrapple", RemoveGrapple )