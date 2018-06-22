-- Kill any existing widgets
if Widget_Crosshair then

    Widget_Crosshair:Kill()
    Widget_Crosshair  = nil
	
end

-- Create widget object
Widget_Crosshair = Widget()

-- Setup basic variables to use later
local White = Color( 255, 255, 255, 255 )

local Weapons = {
	
	["grappleshotty"] = Material("grapplegunners/hud/Crosshair-Shotty.png")
	
}

local Translation = {
	
	x = 960,
	y = 540,
	w = 256,
	h = 256,
	
}

function Widget_Crosshair:Draw()
	
	local ply = LocalPlayer()
	if !ply then return end
	if !ply:Alive() then return end
	
	local wep = ply:GetActiveWeapon()
	if !IsValid( wep ) then return end
	if !wep:GetClass() then return end
	
	local Weapon = Weapons[ wep:GetClass() ]
	if !Weapon then return end
	
	SetCol( White )
	SetMat( Weapon )
	DTRectR( Translation )
	
end