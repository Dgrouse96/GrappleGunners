-- Kill any existing widgets
if SniperCrosshair then
	
	SniperCrosshair:Kill()
    SniperCrosshair = nil
	
end

SniperCrosshair = Widget()


SniperCrosshair.Mat = Material("grapplegunners/hud/Crosshair-Sniper.png")
SniperCrosshair.SkullMat = Material("grapplegunners/hud/Lethal.png")
SniperCrosshair.Ring = { x = 960, y = 540, w = 8, h = 8 }

ShottyCrosshair.Lethal = { 
	x = 960, 
	y = 635,
	w = 5,
	h = 5,
	c = Color( 200, 200, 200, 100 ),
}

ShottyCrosshair.BarLeft = {
	
	x = 960 - 25, 
	y = 635,
	w = 25,
	h = 2,
	
}

ShottyCrosshair.BarRight = {
	
	x = 960 + 25, 
	y = 635,
	w = 25,
	h = 2,
	
}

function SniperCrosshair:Think()
	
	
	
end

function SniperCrosshair:Draw()
	
	SetCol( COL_WHITE )
	SetMat( self.Mat )
	DTRectR( self.Ring )
	
	SetCol( self.Lethal.c )
	SetMat( self.SkullMat )
	DTRectR( self.Lethal )
	
end