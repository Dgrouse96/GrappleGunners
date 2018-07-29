Derma_Stats = Derma( true )
Derma_Stats.Enabled = false
Derma_Stats.StatScroll = 0

Derma_Stats.StatList = {

	{ Name = "Global" },
	{
		Name = "Games Played",
		Tooltip = "Total games played",
		StatTotal = S_Completed,
	},
	{
		Name = "Wins",
		Tooltip = "Total wins",
		StatTotal = S_Wins,
	},
	{
		Name = "Kills",
		Tooltip = "Total kills",
		StatTotal = S_Kills,
	},
	{
		Name = "Deaths",
		Tooltip = "Total deaths",
		StatTotal = S_Deaths,
	},
	{
		Name = "Play Time",
		Tooltip = "Total time playing",
		Getter = function( ply )
		
			if PlayTime then return PlayTime:GetTotalPlayTime( ply, true ) end return 0
			
		end,
	},
	
	{}, ----------------------------------------------
	
	{ Name = "FFA" },
	{
		Name = "Games Played",
		Tooltip = "FFA games fully played",
		Stat = S_Completed,
		GameType = "FFA",
	},
	{
		Name = "Wins",
		Tooltip = "FFA wins",
		Stat = S_Wins,
		GameType = "FFA",
	},
	{
		Name = "Kills",
		Tooltip = "Kills in FFA",
		Stat = S_Kills,
		GameType = "FFA",
	},
	{
		Name = "Deaths",
		Tooltip = "Deaths in FFA",
		Stat = S_Deaths,
		GameType = "FFA",
	},
	{
		Name = "Play Time",
		Tooltip = "Total time playing FFA",
		Getter = function( ply )
		
			if PlayTime then return PlayTime:GetPlayTime( ply, GAMETYPE_FFA, true ) end return 0
			
		end,
	},
	
	{}, ----------------------------------------------
	
	{ Name = "Pizza Time" },
	{
		Name = "Shifts taken",
		Tooltip = "Pizza Time games fully played",
		Stat = S_Completed,
		GameType = "PizzaTime",
	},
	{
		Name = "Employee of the Month",
		Tooltip = "Pizza Time wins",
		Stat = S_Wins,
		GameType = "PizzaTime",
	},
	{
		Name = "Pizzas Delivered",
		Tooltip = "Pizzas delivered",
		Stat = S_Kills,
		GameType = "PizzaTime",
	},
	{
		Name = "Pizzas Ruined",
		Tooltip = "Pizzas ruined",
		Stat = S_Deaths,
		GameType = "PizzaTime",
	},
	{
		Name = "Play Time",
		Tooltip = "Total time playing Pizza Time",
		Getter = function( ply )
		
			if PlayTime then return PlayTime:GetPlayTime( ply, 2, true ) end return 0
			
		end,
	},
	
	{}, ----------------------------------------------
}


function Derma_Stats:Init()
	
	if !self.Enabled then return end
	
	if IsValid( self.Frame ) then
		self.Frame:Close()
	end

	self.SpawnTime = CurTime()
	local ply = self.ply
	
	--
	-- Frame
	--
	
	self.Frame = vgui.Create( "DFrame" )
	self.Frame:SetPos( ScrW()*0.04, ScrH()*0.55 )
	self.Frame:SetSize( ScrW()*0.3, ScrH()*0.4 )
	self.Frame:SetTitle( "" )
	self.Frame:SetVisible( true )
	self.Frame:SetDraggable( false )
	self.Frame:ShowCloseButton( false )
	
	self.Frame.Paint = function( frame, w, h )
		
		local Alpha = math.Clamp( ( CurTime() - self.SpawnTime )*5, 0, 1 )
		local Scale = Lerp( Alpha, 0.8, 1 )
		
		-- Background
		draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,Lerp( Alpha, 0, 200 )) )
		draw.OutlinedBox( 0, 0, w, h, Lerp( Alpha, 0, 20 ), Color(255,255,255,10) )
		draw.RoundedBox( 2, 8, 8, 108, 108, Color(150,150,150,100) )
		
		-- Header
		draw.SimpleText( ply:Name(), "StatsHeader", 122, 25, COL_WHITE )
		draw.SimpleText( "Rookie", "StatsSubHeader", 122, 60, Color(150,150,150) )
		
		-- Add user group colours here
		draw.SimpleText( ply:GetUserGroup(), "StatsSubHeader2", 122, 90, Color(150,150,100,150) )
		
	end
	
	--
	-- Avatar
	--
	
	local Avatar = vgui.Create( "AvatarImage", self.Frame )
	Avatar:SetSize( 100, 100 )
	Avatar:SetPos( 12, 12 )
	Avatar:SetPlayer( ply, 128 )
	
	self.sheet = vgui.Create( "DPropertySheet", self.Frame )
	local sheet = self.sheet -- convenience
	
	sheet:Dock( FILL )
	sheet:DockMargin( 14, 100, 14, 14 )
	
	sheet.Paint = function( prop, w, h ) end
	
	--
	-- Player Stats
	--
	
	local Stats = vgui.Create( "DPanel", sheet )
	Stats.Paint = function( stats, w, h ) 
	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		draw.OutlinedBox( 0, 0, w, h, 10, Color(255,255,255,10) )
		
	end
	sheet:AddSheet( "Stats", Stats )
	
	-- Scroll bar
	local Scroll = vgui.Create( "DScrollPanel", Stats )
	Scroll:Dock( FILL )
	Scroll:DockMargin( 0, 10, -5, 10 )
	
	-- Side Bar
	self.sbar = Scroll:GetVBar()
	
	
	function self.sbar:Paint( w, h ) end
	function self.sbar.btnUp:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,100 ) ) end
	self.sbar.btnDown.Paint = self.sbar.btnUp.Paint
	function self.sbar.btnGrip:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,150 ) ) end
	
	--
	-- Stat List
	--
	
	local i = 0
	for k,v in pairs( self.StatList ) do
		
		i = i+1
		
		local Panel = vgui.Create( "DPanel", Scroll )
		Panel:Dock( TOP )
		Panel:DockMargin( 10, 2, 10, 0 )
		
		if v.Tooltip then
		
			Panel:SetTooltip( v.Tooltip )
			
		end
		
		Panel.Paint = function( pan, w, h )
			
			local Font = "StatsCategory"
			local Amount = 0
			local IsData = true
			
			if v.StatTotal then Amount = v.StatTotal:GetTotal( ply )
			elseif v.Stat then Amount = v.Stat:GetData( ply, v.GameType ) 
			elseif v.Getter then Amount = v.Getter( ply )
			else IsData = false end
			
			if IsData then
				draw.RoundedBox( 4, 0, 0, w, h, Color( 0,0,0,100 ) )
				draw.SimpleText( Amount, "StatsStat", w-30, h*0.5, Color(255,255,255,100), 2, 1 )
				Font = "StatsStat"
			end
			
			if v.Name then
				draw.SimpleText( v.Name, Font, 20, h*0.5, COL_WHITE, 0, 1 )
			end
			
		end
		
		
		
	end
	
	self.sbar:SetScroll( self.StatScroll )
	
	
	--
	-- Achievements
	--
	
	local Ach = vgui.Create( "DPanel", sheet )
	Ach.Paint = function( stats, w, h )
	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) ) 
		draw.OutlinedBox( 0, 0, w, h, 10, Color(255,255,255,10) )
		
	end
	sheet:AddSheet( "Achievements", Ach )
	
	-- Scroll bar
	local Scroll2 = vgui.Create( "DScrollPanel", Ach )
	Scroll2:Dock( FILL )
	Scroll2:DockMargin( 0, 10, -5, 10 )
	
	-- Side Bar
	self.sbar2 = Scroll2:GetVBar()
	
	
	function self.sbar2:Paint( w, h ) end
	function self.sbar2.btnUp:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,100 ) ) end
	self.sbar2.btnDown.Paint = self.sbar2.btnUp.Paint
	function self.sbar2.btnGrip:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,150 ) ) end
	
	for k,v in pairs( AchievementReg ) do

		i = i+1
		
		local Panel = vgui.Create( "DPanel", Scroll2 )
		Panel:Dock( TOP )
		Panel:DockMargin( 10, 4, 10, 0 )
		Panel:SetSize( 0, 44 )
		
		Panel.Paint = function( pan, w, h )
			
			local Prog = v:GetProgress( ply ) or 0
			local ProgColour = LerpColor( Prog, Color( 140,50,50,50 ), Color( 255,170,80,150 ) )
			local Data = v:GetData( ply )
			
			if Data.Completed then
				
				Prog = 1
				ProgColour = Color( 100,150,255,150 )
				
			end
			
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0,0,0,100 ) )
			draw.RoundedBox( 4, 0, 0, w * Prog, h, ProgColour )
			draw.SimpleText( v.Name, "Achievment", 20, h*0.3, COL_WHITE, 0, 1 )
			draw.SimpleText( v.Description, "AchievmentDesc", 20, h*0.7, Color(200,200,200,255), 0, 1 )
			
			if !Data.Completed then
				
				local ProgText = v:GetProgressText( ply ) or ""
				draw.SimpleText( ProgText, "AchievmentProgress", w - 10, h*0.5, Color(200,200,200,255), 2, 1 )
				
			end
			
		end
	
	end
	
	--
	-- Paint Tabs
	--
	
	for k,v in pairs( sheet:GetItems() ) do
		
		v.Tab.Paint = function( tab, w, h )
		
			local C = Either( v.Tab:IsActive(), Color( 100,100,100,100 ), Color( 0,0,0,100 ) )
			draw.RoundedBox( 0, 0, 0, w, h, C )
			
		end
		
	end
	
	if self.CurrentTab then
		
		sheet:SwitchToName( self.CurrentTab )
		
	end

	
end


function Derma_Stats:Death()
	
	if IsValid( self.Frame ) then
	
		self.StatScroll = self.sbar:GetScroll()
		
		for k,v in pairs( self.sheet:GetItems() ) do
			
			if v.Tab == self.sheet:GetActiveTab() then

				self.CurrentTab = v.Name
			
			end
			
		end

		self.Frame:Close()
		
	end
	
end


function Derma_Stats:SelectPlayer( ply )
	
	if ply != self.ply then
	
		self.Enabled = true
		self.ply = ply
		self:Death()
		self:SetHidden( false )
	
	else
		
		self.Enabled = false
		self.ply = nil
		self:SetHidden( true )
		
	end
end