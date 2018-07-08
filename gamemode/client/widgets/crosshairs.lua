--
-- Crosshair Updates
--

local Weapons = {
	
	["grappleshotty"] = ShottyCrosshair,
	["grapplesniper"] = SniperCrosshair,
	
}

function RefreshCrosshair( ply, OldWep, NewWep )
	
	local Class = NewWep:GetClass()
	local WepWidget = Weapons[ Class ]
	
	if WepWidget then
	
		HUD_Gameplay:RemoveWidget( "Crosshair" )
		HUD_Gameplay:AddWidget( "Crosshair", Weapons[ Class ] )
		
	else
		
		HUD_Gameplay:RemoveWidget( "Crosshair" )
		
	end
	
end

hook.Add( "PlayerSwitchWeapon", "SwapCrosshair", SwapCrosshair )


function CheckWeapon()
	
	local ply = LocalPlayer()
	
	if IsValid( ply ) and ply:Alive() and IsValid( ply:GetActiveWeapon() ) then
		
		RefreshCrosshair( ply, _, ply:GetActiveWeapon() )
		
	end
	
end

hook.Add( "Tick", "CheckWeapon", CheckWeapon )