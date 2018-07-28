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
function Stats:new( Name, Path )

	if !Path then Path = Name end
	StatsID = StatsID + 1

	local NewStat = {

		Name = Name,
		Description = "",
		Path = "stats/" .. Path .. "/",
		Data = {},
		ID = StatsID,
		Hooks = {},

	}

  setmetatable( NewStat, Stats )
	StatsReg[ StatsID ] = NewStat

	return NewStat

end


-- Creates/gets player data object
function Stats:GetPlayerData( ply )
	
	local Steam = ply:SteamID64() or "bot"

	if !self.Data[ Steam ] then

		self.Data[ Steam ] = GData( self.Path .. Steam )
		return self.Data[ Steam ]

	end

	return self.Data[ Steam ]

end


-- Gets player's data object's data
function Stats:GetData( ply )

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


function Stats:SetPly( ply, Key, Amount, Save )

	local PData = self:GetData( ply )

	if !PData[ Key ] then PData[ Key ] = 0 end

	PData[ Key ] = Amount
	if Save then self:SavePly( ply ) end

	self:RunHook( "OnUpdate", ply, Key, Amount, Save )

end


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

	local PData = self:GetData( ply )
	if !PData[ Key ] then PData[ Key ] = 0 end
	self:SetPly( ply, Key, PData[ Key ] + Amount, Save )

end


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
