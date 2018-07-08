SWEP.PrintName			= "Shotty"
SWEP.Author				= "Ribbit"
SWEP.Instructions		= "Shoot at foes at a close range for best results."

SWEP.ViewModel			= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.SwayScale = 2
SWEP.UseHands = true
SWEP.m_WeaponDeploySpeed = 10

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= 4
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.NumShots      = 8
SWEP.Primary.Sound         = Sound( "grapplegunners/shottyshot.mp3" )
SWEP.Primary.Cone          = 0.15
SWEP.Primary.Delay         = 0.15
SWEP.Primary.Damage        = 8
SWEP.Primary.SoundLevel	   = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ReloadSpeed = 0.7
SWEP.LastReload = 0

function SWEP:PrimaryAttack( worldsound )
	
	if not self:CanPrimaryAttack() then 
		
		if self:Clip1() > 0 then
		
			self.QueueAttack = true
			
		end
		
		return
		
	end

	self.QueueAttack = false
   
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.LastReload = CurTime()

	if not worldsound then
		
		self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel, math.Rand( 95, 100 ) )
	
	elseif SERVER then
	
		sound.Play( self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel, math.Rand( 95, 100 ) )
		
	end

	self:ShootBullet( self.Primary.Damage, 0, self.Primary.NumShots, self.Primary.Cone )
	self:TakePrimaryAmmo( 1 )
	
end

function SWEP:CanPrimaryAttack()

	if self:Clip1() <= 0 then
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		return false
	
	end
	
	return true
	
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	local bullet = {}
	bullet.Num    = numbul
	bullet.Src    = self:GetOwner():GetShootPos()
	bullet.Dir    = self:GetOwner():GetAimVector()
	bullet.Spread = Vector( cone, cone, 0 )
	bullet.Tracer = 1
	bullet.TracerName = "AR2Tracer"
	bullet.Force  = 10
	bullet.Damage = dmg
	bullet.HullSize = 4

	self:GetOwner():FireBullets( bullet )
	
end

function SWEP:SecondaryAttack() end

function SWEP:ReloadBullets()
	
	local Bullets = math.Clamp( math.floor( ( CurTime() - self.LastReload ) / self.ReloadSpeed ), 0, self.Primary.ClipSize - self:Clip1() )
	
	if Bullets > 0 then
	
		self:SetClip1( self:Clip1() + Bullets )
		self.LastReload = CurTime()
		
	end
	
end

function SWEP:Think()
	
	if self:Clip1() < self.Primary.ClipSize then

		if CurTime() > self.LastReload + self.ReloadSpeed then
			
			self:ReloadBullets()
			
			if self.QueueAttack then
				
				self:PrimaryAttack()
				
			end
			
		end
		
	end
	
end

function SWEP:Deploy()
	
	self:ReloadBullets()
	
end

function SWEP:Holster()
	
	return true
	
end