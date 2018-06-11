--
-- Predicted Grapple Movement
--

local MaxCableLength = 2000

-- Trace to find hook location, trace line before trace sphere
local function HookTrace( ply, debugtime )
	
	local trace = {
		start = ply:EyePos(), 
		endpos = ply:EyePos()+ply:EyeAngles():Forward()*MaxCableLength,
		mask = MASK_SOLID_BRUSHONLY,
		radius = 200
	}
	
	local linetrace = util.TraceLine( trace )
	
	if linetrace.Hit then 
	
		if debugtime then
			
			debugoverlay.Line( trace.start, linetrace.HitPos, debugtime, Color(255,120,0) )
			debugoverlay.Cross( linetrace.HitPos, 4, debugtime, Color(255,0,0) )
			
		end
	
		return linetrace
	
	else
	
		return util.spheretrace( trace, true, debugtime )
	
	end
	
end

local function boolnum( bool )

	return Either( bool, 1, 0 )

end

local function KeyNum( cmd, key )

	return boolnum( cmd:KeyDown( key ) )
	
end

local function GetMovementVector( cmd )
	
	local Forward = KeyNum( cmd, IN_FORWARD ) - KeyNum( cmd, IN_BACK )
	local Right = KeyNum( cmd, IN_MOVELEFT ) - KeyNum( cmd, IN_MOVERIGHT )
	return Vector( Forward, Right, 0 ):GetNormal()
	
end

-- Calculate New Velocity
local function CalcGrapple( ply, mv, cmd, trace, tickdata )
	
	-- Grab Variables
	local SwingPos = trace.HitPos
	local Velocity = mv:GetVelocity()
	local Origin = mv:GetOrigin()
	local SwingDist = tickdata.SwingDistance
	local Gravity = cvars.Number( "sv_gravity" ) * FrameTime()
	local MoveVec = Vector()
	
	-- Setup Cable Vectors
	local Cable = Origin - SwingPos
	local CableLength = Cable:Length()
	local CableDirection = Cable:GetNormal()
	
	-- Shorten Cable Length
	if CableLength < SwingDist then
		
		SwingDist = math.Clamp( CableLength, 100, MaxCableLength )
		
	end

	local Elastic = math.Clamp( ( CableLength - SwingDist ) * 0.01, 0, 1 )
	local Reflection = ReflectVector( Velocity, CableDirection ) * -1
	
	-- Aircontrol
	if !ply:IsOnGround() then
		
		local Ang = Angle( 0, ply:EyeAngles().y, 0 )
		local MoveVec = GetMovementVector( cmd )
		local Speed = 200
		
		if cmd:KeyDown( IN_SPEED ) then
			
			Speed = 800
			
		end
		
		MoveVec:Rotate( Ang )
		MoveVec = MoveVec * Lerp( Elastic, Speed, Speed ) * FrameTime()
		MoveVec = MoveVec + Vector( 0, 0, -Gravity )
		
		//print( MoveVec )
		Velocity = Velocity + MoveVec
		
	end
	
	local NewVelocity = Reflection + Vector( 0, 0, Gravity )
	
	if Velocity:GetNormal():Dot( CableDirection ) > 0 then
	
		mv:SetVelocity( LerpVector( Elastic, Velocity, NewVelocity ) )
		
	end
	
	-- Store Tick Data
	local TD = {}
	TD.SwingDistance = SwingDist
	TD.Velocity = mv:GetVelocity() - MoveVec
	TD.Origin = mv:GetOrigin()
	TD.Trace = trace
	
	return TD
	
end

-- Sensitive Prediction stuff
function GM:SetupMove( ply, mv, cmd )
	
	if !ply.TickData then ply.TickData = {} end
	local TD = ply.TickData[ cmd:TickCount() ]
	local LTD = ply.TickData[ cmd:TickCount()-1 ]
	
	if !IsFirstTimePredicted() then
		
		if TD then
			
			mv:SetVelocity( TD.Velocity )
			mv:SetOrigin( TD.Origin )
			
		end
		
		return
	
	end
	
	if cmd:KeyDown( IN_ATTACK2 ) then
		
		local trace
		
		-- If last tick show's we're grappling, lets continue grappling
		if LTD and LTD.Trace then
			
			trace = LTD.Trace
			TD = CalcGrapple( ply, mv, cmd, trace, LTD )
			
		else
			
			-- Check if we can start to grapple
			trace = HookTrace( ply, 0.5 )
			
			if trace and trace.Hit then
				
				TD = {}
				TD.SwingDistance = ( mv:GetOrigin() - trace.HitPos ):Length()
				TD = CalcGrapple( ply, mv, cmd, trace, TD )
				
			end
			
		end
		
		ply.TickData[ cmd:TickCount() ] = TD

	end
	
end