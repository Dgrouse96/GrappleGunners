--
-- Achievement system
-- yeah, lots of copied code... (yet to make child classes)


AchievementReg = AchievementReg or {}

-- Kill any existing data tables
ClearObjects( AchievementReg )


-- Used for registry
local AchievementID = 0


-- Achievement Metatable
Achievement = {}
Achievement.__index = Achievement


-- Call function
function Achievement:new( Name, Path )

	if !Path then Path = Name end
	AchievementID = AchievementID + 1

	local NewAchievement = {

		Name = Name,
		Description = "",
		Path = "achievements/" .. Path .. "/",
		Data = {},
		ID = AchievementID,
		WinAt = 1,
		UpdateOnCompleted = false,

	}

	-- Default Win function
	function NewAchievement:WinCheck( ply )

		return self:GetData( ply )["Amount"] >= self.WinAt

	end

	setmetatable( NewAchievement, Achievement )
	AchievementReg[ AchievementID ] = NewAchievement

	return NewAchievement

end


-- Creates/gets player data object
function Achievement:GetPlayerData( ply )

	local Steam = ply:SteamID64()

	if !self.Data[ Steam ] then

		self.Data[ Steam ] = GData( self.Path .. Steam )
		return self.Data[ Steam ]

	end

	return self.Data[ Steam ]

end


-- Gets player's data object's data
function Achievement:GetData( ply )

	return self:GetPlayerData( ply ):GetData()

end


-- Let the chat know you've earned an achievement!
function Achievement:ServerNotify( ply )

	local Message = { Color(255,220,150), ply, COL_WHITE, " earned the achievement ", Color(255,200,100), self.Name }
	sendTable( "AchievementUnlocked", Message )

end


-- Check if we've reached the requirements
function Achievement:Update( ply )

	local PData = self:GetData( ply )

	if !PData.Completed and self:WinCheck( ply ) then

		PData.Completed = true
		self:ServerNotify( ply )
		self:SavePly( ply )

	end

end


-- Saves player data to file
function Achievement:SavePly( ply )

	self:GetPlayerData( ply ):Save()

end


-- Saves player or table of player's data
function Achievement:Save( ply )

	if !ply then ply = player.GetAll() end

	if istable( ply ) then

		for k,v in pairs( ply ) do

			self:SavePly( v )

		end

	else

		self:SavePly( ply )

	end

end


function Achievement:SetPly( ply, Key, Amount, Save )

	local PData = self:GetData( ply )

	if !PData.Completed or self.UpdateOnCompleted then

		if !PData[ Key ] then PData[ Key ] = 0 end

		PData[ Key ] = Amount
		if Save then self:SavePly( ply ) end

		self:Update( ply )

	end

end


function Achievement:Set( ply, Key, Amount, Save )

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
function Achievement:IncrementPly( ply, Key, Amount, Save )

	local PData = self:GetData( ply )
	if !PData[ Key ] then PData[ Key ] = 0 end
	self:SetPly( ply, Key, PData[ Key ] + Amount, Save )

end


-- Increment a player or table of player's stat
function Achievement:Increment( ply, Key, Amount, Save )

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
function Achievement:Kill()

	table.Empty( self )
	self = nil

end


setmetatable( Achievement, { __call = Achievement.new } )
