-----------------------------------------------------------------------------
-- Threat poller
-- Tidy Plates reads the threat glow of a nameplate only on
-- UNIT_THREAT_SITUATION_UPDATE, which in 3.3.5 fires for units with a unit id
-- (your target, party members...), not for every mob. So when several mobs
-- attack you, only the first / targeted one got its warning.
-- Here we watch the threat glow of every visible nameplate during combat and
-- refresh only the plates whose threat state changed.
-----------------------------------------------------------------------------
local TidyPlates = TidyPlates

local INTERVAL = 0.1 -- seconds
local lastState = {} -- plate -> "LOW" / "MEDIUM1" / "MEDIUM2" / "HIGH"
local elapsedTotal = 0

local function GlowState(glow)
	if not glow or not glow:IsShown() then
		return "LOW"
	end
	local r, g, b = glow:GetVertexColor()
	if r > 0 then
		if g > 0 then
			if b > 0 then
				return "MEDIUM1"
			end
			return "MEDIUM2"
		end
		return "HIGH"
	end
	return "LOW"
end

local poller = CreateFrame("Frame")
poller:SetScript("OnUpdate", function(self, elapsed)
	elapsedTotal = elapsedTotal + elapsed
	if elapsedTotal < INTERVAL then
		return
	end
	elapsedTotal = 0

	local visible = TidyPlates and TidyPlates.NameplatesByVisible
	local update = TidyPlates and TidyPlates.OnUpdateNameplate
	if not (visible and update) then
		return
	end

	if not InCombatLockdown() then
		if next(lastState) then
			wipe(lastState)
		end
		return
	end

	for plate in pairs(visible) do
		local regions = plate.extended and plate.extended.regions
		local state = GlowState(regions and regions.threatglow)
		-- also refresh when the mob first takes damage (e.g. DoT ticks after a DoT opener)
		local bar = plate.extended and plate.extended.bars and plate.extended.bars.health
		if bar then
			local _, max = bar:GetMinMaxValues()
			if max and bar:GetValue() < max then
				state = state .. "-damaged"
			end
		end
		if lastState[plate] ~= state then
			lastState[plate] = state
			update(plate)
		end
	end
	-- forget plates that are no longer visible
	for plate in pairs(lastState) do
		if not visible[plate] then
			lastState[plate] = nil
		end
	end
end)
