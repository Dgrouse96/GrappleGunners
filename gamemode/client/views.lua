--
-- Calc View stuff
--

-- Yucky poop
InCameraAnim = false
local CameraAnimPos = Vector()
local CameraAnimAng = Angle()
local CameraAnimMoveTime = 0
local CameraAnimTime = 0
local CameraAnimStart = 0
local CameraBlendAmount = 0
local CameraCams = {}

local CamSmoothPos = Vector()
local CamSmoothAng = Angle()

function DoCameraAnim( Cams, MoveTime )
	
	if #Cams <= 0 then return end
	
	InCameraAnim = true
	CameraAnimPos = Cams[1][1]
	CameraAnimAng = Cams[1][2]
	
	CamSmoothPos = CameraAnimPos
	CamSmoothAng = CameraAnimAng
	
	CameraAnimMoveTime = MoveTime
	CameraAnimTime = 0
	CameraAnimStart = CurTime()
	CameraBlendAmount = 1 * ( #Cams - 1 )
	
	CameraCams = Cams
	
	hook.Add( "Think", "RunPoseAnims", ThinkPoseAnims )
	
	hook.Add( "CalcView", "CameraAnims", function( ply, pos, angles, fov )
		
		CameraAnimTime = CurTime() - CameraAnimStart
		local LerpTime = inverselerpclamp( CameraAnimTime, 0, CameraAnimMoveTime )
		
		LerpTime = ease( LerpTime, 2, 0.5 )
		
		local CameraTime = LerpTime * CameraBlendAmount
		
		local Alpha = ease( CameraTime % 1, 1.5, Either( CameraTime < 1, 0, 0.5 ) )
		
		if LerpTime < 1 then
		
			local Current = CameraCams[ math.floor( CameraTime ) + 1 ]
			local Next = CameraCams[ math.floor( CameraTime ) + 2 ]
			
			CameraAnimPos = LerpVector( Alpha, Current[1], Next[1] )
			CameraAnimAng = LerpAngle( Alpha, Current[2], Next[2] )
			
		else
			
			CameraAnimPos = CameraCams[ #CameraCams ][1]
			CameraAnimAng = CameraCams[ #CameraCams ][2]
			
		end
		
		CamSmoothPos = LerpVector( FrameTime() * 5, CamSmoothPos, CameraAnimPos )
		CamSmoothAng = LerpAngle( FrameTime() * 5, CamSmoothAng, CameraAnimAng )
		
		return {
			
			origin = CamSmoothPos,
			angles = CamSmoothAng,
			fov = 70,
			drawviewer = true,
		}
		
	end )
	
end

local function StopCameraAnim()
	
	hook.Remove( "CalcView", "CameraAnims" )
	InCameraAnim = false
	UpdateThirdPerson()
	
end
hook.Add( "StopCameraAnim", "FromServer", StopCameraAnim )


local function ThirdPersonView( ply, pos, angles, fov )
	
	if InCameraAnim then return end -- Will need to make a state machine eventually
	
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


function UpdateThirdPerson()
	
	if LocalPlayer().IsThirdPerson and LocalPlayer():IsThirdPerson() then
		
		hook.Add( "CalcView", "ThirdPerson", ThirdPersonView )
		hook.Add( "Think", "RunPoseAnims", ThinkPoseAnims )
	
	else
		
		hook.Remove( "CalcView", "ThirdPerson" )
		hook.Remove( "Think", "RunPoseAnims" )
		
	end
	
end

-- hacky asf
timer.Simple( 2, UpdateThirdPerson )

concommand.Add( "gg_thirdperson", function( args )
	
	LocalSettings:Input( "thirdperson", !LocalSettings:GetData()[ "thirdperson" ], true )
	UpdateThirdPerson()
	
end )