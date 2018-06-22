SWEP.PrintName			= "Shotty"
SWEP.Author				= "Ribbit"
SWEP.Instructions		= "Shoot at foes from a close range for best results."

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
SWEP.UseHands = false

SWEP.Primary.ClipSize		= 400
SWEP.Primary.DefaultClip	= 400
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

function SWEP:PrimaryAttack( worldsound )

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

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
   
      self:EmitSound( "Weapon_Shotgun.Empty" )
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