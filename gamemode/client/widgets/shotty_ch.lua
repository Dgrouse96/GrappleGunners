-- Kill any existing widgets
if ShottyCrosshair then

    ShottyCrosshair:Kill()
    ShottyCrosshair = nil
	
end

ShottyCrosshair = Widget()


ShottyCrosshair.Mat = Material("grapplegunners/hud/Crosshair-Shotty.png")
ShottyCrosshair.Ring = { x = 960, y = 540, w = 256, h = 256 }

ShottyCrosshair.Ammo = { 
	t = "4",
	x = 960, 
	y = 635, 
	f = "ShotgunAmmo",
	ax = 1,
	ay = 1,
	c = Color( 200, 200, 200, 100 ),
}

ShottyCrosshair.Recharge1 = {
	
	x = 960 - 25, 
	y = 635,
	w = 25,
	h = 2,
	
}

ShottyCrosshair.Recharge2 = {
	
	x = 960 + 25, 
	y = 635,
	w = 25,
	h = 2,
	
}


function ShottyCrosshair:Think()
	
	local ply = LocalPlayer()
	
	if IsValid( ply ) then
	
		local Wep = ply:GetActiveWeapon()
		
		if IsValid( Wep ) then
			
			self.Ammo.t = tostring( Wep:Clip1() )
			
			if Wep:Clip1() < Wep.Primary.ClipSize then
				
				if Wep.LastReload and Wep.ReloadSpeed then
				
					local Charge = math.Clamp( inverselerp( CurTime() - Wep.LastReload, 0, Wep.ReloadSpeed ), 0, 1 )
					
					self.Recharge1.w = Lerp( Charge, 25, 0 )
					self.Recharge2.w = Lerp( Charge, 25, 0 )
					
					self.Recharge1.x = 960 + 10 + self.Recharge1.w/2
					self.Recharge2.x = 960 - 10 - self.Recharge1.w/2
					
				end
				
			else
			
				self.Recharge1.w = 0
				self.Recharge2.w = 0
				
			end
			
		end
		
	end
	
end


function ShottyCrosshair:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	SetCol( COL_WHITE )
	SetMat( self.Mat )
	DTRectR( self.Ring )
	
	SetCol( self.Ammo.c )
	DText( self.Ammo )
	
	SetMat()
	DTRectR( self.Recharge1 )
	DTRectR( self.Recharge2 )
	
end