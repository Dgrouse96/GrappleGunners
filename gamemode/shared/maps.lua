--
-- Map List
--

-- Please use console commands to add maps // Not ready yet :o
-- gg_mapadd "mapname" "friendlyname" "description"
-- gg_mapgametype "mapname" "gametype" "weight"
-- gg_mapremove "mapname"

MapList = GData( "maps" )


-- Returns a random Map and GameID
function MapList:GetRandomMap()
	
	local RangeData = {}
	local RangeAmount = 0
	
	for Map,Data in pairs( self:GetData() ) do
		
		//if Map != game.GetMap() then
		
			for GameType,Weight in pairs( Data.GameTypes ) do
				
				RangeAmount = RangeAmount + Weight
				table.insert( RangeData, { 
					Range = RangeAmount,
					Map = Map,
					GameType = GameType,
				} )
				
			end
			
		//end
		
	end
	
	local Decider = math.Rand( 0, RangeAmount )
	
	for k,Data in pairs( RangeData ) do
		
		if Decider <= Data.Range then
			
			return Data.Map, Data.GameType
			
		end
		
	end
	
end


if CLIENT then

	
	function GrabMapList()
	
		sendRequest( "GrabMapList" )
		
	end
	hook.Add( "OnReloaded", "GrabMapList", GrabMapList )
	hook.Add( "MapListUpdate", "UpdateMapList", function( ... ) MapList:Set( ... ) end )
	
end

if CLIENT then return end

CreateConVar( "gg_nextgametype", 1 )

MapList:Input( "gr_crossroads",{
  Name = "Cross Roads",
  Description = "A dark and dank shadow beneath a city, only the most wretched scum survive here.",
  GameTypes = {
	[ GAMETYPE_FFA ] = 1,
  },
} )

MapList:Input( "gm_goldencity_day",{
  Name = "Golden City",
  Description = "\"I have many pizzas that need delivering and you are LATE, as always.\"",
  GameTypes = {
	//[ 2 ] = 0.5,
  },
} )

MapList:Save()

--
-- Replicate Data
--

function SendMapList( ply )
	
	sendArgs( "MapListUpdate", { MapList:GetData() }, ply )
	
end

AddRequest( "GrabMapList", SendMapList )


--
-- Start Votemap
--

function MapList:ChoseAndSendMaps()
	
	self.VoteChoices = {}
	
	for i=1, 3 do
		
		local Map, GameType = self:GetRandomMap()
		self.VoteChoices[ i ] = { Map = Map, GameType = GameType }
		
	end
	
	for k,ply in pairs( player.GetAll() ) do
		
		ply.HasMapVoted = false
		
	end
	
	self.MapVotes = { 0,0,0 }
	sendTable( "AddMapChoices", self.VoteChoices )
	
	SetTimerTime( 15 )
	timer.Create( "MapVoteTimer", 15, 1, function() MapList:PlayVotedMap() end )
	
end

--
-- Player voted for map
--

AddRequest( "VoteMap", function( ply, T )
	
	if MapList.VotedMap then return end
	if !MapList.VoteChoices then return end
	
	if ply.HasMapVoted then return end
	if !T[1] or !isnumber( T[1] ) then return end
	
	MapList.MapVotes[ T[1] ] = MapList.MapVotes[ T[1] ] + 1
	
	ply.HasMapVoted = true
	sendArgs( "MapVoted", { T[1] } )
	
	-- Check if all players have voted
	local MissingVotes = false
	for k,v in pairs( player.GetAll() ) do
		
		if !v.HasMapVoted then
			
			MissingVotes = true
			break
			
		end
		
	end
	
	if !MissingVotes then
		
		timer.Remove( "MapVoteTimer" )
		MapList:PlayVotedMap()
		
	end
	
end )

--
-- Change Level to winning map
--

function MapList:PlayVotedMap()
	
	local HighVotes = {}
	local HighestVote = 0
	
	for k,votes in pairs( self.MapVotes ) do
		
		if votes > HighestVote then
			
			HighVotes = { k }
			HighestVote = votes
			
		elseif votes == HighestVote then
		
			table.insert( HighVotes, k )
			
		end
		
	end
	
	MapList.VotedMap = HighVotes[ math.random( 1, #HighVotes ) ]
	sendArgs( "MapSelected", { MapList.VotedMap } )
	
	SetTimerTime( 3 )
	timer.Simple( 3, function() MapList:ChangeMap() end )
	
end

function MapList:ChangeMap()
	
	if !self.VotedMap or !self.VoteChoices then return end
	
	local Choice = self.VoteChoices[ self.VotedMap ]
	GetConVar( "gg_nextgametype" ):SetInt( Choice.GameType )
	RunConsoleCommand( "changelevel", Choice.Map )
	
end