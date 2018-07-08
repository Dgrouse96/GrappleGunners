--
-- Misc functions
--

function ReflectVector( Direction, Normal )
	
	return 2 * Direction:Dot( Normal ) * Normal - Direction
	
end

function DirectionVector( From, To )
	
	return ( To - From ):GetNormal()
	
end

function boolnum( bool )

	return Either( bool, 1, 0 )

end

function KeyNum( cmd, key )

	return boolnum( cmd:KeyDown( key ) )
	
end

function inrange( A, Min, Max )
	
	if A >= Min and A < Max then return true end
	return false
	
end

-- My personal favourite
function inverselerp( A, Min, Max )
	
	return (A - Min) / (Max - Min)
	
end

-- Powerful easing function
function ease( A, Pow, Inf )

	if A < Inf then return 1 / math.pow( Inf, Pow-1 ) * math.pow( A, Pow ) end
	return 1 - 1 / math.pow( 1-Inf, Pow-1 ) * math.pow( 1-A, Pow )
	
end

function LerpColor( Alpha, A, B )
	
	local Blend = Color(0,0,0,0)
	Blend.r = Lerp( Alpha, A.r, B.r )
	Blend.g = Lerp( Alpha, A.g, B.g )
	Blend.b = Lerp( Alpha, A.b, B.b )
	Blend.a = Lerp( Alpha, A.a, B.a )
	
	return Blend
	
end



--
-- Globals
--

COL_WHITE = Color( 255, 255, 255, 255 )