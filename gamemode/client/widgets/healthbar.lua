-- Create widget object
Widget_HealthBar = Widget()

-- Setup basic variables to use later
local White = Color( 255, 255, 255, 255 )

local Background = Material("grapplegunners/hud/HealthBar-Background.png")
local HealthMats = {
	Material("grapplegunners/hud/HealthBar-Base.png"),
	Material("grapplegunners/hud/HealthBar-Gaining.png"),
	Material("grapplegunners/hud/HealthBar-Losing.png"),
}

local PosX = 50
local PosY = 1080 - 300

local Translation = {
	
	x = PosX,
	y = PosY,
	w = 256,
	h = 256,
	
}

local Text = {
	
	t = "100",
	x = PosX + 120,
	y = PosY - 5,
	f = "EnergyWidget",
	ax = 1,
	ay = 0,
	c = Color( 255, 225, 150, 255 ),
	
}

-- Setup UVs
local Percent = table.Copy( Translation )
Percent.su = 0
Percent.sv = 0
Percent.eu = 1
Percent.ev = 1

Widget_HealthBar.Amount = table.Copy( Percent )
Widget_HealthBar.Text = table.Copy( Text )
Widget_HealthBar.Mat = HealthMats[1]
Widget_HealthBar.HealthAmount = 1


function Widget_HealthBar:Think()
	
	local ply = LocalPlayer()
	if !ply then return end
	
	local HealthDirection = 1
	
	if ply:Health()	then
		
		local Health = ply:Health() * 0.01
		self.HealthAmount = Lerp( FrameTime() * 10, self.HealthAmount, Health )
		
		if self.HealthAmount + 0.01 < Health then HealthDirection = 2 end
		if self.HealthAmount - 0.01 > Health then HealthDirection = 3 end
		
	end
	
	-- Cut away image
	HealthRemap = math.Clamp( Lerp( self.HealthAmount, 0.05, 0.83 ), 0, 1 )
	self.Amount.h = 256 * HealthRemap
	self.Amount.sv = 1 - HealthRemap
	self.Amount.y = PosY + 256 - HealthRemap * 256
	
	-- Shake it up
	if HealthDirection == 3 then
		
		self.Amount.x = PosX + math.Rand( -2, 2 )
		self.Amount.y = self.Amount.y + math.Rand( -2, 2 )
		
	else
	
		self.Amount.x = PosX
		
	end
	
	-- Text Amount
	self.Text.t = tostring( math.ceil( self.HealthAmount * 100 ) )
	self.Text.c = LerpColor( self.HealthAmount, Color( 70, 100, 70, 255 ), Color( 100, 255, 120, 255 ) )
	
	self.Mat = HealthMats[ HealthDirection ]
	
end

function Widget_HealthBar:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	SetCol( White )
	SetMat( Background )
	DTRect( Translation )
	
	SetMat( self.Mat )
	DTRectUV( self.Amount )
	
	SetCol( self.Text.c )
	DText( self.Text )
	
end