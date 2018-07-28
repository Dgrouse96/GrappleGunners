MapList = GData( Either(SERVER,"maps","maps_c") )

if SERVER then

	MapList:Input( "gr_crossroads",{
	  Name = "Cross Roads",
	  Description = "A dark and dank shadow beneath a city, only the most wretched scum survive here.",
	  GameTypes = {
		GAMETYPE_FFA,
	  },
	} )

	MapList:Input( "gm_goldencity_day",{
	  Name = "Golden City",
	  Description = "\"I have many pizzas that need delivering and you are LATE, as always.\"",
	  GameTypes = {
		GAMETYPE_PIZZATIME,
	  },
	} )
	
	MapList:Save()
	
	local function SendMapList( ply )
		
		sendArgs( "MapListUpdate", { MapList:GetData(), true }, ply )
		
	end
	
	hook.Add( "PlayerInitialSpawn", "UpdateMapList", SendMapList )
	hook.Add( "OnReloaded", "UpdateMapList", function() timer.Simple( 1, SendMapList ) end )

else

	hook.Add( "MapListUpdate", "UpdateMapList", function( ... ) MapList:Set( ... ) end )
	
end
