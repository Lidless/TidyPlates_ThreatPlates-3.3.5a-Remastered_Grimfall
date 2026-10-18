-------==------------
-- Threat Widget --
-------------------
local TidyPlatesThreat = TidyPlatesThreat
local path = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ThreatWidget\\"
local db

-- Threat Widget
local function UpdateThreatWidget(frame, unit)
	db = TidyPlatesThreat.db.profile
	local style = TidyPlatesThreat.SetStyle(unit)
	-- Texture names: "HIGH" = safe state, "MEDIUM" = getting dangerous, "LOW" = bad state.
	-- Only warning states get a glow, so the problem mobs stand out.
	local threatLevel
	if TidyPlatesThreat.db.char.threat.tanking then
		local situation = TidyPlatesThreat.EffectiveThreat and TidyPlatesThreat.EffectiveThreat(unit, "tank") or unit.threatSituation
		if situation ~= "HIGH" then
			threatLevel = situation -- mob is not (securely) on you
		end
	else
		if unit.threatSituation == "HIGH" then
			threatLevel = "LOW" -- mob is attacking you
		elseif unit.threatSituation == "MEDIUM" then
			threatLevel = "MEDIUM" -- your threat is getting high
		end
	end
	if threatLevel and ((style == "dps") or (style == "tank") or (style == "unique")) and InCombatLockdown() and unit.class == "UNKNOWN" and db.threat.art.ON then
		if unit.isMarked and db.threat.marked.art then
			frame:Hide()
		else
			frame.Texture:SetTexture(path .. db.threat.art.theme .. "\\" .. threatLevel)
			frame:Show()
		end
	else
		frame:Hide()
	end
end
local function CreateThreatArtWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetFrameLevel(parent.bars.healthbar:GetFrameLevel() + 2)

	db = TidyPlatesThreat.db.profile

	local width = db.settings.healthbar.width
	local height = db.settings.healthbar.height
	frame:SetWidth(width * 2.1333)
	frame:SetHeight(height * 6.4)

	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateThreatWidget
	return frame
end

ThreatPlatesWidgets.CreateThreatArtWidget = CreateThreatArtWidget