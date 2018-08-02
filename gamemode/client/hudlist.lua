HUD_Gameplay = HUD( true )
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
HUD_GameOver:AddWidget( "Timer", Widget_Timer )

HUD_Warmup = HUD()
HUD_Warmup:AddWidget( "Timer", Widget_Timer )
HUD_Warmup:AddWidget( "EnergyBar", Widget_EnergyBar )
HUD_Warmup:AddWidget( "HealthBar", Widget_HealthBar )

function SetGameplayHud( Hud )
	
	CurrentGameplayHud:SetHidden( true )
	CurrentGameplayHud = Hud
	
	if HUD_Scoreboard:GetHidden() then
		
		Hud:ReparentWidgets()
		Hud:SetHidden( false )
		
	end
	
	
end

CurrentGameplayHud = HUD_Warmup