-----------------------------------------------------------------------------
-- Extras (Grimfall edition)
--   * Execute line      : vertical mark on enemy health bars at a set % (off by default)
--   * Cast highlight    : blinking castbar border when an enemy casts a listed spell;
--                         spells interrupted by you or your group are learned automatically
--   * Dispellable arrow : blinking up arrow left of the debuff icons when an enemy has
--                         a magic / enrage buff that can be purged or dispelled
-----------------------------------------------------------------------------
local TidyPlatesThreat = TidyPlatesThreat
local TidyPlates = TidyPlates
local bit_band = bit.band

local AFFIL_GROUP = COMBATLOG_OBJECT_AFFILIATION_MINE + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_RAID
local REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local ARROW_TEXTURE = "Interface\\Buttons\\Arrow-Up-Up"

local function DB()
	return TidyPlatesThreat.db and TidyPlatesThreat.db.profile
end

local function Pulse(t)
	return 0.3 + 0.7 * math.abs(math.sin(t * 5))
end

-------------------------------------------------------------------------------
-- Dispellable (purgeable) enemy buffs
-------------------------------------------------------------------------------
local purgeable = {} -- guid -> { [buffName] = true }

local function KnownPurgeable()
	local g = TidyPlatesThreat.db and TidyPlatesThreat.db.global
	if not g then
		return {}
	end
	g.purgeableBuffs = g.purgeableBuffs or {}
	return g.purgeableBuffs
end

local function IsPurgeType(dispelType)
	return dispelType == "Magic" or dispelType == "Enrage"
end

-- exact data for units with a unit id (target, focus, mouseover)
local function ScanUnit(uid)
	if not UnitExists(uid) or not UnitCanAttack("player", uid) then
		return
	end
	local guid = UnitGUID(uid)
	if not guid then
		return
	end
	local set
	local known = KnownPurgeable()
	for i = 1, 40 do
		local name, _, _, _, dispelType = UnitBuff(uid, i)
		if not name then
			break
		end
		if IsPurgeType(dispelType) then
			set = set or {}
			set[name] = true
			known[name] = true -- learn it, so the combat log can recognize it on other mobs
		end
	end
	purgeable[guid] = set
end

local function HasPurgeable(guid)
	local set = guid and purgeable[guid]
	return set and next(set) ~= nil
end

-------------------------------------------------------------------------------
-- Cast highlight list
-------------------------------------------------------------------------------
local function HighlightList()
	local db = DB()
	if not db then
		return {}
	end
	db.castHighlight.spells = db.castHighlight.spells or {}
	return db.castHighlight.spells
end

function TidyPlatesThreat.AddHighlightSpell(spell, learned)
	if not spell or spell == "" then
		return
	end
	local id = tonumber(spell)
	if id then
		spell = GetSpellInfo(id)
		if not spell then
			return
		end
	end
	local list = HighlightList()
	if not list[spell] then
		list[spell] = true
		if learned and DB().verbose then
			print("|cff89F559Threat Plates|r: learned interruptible spell |cffffd100" .. spell .. "|r (cast highlight).")
		end
	end
end

-------------------------------------------------------------------------------
-- Per-plate decorations
-------------------------------------------------------------------------------
local decor = setmetatable({}, {__mode = "k"}) -- extended -> frames

local function GetDecor(ext)
	local d = decor[ext]
	if d then
		return d
	end
	d = {}
	local bars = ext.bars
	-- execute line
	if bars and bars.healthbar then
		local line = bars.healthbar:CreateTexture(nil, "OVERLAY")
		line:SetTexture(1, 1, 1, 0.9)
		line:SetWidth(2)
		line:Hide()
		d.execute = line
	end
	-- cast highlight border (behind the castbar)
	if bars and bars.castbar then
		local f = CreateFrame("Frame", nil, bars.castbar)
		f:SetFrameLevel(math.max(bars.castbar:GetFrameLevel() - 1, 0))
		f:SetPoint("TOPLEFT", bars.castbar, "TOPLEFT", -3, 3)
		f:SetPoint("BOTTOMRIGHT", bars.castbar, "BOTTOMRIGHT", 3, -3)
		local t = f:CreateTexture(nil, "BACKGROUND")
		t:SetAllPoints(f)
		t:SetTexture(1, 0.15, 0.15, 1)
		f.tex = t
		f:Hide()
		d.cast = f
	end
	-- dispellable arrow
	local arrow = CreateFrame("Frame", nil, ext)
	arrow:SetWidth(16)
	arrow:SetHeight(16)
	arrow:SetFrameLevel(ext:GetFrameLevel() + 5)
	local at = arrow:CreateTexture(nil, "OVERLAY")
	at:SetAllPoints(arrow)
	at:SetTexture(ARROW_TEXTURE)
	at:SetVertexColor(0.3, 0.8, 1)
	arrow.tex = at
	arrow:Hide()
	d.arrow = arrow

	decor[ext] = d
	return d
end

local function IsEnemy(unit)
	return unit and (unit.reaction == "HOSTILE" or unit.reaction == "NEUTRAL")
end

local function PlateGUID(unit)
	if unit.isTarget then
		return UnitGUID("target")
	elseif unit.isMouseover then
		return UnitGUID("mouseover")
	end
	return unit.guid
end

local elapsedTotal, clock = 0, 0
local function UpdatePlates(elapsed)
	clock = clock + elapsed
	elapsedTotal = elapsedTotal + elapsed
	if elapsedTotal < 0.05 then
		return
	end
	elapsedTotal = 0

	local db = DB()
	local visible = TidyPlates and TidyPlates.NameplatesByVisible
	if not (db and visible) then
		return
	end
	local exe, hl, pa = db.executeLine, db.castHighlight, db.purgeArrow
	local pulse = Pulse(clock)
	local list = hl and hl.spells

	for plate in pairs(visible) do
		local ext = plate.extended
		local unit = ext and ext.unit
		if unit then
			local d = GetDecor(ext)
			local enemy = IsEnemy(unit) and ext.stylename ~= "empty" and ext.stylename ~= "text"

			-- execute line
			if d.execute then
				if enemy and exe and exe.ON and (exe.percent or 0) > 0 then
					local hb = ext.bars.healthbar
					local w = hb:GetWidth() or 0
					d.execute:ClearAllPoints()
					d.execute:SetPoint("TOP", hb, "TOPLEFT", w * exe.percent / 100, 0)
					d.execute:SetPoint("BOTTOM", hb, "BOTTOMLEFT", w * exe.percent / 100, 0)
					d.execute:Show()
				else
					d.execute:Hide()
				end
			end

			-- cast highlight
			if d.cast then
				local cb = ext.bars.castbar
				if enemy and hl and hl.ON and cb:IsShown() and unit.isCasting ~= false and unit.spellName and list and list[unit.spellName] then
					d.cast.tex:SetAlpha(pulse)
					d.cast:Show()
				else
					d.cast:Hide()
				end
			end

			-- dispellable arrow
			if enemy and pa and pa.ON and HasPurgeable(PlateGUID(unit)) then
				local dw = ext.widgets and ext.widgets.WidgetDebuff
				d.arrow:ClearAllPoints()
				if dw then
					d.arrow:SetPoint("RIGHT", dw, "LEFT", -2, 0)
				else
					d.arrow:SetPoint("BOTTOM", ext, "TOP", -50, 0)
				end
				d.arrow.tex:SetAlpha(pulse)
				d.arrow:Show()
			else
				d.arrow:Hide()
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------
local driver = CreateFrame("Frame")
driver:SetScript("OnUpdate", function(self, elapsed)
	UpdatePlates(elapsed)
end)

driver:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub, srcGUID, _, srcFlags, dstGUID, _, dstFlags, _, spellName, _, extra1, extra2, extra3 = ...
		local dstEnemy = dstFlags and bit_band(dstFlags, REACTION_FRIENDLY) == 0
		if not dstEnemy then
			return
		end
		if sub == "SPELL_INTERRUPT" then
			-- extra2 = interrupted spell name
			local hl = DB() and DB().castHighlight
			if hl and hl.ON and hl.learn and srcFlags and bit_band(srcFlags, AFFIL_GROUP) > 0 then
				TidyPlatesThreat.AddHighlightSpell(extra2, true)
			end
		elseif sub == "SPELL_AURA_APPLIED" or sub == "SPELL_AURA_REFRESH" then
			-- extra1 = aura type (BUFF / DEBUFF)
			if extra1 == "BUFF" and KnownPurgeable()[spellName] then
				purgeable[dstGUID] = purgeable[dstGUID] or {}
				purgeable[dstGUID][spellName] = true
			end
		elseif sub == "SPELL_AURA_REMOVED" then
			if extra1 == "BUFF" and purgeable[dstGUID] then
				purgeable[dstGUID][spellName] = nil
			end
		elseif sub == "SPELL_DISPEL" or sub == "SPELL_STOLEN" then
			-- extra2 = removed aura name; it was purgeable, so learn it
			if extra2 then
				KnownPurgeable()[extra2] = true
				if purgeable[dstGUID] then
					purgeable[dstGUID][extra2] = nil
				end
			end
		elseif sub == "UNIT_DIED" or sub == "UNIT_DESTROYED" then
			purgeable[dstGUID] = nil
		end
	elseif event == "UNIT_AURA" then
		local uid = ...
		if uid == "target" or uid == "focus" or uid == "mouseover" then
			ScanUnit(uid)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		ScanUnit("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		ScanUnit("mouseover")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		ScanUnit("focus")
	elseif event == "PLAYER_REGEN_ENABLED" then
		wipe(purgeable)
	end
end)
driver:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
driver:RegisterEvent("UNIT_AURA")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
driver:RegisterEvent("PLAYER_REGEN_ENABLED")
