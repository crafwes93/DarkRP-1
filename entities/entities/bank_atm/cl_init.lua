include('shared.lua') 
surface.CreateFont( "MenuItem", 10, 25, true, true, "stid" )
local tidd = "TargetID"
function seebank()
local BZ = vgui.Create( "DFrame" )
BZ:SetSize( 300, 325 )
BZ:SetTitle( "[Bank System]" )
BZ:SetVisible( true )
BZ:SetDraggable( false )
BZ:ShowCloseButton( false )
BZ:Center()
BZ:MakePopup()
BZ:SetSkin("Derma")
local SZ = vgui.Create( "DPropertySheet", BZ )
SZ:SetPos( 5, 20 )
SZ:SetSize( 290, 300 )
SZ.Paint = function() -- The paint function
    surface.SetDrawColor( 125, 37, 49, 125 ) -- What color ( R, B, G, A )
    surface.DrawRect( 0, 0, 290, 300 ) -- How big is it (cords)
		end
local CLZ = vgui.Create( "DButton", BZ )
	CLZ:SetSize( 20, 20 )
	CLZ:SetPos( 275, 1 )
	CLZ:SetText( "X" )
	CLZ.DoClick = function( button )
		datastream.StreamToServer("bankclose")
		BZ:Close()
	end
t1 = vgui.Create("DLabel", BZ)
t1:SetText(LocalPlayer():Nick().."'s Bank".."\n\n    Bank Ballance: "..CUR..tonumber(LocalPlayer():GetNetworkedInt("bank")))
t1:SetColor(Color(15,255,15))
t1:SetPos(45,30)
t1:SetFont("MenuLarge")
t1:SizeToContents()
t2 = vgui.Create("DLabel", BZ)
t2:SetText("Deposit")
t2:SetColor(Color(155,185,112))
t2:SetPos(114,110)
t2:SetFont(tidd)
t2:SizeToContents()
t3 = vgui.Create("DLabel", BZ)
t3:SetText("Withdraw")
t3:SetColor(Color(155,185,112))
t3:SetPos(108,180)
t3:SetFont(tidd)
t3:SizeToContents()
local pout = vgui.Create("TextEntry", BZ)
pout:SetMultiline(false)
pout:SetSize(150,17) 
pout:SetPos(65,157)
local BINS = vgui.Create( "DButton", BZ )
	BINS:SetSize( 80, 20 )
	BINS:SetPos( 100, 135 )
	BINS:SetText( "Deposit" )
	BINS.DoClick = function( button )
	if not tonumber(pout:GetValue()) then LocalPlayer():ChatPrint("You can only enter numbers."); surface.PlaySound( "buttons/button10.wav" ); return end
if LocalPlayer().DarkRPVars.money >= tonumber(pout:GetValue()) then
datastream.StreamToServer("bankclose")
LocalPlayer():ConCommand( "p_1 " .. pout:GetValue() )
surface.PlaySound( "buttons/button14.wav" )
BZ:Close()
	else
LocalPlayer():ChatPrint("You can't afford this."); surface.PlaySound( "buttons/button10.wav" );
	end
end
phcr = vgui.Create("DLabel", BZ)
phcr:SetText("")
phcr:SetColor(Color(155,185,112))
phcr:SetPos(5,307)
phcr:SetFont("stid")
phcr:SizeToContents()
cor1 = vgui.Create("DLabel", BZ)
cor1:SetText(CUR)
cor1:SetColor(Color(1,255,1))
cor1:SetPos(220,153)
cor1:SetFont("TargetID")
cor1:SizeToContents()
cor2 = vgui.Create("DLabel", BZ)
cor2:SetText(CUR)
cor2:SetColor(Color(1,255,1))
cor2:SetPos(220,223)
cor2:SetFont("TargetID")
cor2:SizeToContents()
local pin = vgui.Create("TextEntry", BZ)
pin:SetMultiline(false)
pin:SetSize(150,17) 
pin:SetPos(65,227)
local BANS = vgui.Create( "DButton", BZ )
	BANS:SetSize( 80, 20 )
	BANS:SetPos( 100, 205 )
	BANS:SetText( "Withdraw" )
	BANS.DoClick = function( button )
if not tonumber(pin:GetValue()) then LocalPlayer():ChatPrint("You can only enter numbers."); surface.PlaySound( "buttons/button10.wav" ); return end
if tonumber(LocalPlayer():GetNetworkedInt("bank")) >= tonumber(pin:GetValue()) then
datastream.StreamToServer("bankclose")
LocalPlayer():ConCommand( "p_2 " .. pin:GetValue() )
surface.PlaySound( "buttons/button14.wav" )
BZ:Close()
	else
LocalPlayer():ChatPrint("You can't afford this."); surface.PlaySound( "buttons/button10.wav" );
		end
	end
end
usermessage.Hook("seemybank", seebank)
