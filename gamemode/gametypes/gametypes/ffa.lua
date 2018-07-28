GAMETYPE_FFA = 1 // Enum for maps
GT_FFA = GameType( GAMETYPE_FFA ) // Arg 1 must be unique

GT_FFA.Name = "Free-For-All"
GT_FFA.Description = "Kill anything that moves."
GT_FFA.FragLimit = 20

-- Used with the scoreboard
GT_FFA:AddScoreColumn( "Kills", 1, function( ply ) return ply:Frags() end )
GT_FFA:AddScoreColumn( "Deaths", 2, function( ply ) return ply:Deaths() end )

-- Called when the game type is loaded
function GT_FFA:Init()

	-- Add states when initializing to update State.Parent
	self:AddState( "Warmup", GS_Warmup )
	self:AddState( "FFA", GS_FFA )
	self:AddState( "EndGame", GS_EndGame )

	self:SetNextState( "FFA", self.FragLimit )
	self:SetState( "Warmup", _, 3 )

end

if CLIENT then GT_FFA:Play() return end
StartGameType( GAMETYPE_FFA )
