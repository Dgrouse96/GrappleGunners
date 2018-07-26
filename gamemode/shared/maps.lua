MapList = GData( Either(SERVER,"maps","map_c"), _, 1 )

if CLIENT then return end

MapList:Input( "gr_crossroads",{
  Name = "Cross Roads",
  Description = "A dark and dank shadow beneath a city, only the most wretched scum survive here.",
  GameTypes = {
    GAMETYPE_FFA,
  },
}, _, true )

MapList:Input( "gm_goldencity_day",{
  Name = "Golden City",
  Description = "\"I have many pizzas that need delivering and you are LATE, as always.\"",
  GameTypes = {
    GAMETYPE_PIZZATIME,
  },
}, _, true )

MapList:Save( true )
