--
-- Playtime
--

PlayTime = Stats( Either( SERVER, "playtime", "playtime_c" ) )


-- Used when client syncs with server data
function PlayTime:SetTypeData( ply, ID, Data )
	
	self:GetPlayerData( ply )[ ID ] = Data
	
end
hook.Add( "GetPlayTimeData", "Update", function( ... ) PlayTime:SetTypeData( ... ) end )


function PlayTime:GetTypeData( ply, ID )
	
	local Data = self:GetPlayerData( ply )
	
	if !Data[ ID ] then 
	
		Data[ ID ] = {
			
			Start = 0,
			Total = 0,
			HasData = SERVER,
			SentRequest = false,
			
		}
		
	end
	
	
	-- Client asks server for missing player data
	if !Data[ ID ].HasData and !Data[ ID ].SentRequest then
		
		sendRequest( "GrabPlayTime", { ply, ID } )
		Data[ ID ].SentRequest = true
		
	end
	
	return Data[ ID ]
	
end


function PlayTime:SaveCurrent( ply, Time )
	
	if !self.GameType then return end
		
	local Data = self:GetTypeData( ply, self.GameType )
	
	if Data.Start == 0 then return end
	
	Data.Total = math.floor( Data.Total + Time - Data.Start )
	Data.Start = 0
	Data.HasData = SERVER
	Data.SentRequest = false
	PrintTable( self:GetPlayerData( ply ) )
	self:SavePly( ply )
	
end


function PlayTime:GetPlayTime( ply, GameType )
	
	if !GameType then
		
		if CurrentGameType then
			
			GameType = CurrentGameType.ID
			
		else
		
			return 0
		
		end
		
	end
	
	local Data = self:GetTypeData( ply, GameType )
	return math.floor( CurTime() - Data.Start + Data.Total )
	
end


function PlayTime:SetGameTypeSingle( ply, GameType, Time )
	
	if !Time then Time = CurTime() end
	
	if !GameType then
		
		if CurrentGameType then
			
			GameType = CurrentGameType.ID
			
		else
		
			return
		
		end
		
	end
	
	self:SaveCurrent( ply, Time )
	
	local Data = self:GetTypeData( ply, GameType )
	Data.Start = Time
	
	self.GameType = GameType
	
end


-- Used whenever a GameType changes
function PlayTime:SetGameType( ply, GameType, Time )
	
	if !ply then
	
		for k,v in pairs( player.GetAll() ) do
			
			self:SetGameTypeSingle( v, GameType, Time )
			
		end
	
	else
	
		self:SetGameTypeSingle( ply, GameType, Time )
		
	end
	
end
hook.Add( "UpdatePlayTime", "Update", function( ... ) PlayTime:SetGameType( ... ) end )


if CLIENT then return end

-- Replication
function PlayTime:SetGameTypeRep( ply, GameType )
	
	PlayTime:SetGameType( ply, GameType )
	sendArgs( "UpdatePlayTime", { ply, GameType, CurTime() } )
	
end

AddRequest( "GrabPlayTime", function( T )
	
	if !IsValid( T[1] ) then return end
	if !T[1]:IsPlayer() then return end
	if !isnumber( T[2] ) then return end
	
	local Data = PlayTime:GetTypeData( T[1], T[2] )
	sendArgs( "GetPlayTimeData", { T[1], T[2], Data } )
	
end )

-- Periodic saving of play time
timer.Create( "SavePlayTime", 60, 0, function() PlayTime:SetGameType() end )
