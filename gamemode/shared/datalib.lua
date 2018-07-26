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
function GData:new( File, SaveFile, RepID )

	if !SaveFile then SaveFile = true end

	GDataID = GDataID + 1

	local NewGData = {

		File = "grapplegunners/" .. File .. ".txt",
		Data = {},
		ID = GDataID,
		SaveFile = SaveFile,
		RepID = RepID,

	}

	setmetatable( NewGData, GData )
	GDataRegistry[ GDataID ] = NewGData

	if self:HasAuth( Replicate ) then

		NewGData:Load()

	end

	-- Client Replication
	if RepID and CLIENT then

		hook.Add( "GDataInput", self, self.Input )
		hook.Add( "GDataSet", self, self.Set )
		hook.Add( "GDataSave", self, self.Save )
		hook.Add( "GDataLoad", self, self.Load )
		print( "CHECK" )
	end

	return NewGData

end


-- Check if SERVER and Replicate == true
function GData:HasAuth( Replicate )
	print( self.RepID and ( !Replicate or SERVER ) )
	return self.RepID and ( !Replicate or SERVER )

end


-- If
function GData:DataMismatch( Replicate )
	print( "MEME", Replicate )
	 return CLIENT and Replicate and Replicate != self.RepID

end


-- Replicate new data to player(s)!
function GData:Replicate( Replicate, Ply, Type, ... )

	if !self:HasAuth( Replicate ) then return end -- Do we replicate?
	sendArgs( Type, { ..., self.RepID }, Ply )

end


-- Loads file if it exists
function GData:Load( Replicate, Ply, Data )

	if Data then self.Data = Data end

	if self:DataMismatch( Replicate ) then return end
	self:Replicate( Replicate, Ply, _, _, "GDataLoad" )

	if !file.Exists( self.File, "DATA" ) then return end

	local String = file.Read( self.File )
	if !String then return end

	local JSON = util.JSONToTable( String )
	if !JSON then return end

	self.Data = JSON

end


-- Saves data to file
function GData:Save( Replicate, Ply )

	if self:DataMismatch( Replicate ) then return end
	self:Replicate( Replicate, Ply, "GDataSave" )

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


function GData:Set( Table, Save, Replicate, Ply )

	if self:DataMismatch( Replicate ) then return end
	self:Replicate( Replicate, Ply, "GDataSet", Table, Save )


	table.Empty( self.Data )

	for k,v in pairs( Table ) do

		self.Data[k] = v

	end

	if Save then
		self:Save()
	end

end



function GData:Input( KeyOrTable, Value, Save, Replicate, Ply )

	if self:DataMismatch( Replicate ) then return end
	self:Replicate( Replicate, Ply, "GDataInput", KeyOrTable, Value, Save )

	if istable( KeyOrTable ) then

		for k,v in pairs( KeyOrTable ) do

			self.Data[k] = v

		end

	elseif isnumber( KeyOrTable ) or isstring( KeyOrTable ) then

		self.Data[ KeyOrTable ] = Value


	elseif KeyOrTable == nil then

		table.insert( self.Data, Value )

	end

	if Save then
		self:Save()
	end

end


function GData:Length()

	return #self.Data

end

setmetatable( GData, { __call = GData.new } )
