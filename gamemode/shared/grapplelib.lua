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

function inverselerpclamp( A, Min, Max )
	
	return math.Clamp( inverselerp( A, Min, Max ), 0, 1 )
	
end

function LerpClamp( Alpha, From, To )
	
	return math.Clamp( Lerp( Alpha, From, To ), 0, 1 )
	
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

-- Lerps towards target without over shooting
function Lerp2( Alpha, A, B )
	
	return Lerp( math.Clamp( Alpha, 0, 1 ), A, B )
	
end


-- Kill any existing objects
function ClearObjects( Registry )

	if Registry then
		
		for k,v in pairs( Registry ) do
			
			v:Kill()
			v = nil
			
		end
		
		table.Empty( Registry )
		
	else

		Registry = {}
		
	end
	
end


-- Removes /filename.txt from string
function GetPath( String )
	
	local NewString = ""
	local Explode = string.Explode( "/", String )
	
	for k,v in pairs( Explode ) do
		
		if k != #Explode then
		
			NewString = NewString .. v .. Either( k == #Explode-1, "", "/" )
			
		end
		
	end
	
	return NewString
	
end


-- Increment GG version tag
function IncrementVersion( Current, Milestone )
	
	if !Milestone then Milestone = 3 end
	
	-- Split Version
	local Explode = string.Explode( ".", Current )
	Explode[ Milestone ] = tostring( tonumber( Explode[ Milestone ] ) + 1 )
	
	-- Recombine it
	local NewVersion = ""
	for k,v in pairs( Explode ) do
	
		NewVersion = NewVersion .. v .. Either( k == #Explode, "", "." )
		
	end
	
	return NewVersion
	
end

--
-- Globals
--

COL_WHITE = Color( 255, 255, 255, 255 )
COL_BLACK = Color( 0, 0, 0, 255 )