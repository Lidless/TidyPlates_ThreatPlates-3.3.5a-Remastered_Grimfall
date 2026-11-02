local TidyPlatesThreat = TidyPlatesThreat
local _

-- Threat situation used for warnings.
-- As tank, a mob that is on another known tank (off-tank) is not a warning.
local RANK = {LOW = 1, MEDIUM = 2, HIGH = 3}

local function EffectiveThreat(unit, style)
	local s = unit.threatSituation or "LOW"

	-- The threat glow of the game is not always reliable (e.g. when the mob pulled you
	-- itself it can stay hidden). Use better sources when we have them:
	-- 1) threat API for the units that have a unit id
	local uid = (unit.isTarget and "target") or (unit.isMouseover and "mouseover") or nil
	if uid and UnitExists(uid) and UnitCanAttack("player", uid) then
		local api = UnitThreatSituation("player", uid)
		local fromApi = (api == 3 or api == 2) and "HIGH" or (api == 1 and "MEDIUM") or nil
		if fromApi and RANK[fromApi] > RANK[s] then
			s = fromApi
		end
	end
	-- 2) the mob is attacking me (its target is me)
	local victim = TidyPlatesThreat.GetMobTarget and TidyPlatesThreat.GetMobTarget(unit)
	if victim and victim == UnitName("player") then
		s = "HIGH"
	end

	if style == "tank" and s ~= "HIGH" and TidyPlatesThreat.IsTankedByOtherTank and TidyPlatesThreat.IsTankedByOtherTank(unit) then
		return "HIGH"
	end
	return s
end
TidyPlatesThreat.EffectiveThreat = EffectiveThreat

-------------------------------------------------------------------------------
-- 1. alpha.lua
--

do
	local function SetAlpha(unit)
		local db = TidyPlatesThreat.db.profile
		local T, custom = TidyPlatesThreat.UnitType(unit)
		local style = TidyPlatesThreat.SetStyle(unit)
		local nonTargetAlpha
		if not unit.isTarget and db.blizzFade.toggle and UnitExists("target") then
			nonTargetAlpha = db.blizzFade.amount
		else
			nonTargetAlpha = 0
		end
		if style == "normal" then
			if T then
				return (db.nameplate.alpha[T] + nonTargetAlpha), db.blizzFade.toggle
			else
				return 1
			end
		elseif style == "empty" then
			return 0, db.blizzFade.toggle
		elseif ((style == "tank" or style == "dps") and db.threat.useAlpha) then
			if unit.isMarked and TidyPlatesThreat.db.profile.threat.marked.alpha then
				return (db.nameplate.alpha["Marked"] + nonTargetAlpha), db.blizzFade.toggle
			else
				return (db.threat[style].alpha[EffectiveThreat(unit, style)] + nonTargetAlpha), db.blizzFade.toggle
			end
		else
			if T then
				return (db.nameplate.alpha[T] + nonTargetAlpha), db.blizzFade.toggle
			else
				return 1
			end
		end
	end

	TidyPlatesThreat.SetAlpha = SetAlpha
end

-------------------------------------------------------------------------------
-- 2. scale.lua
--

do
	local function TypeScale(unit)
		local db = TidyPlatesThreat.db.profile.threat
		local T, custom = TidyPlatesThreat.UnitType(unit)
		if db.useType then
			if T == "Neutral" then
				return db.scaleType["Normal"]
			elseif T == "Normal" or T == "Elite" or T == "Boss" then
				return db.scaleType[T]
			end
		else
			return 0
		end
	end

	local function SetScale(unit)
		local db = TidyPlatesThreat.db.profile
		local T, custom = TidyPlatesThreat.UnitType(unit)
		local style = TidyPlatesThreat.SetStyle(unit)
		if style == "normal" then
			return db.nameplate.scale[(unit.isTarget and "Target" or T)] or 1
		elseif (style == "tank" or style == "dps") and db.threat.useScale then
			local targetscale = unit.isTarget and db.nameplate.scale.Target or 0

			if unit.isMarked and db.threat.marked.scale then
				return (db.nameplate.scale.Marked > targetscale) and db.nameplate.scale.Marked or targetscale
			else
				local scale = db.threat[style].scale[EffectiveThreat(unit, style)]
				return (((scale > targetscale) and scale or targetscale) + TypeScale(unit))
			end
		else
			if db.nameplate.scale then
				return (db.nameplate.scale[T] or 1)
			else
				return 1
			end
		end
	end

	TidyPlatesThreat.SetScale = SetScale
end

-------------------------------------------------------------------------------
-- 3. healthtext.lua
--

do
	local Truncate = function(value)
		if TidyPlatesThreat.db.profile.text.truncate then
			if value >= 1e6 then
				return format("%.1fm", value / 1e6)
			elseif value >= 1e4 then
				return format("%.1fk", value / 1e3)
			else
				return value
			end
		else
			return value
		end
	end

	local function SetCustomText(unit)
		local HpPct = ""
		local HpAmt = ""
		local HpMax = ""
		if unit.health then
			if TidyPlatesThreat.db.profile.text.percent then
				if (TidyPlatesThreat.db.profile.text.amount or TidyPlatesThreat.db.profile.text.max) then
					if TidyPlatesThreat.db.profile.text.deficit and not TidyPlatesThreat.db.profile.text.max and unit.health == unit.healthmax then
						HpPct = floor(100 * (unit.health / unit.healthmax)) .. "%"
					else
						HpPct = " - " .. floor(100 * (unit.health / unit.healthmax)) .. "%"
					end
				else
					HpPct = floor(100 * (unit.health / unit.healthmax)) .. "%"
				end
			else
				HpPct = ""
			end
			if TidyPlatesThreat.db.profile.text.amount then
				if TidyPlatesThreat.db.profile.text.deficit then
					if (unit.health == unit.healthmax) then
						HpAmt = ""
					else
						HpAmt = "-" .. Truncate(unit.healthmax - unit.health)
					end
				else
					HpAmt = Truncate(unit.health)
				end
			else
				HpAmt = ""
			end
			if TidyPlatesThreat.db.profile.text.max then
				if TidyPlatesThreat.db.profile.text.amount then
					if TidyPlatesThreat.db.profile.text.deficit and unit.health == unit.healthmax then
						HpMax = Truncate(unit.healthmax)
					else
						HpMax = " / " .. Truncate(unit.healthmax)
					end
				else
					HpMax = Truncate(unit.healthmax)
				end
			else
				HpMax = ""
			end
			if TidyPlatesThreat.db.profile.settings.customtext.show then
				if (unit.health / unit.healthmax) < 1 then
					return HpAmt .. HpMax .. HpPct
				else
					if TidyPlatesThreat.db.profile.text.full then
						return HpAmt .. HpMax .. HpPct
					else
						return ""
					end
				end
			else
				return ""
			end
		else
			return ""
		end
	end

	TidyPlatesThreat.SetCustomText = SetCustomText
end

-------------------------------------------------------------------------------
-- 4. healthbarcolor.lua
--

do
	TidyPlatesUtility:EnableGroupWatcher()
	TidyPlatesWidgets:EnableAuraWatcher()
	TidyPlatesWidgets:EnableTankWatch()

	local isTanked = TidyPlatesWidgets.IsTankedByAnotherTank

	local TotemNameFallback = TidyPlatesUtility.TotemNameFallback

	local function SetHealthbarColor(unit)
		local db = TidyPlatesThreat.db.profile
		local style, custom = TidyPlatesThreat.SetStyle(unit)


		if style == "totem" or style == "etotem" then
			if db.settings.raidicon.hpColor and unit.isMarked then
				local R = db.settings.raidicon.hpMarked[unit.raidIcon]
				return R.r, R.g, R.b
			else
				local tS = db.totemSettings[TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]]
				if tS[2] then
					c = tS.color
					return c.r, c.g, c.b
				else
					return unit.red, unit.green, unit.blue
				end
			end
		end

		-- threat color in combat; a fully transparent threat color means "keep the normal color"
		-- (the normal coloring below: custom / friendly player / HP colors), not the plain game color
		local threatColor
		if ((style == "tank") or (style == "dps")) and db.threat.useHPColor and InCombatLockdown() then
			local T = db.settings[style].threatcolor[EffectiveThreat(unit, style)]
			if T and T.a ~= 0 then
				threatColor = T
			end
		end

		if threatColor then
			if db.settings.raidicon.hpColor and unit.isMarked and not custom then
				local R = db.settings.raidicon.hpMarked[unit.raidIcon]
				return R.r, R.g, R.b
			else
				return threatColor.r, threatColor.g, threatColor.b
			end
		else
			if db.settings.raidicon.hpColor and unit.isMarked and not custom then
				local R = db.settings.raidicon.hpMarked[unit.raidIcon]
				return R.r, R.g, R.b
			else
				if db.healthColorChange then
					local pct = unit.health / unit.healthmax
					return (1 - pct), (0 + pct), 0
				elseif unit.reaction == "FRIENDLY" and unit.type == "PLAYER" then
					-- friendly players: one color (light blue by default); class colors mean nothing on Grimfall
					local c = db.fPlayerHPbarColor
					return c.r, c.g, c.b
				elseif db.customColor then
					if unit.reaction == "FRIENDLY" then
						local d = db.fHPbarColor
						return d.r, d.g, d.b
					elseif unit.reaction == "NEUTRAL" then
						local n = db.nHPbarColor
						return n.r, n.g, n.b
					else
						-- enemies (mobs and players alike): one color, no class colors
						local c = db.HPbarColor
						return c.r, c.g, c.b
					end
				elseif unit.type == "PLAYER" and unit.reaction == "HOSTILE" then
					-- enemy players: plain red, no class colors
					return 1, 0, 0
				else
					return unit.red, unit.green, unit.blue
				end
			end
		end
	end

	TidyPlatesThreat.SetHealthbarColor = SetHealthbarColor
end

-------------------------------------------------------------------------------
-- 5. castbarcolor.lua
--

do
	local c = {r = 1, g = 1, b = 0, a = 1}
	local function SetCastbarColor(unit)
		local db = TidyPlatesThreat.db.profile
		c.r, c.g, c.b, c.a = 1, 1, 0, 1
		if db.castbarColor.toggle and not unit.spellIsShielded then
			c.r, c.g, c.b, c.a = db.castbarColor.r, db.castbarColor.g, db.castbarColor.b, db.castbarColor.a
		elseif db.castbarColorShield.toggle and db.castbarColor.toggle and unit.spellIsShielded then
			c.r, c.g, c.b, c.a = db.castbarColorShield.r, db.castbarColorShield.g, db.castbarColorShield.b, db.castbarColorShield.a
		end
		return c.r, c.g, c.b, c.a
	end

	TidyPlatesThreat.SetCastbarColor = SetCastbarColor
end

-------------------------------------------------------------------------------
-- 6. nametextcolor.lua
--

do
	local function SetNameColor(unit)
		local db = TidyPlatesThreat.db.profile
		local color = db.settings.name.color
		local r, g, b = color.r, color.g, color.b

		-- friendly units shown as name only: players in their color, NPCs green
		if unit and unit.reaction == "FRIENDLY" and TidyPlatesThreat.SetStyle(unit) == "text" then
			if unit.type == "PLAYER" then
				local c = db.fPlayerHPbarColor
				r, g, b = c.r, c.g, c.b
			else
				r, g, b = 0.2, 0.6, 0.1
			end
		end
		return r, g, b
	end

	TidyPlatesThreat.SetNameColor = SetNameColor
end

-------------------------------------------------------------------------------
-- 7. threatcolor.lua
--

do
	local c = {r = 0, g = 0, b = 0, a = 0}

	local function SetThreatColor(unit)
		local style = TidyPlatesThreat.SetStyle(unit)
		c.r, c.g, c.b, c.a = 0, 0, 0, 0

		if style == "dps" or style == "tank" or style == "normal" and InCombatLockdown() then
			c.r = TidyPlatesThreat.db.profile.settings[style]["threatcolor"][EffectiveThreat(unit, style)].r
			c.g = TidyPlatesThreat.db.profile.settings[style]["threatcolor"][EffectiveThreat(unit, style)].g
			c.b = TidyPlatesThreat.db.profile.settings[style]["threatcolor"][EffectiveThreat(unit, style)].b
			c.a = TidyPlatesThreat.db.profile.settings[style]["threatcolor"][EffectiveThreat(unit, style)].a
		end

		return c.r, c.g, c.b, c.a
	end

	TidyPlatesThreat.SetThreatColor = SetThreatColor
end
