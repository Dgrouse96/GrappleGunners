--
-- Blend poses to make anims
--

local function LoadRetarget( name )
	
	local read = file.Read( "posemaker/retarget/"..name..".txt" )
	if read then return util.JSONToTable( read ) end
	return {}
	
end

local function LoadPose( name )
	
	local read = file.Read( "posemaker/poses/"..name..".txt" )
	if read then return util.JSONToTable( read ) end
	return {}
	
end

--
-- Load poses then use them later
--

local Idle1,Sprint1,Sprint2,Sprint3,Sprint4 = {},{},{},{},{}

local function StorePoses()
	
	Kick = LoadPose( "kick" )
	Sprint1 = LoadPose( "sprint1" )
	Sprint2 = LoadPose( "sprint2" )
	Sprint3 = LoadPose( "sprint3" )
	Sprint4 = LoadPose( "sprint4" )
	Idle1 = LoadPose( "idle1" )
	
	Female1 = LoadRetarget( "male1-female1" )
	
end

StorePoses()


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
	
	// Pose = RetargetBones( Pose, Female1 )
	
	for i=0, ply:GetBoneCount()-1 do
		
		local v = TidyBoneData( Pose[i] )
		ply:ManipulateBonePosition( i, v.p )
		ply:ManipulateBoneAngles( i, v.a )
		
	end
	
end

-- Lerp 2 poses
local function BlendPoses( ply, Pose1, Pose2, Alpha )

	local ReturnValue = {}
	
	for i=0, ply:GetBoneCount()-1 do
		
		local v1 = TidyBoneData( Pose1[i] )
		local v2 = TidyBoneData( Pose2[i] )
		
		ReturnValue[i] = { 
			p = LerpVector( Alpha, v1.p, v2.p ), 
			a = LerpAngle( Alpha, v1.a, v2.a ),
		}
		
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

local function ReplaceBone( Pose, Bone, Data )
	
	if !Data then return Pose end
	if !Pose[Bone] then Pose[Bone] = Data end
	
	Pose[Bone] = Data
	
	return Pose
	
end

--
-- Running Animation
--

local Power = 1.5

local function Anim_Run( ply )

	local Pose = {}
	
	local Vel = ply:GetVelocity() Vel.z = 0
	local Speed = Vel:Length2D()/50
	
	local Direction = 1
	if Vel:Dot( ply:GetForward() ) < 0 then Direction = -1 end
	
	if !ply.ARunTime then ply.ARunTime = 0 end
	if !ply.ASmoothRun then ply.ASmoothRun = 0 end

	ply.ARunTime = ply.ARunTime + FrameTime() * Speed * Direction
	local Weight = ply.ARunTime % 4
	
	if inrange( Weight, 0, 1 ) then
	
		Pose = BlendPoses( ply, Sprint1, Sprint2, ease( Weight, Power, 1 ) )
		
	elseif inrange( Weight, 1, 2 ) then
	
		Pose = BlendPoses( ply, Sprint2, Sprint3, ease( inverselerp( Weight, 1, 2 ), Power, 0.1 ) )
		
	elseif inrange( Weight, 2, 3 ) then
	
		Pose = BlendPoses( ply, Sprint3, Sprint4, ease( inverselerp( Weight, 2, 3 ), Power, 1 ) )
		
	elseif inrange( Weight, 3, 4 ) then
	
		Pose = BlendPoses( ply, Sprint4, Sprint1, ease( inverselerp( Weight, 3, 4 ), Power, 0.1 ) )
	
	end
	
	ply.ASmoothRun = Lerp( FrameTime() * 10, ply.ASmoothRun, Speed )
	Pose = BlendPoses( ply, Idle1, Pose, math.Clamp( inverselerp( ply.ASmoothRun, 0, 1 ), 0, 1.3 ) )
	
	return Pose
	
end


--
-- Additive Run Tilt
--

local function RunTilt( ply )
	
	if !ply.SmoothTilt then ply.SmoothTilt = 0 end
	if !ply.LastVelocity then ply.LastVelocity = Vector() end
	
	local Velocity = ply:GetVelocity():GetNormalized()
	local Tilt = math.Clamp( Velocity:Cross( ply.LastVelocity ).z * 600, -60, 60 )
	
	ply.SmoothTilt = Lerp( FrameTime() * 2, ply.SmoothTilt, Tilt )
	
	ply.LastVelocity = Velocity
	
	return { 
		p = Vector(), 
		a = Angle( 0, ply.SmoothTilt, 0 )
	}
	
end

--
-- Main Anim Function
--
function RunPoseAnims( ply )
	
	for k,ply in pairs( player.GetAll() ) do
	
		local Pose = Anim_Run( ply )
		Pose = AdditiveBone( Pose, 0, RunTilt( ply ) )
		ApplyPose( ply, Pose )
		
	end

end
hook.Add( "Think", "RunPoseAnims", RunPoseAnims )


--
-- 3RD Person
--

local function MyCalcView( ply, pos, angles, fov )

	local view = {}
	
	
	view.origin = pos + Vector(0,0,-20) - angles:Forward()*100
	view.angles = angles
	
	
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
hook.Remove( "CalcView", "MyCalcView" )
