FAdmin.ScoreBoard.Player.Information = {}
FAdmin.ScoreBoard.Player.ActionButtons = {}

local CancelRetrieveAvatar = false
local function GetBigAvatar(content, size)
	if not FAdmin.ScoreBoard.Player.Controls.AvatarBackground or not FAdmin.ScoreBoard.Player.Controls.AvatarBackground:IsVisible() or CancelRetrieveAvatar then
		if FAdmin.ScoreBoard.Player.Controls.AvatarLarge then
			FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(false)
		end
		return
	end
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	local _, firstplace = string.find(content, "<avatarFull><!%[CDATA%[")
	local endplace = string.find(content, "]]></avatarFull>")
	if not firstplace or not endplace then if FAdmin.ScoreBoard.Player.Controls.AvatarLarge then FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(false) end return end
	
	local match = string.sub(content, firstplace + 1, endplace - 1)

	FAdmin.ScoreBoard.Player.Controls.AvatarLarge = FAdmin.ScoreBoard.Player.Controls.AvatarLarge or vgui.Create("HTML")
	FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100)
	FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetSize(213, 218)
	FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(false)
	FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetHTML("<body bgcolor=black> <img SRC=\""..match.."\"/></body>")
	function FAdmin.ScoreBoard.Player.Controls.AvatarLarge:FinishedURL(url)
		if CancelRetrieveAvatar or not FAdmin.ScoreBoard.Player.Controls.AvatarBackground or not FAdmin.ScoreBoard.Player.Controls.AvatarBackground:IsVisible() then
			if FAdmin.ScoreBoard.Player.Controls.AvatarLarge then
				FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(false)
			end
			return
		end
		FAdmin.ScoreBoard.Player.Controls.AvatarLarge.Player = FAdmin.ScoreBoard.Player.Player
		FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(true)
	end
end

function FAdmin.ScoreBoard.Player.Show(ply)
	CancelRetrieveAvatar = false
	local OldPly = FAdmin.ScoreBoard.Player.Player
	ply = ply or FAdmin.ScoreBoard.Player.Player
	FAdmin.ScoreBoard.Player.Player = ply
	
	if not ValidEntity(ply) or not ValidEntity(FAdmin.ScoreBoard.Player.Player) then CancelRetrieveAvatar = true FAdmin.ScoreBoard.ChangeView("Main") return end
	
	local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	local SteamID = ply:SteamID()
	
	FAdmin.ScoreBoard.Player.Controls.AvatarBackground = FAdmin.ScoreBoard.Player.Controls.AvatarBackground or vgui.Create("AvatarImage")
	FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100)
	FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetSize(213, 218)
	FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetPlayer(ply)
	FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetVisible(true)
	
	if FAdmin.ScoreBoard.Player.Controls.AvatarLarge and FAdmin.ScoreBoard.Player.Controls.AvatarLarge:IsValid() and FAdmin.ScoreBoard.Player.Controls.AvatarLarge.Player == ply then
		FAdmin.ScoreBoard.Player.Controls.AvatarLarge:SetVisible(true)
	else
		http.Get(FAdmin.SteamToProfile(SteamID).."?xml=true", "", GetBigAvatar)
	end
	
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1 = FAdmin.ScoreBoard.Player.Controls.InfoPanel1 or vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100 + 218 + 5 /* + Avatar size*/)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetSize(213, ScreenHeight*0.1 + 2)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:EnableVerticalScrollbar()
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:EnableHorizontal(false)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetSpacing(3)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetVisible(true)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel1:Clear(true)
	
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2 = FAdmin.ScoreBoard.Player.Controls.InfoPanel2 or vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetPos(FAdmin.ScoreBoard.X + 25 + 213/*+ Avatar*/, FAdmin.ScoreBoard.Y + 100)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetSize(FAdmin.ScoreBoard.Width - 213 - 30 - 10, 218 + 5 + ScreenHeight*0.1 + 2)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:EnableVerticalScrollbar()
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:EnableHorizontal(true)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetSpacing(3)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetVisible(true)
	FAdmin.ScoreBoard.Player.Controls.InfoPanel2:Clear(true)
	
	local InfoPanels = {}
	local function AddInfoPanel()
		local pan = vgui.Create("FAdminPanelList")
		pan:SetSpacing(3)
		pan:EnableHorizontal(false)
		pan:SetSize(1, FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall())
		FAdmin.ScoreBoard.Player.Controls.InfoPanel2:AddItem(pan)
		
		table.insert(InfoPanels, pan)
		return pan
	end
	
	local SelectedPanel = AddInfoPanel() -- Make first panel to put the first things in
	
	for k, v in pairs(FAdmin.ScoreBoard.Player.Information) do
		local Value = v.func(FAdmin.ScoreBoard.Player.Player)
		--if not Value or Value == "" then return --[[ Value = "N/A" ]] end
		if Value and Value ~= "" then
		
			local Text = vgui.Create("Label")
			Text:SetFont("TabLarge")
			Text:SetText(v.name .. ":  ".. Value)
			Text:SizeToContents()
			Text:SetToolTip("Click to copy "..v.name.." to clipboard")
			Text:SetMouseInputEnabled(true)
			function Text:OnMousePressed(mcode)
				self:SetToolTip(v.name.." copied to clipboard!")
				ChangeTooltip(self)
				SetClipboardText(Value)
				self:SetToolTip("Click to copy "..v.name.." to clipboard")
			end
			
			timer.Create("FAdmin_Scoreboard_text_update_"..v.name, 1, 0, function()
				if not ValidEntity(ply) or not ValidEntity(FAdmin.ScoreBoard.Player.Player) or not ValidPanel(Text) then
					timer.Destroy("FAdmin_Scoreboard_text_update_"..v.name)
					CancelRetrieveAvatar = true
					if FAdmin.ScoreBoard.Visible and (not ValidEntity(ply) or not ValidEntity(FAdmin.ScoreBoard.Player.Player)) then FAdmin.ScoreBoard.ChangeView("Main") end
					return 
				end
				Value = v.func(FAdmin.ScoreBoard.Player.Player)
				if not Value or Value == "" then Value = "N/A" end
				Text:SetText(v.name .. ":  "..Value)
			end)
			
			if (#FAdmin.ScoreBoard.Player.Controls.InfoPanel1.Items*17 + 17) <= FAdmin.ScoreBoard.Player.Controls.InfoPanel1:GetTall() and not v.NewPanel then
				FAdmin.ScoreBoard.Player.Controls.InfoPanel1:AddItem(Text)
			else
				if #SelectedPanel.Items*17 + 17 >= SelectedPanel:GetTall() or v.NewPanel then
					SelectedPanel = AddInfoPanel() -- Add new panel if the last one is full
				end
				SelectedPanel:AddItem(Text)
				if Text:GetWide() > SelectedPanel:GetWide() then
					SelectedPanel:SetWide(Text:GetWide() + 40)
				end
			end
		end
	end
	
	local CatColor = team.GetColor(ply:Team())
	if GAMEMODE.Name == "Sandbox" then
		CatColor = Color(100, 150, 245, 255)
		if ply:Team() == TEAM_CONNECTING then
			CatColor = Color(200, 120, 50, 255)
		elseif ply:IsAdmin() then
			CatColor = Color(30, 200, 50, 255)
		end

		if ply:GetFriendStatus() == "friend" then
			CatColor = Color(236, 181, 113, 255)	
		end
	end
	FAdmin.ScoreBoard.Player.Controls.ButtonCat = FAdmin.ScoreBoard.Player.Controls.ButtonCat or  vgui.Create("FAdminPlayerCatagory")
	FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetLabel("  Player options!")
	FAdmin.ScoreBoard.Player.Controls.ButtonCat.CatagoryColor = CatColor
	FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetSize(FAdmin.ScoreBoard.Width - 40, 100)
	FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100 + FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall() + 5)
	FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetVisible(true)
	
	function FAdmin.ScoreBoard.Player.Controls.ButtonCat:Toggle()
	end
	
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel = FAdmin.ScoreBoard.Player.Controls.ButtonPanel or vgui.Create("FAdminPanelList")
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetSpacing(16)
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:EnableHorizontal(true)
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:EnableVerticalScrollbar(true)
	//FAdmin.ScoreBoard.Player.Controls.ButtonPanel :SetAutoSize(true)
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SizeToContents()
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetVisible(true)
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetSize(0, (ScreenHeight - FAdmin.ScoreBoard.Y - 40) - (FAdmin.ScoreBoard.Y + 100 + FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall() + 5))
	FAdmin.ScoreBoard.Player.Controls.ButtonPanel:Clear()
	
	
	for k,v in ipairs(FAdmin.ScoreBoard.Player.ActionButtons) do
		if v.Visible == true or (type(v.Visible) == "function" and v.Visible(FAdmin.ScoreBoard.Player.Player) == true) then 
			local ActionButton = vgui.Create("FAdminActionButton")
			if type(v.Image) == "string" then
				ActionButton:SetImage(v.Image or "gui/silkicons/exclamation")
			elseif type(v.Image) == "table" then
				ActionButton:SetImage(v.Image[1])
				if v.Image[2] then ActionButton:SetImage2(v.Image[2]) end
			elseif type(v.Image) == "function" then
				local img1, img2 = v.Image(ply)
				ActionButton:SetImage(img1)
				if img2 then ActionButton:SetImage2(img2) end
			else
				ActionButton:SetImage("gui/silkicons/exclamation")
			end
			local name = v.Name
			if type(name) == "function" then name = name(FAdmin.ScoreBoard.Player.Player) end
			ActionButton:SetText(name)
			ActionButton:SetBorderColor(v.color)
			
			function ActionButton:DoClick()
				return v.Action(FAdmin.ScoreBoard.Player.Player, self)
			end
			FAdmin.ScoreBoard.Player.Controls.ButtonPanel:AddItem(ActionButton)
			if v.OnButtonCreated then
				v.OnButtonCreated(FAdmin.ScoreBoard.Player.Player, ActionButton)
			end
		end
	end
	
	FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetContents(FAdmin.ScoreBoard.Player.Controls.ButtonPanel )
end

function FAdmin.ScoreBoard.Player:AddInformation(name, func, ForceNewPanel) -- ForeNewPanel is to start a new column
	table.insert(FAdmin.ScoreBoard.Player.Information, {name = name, func = func, NewPanel = ForceNewPanel})
end

function FAdmin.ScoreBoard.Player:AddActionButton(Name, Image, color, Visible, Action, OnButtonCreated)
	table.insert(FAdmin.ScoreBoard.Player.ActionButtons, {Name = Name, Image = Image, color = color, Visible = Visible, Action = Action, OnButtonCreated = OnButtonCreated})
end

FAdmin.ScoreBoard.Player:AddInformation("Name", function(ply) return ply:Nick() end)
FAdmin.ScoreBoard.Player:AddInformation("SteamID", function(ply) return ply:SteamID() end)
FAdmin.ScoreBoard.Player:AddInformation("Kills", function(ply) return ply:Frags() end)
FAdmin.ScoreBoard.Player:AddInformation("Deaths", function(ply) return ply:Deaths() end)
FAdmin.ScoreBoard.Player:AddInformation("Health", function(ply) return ply:Health() end)
FAdmin.ScoreBoard.Player:AddInformation("Ping", function(ply) return ply:Ping() end)

FAdmin.ScoreBoard.Player:AddInformation("Website", function(ply) return ply:GetWebsite() end, true)
FAdmin.ScoreBoard.Player:AddInformation("Location", function(ply) return ply:GetLocation() end)
FAdmin.ScoreBoard.Player:AddInformation("Email", function(ply) return ply:GetEmail() end)
FAdmin.ScoreBoard.Player:AddInformation("GTalk", function(ply) return ply:GetGTalk() end)
FAdmin.ScoreBoard.Player:AddInformation("MSN", function(ply) return ply:GetMSN() end)
FAdmin.ScoreBoard.Player:AddInformation("AIM", function(ply) return ply:GetAIM() end)
FAdmin.ScoreBoard.Player:AddInformation("XFire", function(ply) return ply:GetXFire() end)

FAdmin.ScoreBoard.Player:AddInformation("Props", function(ply) return ply:GetCount("Props") + ply:GetCount("ragdolls") + ply:GetCount("effects") end, true)
FAdmin.ScoreBoard.Player:AddInformation("HoverBalls", function(ply) return ply:GetCount("hoverballs") end)
FAdmin.ScoreBoard.Player:AddInformation("Thrusters", function(ply) return ply:GetCount("thrusters") end)
FAdmin.ScoreBoard.Player:AddInformation("Balloons", function(ply) return ply:GetCount("balloons") end)
FAdmin.ScoreBoard.Player:AddInformation("Buttons", function(ply) return ply:GetCount("buttons") end)
FAdmin.ScoreBoard.Player:AddInformation("Dynamite", function(ply) return ply:GetCount("dynamite") end)
FAdmin.ScoreBoard.Player:AddInformation("SENTs", function(ply) return ply:GetCount("sents") end)
