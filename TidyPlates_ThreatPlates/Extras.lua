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
--   * Service icons     : icon above friendly / neutral service NPCs (flight master, innkeeper,
--                         repair, bank, auction, trainers, vendors...). The game gives only the
--                         NPC's title (<Flight Master>) in its tooltip, so an NPC is learned the
--                         first time you mouse over it and remembered for all characters.
--   * Quest mobs        : big yellow "!" with the progress (3/10) above mobs you still need for a
--                         quest: kill objectives from the quest log, item drop mobs learned
--                         from tooltips (any line naming an objective / quest) and from loot
--                         (only while switched on; forgotten when the quest leaves the log).
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

-- returns text, r, g, b, band, uid (nil = nothing to show)
-- bands: DPS / Healer "low" < 70% <= "mid" < 90% <= "high", "aggro" = the mob is on you
--        Tank "ok" = the mob is on you, "close" >= 90%, "mid" >= 70%, "low" below
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
			return "100%", 1, 1, 1, "ok", uid
		elseif not pct then
			return
		end
		pct = math.floor(pct + 0.5)
		if pct >= 90 then
			return pct .. "%", 1, 0.6, 0.1, "close", uid
		elseif pct >= 70 then
			return pct .. "%", 1, 1, 0.2, "mid", uid
		end
		return pct .. "%", 1, 0.2, 0.2, "low", uid
	end
	if not pct then
		return
	end
	pct = math.floor(pct + 0.5)
	if isTanking then
		return pct .. "%", 1, 0.2, 0.2, "aggro", uid
	elseif pct >= 90 then
		return pct .. "%", 1, 0.2, 0.2, "high", uid
	elseif pct >= 70 then
		return pct .. "%", 1, 0.6, 0.1, "mid", uid
	end
	return pct .. "%", 1, 1, 1, "low", uid
end

-- sound when it gets dangerous (target only): DPS / Healer reaching 90% or pulling aggro,
-- tank losing the mob. The aggro pull itself is skipped when the game's own
-- "Play Aggro Sounds" is on, so it never sounds twice.
local DANGER_RANK = {low = 0, mid = 1, high = 2, aggro = 3}
local function ThreatSound(oldBand, newBand)
	if TidyPlatesThreat:GetRole() == "TANK" then
		if oldBand == "ok" and newBand ~= "ok" then
			PlaySound("RaidWarning")
		end
		return
	end
	local o, n = DANGER_RANK[oldBand], DANGER_RANK[newBand]
	if not (o and n) or n <= o or n < 2 then
		return
	end
	if newBand == "aggro" then
		if GetCVar("threatPlaySounds") ~= "1" then
			PlaySound("RaidWarning")
		end
	elseif o < 2 then
		PlaySoundFile("Sound\\Interface\\AlarmClockWarning3.wav")
	end
end

-------------------------------------------------------------------------------
-- Service icons (traders)
-------------------------------------------------------------------------------
local TRACK = "Interface\\Minimap\\Tracking\\"
local VENDOR_ICON = "Interface\\GossipFrame\\VendorGossipIcon"
local PROFESSIONS = {
	"alchemy", "blacksmith", "enchant", "engineer", "herbalis", "inscription", "jewelcraft",
	"leatherwork", "mining", "skinning", "tailor", "cooking", "first aid", "fishing", "riding"
}
-- first match wins (lower case parts of the title)
local SERVICE_RULES = {
	{TRACK .. "FlightMaster", {"flight master", "wind rider master", "gryphon master", "hippogryph master", "bat handler", "flight"}},
	{TRACK .. "Innkeeper", {"innkeeper"}},
	{TRACK .. "StableMaster", {"stable master"}},
	{TRACK .. "Banker", {"banker", "bank"}},
	{TRACK .. "Auctioneer", {"auctioneer"}},
	{TRACK .. "BattleMaster", {"battlemaster"}},
	{"TRAINER", {"trainer"}},
	{TRACK .. "Repair", {"armorer", "weaponsmith", "weapon merchant", "repair", "armor merchant", "armorsmith"}},
	{TRACK .. "Poisons", {"poison"}},
	{TRACK .. "Reagents", {"reagent"}},
	{TRACK .. "Ammunition", {"ammo", "bowyer", "gunsmith", "arrow", "bullet"}},
	{TRACK .. "Food", {"food", "drink", "baker", "bread", "butcher", "meat", "fruit", "mushroom", "wine", "brew", "bartender", "cheese", "fishmonger"}},
	{"Interface\\GossipFrame\\TabardGossipIcon", {"guild master", "tabard"}},
	{VENDOR_ICON, {"vendor", "merchant", "supplies", "supplier", "goods", "trade", "shop", "seller", "quartermaster", "tailor", "clothier", "smith", "dealer", "provisioner"}}
}

local function ServiceIcon(title)
	local t = title and string.lower(title)
	if not t then
		return
	end
	for _, rule in ipairs(SERVICE_RULES) do
		for _, word in ipairs(rule[2]) do
			if string.find(t, word, 1, true) then
				if rule[1] == "TRAINER" then
					for _, prof in ipairs(PROFESSIONS) do
						if string.find(t, prof, 1, true) then
							return TRACK .. "Profession"
						end
					end
					return TRACK .. "Class"
				end
				return rule[1]
			end
		end
	end
end

local function KnownTitles()
	local g = TidyPlatesThreat.db and TidyPlatesThreat.db.global
	if not g then
		return {}
	end
	g.npcTitles = g.npcTitles or {}
	return g.npcTitles
end

-- a non-player unit's tooltip: line 2 is its title ("Trade Supplies" on Grimfall, "<Trade Supplies>"
-- on other clients); NPCs without a title have the level line there
local LEVEL_PREFIX = "^" .. (LEVEL or "Level") .. " "
local function TooltipTitle(line)
	if not line then
		return
	end
	line = string.gsub(line, "|c%x%x%x%x%x%x%x%x", "")
	line = string.gsub(line, "|r", "")
	line = string.match(line, "^%s*(.-)%s*$")
	if line == "" or string.find(line, LEVEL_PREFIX) or string.find(line, "^Level ") then
		return
	end
	return string.match(line, "^<(.+)>$") or line
end

-- learns also while the icons are switched off, so turning them on needs no new learning
local function ScanServiceTooltip()
	local _, uid = GameTooltip:GetUnit()
	if not uid or UnitIsPlayer(uid) or UnitPlayerControlled(uid) or UnitCanAttack("player", uid) then
		return
	end
	local name = UnitName(uid)
	local fs = _G["GameTooltipTextLeft2"]
	local line = fs and fs:GetText()
	local title = TooltipTitle(line)
	if name and title then
		KnownTitles()[name] = title
	end
end

function TidyPlatesThreat.ForgetServiceNPCs()
	wipe(KnownTitles())
end

-------------------------------------------------------------------------------
-- Quest mobs
-------------------------------------------------------------------------------
local QUEST_TEXTURE = "Interface\\GossipFrame\\AvailableQuestIcon"
local MIN_MATCH_LEN = 4 -- objective / quest names shorter than this are not matched in tooltips
local questObjectives = {} -- list of objectives {quest, name, cur, max, done, kind, key}
local objectiveByKey = {}  -- "quest|objective" -> objective
local killTargets = {}     -- lower case mob name -> objective (open kill objectives)
local killNames = {}       -- lower case mob name -> true (every kill objective, open or done)
local questDirty, lastQuestBuild = true, 0
local QUEST_REFRESH = 2 -- seconds; the quest log is also re-read regularly (the game can report a
                        -- change before the log really changed, e.g. right at turn-in)
local pruneAfter = 0    -- no forgetting right after login: the quest log can still be empty then

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
	wipe(killNames)
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
					if kind == "monster" then
						killNames[Lower(name)] = true
						if not obj.done then
							killTargets[Lower(name)] = obj
						end
					end
				end
			end
		end
	end
	questDirty = false
	lastQuestBuild = GetTime()
	-- forget mobs learned for quests that are no longer in the quest log (turned in / abandoned)
	if GetTime() < pruneAfter then
		return
	end
	local learned = LearnedQuestMobs()
	for mob, keys in pairs(learned) do
		for key in pairs(keys) do
			-- quest gone, or the mob is a kill objective (its mark comes from the kill objective)
			if not objectiveByKey[key] or killNames[mob] then
				keys[key] = nil
			end
		end
		if not next(keys) then
			learned[mob] = nil
		end
	end
end

local function UpdateQuestsIfNeeded()
	local age = GetTime() - lastQuestBuild
	if (questDirty and age > 0.5) or age > QUEST_REFRESH then
		RebuildQuests()
	end
end

local function LearnQuestMob(mob, obj)
	local l = Lower(mob)
	-- a mob you have to kill gets its mark from the kill objective; never tie it to other
	-- objectives of the quest (e.g. an item dropped by another, named mob)
	if killNames[l] or obj.kind == "monster" then
		return
	end
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

-- /tptpquest: why does the target (or the mouseover) have a quest mark?
SLASH_TPTPQUEST1 = "/tptpquest"
SlashCmdList["TPTPQUEST"] = function()
	local uid = UnitExists("target") and "target" or "mouseover"
	local mob = UnitName(uid)
	local p = "|cff89F559Threat Plates|r: "
	if not mob then
		print(p .. "target a mob first")
		return
	end
	RebuildQuests()
	local l = Lower(mob)
	local kill = killTargets[l]
	print(p .. mob .. " - kill objective: " .. (kill and (kill.quest .. " / " .. kill.name .. " " .. kill.cur .. "/" .. kill.max) or "none"))
	local keys = LearnedQuestMobs()[l]
	if keys then
		for key in pairs(keys) do
			local obj = objectiveByKey[key]
			print(p .. "  learned for: " .. key .. (obj and (" " .. obj.cur .. "/" .. obj.max .. (obj.done and " (done)" or "")) or " (quest gone)"))
		end
	else
		print(p .. "  not learned for any quest")
	end
end

-- tooltip of a mob: any line naming an open objective or quest -> remember the mob
-- learns only while quest marks are switched on
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
	-- only mobs you can attack: quest givers / turn-in NPCs name the quest in their tooltip too
	if not UnitCanAttack("player", uid) then
		LearnedQuestMobs()[Lower(mob)] = nil -- clean up a wrong earlier match
		return
	end
	if questDirty then
		RebuildQuests()
	end
	-- the tooltip often names the exact objective of this mob ("- Kreenig Snarlsnout's Tusk: 0/1");
	-- the quest title alone is used only when no objective is named
	local byObjective, byTitle = {}, {}
	for i = 2, GameTooltip:NumLines() do
		local fs = _G["GameTooltipTextLeft" .. i]
		local text = fs and Lower(fs:GetText())
		if text and text ~= "" then
			for _, obj in ipairs(questObjectives) do
				local on, oq = Lower(obj.name), Lower(obj.quest)
				if #on >= MIN_MATCH_LEN and string.find(text, on, 1, true) then
					byObjective[obj] = true
				elseif #oq >= MIN_MATCH_LEN and string.find(text, oq, 1, true) then
					byTitle[obj] = true
				end
			end
		end
	end
	local learnFrom = next(byObjective) and byObjective or byTitle
	for obj in pairs(learnFrom) do
		if not obj.done then
			LearnQuestMob(mob, obj)
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
		ScanServiceTooltip()
	end
end)
GameTooltip:HookScript("OnTooltipSetUnit", function()
	tooltipScanner:Show()
end)

-- looting a quest item from a corpse -> remember the mob
-- learns only while quest marks are switched on
local function ScanLoot()
	local db = DB()
	if not (db and db.questMobs and db.questMobs.ON) then
		return
	end
	local mob
	if UnitExists("mouseover") and UnitIsDead("mouseover") and not UnitIsPlayer("mouseover") and UnitCanAttack("player", "mouseover") then
		mob = UnitName("mouseover")
	elseif UnitExists("target") and UnitIsDead("target") and not UnitIsPlayer("target") and UnitCanAttack("player", "target") then
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
	arrow:SetWidth(19) -- 20% bigger than the first version, easier to see
	arrow:SetHeight(19)
	arrow:SetFrameLevel(ext:GetFrameLevel() + 5)
	local at = arrow:CreateTexture(nil, "OVERLAY")
	at:SetAllPoints(arrow)
	at:SetTexture(ARROW_TEXTURE)
	at:SetVertexColor(1, 0.55, 0) -- orange
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
	-- quest mark: big yellow "!" above the nameplate (over the debuff row), progress right of it
	local quest = CreateFrame("Frame", nil, ext)
	quest:SetWidth(22)
	quest:SetHeight(22)
	quest:SetFrameLevel(ext:GetFrameLevel() + 6)
	local qt = quest:CreateTexture(nil, "OVERLAY")
	qt:SetAllPoints(quest)
	qt:SetTexture(QUEST_TEXTURE)
	local qs = quest:CreateFontString(nil, "OVERLAY")
	qs:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
	qs:SetTextColor(1, 0.82, 0)
	qs:SetPoint("LEFT", quest, "RIGHT", 0, 0)
	quest.text = qs
	quest:SetPoint("CENTER", ext, "CENTER", -12, 52)
	quest:Hide()
	d.quest = quest
	-- service icon above the name of friendly / neutral NPCs
	local svc = CreateFrame("Frame", nil, ext)
	svc:SetFrameLevel(ext:GetFrameLevel() + 6)
	local st = svc:CreateTexture(nil, "OVERLAY")
	st:SetAllPoints(svc)
	svc.tex = st
	-- the title as text (e.g. "Shaman Trainer"), instead of or next to the icon
	local sl = svc:CreateFontString(nil, "OVERLAY")
	sl:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
	sl:SetTextColor(1, 0.82, 0)
	svc.label = sl
	svc:Hide()
	d.service = svc
	-- threat %
	local tp = CreateFrame("Frame", nil, ext)
	tp:SetWidth(40)
	tp:SetHeight(14)
	tp:SetFrameLevel(ext:GetFrameLevel() + 6)
	local tpt = tp:CreateFontString(nil, "OVERLAY")
	tpt:SetPoint("BOTTOMLEFT", tp, "BOTTOMLEFT", 0, 0)
	tpt:SetJustifyH("LEFT")
	tp.text = tpt
	-- dark box behind the number, so it can be read on any ground; follows the text size
	local tbg = tp:CreateTexture(nil, "BACKGROUND")
	tbg:SetTexture(0, 0, 0, 0.7)
	tbg:SetPoint("TOPLEFT", tpt, "TOPLEFT", -3, 2)
	tbg:SetPoint("BOTTOMRIGHT", tpt, "BOTTOMRIGHT", 3, -2)
	tp.bg = tbg
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
			local ttext, tr, tg, tb, band, tuid
			if enemy and tpc and tpc.ON then
				ttext, tr, tg, tb, band, tuid = ThreatText(unit)
			end
			if ttext then
				local tp = d.threatPct
				-- level change on the same mob: blink twice (and maybe a sound); a mob that
				-- just appeared (new target / mouseover) never blinks
				if tp.mob == unit.name and tp.band and tp.band ~= band then
					if tpc.blink then
						tp.blinkUntil = clock + 0.8
					end
					if tpc.sound and tuid == "target" then
						ThreatSound(tp.band, band)
					end
				end
				tp.mob, tp.band = unit.name, band
				if tp.blinkUntil and tp.blinkUntil > clock then
					-- 4 phases in 0.8 s: off / on / off / on = two flashes
					local phase = math.floor((tp.blinkUntil - clock) / 0.2)
					tp.text:SetAlpha((phase % 2 == 1) and 0.1 or 1)
				else
					tp.blinkUntil = nil
					tp.text:SetAlpha(1)
				end
				if tp.size ~= tpc.size then
					tp.text:SetFont(STANDARD_TEXT_FONT, tpc.size or 11, "OUTLINE")
					tp.size = tpc.size
				end
				tp:ClearAllPoints()
				if tp.hb then
					-- up and to the right of the health bar, clear of the name and the level
					tp:SetPoint("BOTTOMLEFT", tp.hb, "TOPRIGHT", tpc.x or 2, tpc.y or 16)
				else
					tp:SetPoint("BOTTOM", ext, "TOP", tpc.x or 2, tpc.y or 16)
				end
				tp.text:SetText(ttext)
				tp.text:SetTextColor(tr, tg, tb)
				if tpc.background == false then
					tp.bg:Hide()
				else
					tp.bg:Show()
				end
				tp:Show()
			else
				d.threatPct.mob, d.threatPct.band, d.threatPct.blinkUntil = nil, nil, nil
				d.threatPct:Hide()
			end

			-- service icon / title (friendly / neutral NPCs, also when shown as name only)
			local si = db.serviceIcons
			local title, icon
			if si and si.ON and unit.type == "NPC" and (unit.reaction == "FRIENDLY" or unit.reaction == "NEUTRAL") and ext.stylename ~= "empty" then
				title = KnownTitles()[unit.name]
				icon = ServiceIcon(title)
			end
			local mode = si and si.mode or "both"
			local showIcon = icon and (mode == "icon" or mode == "both")
			local showText = title and (mode == "text" or mode == "both")
			if showIcon or showText then
				local svc = d.service
				local size = si.size or 20
				svc:SetHeight(size)
				svc.label:ClearAllPoints()
				if showIcon then
					svc.tex:SetTexture(icon)
					svc.tex:ClearAllPoints()
					svc.tex:SetPoint("LEFT", svc, "LEFT", 0, 0)
					svc.tex:SetWidth(size)
					svc.tex:SetHeight(size)
					svc.tex:Show()
				else
					svc.tex:Hide()
				end
				if showText then
					svc.label:SetText(title)
					if showIcon then
						svc.label:SetPoint("LEFT", svc.tex, "RIGHT", 2, 0)
					else
						svc.label:SetPoint("LEFT", svc, "LEFT", 0, 0)
					end
					svc.label:Show()
				else
					svc.label:SetText("")
					svc.label:Hide()
				end
				-- centre the icon + text group above the name
				local width = (showIcon and size or 0) + (showText and ((showIcon and 2 or 0) + (svc.label:GetStringWidth() or 0)) or 0)
				svc:SetWidth(math.max(width, 1))
				svc:ClearAllPoints()
				svc:SetPoint("BOTTOM", ext, "CENTER", 0, 18 + (si.y or 0))
				svc:Show()
			else
				d.service:Hide()
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
		pruneAfter = GetTime() + 10
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
