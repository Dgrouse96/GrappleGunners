include( "cl_files.lua" )
print( "Grapple Gunners - Version 0.1" )

-- Draw Hands
function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end

--
-- Hide Default HUD
--

local Hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )

	if ( Hide[ name ] ) then return false end

end )