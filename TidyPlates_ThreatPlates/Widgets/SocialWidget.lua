-- Friends & Guild icon: small icon on the nameplates of your friends and guild members
local f = CreateFrame("frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("FRIENDLIST_UPDATE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")

--local
local weaktable = TidyPlatesUtility.weaktable
local ListTable = {}
ListTable.g = setmetatable({}, weaktable)
ListTable.f = setmetatable({}, weaktable)
local eventsRegistered = true

local function EventHandler(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		ShowFriends()
		if IsInGuild() then
			GuildRoster()
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		wipe(ListTable.g)
		for i = 1, GetNumGuildMembers() do
			local name = select(1, GetGuildRosterInfo(i))
			tinsert(ListTable.g, name)
		end
	elseif event == "FRIENDLIST_UPDATE" then
		wipe(ListTable.f)
		local friendsTotal, friendsOnline = GetNumFriends()
		for i = 1, friendsOnline do
			local name = select(1, GetFriendInfo(i))
			tinsert(ListTable.f, name)
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...) EventHandler(self, event, ...) end)

local path = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\SocialWidget\\"

local function UpdateSocialWidget(frame, unit)
	local db = TidyPlatesThreat.db.profile.socialWidget
	if db.ON then
		if tContains(ListTable.f, unit.name) then
			frame.Icon:SetTexture(path .. "friendicon")
			frame:Show()
		elseif tContains(ListTable.g, unit.name) then
			frame.Icon:SetTexture(path .. "guildicon")
			frame:Show()
		else
			frame:Hide()
		end
		f:SetScript("OnEvent", function(self, event, ...) EventHandler(self, event, ...) end)
	else
		frame:Hide()
		f:SetScript("OnEvent", nil)
	end
end
local function CreateSocialWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(32)
	frame:SetWidth(32)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateSocialWidget
	return frame
end

ThreatPlatesWidgets.CreateSocialWidget = CreateSocialWidget