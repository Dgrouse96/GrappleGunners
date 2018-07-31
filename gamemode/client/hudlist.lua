HUD_Gameplay = HUD()
HUD_Gameplay:AddWidget( "EnergyBar", Widget_EnergyBar )
HUD_Gameplay:AddWidget( "HealthBar", Widget_HealthBar )
HUD_Gameplay:AddWidget( "DamageNotify", Widget_DamageNotify )
HUD_Gameplay:AddWidget( "KillNotify", Widget_KillNotify )

HUD_Scoreboard = HUD( true )
HUD_Scoreboard:AddWidget( "ColourTint", Widget_ColourTint )
HUD_Scoreboard:AddWidget( "Scoreboard", Derma_Scoreboard )
HUD_Scoreboard:AddWidget( "Stats", Derma_Stats )

HUD_GameOver = HUD( true )
HUD_GameOver:AddWidget( "MapVote", Derma_MapVote )

function SetGameplayHud( Hud )
	
	CurrentGameplayHud:SetHidden( true )
	CurrentGameplayHud = Hud
	
	if HUD_Scoreboard:GetHidden() then
	
		Hud:SetHidden( false )
		
	end
	
	
end

CurrentGameplayHud = HUD_Gameplay