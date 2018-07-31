Derma_Scoreboard = Derma( true )
Derma_Scoreboard.Enabled = false
-- On Creation
function Derma_Scoreboard:Init()
	
	self.Enabled = true
	self.SpawnTime = CurTime()
	gui.EnableScreenClicker( true )
	
	hook.Add( "PreDrawHUD", "ToyTownBlur", function()
		
		if render.SupportsPixelShaders_2_0() then
			
			local Alpha = math.Clamp( ( CurTime() - self.SpawnTime )*10, 0, 1 )
			DrawToyTown( Alpha * 4, ScrH() )
			
		end
		
	end )
	
	self.Frame = vgui.Create( "DFrame" )
	self.Frame:SetPos( ScrW()*0.38, 0 )
	self.Frame:SetSize( ScrW()*0.6, ScrH() )
	self.Frame:SetTitle( "" )
	self.Frame:SetVisible( true )
	self.Frame:SetDraggable( false )
	self.Frame:ShowCloseButton( false )
	
	self.Frame.Paint = function( frame, w, h )
		
		--
		-- Background
		--
		
		local Alpha = math.Clamp( ( CurTime() - self.SpawnTime )*5, 0, 1 )
		local Alpha2 = math.Clamp( ( CurTime() - self.SpawnTime )*2, 0, 1 )
		local Alpha2Ease = ease( Alpha2, 2, 0 )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,Lerp( Alpha, 0, 200 )) )
		
		local SideWidth = math.ceil( Lerp( Alpha2Ease, 0, w*0.03 ) )
		local SideColour = Color( 255, 255, 255, Lerp( Alpha2Ease, 0, 10 ) )
		draw.RoundedBox( 0, 0, 0, SideWidth, h, SideColour )
		draw.RoundedBox( 0, w - SideWidth, 0, SideWidth, h, SideColour )
		
		--
		-- Header
		--
		
		draw.SimpleText( "Grapple Gunners", "ScoreboardTitle", w*0.5, 10, COL_WHITE, 1 )
		
		draw.RoundedBox( 0, 0, 100, w, 44, Color(0,0,0,150) )
		draw.SimpleText( "Name", "ScoreboardText1", w*0.08, 122, COL_WHITE, 0, 1 )
		draw.SimpleText( "Cash", "ScoreboardText1", w*0.75, 122, COL_WHITE, 1, 1 )
		draw.SimpleText( "Ping", "ScoreboardText1", w*0.95, 122, COL_WHITE, 2, 1 )
		
		--
		-- GameType Columns
		--
		
		if CurrentGameType then
			
			local ScoreCount = #CurrentGameType.Scores
			
			for k,v in pairs( CurrentGameType.Scores ) do
			
				local spread = 0.3 / ScoreCount
				local pos = w * ( 0.35 + (k-0.5) * spread )
				draw.SimpleText( v.Name, "ScoreboardText1", pos, 122, COL_WHITE, 1, 1 )
				
			end
			
		end
		
	end
	
	
	--
	-- Scroll Panel
	--
	
	local FPad = self.Frame:GetWide()*0
	
	self.Scroll = vgui.Create( "DScrollPanel", self.Frame )
	self.Scroll:Dock( FILL )
	self.Scroll:DockMargin( -5, 120, -5, 0 )
	
	-- Side Bar
	local sbar = self.Scroll:GetVBar()
	sbar:SetSize( FPad*0.75 )
	
	function sbar:Paint( w, h ) end
	
	function sbar.btnUp:Paint( w, h )
	
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0,0,0,100 ) )
		
	end
	
	sbar.btnDown.Paint = sbar.btnUp.Paint
	
	function sbar.btnGrip:Paint( w, h )
	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,150 ) )
		
	end
	
	
	--
	-- Player List
	--
	
	local Players
	
	if CurrentGameType then
	
		Players = CurrentGameType:SortedPlayers()
		
	else
	
		Players = player.GetAll()
		
	end
	
	for i,ply in pairs( Players ) do
	
		local PlyRow = self.Scroll:Add( "DButton" )
		PlyRow:SetSize( 0, 54 )
		PlyRow:SetText( "" )
		PlyRow:Dock( TOP )
		PlyRow:DockMargin( FPad, 0, FPad, 4 )
		PlyRow.Ply = ply
		
		function PlyRow:DoClick()
		
			Derma_Stats:SelectPlayer( ply )
		
		end
		
		local Avatar = vgui.Create( "AvatarImage", PlyRow )
		Avatar:SetSize( 50, 50 )
		Avatar:SetPos( 2+8, 2 )
		Avatar:SetPlayer( ply, 64 )
		Avatar:MouseCapture( false )
		Avatar:SetMouseInputEnabled( false )
		
		-- Per player bars
		local Colour
		local Font = "ScoreboardText2"
		
		if i == 1 then 
		
			Colour = Color(50,150,255,200)
			Font = "ScoreboardLeader"
			
		elseif i == 2 then 
		
			Colour = Color(100,200,100,100)
			Font = "Scoreboard2nd"
			
		elseif i == 3 then 
			
			Colour = Color(180,70,50,100)
			Font = "Scoreboard3rd"
			
		else 
			
			Colour = LerpColor( inverselerp( i, 4, #Players ), Color(60,30,20,200), Color(20,20,0,200) )
			
		end
		
		
		function PlyRow:Paint( w, h )
			
			-- Background
			draw.RoundedBox( 0, 0, h*0.05, w, h*0.9, Colour )
			draw.RoundedBox( 1, 8, 0, 54, 54, Color( 100,100,100,220 ) )
			
			-- Text
			draw.SimpleText( ply:Name(), Font, w*0.08, h*0.5, COL_WHITE, 0, 1 )
			
			local Amount = 0
			
			draw.SimpleText( Amount, Font, w*0.75, h*0.5, COL_WHITE, 1, 1 )
			
			draw.SimpleText( ply:Ping(), Font, w*0.95, h*0.5, COL_WHITE, 2, 1 )
			
			if CurrentGameType then
				
				local ScoreCount = #CurrentGameType.Scores
			
				for k,v in pairs( CurrentGameType.Scores ) do
				
					local spread = 0.3 / ScoreCount
					local pos = w * ( 0.35 + (k-0.5) * spread )
					draw.SimpleText( v.Getter( ply ), Font, pos, h*0.5, COL_WHITE, 1, 1 )
					
				end
				
			end
			
		end
		
	end

end

-- On Death
function Derma_Scoreboard:Death()
	
	self.Enabled = false
	gui.EnableScreenClicker( false )

	if IsValid( self.Frame ) then
	
		self.Frame:Close()
		
	end
	
	hook.Remove( "PreDrawHUD", "ToyTownBlur" )
	
end

--
-- Show/Hide
--

function GM:ScoreboardShow()
	
	CurrentGameplayHud:SetHidden( true )
	HUD_Scoreboard:SetHidden( false )
	
end

function GM:ScoreboardHide()

	HUD_Scoreboard:SetHidden( true )
	CurrentGameplayHud:SetHidden( false )
	
end