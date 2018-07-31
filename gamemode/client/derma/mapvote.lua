Derma_MapVote = Derma()
Derma_MapVote.SpawnTime = 0
Derma_MapVote.Enabled = false

local MapChoices = {}
local VoteTick = Material( "grapplegunners/hud/votetick.png" )

function Derma_MapVote:Init()
	
	self.Enabled = true
	
	if IsValid( self.Frame ) then
		self.Frame:Close()
	end
	
	if #MapChoices <= 0 then return end
	
	gui.EnableScreenClicker( !self.Chose and !self.MapSelected )
	self.SpawnTime = CurTime()
	
	--
	-- Frame
	--
	
	self.Frame = vgui.Create( "DFrame" )
	self.Frame:SetPos( ScrW()*0.05, ScrH() - 400 )
	self.Frame:SetSize( ScrW()*0.9, 400 )
	self.Frame:SetTitle( "" )
	self.Frame:SetAlpha( 0 )
	self.Frame:SetVisible( true )
	self.Frame:SetDraggable( false )
	self.Frame:ShowCloseButton( false )
	self.Frame.Paint = function( fram, w, h )
		
		local Alpha = math.Clamp( ( CurTime() - self.SpawnTime )*2, 0, 1 )
		fram:SetAlpha( Lerp( ease( Alpha, 1.5, 0.1 ), 0, 255 ) )
			
		local Text = "Vote Map"
		draw.SimpleText( Text, "MapVoteHeader", w*0.5 + 2, 2, COL_BLACK, 1 )
		draw.SimpleText( Text, "MapVoteHeader", w*0.5, 0, COL_WHITE, 1 )
		
	end
	
	for k,Data in pairs( MapChoices ) do
	
		local Button = vgui.Create( "DButton", self.Frame )
		Button:SetSize( ScrW()*0.29, 300 )
		Button:SetPos( ScrW()*0.3*(k-1), 80 )
		Button:SetText( "" )
		Button.Key = k
		Button.Pressed = ( self.Chose or -1 ) == k
		
		Button.DoClick = function( but )
			
			if !self.Chose and !self.MapSelected then
			
				but.Pressed = true
				self:VoteForMap( but.Key )
				gui.EnableScreenClicker( false )
				
			end
			
		end
		
		Button.Paint = function( but, w, h )
			
			-- Background
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,200 ) )
			
			if Data.SplashBlur then
			
				SetCol( Color( 255,255,255,255 ) )
				SetMat( Data.SplashBlur )
				surface.DrawTexturedRectUV( 0, 0, w, w * 0.5625, 0, 0, 1, 1 )
				
			end
			
			draw.RoundedBox( 0, 0, 0, w, h, Color( 20,20,20,150 ) )
			
			
			-- Border
			local Size = 10
			local Highlight = 30
			
			if ( self.Chose and self.Chose != but.Key ) and ( !self.MapSelected or self.MapSelected != but.Key ) then
				
				but.SChose = Lerp( FrameTime() * 10, but.SChose or 0, 1 )
				Size = Lerp( but.SChose, 10, 5 )
				Highlight = Lerp( but.SChose, 10, 2 )
				
			elseif !self.MapSelected or self.MapSelected == but.Key then
				
				local Hover = but:IsHovered()
				but.SHover = Lerp( FrameTime() * 10, but.SHover or 0, Either(Hover,1,0) )
				but.SPress = Lerp( FrameTime() * 20, but.SPress or 0, Either(but.Pressed,1,0) )
				
				if self.MapSelected then
					
					local Time = CurTime() - self.MapSelectedTime
					local Blinker = 1 - math.Round( ( Time*2 )%1 )
					Highlight = 255*Blinker
					Size = 15*Blinker
					
				else
					
					Size = Lerp( but.SPress, Lerp( but.SHover, 10, 15 ), 10 )
					Highlight = Lerp( but.SPress, Lerp( but.SHover, 30, 255 ), 255 )
					
				end
				
				if Data.Splash then
					
					local SplashAlpha = 255 - but.SHover * 255
					SetCol( Color( 255,255,255,SplashAlpha ) )
					SetMat( Data.Splash )
					surface.DrawTexturedRectUV( 0, 0, w, w * 0.5625, 0, 0, 1, 1 )
					
				end
				
			end
			
			draw.RoundedBox( 0, 0, 26, w, 84, Color( 10,10,10,250 ) )
			draw.OutlinedBox( 4, 4, w-8, h-8, Size, Color( 255,255,255,Highlight ), Color( 50,50,50,0 ) )
			draw.OutlinedBox( 0, 0, w, h, 4, COL_BLACK )
			
			-- Map Name
			draw.SimpleText( Data.Map, "MapVoteName", 42, 32, COL_BLACK )
			draw.SimpleText( Data.Map, "MapVoteName", 40, 30, COL_WHITE )
			
			-- Game Type
			local GTText = Data.GameType
			local GT = GetGameTypeByID( Data.GameType )
			
			if GT and GT.Name then GTText = GT.Name end
			draw.SimpleText( GTText, "MapVoteGame", 42, 72, COL_BLACK )
			draw.SimpleText( GTText, "MapVoteGame", 40, 70, Color( 200,200,200,255 ) )
			
		end
		
		Button.PaintOver = function( but, w, h )
			
			if self.Chose and self.Chose != but.Key then
				
				but.SGrey = Lerp( FrameTime() * 10, but.SGrey or 0, 1 )
				local Alpha = Lerp( but.SGrey, 0, 30 )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 150,150,150,Alpha ) )
				
			end
			
		end
		
		--
		-- Vote Counting
		--
		
		local VoteBox = vgui.Create( "DPanel", Button )
		VoteBox:Dock( BOTTOM )
		VoteBox:DockMargin( 30, 0, 30, 30 )
		VoteBox:SetSize( 0, 80 )
		VoteBox:MouseCapture( false )
		VoteBox:SetMouseInputEnabled( false )
		
		VoteBox.Paint = function( vbox, w, h )
			--Data.Votes
			
			SetMat( VoteTick )
			
			local Count = #Data.Votes
			for k,time in pairs( Data.Votes ) do
				
				local Life = CurTime() - ( time or 0 )
				local Alpha = ease( inverselerpclamp( Life, 0, 0.3 ), 2, 0.999 )
				
				SetCol( Color(255,255,255,255*Alpha) )
			
				-- Don't allow ticks to fall off panel, just shink their distances.
				local W = w-30
				local Shrink = math.Clamp( ( Count*30 )/W, 1, 1000 )
				
				local Size = Lerp( Alpha, 100, 40 )
				surface.DrawTexturedRectRotated( (k-1)*30/Shrink + 20, 40, Size, Size, 0 )
				
			end
			
		end
		
		--
		-- Map Description
		--
		
		local Description = vgui.Create( "DLabel", Button )
		Description:Dock( BOTTOM )
		Description:DockMargin( 40, 0, 40, 1 )
		Description:SetSize( 0, 80 )
		Description:MouseCapture( false )
		Description:SetMouseInputEnabled( false )
		
		Description:SetWrap( true )
		Description:SetFont( "MapVoteDesc" )
		Description:SetText( Data.Desc )
		
	end
	
end


function Derma_MapVote:Death()
	
	self.Enabled = false
	gui.EnableScreenClicker( false )
	
	if IsValid( self.Frame ) then
		
		self.Frame:Close()
		
	end
	
end


local function MapSelected( Selection )
	
	gui.EnableScreenClicker( false )
	Derma_MapVote.MapSelected = Selection
	Derma_MapVote.MapSelectedTime = CurTime()
	
end
hook.Add( "MapSelected", "Replicate", MapSelected )

local function MapVoted( Selection )
	
	local Sel = MapChoices[ Selection ]
	table.insert( Sel.Votes, CurTime() )
	
end
hook.Add( "MapVoted", "Replicate", MapVoted )


function Derma_MapVote:VoteForMap( Selection )
	
	self.Chose = Selection
	sendRequest( "VoteMap", { Selection } )
	
end


local function AddMapChoices( Choices )
	
	for k,v in pairs( Choices ) do
		
		local Map, GT = v.Map, v.GameType
		local Data = MapList:GetData()[ Map ]
		
		MapChoices[ k ] = {
		
			Map = Data.Name,
			Desc = Data.Description,
			GameType = GT,
			Votes = {},
			
		}
		
		local Splash = Material( "grapplegunners/maps/" .. Map .. "_splash.png" )
		if !Splash:IsError() then
		
			MapChoices[ k ].Splash = Splash
			
		end
		
		local SplashBlur = Material( "grapplegunners/maps/" .. Map .. "_splashblur.png" )
		if !SplashBlur:IsError() then
		
			MapChoices[ k ].SplashBlur = SplashBlur
			
		end
		
	end
	
	if Derma_MapVote.Enabled then
		
		Derma_MapVote:Init()
		
	end
end
hook.Add( "AddMapChoices", "Replicate", AddMapChoices )