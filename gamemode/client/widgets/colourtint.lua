Widget_ColourTint = Widget( true )

local Tint = Material("grapplegunners/hud/colourtint.png")

Widget_ColourTint.Box = {
	
	x = ScrW()/2,
	y = ScrH()/2,
	w = ScrW() + 5,
	h = ScrH() + 5,
	c = Color(150,150,150,150)
	
}

function Widget_ColourTint:Init()
	
	self.StartTime = CurTime()
	
end

function Widget_ColourTint:Think()
	
	local Alpha = math.Clamp( ( CurTime() - self.StartTime )*1 , 0, 1 )
	self.Box.c.a = Lerp( ease( Alpha, 2, 0 ), 0, 150 )
	
end

function Widget_ColourTint:Draw()
	
	SetCol( self.Box.c )
	SetMat( Tint )
	DTRectSimpleR( self.Box )
	
end