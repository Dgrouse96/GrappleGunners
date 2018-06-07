function FindReflectionAngle( Direction, Normal )
	
	return 2 * Direction:Dot( Normal ) * Normal - Direction
	
end