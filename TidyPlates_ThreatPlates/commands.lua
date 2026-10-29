--[[TPTP Role / Toggle Commands]] --
local L = LibStub("AceLocale-3.0"):GetLocale("TidyPlatesThreat", false)

-- Role commands (class independent)
local function SetRole(role)
	TidyPlatesThreat:SetRole(role)
	if not TidyPlatesThreat.db.profile.verbose then
		print("|cff89F559Threat Plates|r: role set to " .. TidyPlatesThreat:roleText() .. ".")
	end
end

SLASH_TPTPDPS1 = "/tptpdps"
SlashCmdList["TPTPDPS"] = function()
	SetRole("DPS")
end

SLASH_TPTPTANK1 = "/tptptank"
SlashCmdList["TPTPTANK"] = function()
	SetRole("TANK")
end

SLASH_TPTPHEAL1 = "/tptpheal"
SLASH_TPTPHEAL2 = "/tptphealer"
SlashCmdList["TPTPHEAL"] = function()
	SetRole("HEALER")
end

-- /tptprole tank | dps | heal   (no argument: show current role)
SLASH_TPTPROLE1 = "/tptprole"
SlashCmdList["TPTPROLE"] = function(msg)
	msg = string.lower(strtrim(msg or ""))
	if msg == "tank" or msg == "t" then
		SetRole("TANK")
	elseif msg == "dps" or msg == "d" then
		SetRole("DPS")
	elseif msg == "heal" or msg == "healer" or msg == "h" then
		SetRole("HEALER")
	else
		print("|cff89F559Threat Plates|r: current role: " .. TidyPlatesThreat:roleText() .. ". Usage: /tptprole tank || dps || heal")
	end
end

-- Old toggle kept: switches between Tank and DPS
SLASH_TPTPTOGGLE1 = "/tptptoggle"
SlashCmdList["TPTPTOGGLE"] = function()
	if TidyPlatesThreat:GetRole() == "TANK" then
		SetRole("DPS")
	else
		SetRole("TANK")
	end
end

local function TPTPOVERLAP()
	SetCVar("nameplateAllowOverlap", abs(GetCVar("nameplateAllowOverlap") - 1))
	if GetCVar("nameplateAllowOverlap") == "0" and TidyPlatesThreat.db.profile.verbose then
		print(L["-->>Nameplate Overlapping is now |cffff0000OFF!|r<<--"])
	else
		print(L["-->>Nameplate Overlapping is now |cff00ff00ON!|r<<--"])
	end
end
SLASH_TPTPOVERLAP1 = "/tptpol"
SlashCmdList["TPTPOVERLAP"] = TPTPOVERLAP

local function TPTPVERBOSE()
	TidyPlatesThreat.db.profile.verbose = not TidyPlatesThreat.db.profile.verbose
	if TidyPlatesThreat.db.profile.verbose then
		print(L["-->>Threat Plates verbose is now |cff00ff00ON!|r<<--"])
	else
		print(L["-->>Threat Plates verbose is now |cffff0000OFF!|r<<-- shhh!!"])
	end
end
SLASH_TPTPVERBOSE1 = "/tptpverbose"
SlashCmdList["TPTPVERBOSE"] = TPTPVERBOSE
-- /tptpdebug: prints the threat data of your target's nameplate (for bug reports)
local function TPTPDEBUG()
	local p = "|cff89F559TPTP debug|r: "
	if not UnitExists("target") then
		print(p .. "no target. Target the mob and type /tptpdebug again.")
		return
	end
	local plate
	for pl in pairs(TidyPlates.NameplatesByVisible or {}) do
		if pl.extended and pl.extended.unit and pl.extended.unit.isTarget then
			plate = pl
			break
		end
	end
	local sit = UnitThreatSituation("player", "target")
	local _, status, pct = UnitDetailedThreatSituation("player", "target")
	print(p .. "role=" .. TidyPlatesThreat:GetRole() .. " tanking=" .. tostring(TidyPlatesThreat.db.char.threat.tanking)
		.. " combat=" .. tostring(InCombatLockdown()) .. " threatWarning=" .. tostring(GetCVar("threatWarning"))
		.. " threatON=" .. tostring(TidyPlatesThreat.db.profile.threat.ON))
	print(p .. "API: situation=" .. tostring(sit) .. " status=" .. tostring(status) .. " pct=" .. tostring(pct)
		.. " target of target=" .. tostring(UnitName("targettarget")))
	if not plate then
		print(p .. "target nameplate not found (is it visible?)")
		return
	end
	local u = plate.extended.unit
	local glow = plate.extended.regions and plate.extended.regions.threatglow
	local gs = "none"
	if glow then
		local r, g, b = glow:GetVertexColor()
		gs = (glow:IsShown() and "shown" or "hidden") .. string.format(" (%.2f %.2f %.2f)", r or 0, g or 0, b or 0)
	end
	local style = TidyPlatesThreat.SetStyle(u)
	print(p .. "plate: glow=" .. gs .. " threatSituation=" .. tostring(u.threatSituation) .. " style=" .. tostring(style)
		.. " class=" .. tostring(u.class) .. " reaction=" .. tostring(u.reaction) .. " type=" .. tostring(u.type))
	print(p .. "plate: isInCombat=" .. tostring(u.isInCombat) .. " health=" .. tostring(u.health) .. "/" .. tostring(u.healthmax)
		.. " elite=" .. tostring(u.isElite) .. " boss=" .. tostring(u.isBoss) .. " marked=" .. tostring(u.isMarked))
end
SLASH_TPTPDEBUG1 = "/tptpdebug"
SlashCmdList["TPTPDEBUG"] = TPTPDEBUG
