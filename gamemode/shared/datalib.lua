--
-- Object based file system
--


-- Kill any existing data tables
if !GDataRegistry then GDataRegistry = {} end
ClearObjects( GDataRegistry )


-- Used for registry
local GDataID = 0


-- GData Metatable
GData = {}
GData.__index = GData


-- Call function
function GData:new( File, SaveFile )
	
	if !SaveFile then SaveFile = true end
	
	GDataID = GDataID + 1
	
	local NewGData = {
		
		File = "grapplegunners/" .. File .. ".txt",
		Data = {},
		ID = GDataID,
		SaveFile = SaveFile,
		
	}
	
	setmetatable( NewGData, GData )
	GDataRegistry[ GDataID ] = NewGData
	
	NewGData:Load()
	
	return NewGData
	
end


-- Loads file if it exists
function GData:Load()

	if !file.Exists( self.File, "DATA" ) then return end
	
	local String = file.Read( self.File )
	if !String then return end
	
	local JSON = util.JSONToTable( String )
	if !JSON then return end

	self.Data = JSON
	
end


-- Saves data to file
function GData:Save()
	
	if !self.SaveFile then return end
	
	local JSON = util.TableToJSON( self.Data )
	
	file.CreateDir( GetPath( self.File ) )
	file.Write( self.File, JSON )
	
end


function GData:Kill()
	
	table.Empty( self )
	self = nil
	
end


function GData:GetData( Load )
	
	if Load then
	
		self:Load()
		
	end
	
	return self.Data
	
end


function GData:Set( Table )
	
	table.Empty( self.Data )
	
	for k,v in pairs( Table ) do
		
		self.Data[k] = v
		
	end
	
end


function GData:Input( KeyOrTable, Value )
	
	if istable( KeyOrTable ) then
		
		for k,v in pairs( KeyOrTable ) do
			
			self.Data[k] = v
			
		end
		
	elseif isnumber( KeyOrTable ) or isstring( KeyOrTable ) then
		
		self.Data[ KeyOrTable ] = Value
		
	
	elseif KeyOrTable == nil then
		
		table.insert( self.Data, Value )
		
	end
	
end

function GData:Length()
	
	return #self.Data
	
end

setmetatable( GData, { __call = GData.new } )