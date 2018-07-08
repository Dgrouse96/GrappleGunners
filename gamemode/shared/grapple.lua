--
-- Predicted Grapple Movement
--

local MaxCableLength = 1500
local AirAccelerate = 1000
local DecendAccelerate = 1500
local MaxAirSpeed = 800
local MaxDecendSpeed = 1000
local BoostConsumption = 0.16
local BoostRecharge = 0.5

local GroundSlams = {}

-- Trace to find hook location, trace line before trace sphere
local function HookTrace( ply, mv, debugtime )
	
	-- ply:EyeAngles() is not predicted!
	local Eye = mv:GetOrigin() + Vector( 0, 0, 64 )
	local EyeAng = mv:GetAngles()
	
	local trace = {
		start = Eye, 
		endpos = Eye + EyeAng:Forward() * MaxCableLength,
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
	//if !IsValid( ply.TickData[ cmd:TickCount() ] ) then ply.TickData[ cmd:TickCount() ] = {} end
	local TD = ply.TickData[ cmd:TickCount() ]
	
	if !IsFirstTimePredicted() then
		
		if TD and IsValid( TD.Velocity ) then
			
			mv:SetVelocity( TD.Velocity )
			return
			
		end
	
	end
	
	-- Keep table clean
	if ply.TickData[ cmd:TickCount()-50 ] then
	
		table.remove( ply.TickData, cmd:TickCount()-50 )
	
	end
	
	
	-- Last Tick Data
	local LTD = ply.TickData[ cmd:TickCount()-1 ]
	if !LTD then LTD = {} end
	
	local CurrentVelocity = mv:GetVelocity()
	
	-- Ground slamming
	for k,v in pairs( GroundSlams ) do
	
		if v.ply != ply then
		
			if v.time < CurTime()+3 then
				
				local Power = 5000
				local Multiplier = math.Clamp( 0.1 + v.time - CurTime(), 0, 1 )
				local Direction = mv:GetOrigin() - v.pos
				local Distance = Direction:Length()
				
				local DistanceFade = math.Clamp( inverselerp( Distance, 400, 0 ), 0, 1 )
				Direction:Normalize()

				CurrentVelocity = CurrentVelocity + Direction * Power * Multiplier * DistanceFade
				
				if SERVER then
				
					ply:TakeDamage( 150 * Multiplier * DistanceFade, v.ply )
				
				end
			
			else
				
				table.remove( GroundSlams, k )
				
			end
		
		end
	
	end
	--
	
	local BoostAmount = LTD.BoostAmount
	if !BoostAmount then BoostAmount = 1 end
	
	local MoveVec = Vector()
	
	-- Aircontrol
	if !ply:IsOnGround() then
		
		MoveVec = GetMovementVector( cmd )
		local Ang = Angle( 0, ply:EyeAngles().y, 0 )
		local Speed = 500
		local Decend = 0
		local MaxSpeed = false
		
		local CurrentAirSpeed = ( CurrentVelocity + MoveVec ):Length2D()
		local CurrentDecendSpeed = CurrentVelocity.z * -1
		
		-- Boosting
		if CurrentAirSpeed < MaxAirSpeed then
			
			if BoostAmount > 0 then
				
				if cmd:KeyDown( IN_SPEED ) then
				
					Speed = AirAccelerate
					
				end
				
			end
					
		else
				
			Speed = 0
			MaxSpeed = true
		
		end
		
		if CurrentDecendSpeed < MaxDecendSpeed then
			
			if cmd:KeyDown( IN_DUCK ) then
				
				if BoostAmount > 0 then
					
					Decend = DecendAccelerate
					
				else
					
					Decend = 200
					
				end
				
			end
		
		else
		
			Decend = 0
		
		end
		
		ply.UsingBoost = cmd:KeyDown( IN_DUCK ) or cmd:KeyDown( IN_SPEED )
		
		if ply.UsingBoost then
			
			BoostAmount = math.Clamp( BoostAmount - FrameTime() * BoostConsumption, 0, 1 )
			
		end
		
		MoveVec:Rotate( Ang )
		MoveVec = MoveVec * Speed * FrameTime()
		MoveVec = MoveVec + Vector( 0, 0, - Decend ) * FrameTime()
	
	else
	
		BoostAmount = math.Clamp( BoostAmount + FrameTime() * BoostRecharge, 0, 1 )
	
	end
	
	-- Use these for Hud variables
	ply.UsingBoost = !ply:IsOnGround() and ( cmd:KeyDown( IN_DUCK ) or cmd:KeyDown( IN_SPEED ) )
	ply.BoostAmount = BoostAmount
	
	-- Grappling
	if cmd:KeyDown( IN_ATTACK2 ) then
		
		local trace
		
		-- If last tick show's we're grappling, lets continue grappling
		if LTD and LTD.Trace then
			
			trace = LTD.Trace
			TD = CalcGrapple( ply, mv, cmd, trace, LTD, MoveVec, CurrentVelocity )
			
		else
			
			-- Check if we can start to grapple
			trace = HookTrace( ply, mv, 0.5 )
			
			-- Start Grappling
			if trace and trace.Hit then
				
				TD = {}
				TD.SwingDistance = ( mv:GetOrigin() - trace.HitPos ):Length()
				TD = CalcGrapple( ply, mv, cmd, trace, TD, MoveVec, CurrentVelocity )
				
				-- Use this for drawing cable
				local HookData = { ply = ply, pos = trace.HitPos }
				
				if SERVER then
					-- Draw cable for other clients
					sendTable( "GrappleLocation", HookData, EveryoneBut( ply ) )
				
				else
				
					hook.Run( "GrappleLocation", HookData )
					
				end
				
			end
			
		end
		
		if !TD then TD = {} end
		TD.BoostAmount = BoostAmount
		ply.TickData[ cmd:TickCount() ] = TD
	
	else
		
		local NewVelocity = CurrentVelocity + MoveVec
		mv:SetVelocity( NewVelocity )
		
		ply.TickData[ cmd:TickCount() ] = { 
		
			Velocity = NewVelocity,
			BoostAmount = BoostAmount,
			
		}
		
		if SERVER then
			
			sendEntity( "RemoveGrapple", ply, EveryoneBut( ply ) )
			
		else
		
			hook.Run( "RemoveGrapple", ply )
			
		end

	end
	
end



--
-- Ground Slamming
--

local GroundSounds = {}

for i=1, 4 do
	
	GroundSounds[ i ] = Sound( "physics/concrete/boulder_impact_hard" .. i .. ".wav" )
		
end

function DoGroundSlam( ply )
	
	-- Decal
	local PlyPos = ply:GetPos()
	util.Decal( "GG-GroundSlam", PlyPos, PlyPos - Vector( 0, 0, 30 ), ply )
	
	-- Sound
	local SoundToPlay = GroundSounds[ math.random( 1, 4 ) ]
	EmitSound( SoundToPlay, PlyPos, ply:EntIndex(), CHAN_BODY, ply )
	
	-- Temporary particle
	local smoke = EffectData()
	smoke:SetOrigin( PlyPos + Vector( 0, 0, 10 ) )
	smoke:SetScale( 500 )
	util.Effect( "ThumperDust", smoke )
	
	table.insert( GroundSlams, {
		time = CurTime(),
		pos = PlyPos,
		ply = ply
	} )
	
end
hook.Add( "DoGroundSlam", "Execute", DoGroundSlam )


function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	
	if !IsFirstTimePredicted() then return end
	
	if speed > 1200 then
		
		DoGroundSlam( ply )
		
		-- Clients don't run this function for other players
		if SERVER then
		
			sendEntity( "DoGroundSlam", ply, EveryoneBut( ply ) )
			
		end
		
	end
	
end