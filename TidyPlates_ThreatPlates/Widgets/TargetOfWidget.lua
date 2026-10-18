-----------------------------------------------------------------------------
-- Mob Target Widget: shows who a mob is attacking, e.g. "> Gorbak [T]"
-- Roles: [T] Tank (green), [D] DPS (orange), [H] Healer (red = most dangerous)
-- Letter + color, so it does not rely on color only.
--
-- WoW 3.3.5 does not give a unit id for every nameplate, so the mob's target is
-- known only for mobs that are targeted by you or a group member (or focus /
-- mouseover). For other mobs nothing is shown.
-----------------------------------------------------------------------------
local TidyPlatesThreat = TidyPlatesThreat
local db

local COMM_PREFIX = "TPTPR"
-- Blizzard's standard font with outline + shadow: readable on any background
local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

local victimByGUID = {} -- mob GUID -> name of the unit it attacks
local scratch = {}
local sharedRoles = {} -- player name -> role received from their Threat Plates
local assignedRoles = {} -- player name -> role from raid / LFG assignment
local groupNames = {} -- names of players in my group

-------------------------------------------------------------------------------
-- Roles of group members
-------------------------------------------------------------------------------
local function AssignedRole(unitid)
	if GetPartyAssignment and GetPartyAssignment("MAINTANK", unitid) then
		return "TANK"
	end
	if UnitGroupRolesAssigned then
		-- 3.3.5 returns isTank, isHealer, isDamage; newer clients return a string
		local a, b, c = UnitGroupRolesAssigned(unitid)
		if a == true or a == "TANK" then
			return "TANK"
		elseif b == true or a == "HEALER" then
			return "HEALER"
		elseif c == true or a == "DAMAGER" then
			return "DPS"
		end
	end
end

local function ScanRoster()
	wipe(groupNames)
	wipe(assignedRoles)
	local raid = GetNumRaidMembers()
	if raid > 0 then
		for i = 1, raid do
			local u = "raid" .. i
			local name = UnitName(u)
			if name then
				groupNames[name] = true
				assignedRoles[name] = AssignedRole(u)
			end
		end
	else
		for i = 1, GetNumPartyMembers() do
			local u = "party" .. i
			local name = UnitName(u)
			if name then
				groupNames[name] = true
				assignedRoles[name] = AssignedRole(u)
			end
		end
	end
	-- forget shared roles of players who left
	for name in pairs(sharedRoles) do
		if not groupNames[name] then
			sharedRoles[name] = nil
		end
	end
end

local function RoleOf(name)
	if not name then
		return nil
	end
	if name == UnitName("player") then
		return TidyPlatesThreat:GetRole()
	end
	return sharedRoles[name] or assignedRoles[name]
end

-- As tank: is this mob attacking another (known) tank?
function TidyPlatesThreat.IsTankedByOtherTank(unit)
	local victim = TidyPlatesThreat.GetMobTarget(unit)
	if victim and victim ~= UnitName("player") and RoleOf(victim) == "TANK" then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
-- Role sharing between Threat Plates users (addon messages)
-------------------------------------------------------------------------------
local lastBroadcast = 0
local broadcastPending = false

local function GroupChannel()
	if GetNumRaidMembers() > 0 then
		return "RAID"
	elseif GetNumPartyMembers() > 0 then
		return "PARTY"
	end
end

local function Broadcast()
	local channel = GroupChannel()
	if channel then
		SendAddonMessage(COMM_PREFIX, "R:" .. TidyPlatesThreat:GetRole(), channel)
		lastBroadcast = GetTime()
	end
	broadcastPending = false
end

local function RequestBroadcast()
	broadcastPending = true
end

TidyPlatesThreat.RoleChanged = RequestBroadcast

-------------------------------------------------------------------------------
-- Mob target tracking
-------------------------------------------------------------------------------
local function Track(unitid)
	if UnitExists(unitid) and UnitCanAttack("player", unitid) then
		local guid = UnitGUID(unitid)
		if guid and scratch[guid] == nil then
			scratch[guid] = UnitName(unitid .. "target") or false
		end
	end
end

local function ScanTargets()
	wipe(scratch)
	Track("target")
	Track("focus")
	Track("mouseover")
	Track("pettarget")
	local raid = GetNumRaidMembers()
	if raid > 0 then
		for i = 1, raid do
			Track("raid" .. i .. "target")
			Track("raidpet" .. i .. "target")
		end
	else
		for i = 1, GetNumPartyMembers() do
			Track("party" .. i .. "target")
			Track("partypet" .. i .. "target")
		end
	end

	local changed = false
	for guid, victim in pairs(scratch) do
		if victimByGUID[guid] ~= victim then
			changed = true
		end
	end
	for guid in pairs(victimByGUID) do
		if scratch[guid] == nil then
			changed = true
		end
	end
	if changed then
		wipe(victimByGUID)
		for guid, victim in pairs(scratch) do
			victimByGUID[guid] = victim
		end
	end
	return changed
end

-- Name of the unit the mob on this nameplate is attacking (or nil if unknown)
function TidyPlatesThreat.GetMobTarget(unit)
	local victim
	if unit.isTarget then
		victim = UnitName("targettarget")
	elseif unit.isMouseover then
		victim = UnitName("mouseovertarget")
	elseif unit.guid then
		victim = victimByGUID[unit.guid]
	end
	return victim or nil
end

-------------------------------------------------------------------------------
-- Event / update driver
-------------------------------------------------------------------------------
local driver = CreateFrame("Frame")
local elapsedScan = 0
local dirty = false

driver:SetScript("OnUpdate", function(self, elapsed)
	elapsedScan = elapsedScan + elapsed
	-- scan often in combat, rarely out of combat
	local interval = (InCombatLockdown() and 0.25) or 1
	if elapsedScan >= interval then
		elapsedScan = 0
		if ScanTargets() then
			dirty = true
		end
		if dirty and TidyPlates and TidyPlates.Update then
			dirty = false
			TidyPlates:Update()
		end
	end
	if broadcastPending and GetTime() - lastBroadcast > 3 then
		Broadcast()
	end
end)

driver:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if prefix == COMM_PREFIX and sender and sender ~= UnitName("player") then
			local role = message and message:match("^R:(%u+)$")
			if role == "TANK" or role == "DPS" or role == "HEALER" then
				if sharedRoles[sender] ~= role then
					sharedRoles[sender] = role
					dirty = true
				end
			end
		end
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		ScanRoster()
		RequestBroadcast()
		dirty = true
	elseif event == "UNIT_TARGET" or event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" then
		elapsedScan = 1 -- rescan on the next frame
	end
end)
driver:RegisterEvent("CHAT_MSG_ADDON")
driver:RegisterEvent("PARTY_MEMBERS_CHANGED")
driver:RegisterEvent("RAID_ROSTER_UPDATE")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("UNIT_TARGET")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

-------------------------------------------------------------------------------
-- Nameplate widget
-------------------------------------------------------------------------------
local function UpdateTargetOfWidget(frame, unit)
	db = TidyPlatesThreat.db.profile
	local cfg = db.targetOfWidget
	if not (cfg and cfg.ON) or unit.reaction == "FRIENDLY" or not (unit.isInCombat or InCombatLockdown()) then
		frame:Hide()
		return
	end

	local victim = TidyPlatesThreat.GetMobTarget(unit)
	-- only show when the mob attacks me, my pet or a group member
	if not victim or not (victim == UnitName("player") or groupNames[victim] or victim == UnitName("pet")) then
		frame:Hide()
		return
	end

	local role = (victim ~= UnitName("pet")) and RoleOf(victim) or nil
	local text = "> " .. victim
	if role then
		text = text .. " [" .. TidyPlatesThreat.ROLE_LETTER[role] .. "]"
		local c = TidyPlatesThreat.ROLE_COLOR[role]
		frame.Text:SetTextColor(c.r, c.g, c.b)
	else
		frame.Text:SetTextColor(1, 1, 1)
	end

	if frame.size ~= cfg.size then
		frame.Text:SetFont(FONT, cfg.size, "OUTLINE")
		frame.size = cfg.size
	end
	frame.Text:SetText(text)
	frame:Show()
end

local function CreateTargetOfWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(220)
	frame:SetHeight(16)
	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetAllPoints(frame)
	frame.Text:SetJustifyH("CENTER")
	frame.Text:SetFont(FONT, 11, "OUTLINE")
	frame.Text:SetShadowColor(0, 0, 0, 1)
	frame.Text:SetShadowOffset(1, -1)
	frame.size = 11
	frame:Hide()
	frame.Update = UpdateTargetOfWidget
	return frame
end

ThreatPlatesWidgets.CreateTargetOfWidget = CreateTargetOfWidget
