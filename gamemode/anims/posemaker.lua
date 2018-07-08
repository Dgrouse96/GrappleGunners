--
-- GUI/Tools for creating poses
--

-- Select a bone to edit
local function SelectBone( bone )

	local ply = LocalPlayer()
	if !ply.BoneProperties then return end
	
	ply.SelectedBone = bone
	
	local P = ply.BoneProperties
	local BoneAngle = ply:GetManipulateBoneAngles( bone )
	local BonePos = ply:GetManipulateBonePosition( bone )
	
	P[1]:SetValue( BonePos.x )
	P[2]:SetValue( BonePos.y )
	P[3]:SetValue( BonePos.z )
	
	P[4]:SetValue( BoneAngle.p )
	P[5]:SetValue( BoneAngle.y )
	P[6]:SetValue( BoneAngle.r )
	
end

-- Fills panel with all the bones
local function FillPanel( frame, bone, node )
	
	if !IsValid( node ) then return end
	
	local ply = LocalPlayer()
	local name = string.TrimLeft( ply:GetBoneName( bone ), "ValveBiped.Bip01_" )
	
	local newnode = node:AddNode( tostring( bone ) .. ":" .. name )
	newnode:SetExpanded( true, true )
	newnode.BoneID = bone
	newnode.OnNodeSelected = function(self) SelectBone( self.BoneID ) end
	
	for k,v in pairs( ply:GetChildBones( bone ) ) do
		
		FillPanel( frame, v, newnode )
		
	end
	
end

-- Properties for pos/ang
local function AddProperty( Panel, Category, Name, changedfunc )
	
	local Row = Panel:CreateRow( Category, Name )
	Row:Setup( "Float", { min = -180, max = 180 } )
	Row:SetValue( Zero )
	Row.DataChanged = changedfunc
	
	return Row
end

-- Menu for editing bones
function OpenBonePanel()

	local ply = LocalPlayer()
	local Zero = 0.0000001
	
	-- Allow only 1 panel
	if ply.MakingPose then return end
	ply.MakingPose = true
	

	-- Bone Tree
	local Frame = vgui.Create( "DFrame" )
	Frame:SetPos( 5, 5 )
	Frame:SetSize( 400, 1000 )
	Frame:SetTitle( "Bones" )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	
	local BoneTree = vgui.Create( "DTree", Frame )
	BoneTree:Dock( FILL )
	
	FillPanel( Frame, 0, BoneTree )
	
	-- Bone Settings
	local Frame2 = vgui.Create( "DFrame" )
	Frame2:SetPos( ScrW()-5-1000, 5 )
	Frame2:SetSize( 400, 235 )
	Frame2:SetTitle( "Bone Settings" )
	Frame2:SetVisible( true )
	Frame2:SetDraggable( true )
	Frame2:ShowCloseButton( true )
	Frame2:MakePopup()
	
	local Properties = vgui.Create( "DProperties", Frame2 )
	Properties:Dock( FILL )
	
	-- X
	local PosX = AddProperty( Properties, "Pos", "X", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local P = ply:GetManipulateBonePosition( ply.SelectedBone )
		ply:ManipulateBonePosition( ply.SelectedBone, Vector( val, P.y, P.z ) )
	
	end )
	
	-- Y
	local PosY = AddProperty( Properties, "Pos", "Y", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local P = ply:GetManipulateBonePosition( ply.SelectedBone )
		ply:ManipulateBonePosition( ply.SelectedBone, Vector( P.x, val, P.z ) )
	
	end )
	
	-- Z
	local PosZ = AddProperty( Properties, "Pos", "Z", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local P = ply:GetManipulateBonePosition( ply.SelectedBone )
		ply:ManipulateBonePosition( ply.SelectedBone, Vector( P.x, P.y, val ) )
	
	end )
	
	-- PITCH
	local Pitch = AddProperty( Properties, "Angle", "Pitch", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local A = ply:GetManipulateBoneAngles( ply.SelectedBone )
		ply:ManipulateBoneAngles( ply.SelectedBone, Angle( val, A.y, A.r ) )
	
	end )
	
	-- YAW
	local Yaw = AddProperty( Properties, "Angle", "Yaw", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local A = ply:GetManipulateBoneAngles( ply.SelectedBone )
		ply:ManipulateBoneAngles( ply.SelectedBone, Angle( A.p, val, A.r ) )
	
	end )
	
	-- ROLL
	local Roll = AddProperty( Properties, "Angle", "Roll", function( _, val ) 
	
		if !ply.SelectedBone then return end
		
		local A = ply:GetManipulateBoneAngles( ply.SelectedBone )
		ply:ManipulateBoneAngles( ply.SelectedBone, Angle( A.p, A.y, val ) )
	
	end )
	
	ply.BoneProperties = { PosX, PosY, PosZ, Pitch, Yaw, Roll }
	SelectBone( 0 )
	
	-- Reset pos/ang
	local Reset = vgui.Create( "DButton", Frame2 )
	Reset:SetText( "Reset" )
	Reset:Dock( BOTTOM )
	Reset:SetSize( 250, 30 )
	Reset.DoClick = function()
		
		local ply = LocalPlayer()
		local P = ply.BoneProperties
		
		for i=1, 6 do
		
			P[i]:SetValue( Zero )
			
		end
		
		ply:ManipulateBoneAngles( ply.SelectedBone, Angle() )
		ply:ManipulateBonePosition( ply.SelectedBone, Vector() )
		
	end
	
	-- Remove Panels
	Frame.OnRemove = function() Frame2:Remove() ply.MakingPose = false end
	Frame2.OnRemove = function() Frame:Remove() ply.MakingPose = false end
end
concommand.Add( "editbones", OpenBonePanel )


-- Put player in TPose
local function TPose()
	
	local ply = LocalPlayer()
	
	for i=0, ply:GetBoneCount() - 1 do
		
		ply:ManipulateBonePosition( i, Vector() )
		ply:ManipulateBoneAngles( i, Angle() )
		
	end
	
end
concommand.Add( "resetpose", TPose )

--
-- SAVING / LOADING
--

function SavePose( name )
	
	if !name then print( "Please supply a file name" ) return end
	
	local ply = LocalPlayer()
	local bones = {}
	
	for i=0, ply:GetBoneCount() - 1 do
		
		local pos = ply:GetManipulateBonePosition( i )
		local ang = ply:GetManipulateBoneAngles( i )
		bones[i] = { p = pos, a = ang }
		
	end
	
	local json = util.TableToJSON( bones )
	file.CreateDir( "posemaker/poses" )
	file.Write( "posemaker/poses/"..name..".txt", json )
	
	print( "Saved pose: "..name..".txt" )
	
end


local function comSavePose( _, _, args )

	SavePose( args[1] )
	
end
concommand.Add( "savepose", comSavePose )


local function GetChildren( ply, bone )
	
	
	local Children = { bone }
	
	for k,v in pairs( ply:GetChildBones( bone ) ) do
		
		table.Add( Children, GetChildren( ply, v ) )
		
	end
	
	return Children
	
end

function SaveLimb( name, bone )
	
	if !name then print( "Please supply a file name" ) return end
	if !bone then print( "Please supply a bone ID" ) return end
	
	local ply = LocalPlayer()
	local bones = {}
	
	for k,v in pairs( GetChildren( ply, bone ) ) do
		
		local pos = ply:GetManipulateBonePosition( v )
		local ang = ply:GetManipulateBoneAngles( v )
		bones[v] = { p = pos, a = ang }
		
	end
	
	local json = util.TableToJSON( bones )
	file.CreateDir( "posemaker/poses" )
	file.Write( "posemaker/poses/"..name..".txt", json )
	
	print( "Saved pose: "..name..".txt" )
	
end


local function comSaveLimb( _, _, args )

	SaveLimb( args[1], tonumber(args[2]) )
	
end
concommand.Add( "savelimb", comSaveLimb )


function LoadPose( name )
	
	if !name then print( "Please supply a file name" ) return end
	local read = file.Read( "posemaker/poses/"..name..".txt" )
	if !read then print( "Can't find file: "..name..".txt" ) return end
	
	local ply = LocalPlayer()
	local bones = util.JSONToTable( read )
	
	for k,v in pairs( bones ) do
		
		ply:ManipulateBonePosition( k,v.p )
		ply:ManipulateBoneAngles( k,v.a )
		
	end
	
end


local function comLoadPose( _, _, args )
	
	LoadPose( args[1] )
	
end
concommand.Add( "loadpose", comLoadPose )


-- Use this for retargetting
local function SaveBoneNames( name )
	
	if !name then print( "Please supply a file name" ) return end
	local ply = LocalPlayer()
	local bones = {}
	
	for i=0, ply:GetBoneCount()-1 do
		
		bones[i] = ply:GetBoneName( i )
		
	end
	
	
	local json = util.TableToJSON( bones )
	file.CreateDir( "posemaker/bones" )
	file.Write( "posemaker/bones/"..name..".txt", json )
	
end


local function comSaveBones( _, _, args )
	
	SaveBoneNames( args[1] )
	
end
concommand.Add( "savebones", comSaveBones )



-- Retarget bone IDs
local function RetargetBones( name, source )
	
	if !name then print( "Please supply a file name" ) return end
	if !source then print( "Please supply a file name for source bones" ) return end
	
	local read = file.Read( "posemaker/bones/"..source..".txt" )
	if !read then print( "Can't find file: "..source..".txt" ) return end
	
	local ply = LocalPlayer()
	local bones = util.JSONToTable(read)
	local retarget = {}
	
	for id,bonename in pairs( bones ) do
		
		for i=0, ply:GetBoneCount() - 1 do
			
			if ply:GetBoneName( i ) == bonename then
			
				retarget[id] = i
			
			end
			
		end
		
	end
	
	local json = util.TableToJSON( retarget )
	file.CreateDir( "posemaker/retarget" )
	file.Write( "posemaker/retarget/" .. name .. ".txt", json )
	
end

local function comRetargetBones( _, _, args )
	
	RetargetBones( args[1], args[2] )
	
end
concommand.Add( "retargetbones", comRetargetBones )



local function SaveHands( name )
	
	if !name then print( "Please supply a file name" ) return end
	local ply = LocalPlayer()
	local bones = {}
	
	for i=0, ply:GetHands():GetBoneCount() - 1 do
	
		bones[i] = ply:GetHands():GetBoneName( i )
		
	end
	
	local json = util.TableToJSON( bones )
	file.CreateDir( "posemaker/bones" )
	file.Write( "posemaker/bones/"..name..".txt", json )
	
end

local function comSaveHands( _, _, args )
	
	SaveHands( args[1] )
	
end
concommand.Add( "savehands", comSaveHands )


local function RetargetHands( name, source )
	
	if !name then print( "Please supply a file name" ) return end
	if !source then print( "Please supply a file name for source bones" ) return end
	
	local read = file.Read( "posemaker/bones/"..source..".txt" )
	if !read then print( "Can't find file: "..source..".txt" ) return end
	
	local ply = LocalPlayer()
	local bones = util.JSONToTable(read)
	local retarget = {}
	
	for id,bonename in pairs( bones ) do
		
		for i=0, ply:GetHands():GetBoneCount() - 1 do
			
			if string.Right( ply:GetBoneName( i ), 6 ) == string.Right( bonename, 6 ) then
			
				retarget[id] = i
			
			end
			
		end
		
	end
	
	local json = util.TableToJSON( retarget )
	file.CreateDir( "posemaker/retarget" )
	file.Write( "posemaker/retarget/" .. name .. ".txt", json )
	
end

local function comRetargetHands( _, _, args )
	
	RetargetHands( args[1], args[2] )
	
end
concommand.Add( "retargethands", comRetargetHands )



-- Copy bone data to clipboard
local function CopyPose( name, dir )
	
	if !dir then dir = "poses" end
	
	if !name then print( "Please supply a file name" ) return end
	local read = file.Read( "posemaker/"..dir.."/"..name..".txt" )
	if !read then print( "Can't find file: "..name..".txt" ) return end
	
	local ply = LocalPlayer()
	local bones = util.JSONToTable( read )
	local String = table.ToString( bones, name, false )
	
	String = string.Replace( String, name .. "={", "" )
	String = "[\"" .. name .. "\"]={\n	" .. String
	
	SetClipboardText( String )
	
end

local function comCopyPose( _, _, args )
	
	CopyPose( args[1] )
	
end
concommand.Add( "copypose", comCopyPose )

local function comCopyRetarget( _, _, args )
	
	CopyPose( args[1], "retarget" )
	
end
concommand.Add( "copyretarget", comCopyRetarget )