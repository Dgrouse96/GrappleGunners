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
		
		local Amount = self:GetData( ply )["Amount"]
		if !Amount then Amount = 0 end
		
		return Amount >= self.WinAt

	end
	
	-- Default Progress function
	function NewAchievement:GetProgress( ply )
		
		local Amount = self:GetData( ply )["Amount"]
		if !Amount then Amount = 0 end
		
		return Amount / self.WinAt
		
	end
	
	-- Default Progress text function
	function NewAchievement:GetProgressText( ply )
		
		local Amount = self:GetData( ply )["Amount"]
		if !Amount then Amount = 0 end
		
		return tostring( Amount ) .. "/" .. tostring( self.WinAt )
		
	end

	setmetatable( NewAchievement, Achievement )
	AchievementReg[ AchievementID ] = NewAchievement

	return NewAchievement

end


function GetAchievement( ID )
	
	return AchievementReg[ ID ]
	
end


-- Creates/gets player data object
function Achievement:GetPlayerData( ply )

	local Steam = ply:SteamID64() or "bot"

	if !self.Data[ Steam ] then

		self.Data[ Steam ] = GData( self.Path .. Steam )
		return self.Data[ Steam ]

	end
	
	if CLIENT and !self.Data[ Steam ].HasData and !self.Data[ Steam ].SendRequest then
		
		sendRequest( "GrabAchiementData", { ply, self.ID } )
		self.Data[ Steam ].SendRequest = true
		
	end

	return self.Data[ Steam ]

end

-- Sync Player Data
if SERVER then

	AddRequest( "GrabAchiementData", function( ply, T )
	
		if !IsValid( T[1] ) then return end
		if !T[1]:IsPlayer() then return end
		if !isnumber( T[2] ) then return end
		
		local Data = GetAchievement( T[2] ):GetData( T[1] )
		sendArgs( "AchievementSetData", { T[2], T[1], Data }, ply )
		
	end )
	
end


-- Gets player's data object's data
function Achievement:GetData( ply )

	return self:GetPlayerData( ply ):GetData()

end


-- Let the chat know you've earned an achievement!
function Achievement:ServerNotify( ply )

	if !SERVER then return end
	local Message = { Color(255,220,150), ply, COL_WHITE, " earned the achievement ", Color(255,200,100), self.Name }
	sendTable( "AchievementUnlocked", Message )

end


-- Let chat know someone earned an achievement!
local function NotifyChat( T )
	
	if !CLIENT then return end
	chat.AddText( unpack( T ) )
	
end
hook.Add( "AchievementUnlocked", "NotifyChat", NotifyChat )


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
	
	if !SERVER then return end
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


function Achievement:SetDataPly( ply, Table, Save )
	
	self:GetPlayerData( ply ):Set( Table, Save )
	
	if SERVER then
		
		sendArgs( "AchievementSetData", { self.ID, ply, Table } )
		
	end
	
	if Save then self:SavePly( ply ) end
	self:Update( ply )
	
end

-- Replicate
hook.Add( "AchievementSetData", "Replicate", function( ID, ply, Table )

	local Ach = GetAchievement( ID )
	local PData = Ach:GetPlayerData( ply )
	
	PData.HasData = true
	PData.SentRequest = false
	
	Ach:SetDataPly( ply, Table )
	
end )


function Achievement:SetData( ply, Table, Save )

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


function Achievement:SetPly( ply, Key, Amount, Save )

	local PData = self:GetData( ply )

	if !PData.Completed or self.UpdateOnCompleted then
	
		if SERVER then
		
			sendArgs( "AchievementSet", { self.ID, ply, Key, Amount } )
			
		end

		if !PData[ Key ] then PData[ Key ] = 0 end

		PData[ Key ] = Amount
		if Save then self:SavePly( ply ) end

		self:Update( ply )

	end

end

-- Replicate
hook.Add( "AchievementSet", "Replicate", function( ID, ... ) GetAchievement( ID ):SetPly( ... ) end )


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
	
	if SERVER then
		
		sendArgs( "AchievementInc", { self.ID, ply, Key, Amount } )
		
	end
	
	local PData = self:GetData( ply )
	if !PData[ Key ] then PData[ Key ] = 0 end
	self:SetPly( ply, Key, PData[ Key ] + Amount, Save )

end

-- Replicate
hook.Add( "AchievementInc", "Replicate", function( ID, ... ) GetAchievement( ID ):IncrementPly( ... ) end )


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
