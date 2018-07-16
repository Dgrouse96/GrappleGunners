-- Kill any existing widgets
if SniperCrosshair then
	
	SniperCrosshair:Kill()
    SniperCrosshair = nil
	
end

SniperCrosshair = Widget()


SniperCrosshair.Mat = Material("grapplegunners/hud/Crosshair-Sniper.png")
SniperCrosshair.SkullMat = Material("grapplegunners/hud/Lethal.png")
SniperCrosshair.Ring = { x = 960, y = 540, w = 7, h = 7 }
SniperCrosshair.UseSkull = false

SniperCrosshair.Lethal = { 
	x = 960, 
	y = 540-16,
	w = 20,
	h = 20,
	c = Color( 200, 60, 10, 150 ),
}

SniperCrosshair.BarLeft = {
	
	x = 960 - 24 - 4, 
	y = 540 - 1,
	w = 30,
	h = 2,
	
}

SniperCrosshair.BarRight = {
	
	x = 960 + 4, 
	y = 540 - 1,
	w = 30,
	h = 2,
	
}

function SniperCrosshair:Think()
	
	local Weapon = LocalPlayer():GetActiveWeapon()
	
	if Weapon and Weapon.GetSpeedDamage then
	
		local Damage = Weapon:GetSpeedDamage()
		
		local Alpha = math.Clamp( inverselerp( Damage, 0, 100 ), 0, 1 )
		
		self.BarRight.w = Lerp( Alpha, 30, 0 )
		self.BarLeft.w = self.BarRight.w
		self.BarLeft.x = 956 - self.BarLeft.w
		
		self.Lethal.c = LerpColor( Alpha, Color( 255, 225, 150, 10 ), Color( 255, 50, 20, 120 ) )
		
		self.UseSkull = ( Alpha == 1 )
		
	end
	
end

function SniperCrosshair:Draw()
	
	SetCol( COL_WHITE )
	SetMat( self.Mat )
	DTRectR( self.Ring )
	
	SetCol( self.Lethal.c )
	
	if self.UseSkull then
	
		SetMat( self.SkullMat )
		DTRectR( self.Lethal )
		
	else
	
		DBox( self.BarLeft )
		DBox( self.BarRight )
		
	end
end