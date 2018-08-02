--
-- Generic Timer
--

Widget_Timer = Widget()
Widget_Timer.StartTime = 0
Widget_Timer.Length = 0

Widget_Timer.Text = { 
	t = "0",
	x = 960, 
	y = 50, 
	f = "Timer",
	ax = 1,
	ay = 1,
	c = COL_WHITE,
}


function Widget_Timer:Think()
	
	local TimeLeft = self.Length - ( CurTime() - self.StartTime )
	TimeLeft = math.Clamp( math.ceil( TimeLeft ), 0, self.Length )
	
	if TimeLeft <= 0 then
		
		self.Text.t = "0"
		
	else
	
		self.Text.t = tostring( TimeLeft )
		
	end

end


function Widget_Timer:Draw()
	
	if self.Length > 0 then
	
		DTextShadow( self.Text, 1 )
		
	end
	
end


function GrabTime( Length, StartTime )
	
	Widget_Timer.StartTime = StartTime
	Widget_Timer.Length = Length
	Widget_Timer:SetHidden( false )
	
end
hook.Add( "SetTimerTime", "Replication", GrabTime )