--
-- Drawing Wrapper
--

-- Good for fixed size scaling
function sres(x)

	local RES = ( ScrW()+ScrH() ) / 3000
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
	
end

-- Position scaling along X
function sresx(x)

	local RES = ScrW() / 1920
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
end

-- Position scaling along Y
function sresy(x)

	local RES = ScrH()/1080
	
	if x and type( x ) == "number" then
	
		return math.floor( x * RES )
		
	end
	
end

local None = Material( "vgui/white" )

function SetMat( s )
	if !s then
		surface.SetMaterial( None )
	else
		surface.SetMaterial( s )
	end
end

function SetTex( s )
	surface.SetTexture( surface.GetTextureID( s ) )
end

function SetCol( t )
	surface.SetDrawColor( t.r,t.g,t.b,t.a )
end

function DText( t )
	draw.SimpleText( t.t, t.f, sresx(t.x),sresy(t.y), t.c, t.ax, t.ay )
end

function DTextShadow( t,dist )

	if !dist then dist = 2 end
	
	local s = table.Copy( t )
	
	s.x = s.x+dist
	s.y = s.y+dist
	s.c = Color(0,0,0,t.c.a)
	
	DText( s )
	DText( t )
	
end

function DTextSimple( t )
	draw.SimpleText( t.t, t.f,t.x,t.y, t.c, t.ax, t.ay )
end

function DTRectSimple( t )
	surface.DrawTexturedRect(t.x,t.y,t.w,t.h)
end

function DTRectSimpleR( t )
	if !t.r then t.r = 0 end
	surface.DrawTexturedRectRotated(t.x,t.y,t.w,t.h,t.r)
end

function DTRect( t )
	surface.DrawTexturedRect(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h))
end

function DTRectUV( t )
	surface.DrawTexturedRectUV(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h), t.su, t.sv, t.eu, t.ev)
end

function DTRectR( t )
	if !t.r then t.r = 0 end
	surface.DrawTexturedRectRotated(sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.r)
end

function DBoxSimple( t )
	surface.DrawRect( t.x,t.y,t.w,t.h )
end

function DBox( t )
	surface.DrawRect( sresx(t.x),sresy(t.y),sres(t.w),sres(t.h) )
end

function DRBox( t )
	draw.RoundedBox( sres(t.r),sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.c )
end

function DRBoxS( t )
	draw.RoundedBox( sres(t.r),sresx(t.x),sresy(t.y),sres(t.w),sres(t.h),t.c )
end

-- Check for resolution changes
local Sw,Sh = ScrW(),ScrH()

timer.Create( "CheckResolution", 1, 0, function()

	if Sw != ScrW() or Sh != ScrH() then
	
		Sw,Sh = ScrW(),ScrH()
		hook.Run("UpdateScreenRes",Sw,Sh)
		
	end
	
end)

local AvatarRes = { 16, 32, 64, 84, 128, 184 }

function AvatarResolution( Size )

	for k,v in pairs( AvatarRes ) do
	
		if Size <= v then
		
			return v
			
		end
		
	end
	
	return AvatarRes[ table.Count( AvatarRes ) ]
	
end

function string.SortTime( s )
	
	local days = math.floor( s / 86400 )
	local hours = math.floor( (s%86400) / 3600 )
	local minutes = math.floor( (s%3600) / 60 )
	local seconds = math.floor( s%60 )
	
	local T = {
		{ s = "s", t = seconds, a = 0 },
		{ s = "m", t = minutes, a = 60 },
		{ s = "h", t = hours, a = 3600 },
		{ s = "d", t = days, a = 86400 },
	}
	
	local time = ""
	for k,v in pairs( T ) do
		
		if s < v.a then break end
		time = v.t .. v.s .. " " .. time
		
	end
	
	return time
	
end

function draw.OutlinedBox( x, y, w, h, thickness, clr )
	surface.SetDrawColor( clr )
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end