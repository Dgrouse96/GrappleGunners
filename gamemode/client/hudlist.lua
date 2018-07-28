HUD_Gameplay = HUD()
HUD_Gameplay:AddWidget( "EnergyBar", Widget_EnergyBar )
HUD_Gameplay:AddWidget( "HealthBar", Widget_HealthBar )

HUD_Scoreboard = HUD( true )
HUD_Scoreboard:AddWidget( "ColourTint", Widget_ColourTint )
HUD_Scoreboard:AddWidget( "Scoreboard", Derma_Scoreboard )