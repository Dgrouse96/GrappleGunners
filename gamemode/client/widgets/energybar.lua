-- Kill any existing widgets
if Widget_EnergyBar then

    Widget_EnergyBar:Kill()
    Widget_EnergyBar = nil
	
end

-- Create widget object
Widget_EnergyBar = Widget()

-- Setup basic variables to use later
local White = Color( 255, 255, 255, 255 )

local Background = Material("grapplegunners/hud/BoostBar-Background.png")
local Base = Material("grapplegunners/hud/BoostBar-Base.png")
local Amount = Material("grapplegunners/hud/BoostBar-Amount.png")
local Active = Material("grapplegunners/hud/BoostBar-Active.png")

local PosX = 1920-300
local PosY = 1080-300

local Translation = {
	
	x = PosX,
	y = PosY,
	w = 256,
	h = 256,
	
}

local Text = {
	
	t = "100",
	x = PosX + 133,
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

Widget_EnergyBar.Amount = table.Copy( Percent )
Widget_EnergyBar.AmountColour = table.Copy( White )
Widget_EnergyBar.ActiveColour = table.Copy( White )


Widget_EnergyBar.Text = table.Copy( Text )



function Widget_EnergyBar:Think()
	
	local ply = LocalPlayer()
	if !ply then return end
	
	local BoostAmount = 1
	if ply.BoostAmount then BoostAmount = ply.BoostAmount end
	
	-- Cut away image
	BoostRemap = math.Clamp( Lerp( BoostAmount, 0.05, 0.83 ), 0, 1 )
	self.Amount.h = 256 * BoostRemap
	self.Amount.sv = 1 - BoostRemap
	self.Amount.y = PosY + 256 - BoostRemap * 256
	
	-- Set Alphas
	self.AmountColour.a = BoostAmount^4 * 255
	self.ActiveColour.a = Either( ply.UsingBoost, 255, 0 )
	
	if ply.UsingBoost then
		
		self.Amount.x = PosX + math.Rand( -2, 2 )
		self.Amount.y = self.Amount.y + math.Rand( -2, 2 )
		
	else
	
		self.Amount.x = PosX
		
	end
	
	-- Text Amount
	self.Text.t = tostring( math.ceil( BoostAmount * 100 ) )
	self.Text.c = LerpColor( BoostAmount, Color( 255, 50, 20, 255 ), Color( 255, 225, 150, 255 ) )
	
end

function Widget_EnergyBar:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	SetCol( White )
	SetMat( Background )
	DTRect( Translation )
	
	SetMat( Base )
	DTRectUV( self.Amount )
	
	SetCol( self.AmountColour )
	SetMat( Amount )
	DTRectUV( self.Amount )
	
	SetCol( self.ActiveColour )
	SetMat( Active )
	DTRectUV( self.Amount )
	
	SetCol( self.Text.c )
	DText( self.Text )
	
end