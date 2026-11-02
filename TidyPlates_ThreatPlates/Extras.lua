-----------------------------------------------------------------------------
-- Extras (Grimfall edition)
--   * Execute line      : vertical mark on enemy health bars at a set % (off by default)
--   * Cast highlight    : blinking castbar border when an enemy casts a listed spell;
--                         spells interrupted by you or your group are learned automatically
--   * Dispellable arrow : blinking up arrow left of the debuff icons when an enemy has
--                         a magic / enrage buff that can be purged or dispelled
--   * Enemy healers     : big heal icon above enemy healers. Players: in battlegrounds and
--                         arenas; NPCs: everywhere. A unit counts as healer after healing
--                         others 3 times (the client has no role info for enemies).
--   * Threat %          : threat number above the health bar of your target / mouseover /
--                         focus (the game gives numbers only for these). DPS / Healer: how
--                         close you are to pulling (100% = you pull); Tank: own threat,
--                         100% = the mob is on you, lower = someone else has it.
--   * Quest mobs        : yellow "!" with the progress (3/10) on mobs you still need for a
--                         quest: kill objectives from the quest log, item drop mobs learned
--                         from tooltips (any line naming an objective / quest) and from loot.
-----------------------------------------------------------------------------
local TidyPlatesThreat = TidyPlatesThreat
local TidyPlates = TidyPlates
local bit_band = bit.band

local AFFIL_GROUP = COMBATLOG_OBJECT_AFFILIATION_MINE + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_RAID
local REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local ARROW_TEXTURE = "Interface\\Buttons\\Arrow-Up-Up"
local HEALER_TEXTURE = "Interface\\Icons\\Spell_Holy_FlashHeal"
local REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC

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
-- Enemy healers
-------------------------------------------------------------------------------
local HEALS_NEEDED = 3 -- heals on others before a unit counts as healer
local HEAL_THROTTLE = 1 -- seconds; one AoE heal / proc hitting many targets counts once
-- heals that also come from damage dealers (procs, passive group heals)
local NOT_HEALER_SPELLS = {
	["Vampiric Embrace"] = true,
	["Judgement of Light"] = true,
	["Judgement of Wisdom"] = true,
	["Improved Leader of the Pack"] = true,
	["Blood Craze"] = true,
	["Spirit Link"] = true
}
local healCount, lastHeal, healers = {}, {}, {} -- name -> count / time / true

local function ShortName(name)
	return name and (string.match(name, "^([^%-]+)") or name)
end

local function InPvPInstance()
	local _, iType = IsInInstance()
	return iType == "pvp" or iType == "arena"
end

local function ResetHealers()
	wipe(healCount)
	wipe(lastHeal)
	wipe(healers)
end

local function OnEnemyHeal(srcGUID, srcName, srcFlags, dstGUID, dstFlags, spellName)
	local db = DB()
	local eh = db and db.enemyHealers
	if not (eh and eh.ON) or not srcName or not srcFlags or srcGUID == dstGUID then
		return
	end
	-- an enemy healing another enemy (its ally)
	if bit_band(srcFlags, REACTION_HOSTILE) == 0 or not dstFlags or bit_band(dstFlags, REACTION_HOSTILE) == 0 then
		return
	end
	if NOT_HEALER_SPELLS[spellName] then
		return
	end
	if bit_band(srcFlags, TYPE_PLAYER) > 0 then
		if not InPvPInstance() then
			return
		end
	elseif bit_band(srcFlags, TYPE_NPC) > 0 then
		if not eh.npcs then
			return
		end
	else
		return -- pets, guardians, totems
	end
	local name = ShortName(srcName)
	if healers[name] then
		return
	end
	local now = GetTime()
	if lastHeal[name] and now - lastHeal[name] < HEAL_THROTTLE then
		return
	end
	lastHeal[name] = now
	healCount[name] = (healCount[name] or 0) + 1
	if healCount[name] >= HEALS_NEEDED then
		healers[name] = true
	end
end

function TidyPlatesThreat.IsEnemyHealer(name)
	return name and healers[ShortName(name)] or false
end

-------------------------------------------------------------------------------
-- Threat %
-------------------------------------------------------------------------------
local function PlateUnitId(unit)
	if unit.isTarget then
		return "target"
	elseif unit.isMouseover then
		return "mouseover"
	end
	-- focus: same name and same health as the plate
	if UnitExists("focus") and UnitName("focus") == unit.name and UnitHealth("focus") == unit.health then
		return "focus"
	end
end

-- returns text, r, g, b (nil = nothing to show)
local function ThreatText(unit)
	local uid = PlateUnitId(unit)
	if not uid or not UnitAffectingCombat(uid) then
		return
	end
	local isTanking, _, pct = UnitDetailedThreatSituation("player", uid)
	if TidyPlatesThreat:GetRole() == "TANK" then
		-- tank: own threat. 100% white = the mob is on you; below 100% someone else has it:
		-- orange from 90% (you take it back soon), yellow from 70%, red below
		if isTanking then
			return "100%", 1, 1, 1
		elseif not pct then
			return
		end
		pct = math.floor(pct + 0.5)
		if pct >= 90 then
			return pct .. "%", 1, 0.6, 0.1
		elseif pct >= 70 then
			return pct .. "%", 1, 1, 0.2
		end
		return pct .. "%", 1, 0.2, 0.2
	end
	if not pct then
		return
	end
	pct = math.floor(pct + 0.5)
	if isTanking or pct >= 90 then
		return pct .. "%", 1, 0.2, 0.2
	elseif pct >= 70 then
		return pct .. "%", 1, 0.6, 0.1
	end
	return pct .. "%", 1, 1, 1
end

-------------------------------------------------------------------------------
-- Quest mobs
-------------------------------------------------------------------------------
local QUEST_TEXTURE = "Interface\\GossipFrame\\AvailableQuestIcon"
local MIN_MATCH_LEN = 4 -- objective / quest names shorter than this are not matched in tooltips
local questObjectives = {} -- list of objectives {quest, name, cur, max, done, kind, key}
local objectiveByKey = {}  -- "quest|objective" -> objective
local killTargets = {}     -- lower case mob name -> objective (kill objectives)
local questDirty, lastQuestBuild = true, 0

local function Lower(str)
	return str and string.lower(str)
end

local function LearnedQuestMobs()
	local g = TidyPlatesThreat.db and TidyPlatesThreat.db.global
	if not g then
		return {}
	end
	g.questMobs = g.questMobs or {}
	return g.questMobs
end

local function RebuildQuests()
	wipe(questObjectives)
	wipe(objectiveByKey)
	wipe(killTargets)
	for i = 1, (GetNumQuestLogEntries() or 0) do
		local title, _, _, _, isHeader = GetQuestLogTitle(i)
		if title and not isHeader then
			for j = 1, (GetNumQuestLeaderBoards(i) or 0) do
				local text, kind, finished = GetQuestLogLeaderBoard(j, i)
				local name, cur, max = string.match(text or "", "^(.-):%s*(%d+)%s*/%s*(%d+)")
				if name then
					if kind == "monster" then
						name = string.gsub(name, "%s+slain$", "")
					end
					cur, max = tonumber(cur), tonumber(max)
					local obj = {quest = title, name = name, cur = cur, max = max, kind = kind}
					obj.done = finished and true or (cur >= max)
					obj.key = title .. "|" .. name
					objectiveByKey[obj.key] = obj
					table.insert(questObjectives, obj)
					if kind == "monster" and not obj.done then
						killTargets[Lower(name)] = obj
					end
				end
			end
		end
	end
	questDirty = false
	lastQuestBuild = GetTime()
end

local function UpdateQuestsIfNeeded()
	if questDirty and GetTime() - lastQuestBuild > 0.5 then
		RebuildQuests()
	end
end

local function LearnQuestMob(mob, obj)
	local l = Lower(mob)
	local learned = LearnedQuestMobs()
	learned[l] = learned[l] or {}
	learned[l][obj.key] = true
end

-- the objective a mob is (still) needed for, or nil
local function QuestFor(mob)
	local l = Lower(mob)
	if not l then
		return
	end
	local obj = killTargets[l]
	if obj then
		return obj
	end
	local keys = LearnedQuestMobs()[l]
	if keys then
		for key in pairs(keys) do
			obj = objectiveByKey[key]
			if obj and not obj.done then
				return obj
			end
		end
	end
end

-- tooltip of a mob: any line naming an open objective or quest -> remember the mob
local function ScanTooltip()
	local db = DB()
	if not (db and db.questMobs and db.questMobs.ON) then
		return
	end
	local _, uid = GameTooltip:GetUnit()
	if not uid or UnitIsPlayer(uid) or UnitPlayerControlled(uid) then
		return
	end
	local mob = UnitName(uid)
	if not mob then
		return
	end
	if questDirty then
		RebuildQuests()
	end
	for i = 2, GameTooltip:NumLines() do
		local fs = _G["GameTooltipTextLeft" .. i]
		local text = fs and Lower(fs:GetText())
		if text and text ~= "" then
			for _, obj in ipairs(questObjectives) do
				if not obj.done then
					local on, oq = Lower(obj.name), Lower(obj.quest)
					if (#on >= MIN_MATCH_LEN and string.find(text, on, 1, true)) or (#oq >= MIN_MATCH_LEN and string.find(text, oq, 1, true)) then
						LearnQuestMob(mob, obj)
					end
				end
			end
		end
	end
end

-- other addons may add their lines to the tooltip right after us: scan on the next frame
local tooltipScanner = CreateFrame("Frame")
tooltipScanner:Hide()
tooltipScanner:SetScript("OnUpdate", function(self)
	self:Hide()
	if GameTooltip:IsShown() then
		ScanTooltip()
	end
end)
GameTooltip:HookScript("OnTooltipSetUnit", function()
	tooltipScanner:Show()
end)

-- looting a quest item from a corpse -> remember the mob
local function ScanLoot()
	local db = DB()
	if not (db and db.questMobs and db.questMobs.ON) then
		return
	end
	local mob
	if UnitExists("mouseover") and UnitIsDead("mouseover") and not UnitIsPlayer("mouseover") then
		mob = UnitName("mouseover")
	elseif UnitExists("target") and UnitIsDead("target") and not UnitIsPlayer("target") then
		mob = UnitName("target")
	end
	if not mob then
		return
	end
	if questDirty then
		RebuildQuests()
	end
	for slot = 1, (GetNumLootItems() or 0) do
		local _, itemName = GetLootSlotInfo(slot)
		local l = Lower(itemName)
		if l then
			for _, obj in ipairs(questObjectives) do
				if obj.kind == "item" and Lower(obj.name) == l then
					LearnQuestMob(mob, obj)
				end
			end
		end
	end
end

function TidyPlatesThreat.ForgetQuestMobs()
	wipe(LearnedQuestMobs())
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
	-- enemy healer icon
	local heal = CreateFrame("Frame", nil, ext)
	heal:SetFrameLevel(ext:GetFrameLevel() + 6)
	local hb = heal:CreateTexture(nil, "BACKGROUND")
	hb:SetAllPoints(heal)
	hb:SetTexture(0, 0, 0, 1)
	local ht = heal:CreateTexture(nil, "OVERLAY")
	ht:SetPoint("TOPLEFT", heal, "TOPLEFT", 2, -2)
	ht:SetPoint("BOTTOMRIGHT", heal, "BOTTOMRIGHT", -2, 2)
	ht:SetTexture(HEALER_TEXTURE)
	ht:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	heal:Hide()
	d.healer = heal
	-- quest mark: yellow "!" left of the health bar, progress text left of it
	local quest = CreateFrame("Frame", nil, ext)
	quest:SetWidth(16)
	quest:SetHeight(16)
	quest:SetFrameLevel(ext:GetFrameLevel() + 6)
	local qt = quest:CreateTexture(nil, "OVERLAY")
	qt:SetAllPoints(quest)
	qt:SetTexture(QUEST_TEXTURE)
	local qs = quest:CreateFontString(nil, "OVERLAY")
	qs:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
	qs:SetTextColor(1, 0.82, 0)
	qs:SetPoint("RIGHT", quest, "LEFT", 0, 0)
	quest.text = qs
	if bars and bars.healthbar then
		quest:SetPoint("RIGHT", bars.healthbar, "LEFT", -2, 0)
	else
		quest:SetPoint("BOTTOM", ext, "TOP", 0, 0)
	end
	quest:Hide()
	d.quest = quest
	-- threat %
	local tp = CreateFrame("Frame", nil, ext)
	tp:SetWidth(40)
	tp:SetHeight(14)
	tp:SetFrameLevel(ext:GetFrameLevel() + 6)
	local tpt = tp:CreateFontString(nil, "OVERLAY")
	tpt:SetPoint("BOTTOMRIGHT", tp, "BOTTOMRIGHT", 0, 0)
	tpt:SetJustifyH("RIGHT")
	tp.text = tpt
	tp.hb = bars and bars.healthbar
	tp:Hide()
	d.threatPct = tp

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
	UpdateQuestsIfNeeded()
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

			-- enemy healer icon
			local eh = db.enemyHealers
			if enemy and eh and eh.ON and healers[ShortName(unit.name)] then
				local size = eh.size or 32
				d.healer:SetWidth(size)
				d.healer:SetHeight(size)
				d.healer:ClearAllPoints()
				d.healer:SetPoint("CENTER", ext, "CENTER", 0, eh.y or 62)
				d.healer:Show()
			else
				d.healer:Hide()
			end

			-- threat %
			local tpc = db.threatPercent
			local ttext, tr, tg, tb
			if enemy and tpc and tpc.ON then
				ttext, tr, tg, tb = ThreatText(unit)
			end
			if ttext then
				local tp = d.threatPct
				if tp.size ~= tpc.size then
					tp.text:SetFont(STANDARD_TEXT_FONT, tpc.size or 11, "OUTLINE")
					tp.size = tpc.size
				end
				tp:ClearAllPoints()
				if tp.hb then
					tp:SetPoint("BOTTOMRIGHT", tp.hb, "TOPRIGHT", tpc.x or 0, tpc.y or 2)
				else
					tp:SetPoint("BOTTOM", ext, "TOP", tpc.x or 0, tpc.y or 2)
				end
				tp.text:SetText(ttext)
				tp.text:SetTextColor(tr, tg, tb)
				tp:Show()
			else
				d.threatPct:Hide()
			end

			-- quest mark
			local qm = db.questMobs
			local obj = enemy and qm and qm.ON and QuestFor(unit.name)
			if obj then
				if qm.progress and obj.max and obj.max > 1 then
					d.quest.text:SetText(obj.cur .. "/" .. obj.max)
				else
					d.quest.text:SetText("")
				end
				d.quest:Show()
			else
				d.quest:Hide()
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
		local _, sub, srcGUID, srcName, srcFlags, dstGUID, _, dstFlags, _, spellName, _, extra1, extra2, extra3 = ...
		if sub == "SPELL_HEAL" or sub == "SPELL_PERIODIC_HEAL" then
			OnEnemyHeal(srcGUID, srcName, srcFlags, dstGUID, dstFlags, spellName)
			return
		end
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
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- new battleground / arena / dungeon: forget the old healers
		ResetHealers()
		questDirty = true
	elseif event == "QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" then
		questDirty = true
	elseif event == "LOOT_OPENED" then
		ScanLoot()
	end
end)
driver:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
driver:RegisterEvent("UNIT_AURA")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
driver:RegisterEvent("PLAYER_REGEN_ENABLED")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("QUEST_LOG_UPDATE")
driver:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
driver:RegisterEvent("LOOT_OPENED")
