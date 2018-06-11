--
-- Misc functions
--

function ReflectVector( Direction, Normal )
	
	return 2 * Direction:Dot( Normal ) * Normal - Direction
	
end

function DirectionVector( From, To )
	
	return ( To - From ):GetNormal()
	
end