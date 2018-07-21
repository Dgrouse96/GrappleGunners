-- Let chat know someone earned an achievement!
local function NotifyChat( T )

	chat.AddText( unpack( T ) )
	
end
hook.Add( "AchievementUnlocked", "NotifyChat", NotifyChat )