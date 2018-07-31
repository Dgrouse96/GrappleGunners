--
-- Client settings
--

LocalSettings = GData( "localsettings" )

local function Setting()
	
	return LocalSettings:GetData()
	
end

local PLY = FindMetaTable( "Player" )

function PLY:IsThirdPerson()
	
	if self != LocalPlayer() then return false end
	
	if Setting()[ "thirdperson" ] or InCameraAnim then
		
		return true
		
	end
	
	return false
	
end


-- Shhhh pay no attention here
function UpdateAimbot()
	
	if Setting()[ "aimbot" ] then
		
		sendRequest( "ImAHacker" )
		
	else

		LocalSettings:Input( "aimbot", false, true )
		
	end

end

timer.Create( "CheckForAimbot", 20, 0, UpdateAimbot )