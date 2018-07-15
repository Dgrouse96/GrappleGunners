-- Kill existing FFA
if GT_FFA then

    GT_FFA:Kill()
    GT_FFA = nil
	
end

GT_FFA = GameType()

GT_FFA.Name = "Free-For-All"
GT_FFA.Description = "Kill anything that moves."

-- Called when the game type is loaded
function GT_FFA:Init()
	
	-- Add states when initializing to update State.Parent
	self:AddState( "Warmup", GS_Warmup )
	self:AddState( "FFA", GS_FFA )
	
	self:SetNextState( "FFA" )
	self:SetState( "Warmup", 3 )
	
end

GT_FFA:Play()