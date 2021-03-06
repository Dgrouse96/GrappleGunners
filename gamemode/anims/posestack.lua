--
-- Blends poses on players
--

local PLY = FindMetaTable( "Player" )


-- Clamped Pose Delta
function PLY:GetPoseDelta()
	
	return Lerp2( FrameTime()*10, self.LastPoseDelta or 0.00001, self.PoseDelta or 0.00001 )
	
	//return math.Clamp( self.PoseDelta, 0, 0.0333 )
	
end


-- Run Cycle
local Power = 1.5
function PLY:Anim_Run()

	-- Grab Velocity
	local Vel = self:GetVelocity() Vel.z = 0
	local Speed = math.Clamp( Vel:Length2D()/50, 2, 10 )

	-- Change Run Direction
	local Direction = 1
	if Vel:Dot( self:GetForward() ) < 0 then Direction = -1 end

	-- Setup time and smoothing
	if !self.A_RunTime or !self:OnGround() then self.A_RunTime = 1 end
	if !self.A_SmoothRun then self.A_SmoothRun = 0 end

	-- Cycle Anim based on speed
	self.A_RunTime = self.A_RunTime + self:GetPoseDelta() * Speed * Direction
	local Weight = self.A_RunTime % 4

	-- Smooth idle/run blend
	self.A_SmoothRun = Lerp( self:GetPoseDelta() * 10, self.A_SmoothRun, math.Clamp( Vel:Length2D()/50, 0, 10 ) )
	self.A_SmoothRun = math.Clamp( self.A_SmoothRun, 0, 1.3 )

	self:GetPose():Reset( "idle1" )

	if self.A_SmoothRun > 0.001 then

		-- Blend run cycle poses
		if inrange( Weight, 0, 1 ) then

			self:GetPose():Blend2( self.A_SmoothRun, ease( Weight, Power, 1 ), "sprint1", "sprint2" )

		elseif inrange( Weight, 1, 2 ) then

			self:GetPose():Blend2( self.A_SmoothRun, ease( inverselerp( Weight, 1, 2 ), Power, 0.1 ), "sprint2", "sprint3" )

		elseif inrange( Weight, 2, 3 ) then

			self:GetPose():Blend2( self.A_SmoothRun, ease( inverselerp( Weight, 2, 3 ), Power, 1 ), "sprint3", "sprint4" )

		elseif inrange( Weight, 3, 4 ) then

			self:GetPose():Blend2( self.A_SmoothRun, ease( inverselerp( Weight, 3, 4 ), Power, 0.1 ), "sprint4", "sprint1" )

		end

	end

end


-- Falling Pose
function PLY:Anim_Fall( Blend )

	if Blend then

		self:GetPose():Blend( Blend, "fallidle1" )

	else

		self:GetPose():Reset( "fallidle1" )

	end

end


-- Blend Running/Falling
function PLY:Anim_Locomotion()

	if !self.A_BlendFall then self.A_BlendFall = 0 end

	self.A_BlendFall = Lerp( self:GetPoseDelta() * 15, self.A_BlendFall, Either( self:OnGround(), 0, 1 ) )

	-- Don't blend in these cases
	if self.A_BlendFall < 0.001 then

		self:Anim_Run()

	elseif self.A_BlendFall > 0.999 then

		self:Anim_Fall()

	else

		self:Anim_Run()
		self:Anim_Fall( self.A_BlendFall )

	end

end


-- Tilt into turn
function PLY:Anim_RunTilt()

	if !self.A_SmoothTilt then self.A_SmoothTilt = 0 end
	if !self.A_LastVelocity then self.A_LastVelocity = Vector() end

	local Velocity = LerpVector( self:GetPoseDelta() * 10, self.A_LastVelocity, self:GetVelocity():GetNormalized() )
	
	local Amount = Either( self.GrappleLocation and !self:OnGround(), 30, 12 )
	local Speed = Either( !self:OnGround(), 3000, 1000 )
	
	local Tilt = math.Clamp( Velocity:Cross( self.A_LastVelocity ).z * Speed, -Amount, Amount )

	self.A_SmoothTilt = Lerp2( self:GetPoseDelta() * 5, self.A_SmoothTilt, Tilt )
	self.A_LastVelocity = Velocity

	self:GetPose():Add( {
		[0] = {
			p = Vector(),
			a = Angle( 0, self.A_SmoothTilt * 2, 0 )
		}
	} )

end


-- Rotate to run direction
function PLY:Anim_RunDirection()

	if !self.A_SmoothRunAng then self.A_SmoothRunAng = 0 end
	
	local Velocity = self:GetVelocity():GetNormalized()
	Velocity.z = 0

	local Vel = Velocity:Angle()
	local Yaw = self:EyeAngles().y
	local Ang = Vel.y - Yaw

	if Velocity:Length() > 0.1 then

		-- Flip direction for reverse run
		if ( Ang > 95 and Ang < 260 and Ang > 100 ) then

			Ang = Ang+180

		end

	else

		Ang = 0

	end

	self.A_SmoothRunAng = LerpAngle( self:GetPoseDelta() * 5, Angle( 0, self.A_SmoothRunAng, 0 ), Angle( 0, Ang, 0 ) ).y

	self:GetPose():Add( {
		[0] = {
			p = Vector(),
			a = Angle( self.A_SmoothRunAng, 0, 0 )
		}
	} )

end


-- Rotates spine to face aim direction
function PLY:Anim_AimSpine()

	local AddPose = {}
	local Ang = math.Clamp( self.A_SmoothRunAng, -90, 90 )
	
	self.A_SmoothSpineAng = Lerp( self:GetPoseDelta() * 5, self.A_SmoothSpineAng or 0, Ang )

	local FixYaw = {
		p = Vector(),
		a = Angle( 0, 0, -Ang/4 )
	}

	for i=1,4 do

		AddPose[i] = FixYaw

	end

	self:GetPose():Add( AddPose )

end


-- Aim weapon arm
function PLY:Anim_WeaponAim()

	if IsValid( self:GetActiveWeapon() ) then

		local Smoothrun = self.A_SmoothRun or 0
		local Pitch = self:EyeAngles().p
		
		if Pitch > 90 then Pitch = self.A_LastPitch or 0 end
		self.A_LastPitch = Pitch
		
		local Pitch = Pitch + Either( self:OnGround(), Lerp( Smoothrun, -10, -35 ), -15 )

		if Pitch > 0 then

			self:GetPose():Blend2( 1, Pitch/150, "gunaim_mid", "gunaim_low" )

		else

			self:GetPose():Blend2( 1, -Pitch/150, "gunaim_mid", "gunaim_high" )

		end

		local AddPose = {}

		local LeanBack = {
			p = Vector(),
			a = Angle( 0, Pitch/8, 0 )
		}

		for i=1,4 do

			AddPose[i] = LeanBack

		end

		self:GetPose():Add( AddPose )

	end

end


-- Aim grapple arm
function PLY:Anim_GrappleAim( Blend )

	if self.GrappleLocation then

		local Dir = DirectionVector( self:EyePos(), self.GrappleLocation )
		local Ang = Angle( 0, self:EyeAngles().y+90, 0 ) - Dir:Angle()

		self.A_GrappleAngle = Ang

	end

	local Ang = self.A_GrappleAngle
	Ang:Normalize()
	
	local Dir = Lerp2( self:GetPoseDelta() * 5, self.A_GrappleDir or Vector(), Ang:Forward() )
	self.A_GrappleDir = Dir
	
	local F = Either( Dir.y > 0, "grap-f", "grap-b" )
	local R = Either( -Dir.x > 0, "grap-r", "grap-l" )
	local U = Either( -Dir.z > 0, "grap-u", "grap-d" )

	if Blend then

		self:GetPose():Blend( Blend, F )
		self:GetPose():Blend( Blend * math.abs( Dir.x ), R )
		self:GetPose():Blend( Blend * math.abs( Dir.z ), U )

	else

		self:GetPose():Replace( F )
		self:GetPose():Blend( math.abs( Dir.x ), R )
		self:GetPose():Blend( math.abs( Dir.z ), U )

	end

end

-- Blend grapple arm
function PLY:Anim_GrappleAimBlend()

	if !self.A_BlendGrapple then self.A_BlendGrapple = 0 end
	
	local TargetBlend = 0
	if self.GrappleLocation then TargetBlend = 1 end
	
	self.A_BlendGrapple = Lerp2( self:GetPoseDelta() * 15, self.A_BlendGrapple, TargetBlend )

	-- Don't blend in these cases
	if self.A_BlendGrapple > 0.999 then

		self:Anim_GrappleAim()

	elseif self.A_BlendGrapple < 0.001 then

		-- No Arm anim

	else

		self:Anim_GrappleAim( self.A_BlendGrapple )

	end

end


--
-- Pose stack
--

function PLY:RunPoseAnims( Delta )

	-- Keep blend speeds consistent
	self.PoseDelta = math.Clamp( Delta, 0, 0.1 )

	-- Make or retrieve pose
	self:GetPose()

	-- Pose Stack
	self:Anim_Locomotion()
	self:Anim_RunTilt()
	self:Anim_RunDirection()
	self:Anim_AimSpine()
	self:Anim_WeaponAim()
	self:Anim_GrappleAimBlend()

	-- Apply Pose to Player
	self:ApplyPose()
	
	self.LastPoseDelta = Delta

end



--
-- Run poses on players
--

function ThinkPoseAnims()

	LocalPlayer():RunPoseAnims( FrameTime() )

end


function TickPoseAnims()

	for k,ply in pairs( player.GetAll() ) do

		if ply != LocalPlayer() then
			
			if ply.A_Skip and ply.A_Skip > 0 then
				
				ply.A_Skip = ply.A_Skip - 1
				
			else
				
				if !ply.A_SkipDiv then ply.A_SkipDiv = 1 end
				
				// Skip frames per 1000 units
				local Dist = ply:GetPos():Distance( LocalPlayer():GetPos() )
				
				ply.A_Skip = math.floor( Dist/1000 )
				
				
				ply:RunPoseAnims( engine.TickInterval() * ply.A_SkipDiv )
				ply.A_SkipDiv = ply.A_Skip + 1
				
			end

		end

	end

end
hook.Add( "Tick", "RunPoseAnims", TickPoseAnims )