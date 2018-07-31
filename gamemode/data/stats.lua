--
-- Stats system
--

StatsReg = StatsReg or {}

-- Kill any existing data tables
ClearObjects( StatsReg )


-- Used for registry
local StatsID = 0


-- Achievement Metatable
Stats = {}
Stats.__index = Stats


-- Call function
function Stats:new( Name, Path, RepID )

	if !Path then Path = Name end
	StatsID = StatsID + 1

	local NewStat = {

		Name = Name,
		Description = "",
		Path = "stats/" .. Path .. "/",
		Data = {},
		ID = StatsID,
		Hooks = {},
		RepID = RepID,
		
	}

	setmetatable( NewStat, Stats )
	StatsReg[ StatsID ] = NewStat

	return NewStat

end


function GetStat( ID )
	
	return StatsReg[ ID ]
	
end

function GetStatRep( RepID )
	
	for k,v in pairs( StatsReg ) do
		
		if v.RepID == RepID then
			
			return v
		
		end
		
	end
	
end


function Stats:Replicates()
	
	return SERVER and self.RepID
	
end


-- Creates/gets player data object
function Stats:GetPlayerData( ply )
	
	local Steam = ply:SteamID64() or "bot"

	if !self.Data[ Steam ] then

		self.Data[ Steam ] = GData( self.Path .. Steam )
		return self.Data[ Steam ]

	end
	
	if CLIENT and self.RepID and !self.Data[ Steam ].HasData and !self.Data[ Steam ].SendRequest then
		
		sendRequest( "GrabStatData", { ply, self.RepID } )
		self.Data[ Steam ].SendRequest = true
		
	end

	return self.Data[ Steam ]

end


-- Sync Player Data
if SERVER then

	AddRequest( "GrabStatData", function( ply, T )
	
		if !IsValid( T[1] ) then return end
		if !T[1]:IsPlayer() then return end
		if !isnumber( T[2] ) then return end
		
		local Data = GetStatRep( T[2] ):GetData( T[1] )
		sendArgs( "StatsSetData", { T[2], T[1], Data }, ply )
		
	end )
	
end


-- Gets player's data object's data
function Stats:GetData( ply, Key )
	
	if Key then
	
		return self:GetPlayerData( ply ):GetData()[ Key ] or 0
	
	end
	
	return self:GetPlayerData( ply ):GetData()

end


-- Saves player data to file
function Stats:SavePly( ply )

	self:GetPlayerData( ply ):Save()

end


-- Saves player or table of player's data
function Stats:Save( ply )

	if !ply then ply = player.GetAll() end

	if istable( ply ) then

		for k,v in pairs( ply ) do

			self:SavePly( v )

		end

	else

		self:SavePly( ply )

	end

end


function Stats:SetDataPly( ply, Table, Save )
	
	if self:Replicates() then
		
		sendArgs( "StatsSetData", { self.RepID, ply, Table, Save } )
		
	end
	
	self:GetPlayerData( ply ):Set( Table, Save )
	if Save then self:SavePly( ply ) end
	self:RunHook( "OnSet", ply, Table, Save )
	
end

-- Replicate
hook.Add( "StatsSetData", "Replicate", function( RepID, ply, Table, Save )

	local Stat = GetStatRep( RepID )
	local Data = Stat:GetPlayerData( ply )
	
	Data.HasData = true
	Data.SentRequest = false
	
	Stat:SetDataPly( ply, Table, Save )
	
end )


function Stats:SetData( ply, Table, Save )

	if !Save then Save = true end
	if !ply then ply = player.GetAll() end

	if istable( ply ) then

		for k,v in pairs( ply ) do

			self:SetDataPly( v, Table, Save )

		end

	else

		self:SetDataPly( ply, Table, Save )

	end

end


function Stats:SetPly( ply, Key, Amount, Save )

	if self:Replicates() then
		
		sendArgs( "StatsSet", { self.RepID, ply, Key, Amount, Save } )
		
	end
	
	local PData = self:GetData( ply )
	if !PData[ Key ] then PData[ Key ] = 0 end

	PData[ Key ] = Amount
	if Save then self:SavePly( ply ) end

	self:RunHook( "OnUpdate", ply, Key, Amount, Save )
	
end

-- Replicate
hook.Add( "StatsSet", "Replicate", function( RepID, ... ) GetStatRep( RepID ):SetPly( ... ) end )


function Stats:Set( ply, Key, Amount, Save )

	if !Save then Save = true end
	if !ply then ply = player.GetAll() end

	if istable( ply ) then

		for k,v in pairs( ply ) do

			self:SetPly( v, Key, Amount, Save )

		end

	else

		self:SetPly( ply, Key, Amount, Save )

	end

end


-- Increment a player's achievement stat
function Stats:IncrementPly( ply, Key, Amount, Save )

	if self:Replicates() then
		
		sendArgs( "StatsInc", { self.RepID, ply, Key, Amount, Save } )
		
	end
	
	local PData = self:GetData( ply )
	if !PData[ Key ] then PData[ Key ] = 0 end
	self:SetPly( ply, Key, PData[ Key ] + Amount, Save )

end

-- Replicate
hook.Add( "StatsInc", "Replicate", function( RepID, ... ) GetStatRep( RepID ):IncrementPly( ... ) end )


-- Increment a player or table of player's stat
function Stats:Increment( ply, Key, Amount, Save )

	if !Save then Save = true end
	if !ply then ply = player.GetAll() end

	if istable( ply ) then

		for k,v in pairs( ply ) do

			self:IncrementPly( v, Key, Amount, Save )

		end

	else

		self:IncrementPly( ply, Key, Amount, Save )

	end

end


-- Count up each stat
function Stats:GetTotal( ply )
	
	local Count = 0

	for k,v in pairs( self:GetData( ply ) ) do
	
		if isnumber( v ) then Count = Count + v end

	end

	return Count

	
end


function Stats:TestCombo( ply, Amount )

	if Amount > self:GetData( ply, "Amount" ) then
		
		self:Set( ply, "Amount", Amount )
		
	end
	
end


-- Ensure object death
function Stats:Kill()

	table.Empty( self )
	self = nil

end

--
-- In-house update system
--

function Stats:BindHook( Hook, Identifier, Func )

  if !self.Hooks[ Hook ] then self.Hooks[ Hook ] = {} end
  self.Hooks[ Hook ][ Identifier ] = Func

end


function Stats:UnbindHook( Hook, Identifier )

  if !self.Hooks[ Hook ][ Identifier ] then return end
  self.Hooks[ Hook ][ Identifier ] = nil

end


function Stats:RunHook( Hook, ... )

  if !self.Hooks[ Hook ] then return end

  for k,v in pairs( self.Hooks[ Hook ] ) do v( ... ) end

end


function Stats:BindOnUpdate( Identifier, Func )

  self:BindHook( "OnUpdate", Identifier, Func )

end

function Stats:UnbindOnUpdate( Identifier )

  self:UnbindHook( "OnUpdate", Identifier )

end

setmetatable( Stats, { __call = Stats.new } )
