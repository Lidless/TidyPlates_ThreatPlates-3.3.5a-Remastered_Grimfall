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