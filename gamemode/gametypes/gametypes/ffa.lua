GAMETYPE_FFA = 1 // Enum for maps
GT_FFA = GameType( GAMETYPE_FFA ) // Arg 1 must be unique

GT_FFA.Name = "Free-For-All"
GT_FFA.Description = "Kill anything that moves."
GT_FFA.FragLimit = 20

-- Called when the game type is loaded
function GT_FFA:Init()

	-- Add states when initializing to update State.Parent
	self:AddState( "Warmup", GS_Warmup )
	self:AddState( "FFA", GS_FFA )
	self:AddState( "EndGame", GS_EndGame )

	self:SetNextState( "FFA", self.FragLimit )
	self:SetState( "Warmup", _, 3 )

end

GT_FFA:Play()
