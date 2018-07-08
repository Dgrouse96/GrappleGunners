-- !!!!!!!!!!!!! DEPRECATED !!!!!!!!!!!!!
--
-- Blend poses to make anims
--
// Poses need to be object based, I think this produces a lot of garbage.


local function GetRetarget( name )
	
	return RETARGETS[ name ]
	
end

local function GetPose( name )
	
	local Pose = POSES[ name ]
	if Pose then return table.Copy( Pose ) end
	
	return {}
	
end

-- Match mismatched bone ids and names
local function RetargetBones( Pose, Retarget )
	
	local FinalPose = {}
	
	for k,v in pairs( Pose ) do
		
		if Retarget[k] then
			
			FinalPose[ Retarget[k] ] = v
		
		else
			
			if !FinalPose[k] then FinalPose[k] = v end
			
		end
		
	end
	
	return FinalPose
	
end

-- Return some valid data
local function TidyBoneData( Data )
	
	if !Data then return { p = Vector(), a = Angle() } end
	
	if !isvector( Data.p ) then Data.p = Vector() end
	if !isangle( Data.a ) then Data.a = Angle() end
	
	return Data
	
end

-- Set player's pose
local function ApplyPose( ply, Pose )
	
	if !Pose then Pose = {} end
	
	for i=0, ply:GetBoneCount()-1 do
		
		local v = TidyBoneData( Pose[i] )
		ply:ManipulateBonePosition( i, v.p )
		ply:ManipulateBoneAngles( i, v.a )
		
	end
	
end

-- Good for limbs ( Gun aiming / Grappling )
local function OverrideBones( ply, Pose, Override )
	
	if !Pose then Pose = {} end
	
	for k,v in pairs( Override ) do
		
		Pose[k] = v
		
	end
	
	return Pose
	
end

-- Lerp 2 poses
local function BlendPoses( Pose1, Pose2, Alpha )

	local ReturnValue = {}
	
	for k,v in pairs( Pose1 ) do
		
		local v1 = TidyBoneData( v )
		local v2 = TidyBoneData( Pose2[k] )
		
		ReturnValue[k] = { 
			p = LerpVector( Alpha, v1.p, v2.p ), 
			a = LerpAngle( Alpha, v1.a, v2.a ),
		}
		
	end
	
	for k,v in pairs( Pose2 ) do
		
		if !ReturnValue[k] then
			
			ReturnValue[k] = v
			
		end
		
	end
	
	return ReturnValue
	
end


local function AddPoses( Pose1, Pose2 )

	local ReturnValue = {}
	
	for k,v in pairs( Pose1 ) do
		
		local v1 = TidyBoneData( v )
		local v2 = TidyBoneData( Pose2[k] )
		
		ReturnValue[k] = { 
			p = v1.p + v2.p, 
			a = v1.a + v2.a,
		}
		
	end
	
	for k,v in pairs( Pose2 ) do
		
		if !ReturnValue[k] then
			
			ReturnValue[k] = v
			
		end
		
	end
	
	return ReturnValue
	
end

-- Add pos/ang to a specific bone
local function AdditiveBone( Pose, Bone, Data )
	
	if !Data then return Pose end
	if !Pose[Bone] then Pose[Bone] = Data end
	
	local BD = Pose[Bone]
	
	Pose[Bone] = { p = BD.p + Data.p, a = BD.a + Data.a }
	
	return Pose
	
end

-- Replace a single bone's transform
local function ReplaceBone( Pose, Bone, Data )
	
	if !Data then return Pose end
	if !Pose[Bone] then Pose[Bone] = Data end
	
	Pose[Bone] = Data
	
	return Pose
	
end


--
-- Running Animation
--

local Interval = 0

local Power = 1.5

local function Anim_Run( ply )

	local Pose = {}
	
	local Vel = ply:GetVelocity() Vel.z = 0
	local Speed = math.Clamp( Vel:Length2D()/50, 2, 10 )
	
	local Direction = 1
	if Vel:Dot( ply:GetForward() ) < 0 then Direction = -1 end
	
	if !ply.ARunTime or !ply:OnGround() then ply.ARunTime = 1 end
	if !ply.A_SmoothRun then ply.A_SmoothRun = 0 end

	ply.ARunTime = ply.ARunTime + Interval * Speed * Direction
	local Weight = ply.ARunTime % 4
	
	if inrange( Weight, 0, 1 ) then
	
		Pose = BlendPoses( GetPose( "sprint1" ), GetPose( "sprint2" ), ease( Weight, Power, 1 ) )
		
	elseif inrange( Weight, 1, 2 ) then
	
		Pose = BlendPoses( GetPose( "sprint2" ), GetPose( "sprint3" ), ease( inverselerp( Weight, 1, 2 ), Power, 0.1 ) )
		
	elseif inrange( Weight, 2, 3 ) then
	
		Pose = BlendPoses( GetPose( "sprint3" ), GetPose( "sprint4" ), ease( inverselerp( Weight, 2, 3 ), Power, 1 ) )
		
	elseif inrange( Weight, 3, 4 ) then
	
		Pose = BlendPoses( GetPose( "sprint4" ), GetPose( "sprint1" ), ease( inverselerp( Weight, 3, 4 ), Power, 0.1 ) )
	
	end
	
	ply.A_SmoothRun = Lerp( Interval * 10, ply.A_SmoothRun, math.Clamp( Vel:Length2D()/50, 0, 10 ) )
	ply.A_SmoothRun = math.Clamp( ply.A_SmoothRun, 0, 1.3 )
	
	Pose = BlendPoses( GetPose( "idle1" ), Pose, ply.A_SmoothRun )
	
	return Pose
	
end


--
-- Falling anim
--

local function Anim_Fall()
	
	return GetPose( "fallidle1" )
	
end

local function Anim_BaseLocomotion( ply )
	
	if !ply.A_BlendFall then ply.A_BlendFall = 0 end
	
	ply.A_BlendFall = Lerp( Interval * 15, ply.A_BlendFall, Either( ply:OnGround(), 1, 0 ) )
	
	-- Don't blend in these cases
	if ply.A_BlendFall > 0.999 then
	
		return Anim_Run( ply )
	
	elseif ply.A_BlendFall < 0.001 then
	
		return Anim_Fall()
		
	end
	
	
	return BlendPoses( Anim_Fall(), Anim_Run( ply ), ply.A_BlendFall )
	
end


--
-- Additive Run Tilt
--

local function RunTilt( ply )
	
	if !ply.A_SmoothTilt then ply.A_SmoothTilt = 0 end
	if !ply.A_LastVelocity then ply.A_LastVelocity = Vector() end
	
	local Velocity = ply:GetVelocity():GetNormalized()
	local Tilt = math.Clamp( Velocity:Cross( ply.A_LastVelocity ).z * 500000 * Interval, -20, 20 )
	
	ply.A_SmoothTilt = Lerp( Interval * 2, ply.A_SmoothTilt, Tilt )
	ply.A_LastVelocity = Velocity
	
	return { 
		p = Vector(), 
		a = Angle( 0, ply.A_SmoothTilt * 2, 0 )
	}
	
end


--
-- Orient Player to Velocity Direction
--

local function RunDirection( ply )
	
	if !ply.A_SmoothRunAng then ply.A_SmoothRunAng = 0 end
	
	local Velocity = ply:GetVelocity():GetNormalized()
	Velocity.z = 0
	
	local Vel = Velocity:Angle()
	local Yaw = ply:GetAngles().y
	local Ang = Vel.y - Yaw
	
	if Velocity:Length() > 0.1 then
		
		-- Flip direction for reverse run
		if ( Ang > 95 and Ang < 260 and Ang > 100 ) then
			
			Ang = Ang+180
			
		end
	
	else
	
		Ang = 0
	
	end
	
	ply.A_SmoothRunAng = LerpAngle( Interval * 10, Angle( 0, ply.A_SmoothRunAng, 0 ), Angle( 0, Ang, 0 ) ).y
	
	return { 
		p = Vector(), 
		a = Angle( ply.A_SmoothRunAng, 0, 0 )
	}
	
end

-- Rotates spine to face aim direction
local function Blend_RunDirection( ply, Pose )
	
	Pose = AdditiveBone( Pose, 0, RunDirection( ply ) )
	
	local Ang = math.Clamp( ply.A_SmoothRunAng, -90, 90 )
	local FixYaw = { 
		p = Vector(), 
		a = Angle( 0, 0, -Ang/4 )
	}
	
	for i=1,4 do
		
		Pose = AdditiveBone( Pose, i, FixYaw )
		
	end
	
	return Pose
	
end


--
-- Weapon Aiming
--

local function WeaponAim( ply )
	
	local Pose = {}
	local Smoothrun = ply.A_SmoothRun or 0
	local Pitch = ply:EyeAngles().p
	
	local Pitch = Pitch + Either( ply:OnGround(), Lerp( Smoothrun, 0, -35 ), -15 )
	
	//Pose = AdditiveBone( Pose, 0, RunTilt( ply ) )
	
	if Pitch > 0 then
	
		return BlendPoses( GetPose( "gunaim_mid" ), GetPose( "gunaim_low" ), Pitch/90 )
	
	end
		
	return BlendPoses( GetPose( "gunaim_mid" ), GetPose( "gunaim_high" ), -Pitch/85 )
	
end


--
-- Grapple Aiming
--

local function GrappleAim( ply )
	
	if ply.GrappleLocation then
		
		local Dir = DirectionVector( ply:EyePos(), ply.GrappleLocation )
		local Ang = Angle( 0, ply:EyeAngles().y+90, 0 ) - Dir:Angle()
		
		ply.A_GrappleAngle = Ang
		
	end
	
	local Ang = ply.A_GrappleAngle
	Ang:Normalize()
	
	local Dir = Ang:Forward()
	
	local F = Either( Dir.y > 0, GetPose( "grap-f" ), GetPose( "grap-b" ) )
	local R = Either( -Dir.x > 0, GetPose( "grap-r" ), GetPose( "grap-l" ) )
	local U = Either( -Dir.z > 0, GetPose( "grap-u" ), GetPose( "grap-d" ) )
	
	-- Scale
	local Pose = F
	local Pose = BlendPoses( Pose, R, math.abs( Dir.x ) )
	local Pose = BlendPoses( Pose, U, math.abs( Dir.z ) )
	
	return Pose
	
end

local function Blend_Grapple( ply, Pose )
	
	if !ply.A_BlendGrapple then ply.A_BlendGrapple = 0 end
	
	local TargetBlend = 0
	if ply.GrappleLocation then TargetBlend = 1 end
	
	ply.A_BlendGrapple = Lerp( Interval * 15, ply.A_BlendGrapple, TargetBlend )
	
	-- Don't blend in these cases
	if ply.A_BlendGrapple > 0.999 then
	
		return OverrideBones( ply, Pose, GrappleAim( ply ) )
	
	elseif ply.A_BlendGrapple < 0.001 then
	
		return Pose
		
	end
	
	local OldPose = table.Copy( Pose )
	return BlendPoses( OldPose, OverrideBones( ply, Pose, GrappleAim( ply ) ), ply.A_BlendGrapple )
	
end


--
-- Main Anim Function
--

function RunPoseAnims( ply )
		
	-- Running/Falling Anim
	local Pose = Anim_BaseLocomotion( ply )
	
	
	-- Tilt into turn
	Pose = AdditiveBone( Pose, 0, RunTilt( ply ) )
	
	
	-- Rotate to move direction ( Twists hips back to face aim direction )
	Pose = Blend_RunDirection( ply, Pose )
	
	
	-- Aim Weapon Arm
	if IsValid( ply:GetActiveWeapon() ) then
		
		Pose = OverrideBones( ply, Pose, WeaponAim( ply ) )
		
	end
	
	
	-- Aim Grapple Arm
	Pose = Blend_Grapple( ply, Pose )
	
	
	-- Apply Pose to Player
	ApplyPose( ply, Pose )
	
end


local function ThinkPoseAnims()
	
	Interval = FrameTime()
	RunPoseAnims( LocalPlayer() )
	
end
hook.Add( "Think", "RunPoseAnims", ThinkPoseAnims )
hook.Remove( "Think", "RunPoseAnims" )


local function TickPoseAnims()
	
	for k,ply in pairs( player.GetAll() ) do
		
		if ply != LocalPlayer() then
			
			//print( DirectionVector( EyePos(), ply:GetPos() ):Dot( EyeVector() ) )
			Interval = engine.TickInterval()
			RunPoseAnims( ply )
			
		end
		
	end
	
end
hook.Add( "Tick", "RunPoseAnims", TickPoseAnims )
hook.Remove( "Tick", "RunPoseAnims" )

concommand.Add( "checkposes", function() PrintTable( POSES ) end )



--
-- 3RD Person
--

local function MyCalcView( ply, pos, angles, fov )

	local view = {}
	
	//view.origin = pos + Vector( 0, 0, 40 ) + angles:Forward() * 150
	view.angles = angles
	
	local M = Matrix()
	M:Rotate( angles )
	M:Translate( Vector( -70, 0, 10 ) )
	
	local trace = {
		start = pos, 
		endpos = pos + M:GetTranslation(),
		mask = MASK_SOLID_BRUSHONLY,
		radius = 25
	}
	
	local sphere = util.spheretrace( trace, false )
	
	if sphere then
	
		view.origin = sphere.HitPos
		
	end
	
	/*
	view.origin = pos + Vector(0,0,-20) + ( angles:Forward()*100 )
	angles.p = -angles.p
	view.angles = angles +Angle(0,180,0)
	*/
	
	view.fov = fov
	view.drawviewer = true

	return view
	
end
hook.Add( "CalcView", "MyCalcView", MyCalcView )
//hook.Remove( "CalcView", "MyCalcView" )
