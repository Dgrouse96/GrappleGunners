-- Kill any existing widgets
if HUD_Gameplay then

    HUD_Gameplay:Kill()
    HUD_Gameplay = nil
	
end

HUD_Gameplay = HUD()
HUD_Gameplay:AddWidget( "EnergyBar", Widget_EnergyBar )
HUD_Gameplay:AddWidget( "HealthBar", Widget_HealthBar )

