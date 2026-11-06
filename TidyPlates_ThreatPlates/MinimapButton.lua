-----------------------------------------------------------------------------
-- Minimap button
--   Left click      : role DPS
--   Middle click    : role Tank
--   Right click     : role Healer
--   Alt+right click : open the options
--   Drag            : move the button around the minimap
-- The icon shows the current role.
-----------------------------------------------------------------------------
local TidyPlatesThreat = TidyPlatesThreat

local ROLE_ICON = {
	TANK = "Interface\\Icons\\Ability_Defend",
	DPS = "Interface\\Icons\\Ability_DualWield",
	HEALER = "Interface\\Icons\\Spell_Holy_FlashHeal"
}

local button

local function GetSettings()
	local profile = TidyPlatesThreat.db.profile
	profile.minimap = profile.minimap or {}
	if profile.minimap.angle == nil then
		profile.minimap.angle = 225
	end
	return profile.minimap
end

local function UpdatePosition()
	local angle = math.rad(GetSettings().angle or 225)
	local radius = (Minimap:GetWidth() / 2) + 10
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function OnDragUpdate(self)
	local mx, my = Minimap:GetCenter()
	local scale = Minimap:GetEffectiveScale()
	local cx, cy = GetCursorPosition()
	cx, cy = cx / scale, cy / scale
	GetSettings().angle = math.deg(math.atan2(cy - my, cx - mx)) % 360
	UpdatePosition()
end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("Threat Plates")
	local text = "Role: " .. TidyPlatesThreat:roleText()
	if not TidyPlatesThreat.db.char.roleChosen then
		text = text .. " |cffFF3333(default, not chosen yet)|r"
	end
	GameTooltip:AddLine(text, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffeda55fLeft click:|r DPS", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffeda55fMiddle click:|r Tank", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffeda55fRight click:|r Healer", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffeda55fAlt+right click:|r options", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffeda55fDrag:|r move this button", 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

function TidyPlatesThreat:UpdateMinimapButton()
	if not button then
		return
	end
	if GetSettings().hide then
		button:Hide()
		return
	end
	button.icon:SetTexture(ROLE_ICON[self:GetRole()] or ROLE_ICON.DPS)
	UpdatePosition()
	button:Show()
	if GameTooltip:IsOwned(button) then
		ShowTooltip(button)
	end
end

local function CreateButton()
	button = CreateFrame("Button", "TidyPlatesThreatMinimapButton", Minimap)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:SetWidth(31)
	button:SetHeight(31)
	button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetWidth(20)
	background:SetHeight(20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetWidth(17)
	icon:SetHeight(17)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icon:SetPoint("TOPLEFT", 7, -6)
	button.icon = icon

	button:SetScript("OnClick", function(self, mouse)
		if mouse == "RightButton" and IsAltKeyDown() then
			TidyPlatesThreat:OpenOptions()
		elseif mouse == "RightButton" then
			TidyPlatesThreat:SetRole("HEALER")
		elseif mouse == "MiddleButton" then
			TidyPlatesThreat:SetRole("TANK")
		else
			TidyPlatesThreat:SetRole("DPS")
		end
	end)
	button:SetScript("OnDragStart", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", OnDragUpdate)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnEnter", ShowTooltip)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	TidyPlatesThreat:UpdateMinimapButton()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	CreateButton()
end)
