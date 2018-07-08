SWEP.PrintName			= "Sniper"
SWEP.Author				= "Ribbit"
SWEP.Instructions		= "Shoot at foes at high speeds for best results."

SWEP.ViewModel			= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.SwayScale = 2
SWEP.UseHands = true
SWEP.m_WeaponDeploySpeed = 10

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Sound         = Sound( "grapplegunners/snipershot.mp3" )
SWEP.Primary.Delay         = 1.5
SWEP.Primary.SoundLevel	   = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:PrimaryAttack( worldsound )
	
	if not self:CanPrimaryAttack() then return end
   
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.LastReload = CurTime()

	if not worldsound then
		
		self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel, math.Rand( 95, 100 ) )
	
	elseif SERVER then
	
		sound.Play( self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel, math.Rand( 95, 100 ) )
		
	end

	self:ShootBullet()
	
end

function SWEP:CanPrimaryAttack()
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	return true
	
end

function SWEP:ShootBullet()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	local bullet = {}
	bullet.Num    = 1
	bullet.Src    = self:GetOwner():GetShootPos()
	bullet.Dir    = self:GetOwner():GetAimVector()
	bullet.Force  = 10
	bullet.Tracer = 3
	bullet.Damage = math.Clamp( self:GetOwner():GetVelocity():Length() * 0.1, 5, 1000 )
	bullet.HullSize = 5

	self:GetOwner():FireBullets( bullet )
	
	if IsFirstTimePredicted() then
	
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetEyeTrace().HitPos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self )
		util.Effect( "snipersmoke", effectdata )
		
	end
	
end

function SWEP:SecondaryAttack() end