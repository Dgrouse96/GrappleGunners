--
-- Predicted Grapple Movement
--

local MaxCableLength = 1500
local AirAccelerate = 1000
local DecendAccelerate = 1500
local MaxAirSpeed = 800
local MaxDecendSpeed = 1000

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


-- Air Control Direction
local function GetMovementVector( cmd )
	
	local Forward = KeyNum( cmd, IN_FORWARD ) - KeyNum( cmd, IN_BACK )
	local Right = KeyNum( cmd, IN_MOVELEFT ) - KeyNum( cmd, IN_MOVERIGHT )
	return Vector( Forward, Right, 0 ):GetNormal()
	
end


-- Calculate New Velocity
local function CalcGrapple( ply, mv, cmd, trace, tickdata, MoveVec, Velocity )
	
	-- Grab Variables
	local SwingPos = trace.HitPos
	local Origin = mv:GetOrigin()
	local SwingDist = tickdata.SwingDistance
	local Gravity = cvars.Number( "sv_gravity" ) * FrameTime()
	
	Velocity = Velocity + MoveVec
	
	-- Fix any incorrect grapple locations
	local GrapLocation = ply.GrappleLocation
	
	if CLIENT and ply == LocalPlayer() and GrapLocation and GrapLocation != SwingPos then
	
		//SwingPos = GrapLocation
		
	end
	
	-- Setup Cable Vectors
	local Cable = Origin - SwingPos
	local CableLength = Cable:Length()
	local CableDirection = Cable:GetNormal()
	
	-- Shorten Cable Length
	if CableLength < SwingDist then
		
		SwingDist = math.Clamp( CableLength, 100, MaxCableLength )
		
	end
	
	-- Change velocity direction
	local Elastic = math.Clamp( ( CableLength - SwingDist ) * 0.01, 0, 1 )
	local Reflection = ReflectVector( Velocity, CableDirection ) * -1.001
	
	
	local NewVelocity = Reflection + Vector( 0, 0, -Gravity )
	
	if Velocity:GetNormal():Dot( CableDirection ) > 0 then
	
		mv:SetVelocity( LerpVector( Elastic, Velocity, NewVelocity ) )
	
	else
	
		mv:SetVelocity( Velocity )
		
	end
	
	-- Store Tick Data
	local TD = {}
	TD.SwingDistance = SwingDist
	TD.Velocity = mv:GetVelocity() //- MoveVec
	TD.Trace = trace
	
	return TD
	
end

-- Sensitive Prediction stuff
function GM:SetupMove( ply, mv, cmd )
	
	if CLIENT and ply != LocalPlayer() then return end
	
	if !ply.TickData then ply.TickData = {} end
	local TD = ply.TickData[ cmd:TickCount() ]
	
	if !IsFirstTimePredicted() then
		
		if TD then
			
			mv:SetVelocity( TD.Velocity )
			
		end
		
		return
	
	end
	
	-- Keep table clean
	if ply.TickData[ cmd:TickCount()-50 ] then
	
		table.remove( ply.TickData, cmd:TickCount()-50 )
	
	end
	
	
	-- Last Tick Data
	local LTD = ply.TickData[ cmd:TickCount()-1 ]
	local MoveVec = Vector()
	local CurrentVelocity = mv:GetVelocity()
	
	-- Aircontrol
	if !ply:IsOnGround() then
		
		MoveVec = GetMovementVector( cmd )
		local Ang = Angle( 0, ply:EyeAngles().y, 0 )
		local Speed = 400
		local Decend = 0
		local MaxSpeed = false
		
		local CurrentAirSpeed = ( CurrentVelocity + MoveVec ):Length2D()
		local CurrentDecendSpeed = CurrentVelocity.z * -1
		
		if CurrentAirSpeed < MaxAirSpeed then
		
			if cmd:KeyDown( IN_SPEED ) then
				
				Speed = AirAccelerate
					
			end
				
		else
				
			Speed = 0
			MaxSpeed = true
				
		end
		
		if cmd:KeyDown( IN_DUCK ) and CurrentDecendSpeed < MaxDecendSpeed then
			
			Decend = DecendAccelerate
			
		end
		
		MoveVec:Rotate( Ang )
		
		-- At max speed, allow player to change direction (BROKEN)
		if MaxSpeed then
		
			local NewVel = MoveVec *  CurrentAirSpeed
			NewVel.z = CurrentVelocity.z
			//CurrentVelocity = LerpVector( FrameTime()*5, CurrentVelocity, NewVel )
			
		end
		
		MoveVec = MoveVec * Speed * FrameTime()
		MoveVec = MoveVec + Vector( 0, 0, - Decend ) * FrameTime()
		
	end
	
	if cmd:KeyDown( IN_ATTACK2 ) then
		
		local trace
		
		-- If last tick show's we're grappling, lets continue grappling
		if LTD and LTD.Trace then
			
			trace = LTD.Trace
			TD = CalcGrapple( ply, mv, cmd, trace, LTD, MoveVec, CurrentVelocity )
			
		else
			
			-- Check if we can start to grapple
			trace = HookTrace( ply, 0.5 )
			
			if trace and trace.Hit then
				
				TD = {}
				TD.SwingDistance = ( mv:GetOrigin() - trace.HitPos ):Length()
				TD = CalcGrapple( ply, mv, cmd, trace, TD, MoveVec, CurrentVelocity )
				
				-- Use this for drawing cable
				ply.GrappleLocation = trace.HitPos
				
				if SERVER then
				
					sendTable( "GrappleLocation", { ply = ply, pos = trace.HitPos } )
				
				end
				
			end
			
		end
		
		ply.TickData[ cmd:TickCount() ] = TD
	
	else
	
		ply.GrappleLocation = nil
		
		local NewVelocity = CurrentVelocity + MoveVec
		mv:SetVelocity( NewVelocity )
		ply.TickData[ cmd:TickCount() ] = { Velocity = NewVelocity }
		
		if SERVER then
			
			sendEntity( "RemoveGrapple", ply, EveryoneBut( ply ) )
			
		end

	end
	
end

for i=1, 4 do
	
	util.PrecacheSound( "physics/concrete/boulder_impact_hard" .. i .. ".wav" )
	
end

function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	
	if !IsFirstTimePredicted() then return end
	
	if speed > 1000 then
		
		-- Decal
		local PlyPos = ply:GetPos()
		util.Decal( "GG-GroundSlam", PlyPos, PlyPos - Vector( 0, 0, 20 ) )
		
		-- Sound
		local SoundToPlay = "physics/concrete/boulder_impact_hard" .. math.random( 1, 4 ) .. ".wav"
		EmitSound( SoundToPlay, PlyPos, ply:EntIndex(), CHAN_BODY )
		
		-- Temporary particle
		local smoke = EffectData()
		smoke:SetOrigin( PlyPos + Vector( 0, 0, 10 ) )
		smoke:SetScale( 500 )
		util.Effect( "ThumperDust", smoke )

	end
	
end