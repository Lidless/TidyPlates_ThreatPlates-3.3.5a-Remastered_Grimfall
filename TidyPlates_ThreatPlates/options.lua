local TidyPlatesThreat = LibStub("AceAddon-3.0"):GetAddon("TidyPlatesThreat")
local L = LibStub("AceLocale-3.0"):GetLocale("TidyPlatesThreat")

TidyPlatesThreat.title = GetAddOnMetadata("TidyPlates_ThreatPlates", "title") .. " v" .. GetAddOnMetadata("TidyPlates_ThreatPlates", "version")
local path = "Interface\\Addons\\TidyPlates_ThreatPlates\\Media\\Artwork\\"
local db

-- Reference Tables
local themeList = {"normal", "tank", "dps", "totem", "text"}
local FullAlign = {
	TOPLEFT = "TOPLEFT",
	TOP = "TOP",
	TOPRIGHT = "TOPRIGHT",
	LEFT = "LEFT",
	CENTER = "CENTER",
	RIGHT = "RIGHT",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOM = "BOTTOM",
	BOTTOMRIGHT = "BOTTOMRIGHT"
}
local AlignH = {LEFT = "LEFT", CENTER = "CENTER", RIGHT = "RIGHT"}
local AlignV = {BOTTOM = "BOTTOM", CENTER = "CENTER", TOP = "TOP"}
local FontStyle = {
	NONE = L["None"],
	OUTLINE = L["Outline"],
	THICKOUTLINE = L["Thick Outline"],
	["NONE, MONOCHROME"] = L["No Outline, Monochrome"],
	["OUTLINE, MONOCHROME"] = L["Outline, Monochrome"],
	["THICKOUTLINE, MONOCHROME"] = L["Thick Outline, Monochrome"]
}
local DebuffMode = {
	["whitelist"] = L["White List"],
	["blacklist"] = L["Black List"],
	["whitelistMine"] = L["White List (Mine)"],
	["blacklistMine"] = L["Black List (Mine)"],
	["all"] = L["All Debuffs"],
	["allMine"] = L["All Debuffs (Mine)"],
	["prefix"] = L["By Prefix"],
}
local totemID = {
	[1] = {8177, "A1", "b8d1ff"},
	[2] = {10595, "A2", "b8d1ff"},
	[3] = {10600, "A2", "b8d1ff"},
	[4] = {10601, "A2", "b8d1ff"},
	[5] = {25574, "A2", "b8d1ff"},
	[6] = {58746, "A2", "b8d1ff"},
	[7] = {58749, "A2", "b8d1ff"},
	[8] = {6495, "A3", "b8d1ff"},
	[9] = {8512, "A4", "b8d1ff"},
	[10] = {3738, "A5", "b8d1ff"},
	[11] = {2062, "E1", "ffb31f"},
	[12] = {2484, "E2", "ffb31f"},
	[13] = {5730, "E3", "ffb31f"},
	[14] = {6390, "E3", "ffb31f"},
	[15] = {6391, "E3", "ffb31f"},
	[16] = {6392, "E3", "ffb31f"},
	[17] = {10427, "E3", "ffb31f"},
	[18] = {10428, "E3", "ffb31f"},
	[19] = {25525, "E3", "ffb31f"},
	[20] = {58580, "E3", "ffb31f"},
	[21] = {58581, "E3", "ffb31f"},
	[22] = {58582, "E3", "ffb31f"},
	[23] = {8071, "E4", "ffb31f"},
	[24] = {8154, "E4", "ffb31f"},
	[25] = {8155, "E4", "ffb31f"},
	[26] = {10406, "E4", "ffb31f"},
	[27] = {10407, "E4", "ffb31f"},
	[28] = {10408, "E4", "ffb31f"},
	[29] = {25508, "E4", "ffb31f"},
	[30] = {25509, "E4", "ffb31f"},
	[31] = {58751, "E4", "ffb31f"},
	[32] = {58753, "E4", "ffb31f"},
	[33] = {8075, "E5", "ffb31f"},
	[34] = {8160, "E5", "ffb31f"},
	[35] = {8161, "E5", "ffb31f"},
	[36] = {10442, "E5", "ffb31f"},
	[37] = {25361, "E5", "ffb31f"},
	[38] = {25528, "E5", "ffb31f"},
	[39] = {57622, "E5", "ffb31f"},
	[40] = {58643, "E5", "ffb31f"},
	[41] = {8143, "E6", "ffb31f"},
	[42] = {2894, "F1", "ff8f8f"},
	[43] = {8227, "F2", "ff8f8f"},
	[44] = {8249, "F2", "ff8f8f"},
	[45] = {10526, "F2", "ff8f8f"},
	[46] = {16387, "F2", "ff8f8f"},
	[47] = {25557, "F2", "ff8f8f"},
	[48] = {58649, "F2", "ff8f8f"},
	[49] = {58652, "F2", "ff8f8f"},
	[50] = {58656, "F2", "ff8f8f"},
	[51] = {8181, "F3", "ff8f8f"},
	[52] = {10478, "F3", "ff8f8f"},
	[53] = {10479, "F3", "ff8f8f"},
	[54] = {25560, "F3", "ff8f8f"},
	[55] = {58741, "F3", "ff8f8f"},
	[56] = {58745, "F3", "ff8f8f"},
	[57] = {8190, "F4", "ff8f8f"},
	[58] = {10585, "F4", "ff8f8f"},
	[59] = {10586, "F4", "ff8f8f"},
	[60] = {10587, "F4", "ff8f8f"},
	[61] = {25552, "F4", "ff8f8f"},
	[62] = {58731, "F4", "ff8f8f"},
	[63] = {58734, "F4", "ff8f8f"},
	[64] = {3599, "F5", "ff8f8f"},
	[65] = {6363, "F5", "ff8f8f"},
	[66] = {6364, "F5", "ff8f8f"},
	[67] = {6365, "F5", "ff8f8f"},
	[68] = {10437, "F5", "ff8f8f"},
	[69] = {10438, "F5", "ff8f8f"},
	[70] = {25533, "F5", "ff8f8f"},
	[71] = {58699, "F5", "ff8f8f"},
	[72] = {58703, "F5", "ff8f8f"},
	[73] = {58704, "F5", "ff8f8f"},
	[74] = {30706, "F6", "ff8f8f"},
	[75] = {57720, "F6", "ff8f8f"},
	[76] = {57721, "F6", "ff8f8f"},
	[77] = {57722, "F6", "ff8f8f"},
	[78] = {8170, "W1", "2b76ff"},
	[79] = {8184, "W2", "2b76ff"},
	[80] = {10537, "W2", "2b76ff"},
	[81] = {10538, "W2", "2b76ff"},
	[82] = {25563, "W2", "2b76ff"},
	[83] = {58737, "W2", "2b76ff"},
	[84] = {58739, "W2", "2b76ff"},
	[85] = {5394, "W3", "2b76ff"},
	[86] = {6375, "W3", "2b76ff"},
	[87] = {6377, "W3", "2b76ff"},
	[88] = {10462, "W3", "2b76ff"},
	[89] = {10463, "W3", "2b76ff"},
	[90] = {25567, "W3", "2b76ff"},
	[91] = {58755, "W3", "2b76ff"},
	[92] = {58756, "W3", "2b76ff"},
	[93] = {58757, "W3", "2b76ff"},
	[94] = {5675, "W4", "2b76ff"},
	[95] = {10495, "W4", "2b76ff"},
	[96] = {10496, "W4", "2b76ff"},
	[97] = {10497, "W4", "2b76ff"},
	[98] = {25570, "W4", "2b76ff"},
	[99] = {58771, "W4", "2b76ff"},
	[100] = {58773, "W4", "2b76ff"},
	[101] = {58774, "W4", "2b76ff"},
	[102] = {16190, "W5", "2b76ff"}
}
-- Shared Media Configs
local MediaFetch = TidyPlatesUtility.MediaFetch
local MediaList = TidyPlatesUtility.MediaList
local MediaRegister = TidyPlatesUtility.MediaRegister
MediaRegister("statusbar", "ThreatPlatesBar", [[Interface\Addons\TidyPlates_ThreatPlates\Media\Artwork\TP_BarTexture.tga]])
MediaRegister("font", "Accidental Presidency", [[Interface\Addons\TidyPlates_ThreatPlates\Media\Fonts\Accidental Presidency.ttf]])

-- Functions
local function GetSpellName(number)
	return (GetSpellInfo(number))
end

local function Update()
	TidyPlates:ReloadTheme()
	TidyPlates:ForceUpdate()
end

local SplitToTable
do
	local t = {}
	function SplitToTable(...)
		wipe(t)
		for index = 1, select("#", ...) do
			local line = select(index, ...)
			if line ~= "" then
				t[line] = true
			end
		end
		return t
	end
end

local function TableToString(t)
	local list = ""
	for i = 1, #t do
		if list then
			if (t[(i + 1)] ~= "") then
				list = list .. (tostring(t[i])) .. "\n"
			else
				list = list .. (tostring(t[i]))
			end
		else
			list = (tostring(t[i])) .. "\n"
		end
	end
	return list
end

local function ThreatDisabled()
	if db.threat.ON then
		return false
	else
		return true
	end
end

-- Saved Variables Only

local function GetValue(info)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	if d then
		return db[a][b][c][d]
	elseif c and not d then
		return db[a][b][c]
	elseif b and not d and not c then
		return db[a][b]
	elseif a and not d and not c and not b then
		return db[a]
	end
end

local function SetValue(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]

	if d then
		db[a][b][c][d] = val
	elseif c and not d then
		db[a][b][c] = val
	elseif b and not d and not c then
		db[a][b] = val
	elseif a and not d and not c and not b then
		db[a] = val
	end
	Update()
end

local function GetValueChar(info)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local t = TidyPlatesThreat.db.char
	if d then
		return t[a][b][c][d]
	elseif c and not d then
		return t[a][b][c]
	elseif b and not d and not c then
		return t[a][b]
	elseif a and not d and not c and not b then
		return t[a]
	end
end

local function SetValueChar(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local t = TidyPlatesThreat.db.char
	if d then
		t[a][b][c][d] = val
	elseif c and not d then
		t[a][b][c] = val
	elseif b and not d and not c then
		t[a][b] = val
	elseif a and not d and not c and not b then
		t[a] = val
	end
	Update()
end

-- Colors

local function GetColor(info)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	return color.r, color.g, color.b, color.a
end

local function SetColor(info, r, g, b)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	color.r, color.g, color.b = r, g, b
	Update()
end

local function GetColorAlpha(info)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	return color.r, color.g, color.b, color.a
end

local function SetColorAlpha(info, r, g, b, a)
	local h, i, j, k = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	local color
	if k then
		color = db[h][i][j][k]
	elseif j and not k then
		color = db[h][i][j]
	elseif i and not j and not k then
		color = db[h][i]
	elseif h and not i and not j and not k then
		color = db[h]
	end
	color.r, color.g, color.b, color.a = r, g, b, a
	Update()
end

-- Set Theme Values

local function SetThemeValue(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		TidyPlatesThemeList["Threat Plates"][themeList[i]][b][c] = val
	end
	Update()
end

local function SetThemeValueArt(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		TidyPlatesThemeList["Threat Plates"][themeList[i]][b][c] = path .. val
	end
	Update()
end

-- Shared Media

local function SetLSMFont(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		TidyPlatesThemeList["Threat Plates"][themeList[i]][b][c] = MediaFetch("font", db[a][b][c])
	end
	Update()
end

local function SetLSMTexture(info, val)
	local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
	db[a][b][c] = val
	for i = 1, #themeList do
		TidyPlatesThemeList["Threat Plates"][themeList[i]][b][c] = MediaFetch("statusbar", db[a][b][c])
	end
	Update()
end

local function GetToggleNameplate(info)
	return db.nameplate.toggle[info.arg]
end

local function SetToggleNameplate(info)
	db.nameplate.toggle[info.arg] = not db.nameplate.toggle[info.arg]
	Update()
end

-- Return the Options table
local options = nil
local function GetOptions()
	if not options then
		options = {
			name = TidyPlatesThreat.title,
			handler = TidyPlatesThreat,
			type = "group",
			childGroups = "tab",
			args = {
				-- Role (class independent)
				Role = {
					name = "Role",
					type = "group",
					order = 1,
					args = {
						Header = {
							type = "description",
							order = 1,
							fontSize = "medium",
							name = "Choose what you play on this character. Threat warnings on the nameplates follow this role, regardless of class, talents or stances.\n\n|cff40FF40Tank|r: mobs that are NOT attacking you stand out (bigger, colored, glowing).\n|cffFFA61ADPS|r / |cffFF3333Healer|r: mobs stand out more and more as your threat rises; a mob attacking you is red, big and glowing.\n"
						},
						Status = {
							type = "description",
							order = 1.5,
							fontSize = "medium",
							name = function()
								if TidyPlatesThreat.db.char.roleChosen then
									return "Current role: " .. TidyPlatesThreat:roleText() .. "\n"
								end
								return "Current role: " .. TidyPlatesThreat:roleText() .. " |cffFF3333(default - you have not chosen a role yet)|r\n"
							end
						},
						Choose = {
							name = "Your role",
							type = "group",
							inline = true,
							order = 2,
							args = {
								Tank = {
									name = "|cff40FF40TANK|r",
									type = "toggle",
									order = 1,
									desc = "Warn me when a mob is not attacking me.",
									get = function()
										return TidyPlatesThreat:GetRole() == "TANK"
									end,
									set = function()
										TidyPlatesThreat:SetRole("TANK")
										Update()
									end
								},
								DPS = {
									name = "|cffFFA61ADPS|r",
									type = "toggle",
									order = 2,
									desc = "Warn me when my threat rises on a mob.",
									get = function()
										return TidyPlatesThreat:GetRole() == "DPS"
									end,
									set = function()
										TidyPlatesThreat:SetRole("DPS")
										Update()
									end
								},
								Healer = {
									name = "|cffFF3333HEALER|r",
									type = "toggle",
									order = 3,
									desc = "Warn me when my threat rises on a mob.",
									get = function()
										return TidyPlatesThreat:GetRole() == "HEALER"
									end,
									set = function()
										TidyPlatesThreat:SetRole("HEALER")
										Update()
									end
								}
							}
						},
						Commands = {
							type = "description",
							order = 3,
							name = "\nChat commands: |cff89F559/tptprole tank||dps||heal|r, |cff89F559/tptptank|r, |cff89F559/tptpdps|r, |cff89F559/tptpheal|r.\nYour role is shared with group members who also use this Threat Plates version, so their nameplates can show [T]/[H]/[D] next to your name."
						},
						Minimap = {
							name = "Show minimap button",
							type = "toggle",
							order = 4,
							width = "double",
							desc = "Minimap button showing your role. Left click: open this tab. Right click: switch role (Tank > DPS > Healer). Drag: move it.",
							get = function()
								return not (db.minimap and db.minimap.hide)
							end,
							set = function(info, val)
								db.minimap = db.minimap or {}
								db.minimap.hide = not val
								TidyPlatesThreat:UpdateMinimapButton()
							end
						}
					}
				},
				-- Help
				Help = {
					name = "Help",
					type = "group",
					order = 2,
					args = {
						QuickStart = {
							name = "Quick start",
							type = "group",
							inline = true,
							order = 1,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "1. Open the |cff89F559Role|r tab and choose |cff40FF40Tank|r, |cffFFA61ADPS|r or |cffFF3333Healer|r. Until you choose, |cffFFA61ADPS|r is used and you get a reminder in chat at login and when entering a dungeon or raid.\n2. That's it. The nameplates now warn you about threat according to your role.\n3. Everything else is optional fine tuning (see below).\n\nThe role does not depend on your class, talents or stances: any class can tank, heal or deal damage. Pick the role you actually play right now and switch it any time."
								}
							}
						},
						Warnings = {
							name = "What the threat warnings mean",
							type = "group",
							inline = true,
							order = 2,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "|cff40FF40Tank|r - a mob that is |cffff0000NOT attacking you|r becomes red, bigger and gets a glowing frame. Mobs you hold securely become green, smaller and slightly faded. A mob attacking another tank (off-tank) is not a warning.\n\n|cffFFA61ADPS|r / |cffFF3333Healer|r - a mob looks normal while your threat is low. When your threat gets high, it becomes |cffFFA61Aorange|r and a bit bigger. When the mob |cffff0000attacks you|r, it becomes red, big and gets a glowing frame: stop or slow down, or use a threat drop.\n\nWarnings only appear in combat, on mobs that are in combat."
								}
							}
						},
						MobTarget = {
							name = "Who is the mob attacking?",
							type = "group",
							inline = true,
							order = 3,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "Below an enemy nameplate you see who the mob is attacking, for example: |cff40FF40> Gorbak [T]|r\n\nThe letter shows the role of the player, the color makes it faster to see:\n|cff40FF40[T] Tank|r - green: this is how it should be.\n|cffFFA61A[D] DPS|r - orange: a damage dealer pulled the mob.\n|cffFF3333[H] Healer|r - red: the most dangerous, the healer is attacked.\nNo letter (white name): the role of that player is unknown.\n\nRoles come from: group members who also use this Threat Plates version share their chosen role automatically; otherwise the raid Main Tank mark or the LFG role is used.\n\nLimit of the 3.3.5 client: the mob's target is only known for mobs that you or a group member has targeted (or focus / mouseover). For other mobs no line is shown.\n\nSettings: |cff89F559Widgets -> Mob Target|r (on/off, position, font size)."
								}
							}
						},
						Auras = {
							name = "DoTs, CC and HoTs on nameplates",
							type = "group",
							inline = true,
							order = 3.5,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "|cff89F559Enemies|r (Widgets -> Debuffs): by default your own DoTs / debuffs are shown above the nameplate with the time left, plus crowd control (stun, fear, polymorph...) from anyone, marked with a glow. The mode can be changed (all debuffs, white / black list...).\n\n|cff89F559Friendly players|r (Nameplate Settings -> Friendly): your HoTs and short buffs, and crowd control on party / raid members. Friendly nameplates must be shown (Shift+V).\n\nLimit of the 3.3.5 client: exact durations are known for your target, focus, mouseover and group members; on other mobs the effects come from the combat log."
								}
							}
						},
						EnemyExtras = {
							name = "Execute line, cast highlight, dispellable buffs",
							type = "group",
							inline = true,
							order = 3.6,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "|cff89F559Nameplate Settings -> Enemy Nameplates|r:\n- |cffffd100Execute line|r (off by default): a vertical mark on enemy health bars at the set health %.\n- |cffffd100Cast highlight|r (off by default): the castbar blinks with a red border when an enemy casts a spell from your list. Spells that you or your group interrupt are learned automatically.\n- |cffffd100Quest mobs|r (on by default): a yellow ! with your progress on mobs you still need for a quest.\n- |cffffd100Enemy healers|r (on by default): a big heal icon above enemy players who heal others (battlegrounds / arenas) and above healer mobs.\n\n|cff89F559Widgets -> Debuffs|r: a blinking |cff4cccffup arrow|r left of the debuff icons when an enemy has a magic or enrage buff that can be purged / dispelled. Exact on your target, focus and mouseover; on other mobs it works for buffs it has already seen.\n\n|cff89F559Nameplate Settings -> Friendly|r: tick what you can remove (magic, curse, poison, disease) and those crowd control icons on group members blink.\n\n|cff89F559Nameplate Settings -> Friendly|r: friendly players with a light blue health bar, or name only (the bar appears while the player is damaged); friendly NPCs can be shown as name only."
								}
							}
						},
						Commands = {
							name = "Chat commands",
							type = "group",
							inline = true,
							order = 4,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "|cff89F559/tptp|r - open these options\n|cff89F559/tptprole tank||dps||heal|r - set your role (without argument: show current role)\n|cff89F559/tptptank|r, |cff89F559/tptpdps|r, |cff89F559/tptpheal|r - set your role\n|cff89F559/tptptoggle|r - switch between Tank and DPS\n|cff89F559/tptpverbose|r - turn chat messages of the addon on / off\n|cff89F559/tptpol|r - toggle overlapping nameplates\n\nMinimap button (icon shows your role): left click opens the Role tab, right click switches the role (Tank > DPS > Healer), drag to move it. It can be hidden in the Role tab.\n\nBugs, ideas, feedback: GitHub issues at |cff00ff00github.com/Lidless/TidyPlates_ThreatPlates-3.3.5a-Remastered_Grimfall|r"
								}
							}
						},
						Settings = {
							name = "Where to fine tune",
							type = "group",
							inline = true,
							order = 5,
							args = {
								Text = {
									type = "description",
									fontSize = "medium",
									order = 1,
									name = "|cff89F559Threat System|r\n  - Enable Threat System: master switch of all threat warnings.\n  - General Settings: which mob types (normal, elite, boss, neutral) get warnings; ignore mobs that are not in combat.\n  - Alpha: how transparent a nameplate is at low / medium / high threat (separately for Tank and DPS/Healer).\n  - Scale: how big a nameplate is at low / medium / high threat. Bigger = more visible.\n  - Coloring: health bar colors at each threat level. A fully transparent color means 'keep the normal color'.\n  - Textures: the glowing frame around warned nameplates (Default or Bar style).\n  Note: in the Tank columns 'Low threat' is the bad state (mob not on you); in the DPS/Healing columns 'High threat' is the bad state (mob on you).\n\n|cff89F559Widgets|r - extra icons and texts on the nameplates (Mob Target line, debuffs, threat %, target highlight, etc.).\n|cff89F559Nameplate Settings|r - size, fonts, textures and colors of the nameplates themselves; Enemy Nameplates (execute line, cast highlight), Totem Nameplates, and Friendly: which friendly nameplates are shown, players (bar or name only, color), NPCs (name only), HoTs and crowd control on group members.\n|cff89F559Reset|r - the button below puts all settings back to the defaults."
								}
							}
						},
						Reset = {
							name = "Reset",
							type = "group",
							inline = true,
							order = 6,
							args = {
								Text = {
									type = "description",
									order = 1,
									name = "Messed up the settings? This puts every Threat Plates setting back to the defaults. Your role is kept.\n"
								},
								Button = {
									name = "Reset all settings",
									type = "execute",
									order = 2,
									width = "double",
									confirm = true,
									confirmText = "Reset all Threat Plates settings to the defaults?",
									func = function()
										TidyPlatesThreat.db:ResetProfile()
										TidyPlatesThreat:ConfigRefresh()
									end
								}
							}
						},
					}
				},
				-- Config Guide
				NameplateSettings = {
					name = L["Nameplate Settings"],
					type = "group",
					order = 10,
					args = {
						GeneralSettings = {
							name = L["General Settings"],
							type = "group",
							order = 10,
							args = {
								Hiding = {
									name = L["Hiding"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										ShowNeutral = {
											type = "toggle",
											order = 1,
											name = L["Show Neutral"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Neutral"
										},
										ShowNormal = {
											type = "toggle",
											order = 2,
											name = L["Show Normal"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Normal"
										},
										ShowElite = {
											type = "toggle",
											order = 3,
											name = L["Show Elite"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Elite"
										},
										ShowBoss = {
											type = "toggle",
											order = 4,
											name = L["Show Boss"],
											get = GetToggleNameplate,
											set = SetToggleNameplate,
											arg = "Boss"
										}
									}
								},
								BlizzSettings = {
									name = L["Blizzard Settings"],
									type = "group",
									order = 2,
									inline = true,
									args = {
										OpenBlizzardSettings = {
											name = L["Open Blizzard Settings"],
											type = "execute",
											order = 1,
											func = function()
												InterfaceOptionsFrame_OpenToCategory(_G["InterfaceOptionsNamesPanel"])
												LibStub("AceConfigDialog-3.0"):Close("Tidy Plates: Threat Plates")
											end
										},
										Enemy = {
											type = "group",
											name = L["Enemy"],
											order = 3,
											inline = true,
											args = {
												nameplateShowEnemies = {
													name = L["Show Enemies"],
													type = "toggle",
													order = 1,
													get = function()
														return (GetCVar("nameplateShowEnemies") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemies", abs(GetCVar("nameplateShowEnemies") - 1))
													end
												},
												nameplateShowEnemyPets = {
													name = L["Show Enemy Pets"],
													type = "toggle",
													order = 3,
													get = function()
														return (GetCVar("nameplateShowEnemyPets") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemyPets", abs(GetCVar("nameplateShowEnemyPets") - 1))
													end
												},
												nameplateShowEnemyGuardians = {
													name = L["Show Enemy Guardians"],
													type = "toggle",
													order = 4,
													get = function()
														return (GetCVar("nameplateShowEnemyGuardians") == "1")
													end,
													set = function()
														SetCVar("nameplateShowEnemyGuardians", abs(GetCVar("nameplateShowEnemyGuardians") - 1))
													end
												}
											}
										}
									}
								}
							}
						},
						EnemyNameplates = {
							name = "Enemy Nameplates",
							type = "group",
							order = 12,
							args = {
								Execute = {
									name = "Execute Line",
									type = "group",
									inline = true,
									order = 1,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											width = "double",
											desc = "A vertical line on enemy health bars at the set health %, so you see when the execute phase starts.",
											descStyle = "inline",
											get = function()
												return db.executeLine.ON
											end,
											set = function(info, val)
												db.executeLine.ON = val
											end
										},
										Percent = {
											name = "Health %",
											type = "range",
											order = 2,
											min = 1,
											max = 99,
											step = 1,
											disabled = function()
												return not db.executeLine.ON
											end,
											get = function()
												return db.executeLine.percent
											end,
											set = function(info, val)
												db.executeLine.percent = val
											end
										}
									}
								},
								CastHighlight = {
									name = "Cast Highlight (interrupt these!)",
									type = "group",
									inline = true,
									order = 2,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											width = "double",
											desc = "The castbar of an enemy blinks with a red border when it casts a spell from the list below.",
											descStyle = "inline",
											get = function()
												return db.castHighlight.ON
											end,
											set = function(info, val)
												db.castHighlight.ON = val
											end
										},
										Learn = {
											name = "Learn interrupted spells automatically",
											type = "toggle",
											order = 2,
											width = "double",
											desc = "When you or a group member interrupts an enemy cast, that spell is added to the list.",
											descStyle = "inline",
											disabled = function()
												return not db.castHighlight.ON
											end,
											get = function()
												return db.castHighlight.learn
											end,
											set = function(info, val)
												db.castHighlight.learn = val
											end
										},
										List = {
											name = "Spells (one per line, name or spell ID)",
											type = "input",
											order = 3,
											multiline = 10,
											width = "full",
											disabled = function()
												return not db.castHighlight.ON
											end,
											get = function()
												local names = {}
												for name in pairs(db.castHighlight.spells or {}) do
													names[#names + 1] = name
												end
												table.sort(names)
												return table.concat(names, "\n")
											end,
											set = function(info, val)
												db.castHighlight.spells = {}
												for line in string.gmatch(val or "", "[^\n]+") do
													line = strtrim(line)
													if line ~= "" then
														TidyPlatesThreat.AddHighlightSpell(line)
													end
												end
											end
										}
									}
								},
								EnemyHealers = {
									name = "Enemy Healers",
									type = "group",
									inline = true,
									order = 3,
									args = {
										Info = {
											type = "description",
											order = 0,
											fontSize = "medium",
											name = "A big heal icon above enemy healers, so you know whom to kill or interrupt first. The game does not tell the role of enemies, so a unit is marked after it healed |cffffd100others 3 times|r (self heals and procs like Vampiric Embrace do not count). Enemy players are marked only in |cffffd100battlegrounds and arenas|r; the list is cleared when you change zone.\n"
										},
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											width = "double",
											get = function()
												return db.enemyHealers.ON
											end,
											set = function(info, val)
												db.enemyHealers.ON = val
											end
										},
										NPCs = {
											name = "Also healer NPCs",
											type = "toggle",
											order = 2,
											width = "double",
											desc = "Mobs that heal other mobs (e.g. in dungeons) get the icon too, everywhere.",
											descStyle = "inline",
											disabled = function()
												return not db.enemyHealers.ON
											end,
											get = function()
												return db.enemyHealers.npcs
											end,
											set = function(info, val)
												db.enemyHealers.npcs = val
											end
										},
										Size = {
											name = "Icon size",
											type = "range",
											order = 3,
											min = 16,
											max = 64,
											step = 1,
											disabled = function()
												return not db.enemyHealers.ON
											end,
											get = function()
												return db.enemyHealers.size
											end,
											set = function(info, val)
												db.enemyHealers.size = val
											end
										},
										Height = {
											name = "Height above the nameplate",
											type = "range",
											order = 4,
											min = 0,
											max = 150,
											step = 1,
											disabled = function()
												return not db.enemyHealers.ON
											end,
											get = function()
												return db.enemyHealers.y
											end,
											set = function(info, val)
												db.enemyHealers.y = val
											end
										}
									}
								},
								QuestMobs = {
									name = "Quest Mobs",
									type = "group",
									inline = true,
									order = 4,
									args = {
										Info = {
											type = "description",
											order = 0,
											fontSize = "medium",
											name = "A yellow |cffffd100!|r with your progress (e.g. 3/10) left of the health bar of mobs you still need for a quest; it disappears when the objective is complete. Kill objectives come from your quest log. Mobs that drop quest items are learned: when a mob's tooltip names one of your open objectives or quests, or when you loot a quest item from it. Only your own quests (the game does not tell your group's quests).\n"
										},
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											width = "double",
											get = function()
												return db.questMobs.ON
											end,
											set = function(info, val)
												db.questMobs.ON = val
											end
										},
										Progress = {
											name = "Show progress (3/10)",
											type = "toggle",
											order = 2,
											width = "double",
											disabled = function()
												return not db.questMobs.ON
											end,
											get = function()
												return db.questMobs.progress
											end,
											set = function(info, val)
												db.questMobs.progress = val
											end
										},
										Forget = {
											name = "Forget learned quest mobs",
											type = "execute",
											order = 3,
											width = "double",
											desc = "Clears the list of mobs learned from tooltips and loot (e.g. after a wrong match). Kill objectives are not affected.",
											confirm = true,
											confirmText = "Forget all learned quest mobs?",
											func = function()
												TidyPlatesThreat.ForgetQuestMobs()
											end
										}
									}
								},
							}
						},
						Friendly = {
							name = "Friendly",
							type = "group",
							order = 14,
							args = {
								Info = {
									type = "description",
									order = 0,
									fontSize = "medium",
									name = "Everything for |cff40FF40friendly|r nameplates: which ones are shown, how players and NPCs look, and effects on your party / raid members.\n"
								},
								Show = {
									type = "group",
									name = "Show friendly nameplates",
									order = 1,
									inline = true,
									args = {
										nameplateShowFriends = {
											name = "Players (Shift+V)",
											type = "toggle",
											order = 1,
											get = function()
												return (GetCVar("nameplateShowFriends") == "1")
											end,
											set = function()
												SetCVar("nameplateShowFriends", abs(GetCVar("nameplateShowFriends") - 1))
											end
										},
										nameplateShowFriendlyPets = {
											name = "Pets",
											type = "toggle",
											order = 3,
											get = function()
												return (GetCVar("nameplateShowFriendlyPets") == "1")
											end,
											set = function()
												SetCVar("nameplateShowFriendlyPets", abs(GetCVar("nameplateShowFriendlyPets") - 1))
											end
										},
										nameplateShowFriendlyGuardians = {
											name = "Guardians",
											type = "toggle",
											order = 4,
											get = function()
												return (GetCVar("nameplateShowFriendlyGuardians") == "1")
											end,
											set = function()
												SetCVar("nameplateShowFriendlyGuardians", abs(GetCVar("nameplateShowFriendlyGuardians") - 1))
											end
										}
									}
								},
								Players = {
									name = "Friendly players",
									type = "group",
									inline = true,
									order = 2,
									args = {
										Mode = {
											name = "Show as",
											type = "select",
											order = 1,
											width = "double",
											values = {
												bar = "Health bar",
												name = "Name only (health bar while damaged)"
											},
											get = function()
												return db.friendlyPlayerMode or "bar"
											end,
											set = function(info, val)
												db.friendlyPlayerMode = val
												Update()
											end
										},
										Color = {
											name = "Color",
											type = "color",
											order = 2,
											desc = "Health bar and name color of friendly players (light blue by default), so they stand out from friendly NPCs in cities.",
											get = GetColor,
											set = SetColor,
											arg = {"fPlayerHPbarColor"}
										},
										Note = {
											type = "description",
											order = 3,
											name = "With 'Name only' a friendly player shows just the name; when they take damage the health bar appears until they are back at full health. Class colors are not used: on Grimfall (custom classes, classless realm) they would not mean anything."
										}
									}
								},
								Effects = {
									name = "Group members (party / raid)",
									type = "group",
									inline = true,
									order = 3,
									args = {
										Buffs = {
											name = "My HoTs and short buffs",
											type = "toggle",
											order = 1,
											width = "double",
											desc = "Your heal over time effects, shields and other short buffs on group members, with the time left.",
											descStyle = "inline",
											get = function()
												return db.friendlyAuras.buffs
											end,
											set = function(info, val)
												db.friendlyAuras.buffs = val
												Update()
											end
										},
										MaxDuration = {
											name = "Longest buff to show (seconds)",
											type = "range",
											order = 2,
											width = "double",
											min = 10,
											max = 600,
											step = 5,
											desc = "Buffs longer than this (e.g. 30 minute or 1 hour buffs) are not shown, so only HoTs and short effects remain.",
											disabled = function()
												return not db.friendlyAuras.buffs
											end,
											get = function()
												return db.friendlyAuras.maxDuration
											end,
											set = function(info, val)
												db.friendlyAuras.maxDuration = val
												Update()
											end
										},
										Dispel = {
											name = "I can remove (these CC icons blink)",
											type = "multiselect",
											order = 4,
											width = "double",
											values = {Magic = "Magic", Curse = "Curse", Poison = "Poison", Disease = "Disease"},
											disabled = function()
												return not db.friendlyAuras.cc
											end,
											get = function(info, key)
												return db.friendlyAuras.dispel and db.friendlyAuras.dispel[key]
											end,
											set = function(info, key, val)
												db.friendlyAuras.dispel = db.friendlyAuras.dispel or {}
												db.friendlyAuras.dispel[key] = val
												Update()
											end
										},
										CC = {
											name = "Crowd control on group members",
											type = "toggle",
											order = 3,
											width = "double",
											desc = "Stun, fear, polymorph, root, silence... on a group member, shown with a glow.",
											descStyle = "inline",
											get = function()
												return db.friendlyAuras.cc
											end,
											set = function(info, val)
												db.friendlyAuras.cc = val
												Update()
											end
										}
									}
								},
								NPCs = {
									name = "Friendly NPCs",
									type = "group",
									inline = true,
									order = 4,
									args = {
										NameOnly = {
											name = "Name only",
											type = "toggle",
											order = 1,
											width = "double",
											desc = "Friendly NPCs (guards, vendors, quest givers...) show only their name, without a health bar.",
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											arg = {"friendlyNameOnly"}
										}
									}
								},
								Note = {
									type = "description",
									order = 5,
									name = "\nIcon size and position of the group member effects are the same as for enemies: |cff89F559Widgets -> Debuffs|r."
								}
							}
						},
						Totems = {
							name = L["Totem Nameplates"],
							type = "group",
							childGroups = "list",
							order = 140,
							args = {}
						},
						HealthBarTexture = {
							name = L["Healthbar"],
							type = "group",
							inline = false,
							order = 20,
							args = {
								Size = {
									name = L["Size"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Width = {
											type = "range",
											name = L["Width"],
											order = 10,
											get = GetValue,
											set = function(info, val)
												SetThemeValue({arg = {"settings", "healthbar", "width"}}, val)
												SetThemeValue({arg = {"settings", "frame", "width"}}, val + 4)
												SetThemeValue({arg = {"settings", "threatborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "highlight", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "healthborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castborder", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castnostop", "width"}}, (val * 2) + 20)
												SetThemeValue({arg = {"settings", "castbar", "width"}}, val)
												SetThemeValue(info, val)
											end,
											min = 80,
											max = 240,
											step = 0.1,
											bigStep = 1,
											arg = {"settings", "healthbar", "width"}
										},
										Height = {
											type = "range",
											name = L["Height"],
											order = 10,
											get = GetValue,
											set = function(info, val)
												SetThemeValue({arg = {"settings", "healthbar", "height"}}, val)
												SetThemeValue({arg = {"settings", "frame", "height"}}, val + 20)
												SetThemeValue({arg = {"settings", "threatborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "highlight", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "healthborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "castborder", "height"}}, val + 54)
												SetThemeValue({arg = {"settings", "castnostop", "height"}}, val + 54)
												SetThemeValue(info, val)
											end,
											min = 10,
											max = 20,
											step = 0.1,
											bigStep = 1,
											arg = {"settings", "healthbar", "height"}
										}
									}
								},
								HealthBarGroup = {
									name = L["Textures"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										HealthBarTexture = {
											name = L["Healthbar"],
											type = "select",
											width = "double",
											dialogControl = "LSM30_Statusbar",
											order = 1,
											values = MediaList("statusbar"),
											get = GetValue,
											set = SetLSMTexture,
											arg = {"settings", "healthbar", "texture"}
										},
										Header1 = {
											type = "header",
											order = 1.5,
											name = ""
										},
										HealthBorderToggle = {
											type = "toggle",
											order = 2,
											name = L["Show Border"],
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "healthborder", "show"}
										},
										HealthBorder = {
											type = "select",
											order = 3,
											name = L["Normal Border"],
											get = GetValue,
											set = SetThemeValueArt,
											disabled = function()
												return not db.settings.healthborder.show
											end,
											values = {TP_HealthBarOverlay = "Default", TP_HealthBarOverlayThin = "Thin"},
											arg = {"settings", "healthborder", "texture"}
										},
										Header2 = {
											type = "header",
											order = 3.5,
											name = ""
										},
										EliteHealthBorderToggle = {
											type = "toggle",
											order = 4,
											name = L["Show Elite Border"],
											get = GetValue,
											set = SetValue,
											arg = {"settings", "elitehealthborder", "show"}
										},
										EliteBorder = {
											type = "select",
											order = 5,
											name = L["Elite Border"],
											get = GetValue,
											set = SetValue,
											disabled = function()
												return not db.settings.elitehealthborder.show
											end,
											values = {
												TP_HealthBarEliteOverlay = "Default",
												TP_HealthBarEliteOverlayThin = "Thin"
											},
											arg = {"settings", "elitehealthborder", "texture"}
										},
										Header3 = {
											type = "header",
											order = 5.5,
											name = ""
										},
										Target = {
											type = "select",
											order = 6,
											name = L["Target"],
											get = GetValue,
											set = SetThemeValueArt,
											values = {TP_Target = "Default", Empty = "None"},
											arg = {"settings", "target", "texture"}
										},
										Mouseover = {
											type = "select",
											order = 6.5,
											name = L["Mouseover"],
											get = GetValue,
											set = SetThemeValueArt,
											values = {TP_HealthBarHighlight = "Default", Empty = "None"},
											arg = {"settings", "highlight", "texture"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									args = {
										Warning = {
											type = "description",
											descStyle = "inline",
											name = L["Changing these settings will alter the placement of the nameplates, however the mouseover area does not follow. |cffff0000Use with caution!|r"],
											order = 1,
											width = "full"
										},
										OffsetX = {
											name = L["Offset X"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 2,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "frame", "x"}
										},
										Offsety = {
											name = L["Offset Y"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 3,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "frame", "y"}
										}
									}
								},
								Coloring = {
									name = L["Coloring"],
									type = "group",
									inline = true,
									order = 30,
									args = {
										ColorByHPLevel = {
											name = L["Color HP by amount"],
											type = "toggle",
											desc = L["Changes the HP color depending on the amount of HP the nameplate shows."],
											descStyle = "inline",
											width = "double",
											order = 0,
											get = GetValue,
											set = SetValue,
											arg = {"healthColorChange"}
										},
										CustomColors = {
											name = L["Custom HP Color"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												Enable = {
													name = L["Enable Custom HP colors"],
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetValue,
													order = 1,
													arg = {"customColor"}
												},
												Colors = {
													name = "Colors",
													type = "group",
													inline = true,
													order = 2,
													disabled = function()
														return not db.customColor
													end,
													args = {
														FriendlyColor = {
															name = L["Friendly Color"],
															type = "color",
															desc = "Friendly NPCs (friendly players: Nameplate Settings -> Friendly).",
															get = GetColor,
															set = SetColor,
															arg = {"fHPbarColor"}
														},
														NeutralColor = {
															name = L["Neutral Color"],
															type = "color",
															get = GetColor,
															set = SetColor,
															arg = {"nHPbarColor"}
														},
														EnemyColor = {
															name = L["Enemy Color"],
															type = "color",
															get = GetColor,
															set = SetColor,
															arg = {"HPbarColor"}
														}
													}
												}
											}
										},
										RaidMarkColors = {
											name = L["Raid Mark HP Color"],
											order = 4,
											type = "group",
											inline = true,
											args = {
												Enable = {
													name = L["Enable Raid Marked HP colors"],
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetValue,
													order = 1,
													arg = {"settings", "raidicon", "hpColor"}
												},
												Colors = {
													name = L["Colors"],
													type = "group",
													inline = true,
													order = 2,
													disabled = function()
														return not db.settings.raidicon.hpColor
													end,
													get = GetColor,
													set = SetColor,
													args = {
														STAR = {
															type = "color",
															order = 1,
															name = RAID_TARGET_1,
															arg = {"settings", "raidicon", "hpMarked", "STAR"}
														},
														CIRCLE = {
															type = "color",
															order = 2,
															name = RAID_TARGET_2,
															arg = {"settings", "raidicon", "hpMarked", "CIRCLE"}
														},
														DIAMOND = {
															type = "color",
															order = 3,
															name = RAID_TARGET_3,
															arg = {"settings", "raidicon", "hpMarked", "DIAMOND"}
														},
														TRIANGLE = {
															type = "color",
															order = 4,
															name = RAID_TARGET_4,
															arg = {"settings", "raidicon", "hpMarked", "TRIANGLE"}
														},
														MOON = {
															type = "color",
															order = 5,
															name = RAID_TARGET_5,
															arg = {"settings", "raidicon", "hpMarked", "MOON"}
														},
														SQUARE = {
															type = "color",
															order = 6,
															name = RAID_TARGET_6,
															arg = {"settings", "raidicon", "hpMarked", "SQUARE"}
														},
														CROSS = {
															type = "color",
															order = 7,
															name = RAID_TARGET_7,
															arg = {"settings", "raidicon", "hpMarked", "CROSS"}
														},
														SKULL = {
															type = "color",
															order = 8,
															name = RAID_TARGET_8,
															arg = {"settings", "raidicon", "hpMarked", "SKULL"}
														}
													}
												}
											}
										},
										ThreatColors = {
											name = L["Threat Colors"],
											order = 1,
											type = "group",
											inline = true,
											args = {
												ThreatGlow = {
													type = "toggle",
													width = "double",
													order = 1,
													name = L["Show Threat Glow"],
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "threatborder", "show"}
												},
												Header = {
													name = L["Colors"],
													type = "header",
													order = 2
												},
												Low = {
													name = L["|cff00ff00Low threat|r"],
													type = "color",
													order = 3,
													get = GetColorAlpha,
													set = SetColorAlpha,
													arg = {"settings", "normal", "threatcolor", "LOW"},
													hasAlpha = true
												},
												Med = {
													name = L["|cffffff00Medium threat|r"],
													type = "color",
													order = 4,
													get = GetColorAlpha,
													set = SetColorAlpha,
													arg = {"settings", "normal", "threatcolor", "MEDIUM"},
													hasAlpha = true
												},
												High = {
													name = L["|cffff0000High threat|r"],
													type = "color",
													get = GetColorAlpha,
													set = SetColorAlpha,
													order = 5,
													arg = {"settings", "normal", "threatcolor", "HIGH"},
													hasAlpha = true
												}
											}
										}
									}
								}
							}
						},
						CastBarSettings = {
							name = L["Castbar"],
							type = "group",
							order = 30,
							args = {
								Toggles = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 1,
									args = {
										CastbarToggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											get = function()
												return (GetCVar("ShowVKeyCastbar") == "1")
											end,
											set = function(info, val)
												SetCVar("ShowVKeyCastbar", abs(GetCVar("ShowVKeyCastbar") - 1))
												Update()
											end,
											arg = {"settings", "castbar", "show"}
										},
										Header1 = {
											type = "header",
											name = L["Non-Target Castbars"],
											order = 2
										},
										SmartCastbarsToggle = {
											name = L["Enable"],
											type = "toggle",
											desc = L["This allows the castbar to attempt to create a castbar on nameplates of players or creatures you have recently moused over."],
											descStyle = "inline",
											width = "double",
											order = 4,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											get = function(info)
												return TidyPlatesOptions.EnableCastWatcher
											end,
											set = function(info, val)
												TidyPlatesOptions.EnableCastWatcher = not TidyPlatesOptions.EnableCastWatcher
												if TidyPlatesOptions.EnableCastWatcher then
													TidyPlates:StartSpellCastWatcher()
												else
													TidyPlates:StopSpellCastWatcher()
												end
											end
										}
									}
								},
								Textures = {
									name = L["Textures"],
									type = "group",
									inline = true,
									order = 1,
									disabled = function()
										return (GetCVar("ShowVKeyCastbar") ~= "1")
									end,
									args = {
										CastBarTexture = {
											name = L["Castbar"],
											type = "select",
											width = "double",
											dialogControl = "LSM30_Statusbar",
											order = 1,
											values = MediaList("statusbar"),
											get = GetValue,
											set = SetLSMTexture,
											arg = {"settings", "castbar", "texture"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return (GetCVar("ShowVKeyCastbar") ~= "1")
									end,
									args = {
										PlacementX = {
											name = L["X"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 2,
											get = GetValue,
											set = function(info, val)
												local b1 = {arg = {"settings", "castborder", "x"}}
												local b2 = {arg = {"settings", "castnostop", "x"}}
												SetThemeValue(b1, val)
												SetThemeValue(b2, val)
												SetThemeValue(info, val)
											end,
											arg = {"settings", "castbar", "x"}
										},
										PlacementY = {
											name = L["Y"],
											type = "range",
											min = -60,
											max = 60,
											step = 1,
											order = 3,
											get = GetValue,
											set = function(info, val)
												local b1 = {arg = {"settings", "castborder", "y"}}
												local b2 = {arg = {"settings", "castnostop", "y"}}
												SetThemeValue(b1, val)
												SetThemeValue(b2, val)
												SetThemeValue(info, val)
											end,
											arg = {"settings", "castbar", "y"}
										}
									}
								},
								Coloring = {
									name = L["Coloring"],
									type = "group",
									inline = true,
									order = 30,
									args = {
										Enable = {
											name = L["Enable Coloring"],
											type = "toggle",
											order = 1,
											set = SetValue,
											get = GetValue,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColor", "toggle"}
										},
										Interruptable = {
											name = L["Interruptable Casts"],
											type = "color",
											order = 2,
											get = GetColorAlpha,
											set = SetColorAlpha,
											disabled = function()
												return (not db.castbarColor.toggle or GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColor"}
										},
										Header1 = {
											type = "header",
											order = 3,
											name = ""
										},
										Enable2 = {
											name = L["Shielded Coloring"],
											type = "toggle",
											order = 4,
											set = SetValue,
											get = GetValue,
											disabled = function()
												return (not db.castbarColor.toggle or GetCVar("ShowVKeyCastbar") ~= "1")
											end,
											arg = {"castbarColorShield", "toggle"}
										},
										Shielded = {
											name = L["Uninterruptable Casts"],
											type = "color",
											order = 5,
											get = GetColorAlpha,
											set = SetColorAlpha,
											disabled = function()
												return (GetCVar("ShowVKeyCastbar") ~= "1" or not db.castbarColor.toggle or not db.castbarColorShield.toggle)
											end,
											arg = {"castbarColorShield"}
										}
									}
								}
							}
						},
						Alpha = {
							name = L["Alpha"],
							type = "group",
							order = 40,
							args = {
								BlizzFadeEnable = {
									name = L["Blizzard Target Fading"],
									type = "group",
									order = 1,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Enable = {
											name = L["Enable Blizzard 'On-Target' Fading"],
											type = "toggle",
											desc = L["Enabling this will allow you to set the alpha adjustment for non-target nameplates."],
											descStyle = "inline",
											order = 1,
											get = GetValue,
											set = SetValue,
											width = "double",
											arg = {"blizzFade", "toggle"}
										},
										Adjustment = {
											name = L["Non-Target Alpha"],
											type = "range",
											order = 2,
											width = "double",
											disabled = function()
												return not db.blizzFade.toggle
											end,
											min = -1,
											max = 0,
											step = 0.01,
											isPercent = true,
											arg = {"blizzFade", "amount"}
										}
									}
								},
								NameplateAlpha = {
									name = L["Alpha Settings"],
									type = "group",
									order = 2,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Neutral = {
											type = "range",
											order = 2,
											name = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
											arg = {"nameplate", "alpha", "Neutral"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Normal = {
											type = "range",
											order = 3,
											name = PLAYER_DIFFICULTY1,
											arg = {"nameplate", "alpha", "Normal"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Elite = {
											type = "range",
											order = 4,
											name = ELITE,
											arg = {"nameplate", "alpha", "Elite"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										},
										Boss = {
											type = "range",
											order = 5,
											name = BOSS,
											arg = {"nameplate", "alpha", "Boss"},
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true
										}
									}
								}
							}
						},
						Scale = {
							name = L["Scale"],
							type = "group",
							order = 50,
							args = {
								NameplateScale = {
									name = L["Scale Settings"],
									type = "group",
									order = 2,
									inline = true,
									get = GetValue,
									set = SetValue,
									args = {
										Neutral = {
											type = "range",
											order = 2,
											name = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
											arg = {"nameplate", "scale", "Neutral"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Normal = {
											type = "range",
											order = 3,
											name = PLAYER_DIFFICULTY1,
											arg = {"nameplate", "scale", "Normal"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Elite = {
											type = "range",
											order = 4,
											name = ELITE,
											arg = {"nameplate", "scale", "Elite"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Boss = {
											type = "range",
											order = 5,
											name = BOSS,
											arg = {"nameplate", "scale", "Boss"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										},
										Target = {
											type = "range",
											order = 5,
											name = STATUS_TEXT_TARGET,
											arg = {"nameplate", "scale", "Target"},
											step = 0.05,
											min = 0.6,
											max = 1.3,
											isPercent = true
										}
									}
								}
							}
						},
						Nametext = {
							name = L["Name Text"],
							type = "group",
							order = 60,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Name Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "name", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.name.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "name", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "flags"}
												},
												Header1 = {
													type = "header",
													order = 3,
													name = ""
												},
												Color = {
													type = "color",
													order = 3,
													name = L["Color"],
													get = GetColor,
													set = SetColor,
													arg = {"settings", "name", "color"},
													hasAlpha = false
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 5,
													type = "toggle",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															descStyle = "inline",
															order = 1,
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "name", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "name", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "name", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						Healthtext = {
							name = L["Health Text"],
							type = "group",
							order = 70,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Health Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "customtext", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										if db.settings.customtext.show then
											return false
										else
											return true
										end
									end,
									args = {
										DisplaySettings = {
											name = L["Display Settings"],
											type = "group",
											order = 0,
											inline = true,
											args = {
												Full = {
													name = L["Text at Full HP"],
													type = "toggle",
													order = 0,
													width = "double",
													desc = L["Display health text on targets with full HP."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "full"}
												},
												EnablePercent = {
													name = L["Percent Text"],
													type = "toggle",
													order = 1,
													width = "double",
													desc = L["Display health percentage text."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "percent"}
												},
												EnableAmount = {
													name = L["Amount Text"],
													type = "toggle",
													order = 2,
													width = "double",
													desc = L["Display health amount text."],
													descStyle = "inline",
													get = GetValue,
													set = SetValue,
													arg = {"text", "amount"}
												},
												AmountSettings = {
													name = L["Amount Text Formatting"],
													type = "group",
													order = 3,
													inline = true,
													get = GetValue,
													set = SetValue,
													disabled = function()
														return not (db.text.amount and db.settings.customtext.show)
													end,
													args = {
														Truncate = {
															name = L["Truncate Text"],
															type = "toggle",
															order = 1,
															width = "double",
															desc = L["This will format text to a simpler format using M or K for millions and thousands. Disabling this will show exact HP amounts."],
															descStyle = "inline",
															arg = {"text", "truncate"}
														},
														MaxHP = {
															name = L["Max HP Text"],
															type = "toggle",
															order = 2,
															width = "double",
															desc = L["This will format text to show both the maximum hp and current hp."],
															descStyle = "inline",
															arg = {"text", "max"}
														},
														Deficit = {
															name = L["Deficit Text"],
															type = "toggle",
															order = 3,
															width = "double",
															desc = L["This will format text to show hp as a value the target is missing."],
															descStyle = "inline",
															arg = {"text", "deficit"}
														}
													}
												}
											}
										},
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "customtext", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															order = 1,
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "customtext", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "customtext", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "customtext", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						SpellText = {
							name = L["Spell Text"],
							type = "group",
							order = 80,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Spell Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "spelltext", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.spelltext.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "spelltext", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															order = 1,
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "spelltext", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "spelltext", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spelltext", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						Leveltext = {
							name = L["Level Text"],
							type = "group",
							order = 90,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Level Text"],
											type = "toggle",
											desc = L["Enables the showing of text on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "level", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.level.show
									end,
									args = {
										FontLooks = {
											name = L["Font"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Font = {
													name = L["Font"],
													type = "select",
													order = 1,
													dialogControl = "LSM30_Font",
													values = AceGUIWidgetLSMlists.font,
													get = GetValue,
													set = SetLSMFont,
													arg = {"settings", "level", "typeface"}
												},
												FontStyle = {
													type = "select",
													order = 2,
													name = L["Font Style"],
													desc = L["Set the outlining style of the text."],
													values = FontStyle,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "flags"}
												},
												Shadow = {
													name = L["Enable Shadow"],
													order = 4,
													type = "toggle",
													width = "double",
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "shadow"}
												}
											}
										},
										FontSize = {
											name = L["Text Bounds and Sizing"],
											type = "group",
											order = 2,
											inline = true,
											args = {
												FontSize = {
													name = L["Font Size"],
													type = "range",
													width = "double",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "size"},
													max = 36,
													min = 6,
													step = 1,
													isPercent = false
												},
												TextBounds = {
													name = L["Text Boundaries"],
													type = "group",
													order = 2,
													args = {
														Description = {
															type = "description",
															name = L["These settings will define the space that text can be placed on the nameplate.\nHaving too large a font and not enough height will cause the text to be not visible."],
															order = 1,
															width = "full"
														},
														Width = {
															type = "range",
															order = 2,
															name = L["Text Width"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "level", "width"},
															max = 250,
															min = 20,
															step = 1,
															isPercent = false
														},
														Height = {
															type = "range",
															order = 3,
															name = L["Text Height"],
															get = GetValue,
															set = SetThemeValue,
															arg = {"settings", "level", "height"},
															max = 40,
															min = 8,
															step = 1,
															isPercent = false
														}
													}
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												AlignH = {
													name = L["Horizontal Align"],
													type = "select",
													order = 3,
													values = AlignH,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "align"}
												},
												AlignV = {
													name = L["Vertical Align"],
													type = "select",
													order = 4,
													values = AlignV,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "level", "vertical"}
												}
											}
										}
									}
								}
							}
						},
						EliteIcon = {
							name = L["Elite Icon"],
							type = "group",
							order = 100,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Elite Icon"],
											type = "toggle",
											desc = L["Enables the showing of the elite icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "eliteicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.eliteicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Preview = {
													name = L["Preview"],
													type = "execute",
													order = 1,
													image = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\EliteArtWidget\\" .. db.settings.eliteicon.theme
												},
												Style = {
													type = "select",
													order = 2,
													name = L["Elite Icon Style"],
													values = {
														default = "Default",
														skullandcross = "Skull and Crossbones"
													},
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															TidyPlatesThemeList["Threat Plates"][themeList[i]][b]["texture"] = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\EliteArtWidget\\" .. val
														end
														options.args.NameplateSettings.args.EliteIcon.args.Options.args.Texture.args.Preview.image = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\EliteArtWidget\\" .. val
														Update()
													end,
													arg = {"settings", "eliteicon", "theme"}
												},
												Header1 = {
													type = "header",
													order = 3,
													name = ""
												},
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["eliteicon"]["width"] = val
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["eliteicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "eliteicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "eliteicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						SkullIcon = {
							name = L["Skull Icon"],
							type = "group",
							order = 110,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Skull Icon"],
											type = "toggle",
											desc = L["Enables the showing of the skull icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "skullicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.skullicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["skullicon"]["width"] = val
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["skullicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "skullicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "skullicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						SpellIcon = {
							name = L["Spell Icon"],
							type = "group",
							order = 120,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Spell Icon"],
											type = "toggle",
											desc = L["Enables the showing of the spell icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "spellicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.spellicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["spellicon"]["width"] = val
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["spellicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "spellicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "spellicon", "anchor"}
												}
											}
										}
									}
								}
							}
						},
						Raidmarks = {
							name = L["Raid Marks"],
							type = "group",
							order = 130,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable Raid Mark Icon"],
											type = "toggle",
											desc = L["Enables the showing of the raid mark icon on nameplates."],
											descStyle = "inline",
											width = "double",
											order = 1,
											get = GetValue,
											set = SetThemeValue,
											arg = {"settings", "raidicon", "show"}
										}
									}
								},
								Options = {
									name = L["Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.settings.raidicon.show
									end,
									args = {
										Texture = {
											name = L["Texture"],
											type = "group",
											inline = true,
											order = 1,
											args = {
												Size = {
													name = L["Size"],
													type = "range",
													width = "double",
													order = 4,
													get = GetValue,
													set = function(info, val)
														local a, b, c, d = info.arg[1], info.arg[2], info.arg[3], info.arg[4]
														db[a][b][c] = val
														for i = 1, #themeList do
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["raidicon"]["width"] = val
															TidyPlatesThemeList["Threat Plates"][themeList[i]]["raidicon"]["height"] = val
														end
														Update()
													end,
													arg = {"settings", "raidicon", "scale"},
													max = 64,
													min = 6,
													step = 1,
													isPercent = false
												}
											}
										},
										Placement = {
											name = L["Placement"],
											order = 3,
											type = "group",
											inline = true,
											args = {
												X = {
													name = L["X"],
													type = "range",
													order = 1,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "x"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Y = {
													name = L["Y"],
													type = "range",
													order = 2,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "y"},
													max = 120,
													min = -120,
													step = 1,
													isPercent = false
												},
												Anchor = {
													name = L["Anchor"],
													type = "select",
													width = "double",
													order = 3,
													values = FullAlign,
													get = GetValue,
													set = SetThemeValue,
													arg = {"settings", "raidicon", "anchor"}
												}
											}
										}
									}
								}
							}
						}
					}
				},
				ThreatOptions = {
					name = L["Threat System"],
					type = "group",
					order = 30,
					args = {
						Enable = {
							name = L["Enable Threat System"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								local iType = select(2, IsInInstance())
								if iType == "party" or iType == "raid" or iType == "none" then
									db.OldSetting = val
								end
							end,
							arg = {"threat", "ON"}
						},
						GeneralSettings = {
							name = L["General Settings"],
							type = "group",
							order = 0,
							disabled = ThreatDisabled,
							args = {
								AdditionalToggles = {
									name = L["Additional Toggles"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										IgnoreNonCombat = {
											type = "toggle",
											name = L["Ignore Non-Combat Threat"],
											order = 1,
											width = "double",
											desc = L["Disables threat feedback from mobs you're currently not in combat with."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "nonCombat"}
										},
										Neutral = {
											type = "toggle",
											name = L["Show Neutral Threat"],
											order = 2,
											width = "double",
											desc = L["Disables threat feedback from neutral mobs regardless of boss or elite levels."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Neutral"}
										},
										Normal = {
											type = "toggle",
											name = L["Show Normal Threat"],
											order = 3,
											width = "double",
											desc = L["Disables threat feedback from normal mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Normal"}
										},
										Elite = {
											type = "toggle",
											name = L["Show Elite Threat"],
											order = 4,
											width = "double",
											desc = L["Disables threat feedback from elite mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Elite"}
										},
										Boss = {
											type = "toggle",
											name = L["Show Boss Threat"],
											order = 5,
											width = "double",
											desc = L["Disables threat feedback from boss level mobs."],
											descStyle = "inline",
											set = SetValue,
											get = GetValue,
											arg = {"threat", "toggle", "Boss"}
										}
									}
								}
							}
						},
						Alpha = {
							name = L["Alpha"],
							type = "group",
							desc = L["Set alpha settings for different threat reaction types."],
							disabled = ThreatDisabled,
							get = GetValue,
							set = SetValue,
							order = 1,
							args = {
								Enable = {
									name = L["Enable Alpha Threat"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Enable = {
											type = "toggle",
											name = L["Enable"],
											desc = L["Enable nameplates to change alpha depending on the levels you set below."],
											width = "double",
											descStyle = "inline",
											order = 2,
											arg = {"threat", "useAlpha"}
										}
									}
								},
								Tank = {
									name = L["|cff00ff00Tank|r"],
									type = "group",
									inline = true,
									order = 1,
									disabled = function()
										return not db.threat.useAlpha
									end,
									args = {
										Low = {
											name = L["|cffff0000Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "tank", "alpha", "LOW"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "tank", "alpha", "MEDIUM"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cff00ff00High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "tank", "alpha", "HIGH"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										}
									}
								},
								DPS = {
									name = L["|cffff0000DPS/Healing|r"],
									type = "group",
									inline = true,
									order = 2,
									disabled = function()
										return not db.threat.useAlpha
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "dps", "alpha", "LOW"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "dps", "alpha", "MEDIUM"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "dps", "alpha", "HIGH"},
											min = 0.01,
											max = 1,
											step = 0.01,
											isPercent = true
										}
									}
								},
								Marked = {
									name = L["Marked Targets"],
									type = "group",
									inline = true,
									order = 3,
									disabled = function()
										return not db.threat.useAlpha
									end,
									args = {
										Toggle = {
											name = L["Ignore Marked Targets"],
											type = "toggle",
											order = 2,
											width = "double",
											desc = L["This will allow you to disabled threat alpha changes on marked targets."],
											descStyle = "inline",
											arg = {"threat", "marked", "alpha"}
										},
										Alpha = {
											name = L["Ignored Alpha"],
											order = 3,
											type = "range",
											disabled = function()
												return not (db.threat.marked.alpha and db.threat.useAlpha)
											end,
											step = 0.05,
											min = 0,
											max = 1,
											isPercent = true,
											arg = {"nameplate", "alpha", "Marked"}
										}
									}
								}
							}
						},
						Scale = {
							name = L["Scale"],
							type = "group",
							desc = L["Set scale settings for different threat reaction types."],
							disabled = ThreatDisabled,
							order = 1,
							get = GetValue,
							set = SetValue,
							args = {
								Enable = {
									name = L["Enable Scale Threat"],
									type = "group",
									inline = true,
									order = 0,
									args = {
										Enable = {
											type = "toggle",
											name = L["Enable"],
											desc = L["Enable nameplates to change scale depending on the levels you set below."],
											descStyle = "inline",
											width = "double",
											order = 2,
											arg = {"threat", "useScale"}
										}
									}
								},
								Tank = {
									name = L["|cff00ff00Tank|r"],
									type = "group",
									inline = true,
									order = 1,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Low = {
											name = L["|cffff0000Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "tank", "scale", "LOW"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "tank", "scale", "MEDIUM"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cff00ff00High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "tank", "scale", "HIGH"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										}
									}
								},
								DPS = {
									name = L["|cffff0000DPS/Healing|r"],
									type = "group",
									inline = true,
									order = 2,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "range",
											order = 1,
											arg = {"threat", "dps", "scale", "LOW"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "range",
											order = 2,
											arg = {"threat", "dps", "scale", "MEDIUM"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "range",
											order = 3,
											arg = {"threat", "dps", "scale", "HIGH"},
											min = 0.01,
											max = 2,
											step = 0.01,
											isPercent = true
										}
									}
								},
								Marked = {
									name = L["Marked Targets"],
									type = "group",
									inline = true,
									order = 3,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Toggle = {
											name = L["Ignore Marked Targets"],
											type = "toggle",
											order = 2,
											width = "double",
											desc = L["This will allow you to disabled threat scale changes on marked targets."],
											descStyle = "inline",
											arg = {"threat", "marked", "scale"}
										},
										Scale = {
											name = L["Ignored Scaling"],
											type = "range",
											order = 3,
											disabled = function()
												return not (db.threat.marked.scale and db.threat.useScale)
											end,
											step = 0.05,
											min = 0.3,
											max = 2,
											isPercent = true,
											arg = {"nameplate", "scale", "Marked"}
										}
									}
								},
								TypeSpecific = {
									name = L["Additional Adjustments"],
									type = "group",
									inline = true,
									order = 4,
									disabled = function()
										return not db.threat.useScale
									end,
									args = {
										Toggle = {
											name = L["Enable Adjustments"],
											order = 1,
											type = "toggle",
											width = "double",
											desc = L["This will allow you to add additional scaling changes to specific mob types."],
											descStyle = "inline",
											arg = {"threat", "useType"}
										},
										AdditionalSliders = {
											name = L["Additional Adjustments"],
											type = "group",
											order = 3,
											inline = true,
											disabled = function()
												return not (db.threat.useType and db.threat.useScale)
											end,
											args = {
												NormalNeutral = {
													name = PLAYER_DIFFICULTY1 .. " & " .. COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
													order = 1,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Normal"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												},
												Elite = {
													name = ELITE,
													order = 2,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Elite"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												},
												Boss = {
													name = BOSS,
													order = 3,
													type = "range",
													width = "double",
													arg = {"threat", "scaleType", "Boss"},
													min = -0.5,
													max = 0.5,
													step = 0.01,
													isPercent = true
												}
											}
										}
									}
								}
							}
						},
						Coloring = {
							name = L["Coloring"],
							type = "group",
							order = 4,
							disabled = ThreatDisabled,
							args = {
								Toggles = {
									name = L["Toggles"],
									order = 1,
									type = "group",
									inline = true,
									args = {
										UseHPColor = {
											name = L["Color HP by Threat"],
											type = "toggle",
											order = 1,
											desc = L["This allows HP color to be the same as the threat colors you set below."],
											descStyle = "inline",
											get = GetValue,
											set = SetValue,
											width = "double",
											arg = {"threat", "useHPColor"}
										}
									}
								},
								Tank = {
									name = L["|cff00ff00Tank|r"],
									type = "group",
									inline = true,
									get = GetColorAlpha,
									set = SetColorAlpha,
									order = 2,
									disabled = function()
										return not db.threat.useHPColor
									end,
									args = {
										Low = {
											name = L["|cffff0000Low threat|r"],
											type = "color",
											order = 1,
											arg = {"settings", "tank", "threatcolor", "LOW"},
											hasAlpha = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "color",
											order = 2,
											arg = {"settings", "tank", "threatcolor", "MEDIUM"},
											hasAlpha = true
										},
										High = {
											name = L["|cff00ff00High threat|r"],
											type = "color",
											order = 3,
											arg = {"settings", "tank", "threatcolor", "HIGH"},
											hasAlpha = true
										}
									}
								},
								DPS = {
									name = L["|cffff0000DPS/Healing|r"],
									type = "group",
									inline = true,
									get = GetColorAlpha,
									set = SetColorAlpha,
									order = 3,
									disabled = function()
										return not db.threat.useHPColor
									end,
									args = {
										Low = {
											name = L["|cff00ff00Low threat|r"],
											type = "color",
											order = 1,
											arg = {"settings", "dps", "threatcolor", "LOW"},
											hasAlpha = true
										},
										Med = {
											name = L["|cffffff00Medium threat|r"],
											type = "color",
											order = 2,
											arg = {"settings", "dps", "threatcolor", "MEDIUM"},
											hasAlpha = true
										},
										High = {
											name = L["|cffff0000High threat|r"],
											type = "color",
											order = 3,
											arg = {"settings", "dps", "threatcolor", "HIGH"},
											hasAlpha = true
										}
									}
								}
							}
						},
						Textures = {
							name = L["Textures"],
							type = "group",
							order = 5,
							desc = L["Set threat textures and their coloring options here."],
							disabled = ThreatDisabled,
							args = {
								ThreatArt = {
									name = L["Enable"],
									type = "group",
									order = 1,
									inline = true,
									args = {
										Enable = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["These options are for the textures shown on nameplates at various threat levels."],
											descStyle = "inline",
											width = "double",
											get = GetValue,
											set = SetValue,
											arg = {"threat", "art", "ON"}
										}
									}
								},
								Options = {
									name = L["Art Options"],
									type = "group",
									order = 2,
									inline = true,
									disabled = function()
										return not db.threat.art.ON
									end,
									get = GetValue,
									set = SetValue,
									args = {
										PrevLow = {
											name = L["Low Threat"],
											type = "execute",
											order = 1,
											width = "double",
											image = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "HIGH",
											imageWidth = 256,
											imageHeight = 64
										},
										PrevMed = {
											name = L["Medium Threat"],
											type = "execute",
											order = 2,
											width = "double",
											image = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "MEDIUM",
											imageWidth = 256,
											imageHeight = 64
										},
										PrevHigh = {
											name = L["High Threat"],
											type = "execute",
											order = 3,
											width = "double",
											image = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ThreatWidget\\" .. db.threat.art.theme .. "\\" .. "LOW",
											imageWidth = 256,
											imageHeight = 64
										},
										Style = {
											name = L["Style"],
											type = "group",
											order = 4,
											inline = true,
											args = {
												Dropdown = {
													name = "",
													type = "select",
													order = 1,
													set = function(info, val)
														SetValue(info, val)
														local i = options.args.ThreatOptions.args.Textures.args.Options.args
														local p = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ThreatWidget\\"
														i.PrevLow.image = p .. db.threat.art.theme .. "\\" .. "HIGH"
														i.PrevMed.image = p .. db.threat.art.theme .. "\\" .. "MEDIUM"
														i.PrevHigh.image = p .. db.threat.art.theme .. "\\" .. "LOW"
													end,
													values = {default = "Default", bar = "Bar Style"},
													arg = {"threat", "art", "theme"}
												}
											}
										},
										Marked = {
											name = L["Marked Targets"],
											type = "group",
											inline = true,
											order = 4,
											args = {
												Toggle = {
													name = L["Ignore Marked Targets"],
													order = 2,
													type = "toggle",
													desc = L["This will allow you to disabled threat art on marked targets."],
													descStyle = "inline",
													width = "double",
													arg = {"threat", "marked", "art"}
												}
											}
										}
									}
								}
							}
						}
					}
				},
				-- Friendly targets (group members' nameplates)
				Widgets = {
					name = L["Widgets"],
					type = "group",
					order = 40,
					args = {
						ComboPointWidget = {
							name = L["Combo Points"],
							type = "group",
							order = 10,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display combo points on your target nameplate."],
											descStyle = "inline",
											width = "double",
											set = SetValue,
											get = GetValue,
											arg = {"comboWidget", "ON"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.comboWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"comboWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											set = SetValue,
											get = GetValue,
											min = -120,
											max = 120,
											step = 1,
											arg = {"comboWidget", "y"}
										}
									}
								}
							}
						},
						DebuffWidget = {
							name = L["Debuffs"],
							type = "group",
							order = 20,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = L["This widget will display debuffs that match your filtering on your target nameplate and others you recently moused over."],
											descStyle = "inline",
											width = "double",
											arg = {"debuffWidget", "ON"}
										}
									}
								},
								Sizing = {
									name = L["Sizing"],
									type = "group",
									order = 15,
									inline = true,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										Scale = {
											name = L["Scale"],
											type = "range",
											order = 1,
											width = "double",
											min = 0.6,
											max = 1.3,
											step = 0.05,
											isPercent = true,
											arg = {"debuffWidget", "scale"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"debuffWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 2,
											min = -120,
											max = 120,
											step = 1,
											arg = {"debuffWidget", "y"}
										},
										Anchor = {
											name = L["Anchor"],
											type = "select",
											order = 3,
											values = FullAlign,
											arg = {"debuffWidget", "anchor"}
										}
									}
								},
								Filtering = {
									name = L["Filtering"],
									order = 30,
									type = "group",
									inline = true,
									disabled = function()
										return not db.debuffWidget.ON
									end,
									args = {
										Mode = {
											name = L["Mode"],
											type = "select",
											order = 1,
											width = "double",
											values = DebuffMode,
											arg = {"debuffWidget", "mode"}
										},
										PurgeArrow = {
											name = "Arrow for dispellable buffs",
											type = "toggle",
											order = 1.6,
											width = "double",
											desc = "A blinking arrow left of the debuff icons when the enemy has a magic or enrage buff that can be purged / dispelled.",
											descStyle = "inline",
											get = function()
												return db.purgeArrow.ON
											end,
											set = function(info, val)
												db.purgeArrow.ON = val
											end
										},
										ShowCC = {
											name = "Also show crowd control from anyone",
											type = "toggle",
											order = 1.5,
											width = "double",
											desc = "Stuns, fears, polymorph, roots, silences... on enemies are shown (with a glow) whoever cast them, besides the debuffs of the selected mode.",
											descStyle = "inline",
											arg = {"debuffWidget", "showCC"}
										},
										ListHelp = {
											type = "description",
											order = 1.9,
											fontSize = "medium",
											name = function()
												local mode = db.debuffWidget.mode
												if mode == "all" or mode == "allMine" then
													return "\nIn this mode no debuff list is needed. To pick debuffs by name, choose a |cffffd100White List|r, |cffffd100Black List|r or |cffffd100By Prefix|r mode above; the list box then appears here."
												end
												return "\nType one spell name per line (exact name, e.g. |cffffd100Corruption|r), then click |cffffd100Accept|r."
											end
										},
										DebuffList = {
											name = function()
												local mode = db.debuffWidget.mode
												if mode == "whitelist" then
													return "White list: show ONLY these debuffs (from anyone)"
												elseif mode == "whitelistMine" then
													return "White list: show only these debuffs, if you cast them"
												elseif mode == "blacklist" then
													return "Black list: show every debuff EXCEPT these"
												elseif mode == "blacklistMine" then
													return "Black list: show your debuffs EXCEPT these"
												elseif mode == "prefix" then
													return "Prefix list: 'All Name' = from anyone, 'My Name' = only yours, 'No Name' = never"
												end
												return "Debuff list"
											end,
											type = "input",
											order = 2,
											dialogControl = "MultiLineEditBox",
											width = "double",
											get = function(info)
												local list = db.debuffWidget.filter
												return TableToString(list)
											end,
											set = function(info, v)
												v = v:trim()
												if v == "" then
													wipe(db.debuffWidget.filter)
												else
													local tbl = {strsplit("\n", v)}
													db.debuffWidget.filter = tbl
												end
											end,
											hidden = function()
												return (db.debuffWidget.mode == "all" or db.debuffWidget.mode == "allMine")
											end
										}
									}
								}
							}
						},
						SocialWidget = {
							name = "Friends & Guild Icon",
							type = "group",
							order = 30,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											desc = "A small icon on the nameplates of players on your friends list (friend icon) or in your guild (guild icon). Only on friendly players, so friendly nameplates must be shown (Shift+V).",
											descStyle = "inline",
											width = "double",
											order = 1,
											arg = {"socialWidget", "ON"}
										}
									}
								},
								Sizing = {
									name = L["Scale"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.socialWidget.ON
									end,
									args = {
										ScaleSlider = {
											name = "",
											type = "range",
											arg = {"socialWidget", "scale"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 30,
									disabled = function()
										return not db.socialWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"socialWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"socialWidget", "y"}
										}
									}
								}
							}
						},
						TargetOfWidget = {
							name = "Mob Target (who is it hitting)",
							type = "group",
							order = 35,
							set = SetValue,
							get = GetValue,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											order = 1,
											desc = "Shows below the nameplate who the mob is attacking, with the role letter when known: [T] Tank, [H] Healer, [D] DPS. Works on mobs targeted by you or a group member, or that you moused over.",
											descStyle = "inline",
											width = "double",
											arg = {"targetOfWidget", "ON"}
										}
									}
								},
								Placement = {
									name = L["Placement"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.targetOfWidget.ON
									end,
									args = {
										X = {
											name = L["X"],
											type = "range",
											order = 1,
											min = -120,
											max = 120,
											step = 1,
											arg = {"targetOfWidget", "x"}
										},
										Y = {
											name = L["Y"],
											type = "range",
											order = 2,
											min = -120,
											max = 120,
											step = 1,
											arg = {"targetOfWidget", "y"}
										},
										Size = {
											name = "Font size",
											type = "range",
											order = 3,
											min = 6,
											max = 24,
											step = 1,
											arg = {"targetOfWidget", "size"}
										}
									}
								}
							}
						},
						ThreatPercent = {
							name = "Threat %",
							type = "group",
							order = 40,
							args = {
								Info = {
									type = "description",
									order = 0,
									fontSize = "medium",
									name = "Your threat as a number above the right end of the health bar, in combat. The game gives threat numbers only for your |cffffd100target|r, the mob under your |cffffd100mouse|r and your |cffffd100focus|r, so only these show it.\n|cffFFA61ADPS|r / |cffFF3333Healer|r: how close you are to pulling aggro; 100% = you pull (white, orange from 70%, red from 90% or when the mob is on you).\n|cff40FF40Tank|r: the highest threat of the others compared to yours; near 100% someone is about to take the mob (green, orange from 70%, red from 90%). Red own % when the mob is not on you.\n"
								},
								Toggle = {
									name = L["Enable"],
									type = "toggle",
									order = 1,
									width = "double",
									get = function()
										return db.threatPercent.ON
									end,
									set = function(info, val)
										db.threatPercent.ON = val
									end
								},
								Size = {
									name = "Font size",
									type = "range",
									order = 2,
									min = 6,
									max = 24,
									step = 1,
									disabled = function()
										return not db.threatPercent.ON
									end,
									get = function()
										return db.threatPercent.size
									end,
									set = function(info, val)
										db.threatPercent.size = val
									end
								},
								X = {
									name = L["X"],
									type = "range",
									order = 3,
									min = -120,
									max = 120,
									step = 1,
									disabled = function()
										return not db.threatPercent.ON
									end,
									get = function()
										return db.threatPercent.x
									end,
									set = function(info, val)
										db.threatPercent.x = val
									end
								},
								Y = {
									name = L["Y"],
									type = "range",
									order = 4,
									min = -60,
									max = 60,
									step = 1,
									disabled = function()
										return not db.threatPercent.ON
									end,
									get = function()
										return db.threatPercent.y
									end,
									set = function(info, val)
										db.threatPercent.y = val
									end
								}
							}
						},
						TargetArtWidget = {
							name = L["Target Highlight"],
							type = "group",
							order = 60,
							args = {
								Enable = {
									name = L["Enable"],
									type = "group",
									inline = true,
									order = 10,
									args = {
										Toggle = {
											name = L["Enable"],
											type = "toggle",
											desc = L["Enables the showing of a texture on your target nameplate"],
											descStyle = "inline",
											width = "double",
											order = 1,
											set = SetValue,
											get = GetValue,
											arg = {"targetWidget", "ON"}
										}
									}
								},
								Style = {
									name = L["Style"],
									type = "group",
									inline = true,
									order = 20,
									disabled = function()
										return not db.targetWidget.ON
									end,
									args = {
										Width = {
											type = "range",
											name = L["Width"],
											order = 10,
											get = GetValue,
											set = SetValue,
											min = 10,
											max = 80,
											step = 0.1,
											bigStep = 1,
											arg = {"targetWidget", "width"}
										},
										Height = {
											type = "range",
											name = L["Height"],
											order = 20,
											get = GetValue,
											set = SetValue,
											min = 10,
											max = 80,
											step = 0.1,
											bigStep = 1,
											arg = {"targetWidget", "height"}
										},
										Color = {
											name = L["Color"],
											type = "color",
											order = 30,
											get = GetColorAlpha,
											set = SetColorAlpha,
											hasAlpha = true,
											arg = {"targetWidget"}
										},
										Invert = {
											type = "toggle",
											name = L["Invert Texture"],
											order = 40,
											get = GetValue,
											set = SetValue,
											arg = {"targetWidget", "inverted"}
										},
									}
								},
								Texture = {
									name = L["Texture"],
									type = "multiselect",
									width = "half",
									order = 30,
									disabled = function()
										return not db.targetWidget.ON
									end,
									get = function(info, key)
										return db.targetWidget.theme == key
									end,
									set = function(info, val)
										SetValue(info, val)
									end,
									arg = {"targetWidget", "theme"}
								}
							}
						}
					}
				},
				About = {
					name = L["About"],
					type = "group",
					order = 80,
					args = {
						Logo = {
							type = "description",
							name = "",
							order = 1,
							width = "double",
							image = path .. "Logo2",
							imageWidth = 256,
							imageHeight = 32
						},
						AboutInfo = {
							type = "description",
							name = "Clear and easy to use nameplate theme for use with TidyPlates.\n\nGrimfall edition by |cff89F559Lidless|r.\nBugs, ideas, feedback: open an issue on GitHub:\n|cff00ff00github.com/Lidless/TidyPlates_ThreatPlates-3.3.5a-Remastered_Grimfall|r",
							order = 2,
							width = "double"
						},
						author = {
							type = "header",
							name = "Original author: |cff3079ffSuicidal Katt|r",
							order = 10
						},
						authorContact = {
							type = "description",
							name = "WoWInterface: |cff00ff00https://www.wowinterface.com/portal.php?&id=593|r",
							order = 11,
							width = "full"
						},
						seperator = {
							type = "description",
							name = " ",
							order = 12,
							width = "full"
						},
						backporter = {
							type = "header",
							name = "Backported by |cfff58cbaKader|r",
							order = 13
						},
						backporterContact = {
							type = "description",
							name = "Contact: |cff00ff00bkader@mail.com|r",
							order = 13.5,
							width = "full"
						},
						seperator2 = {
							type = "description",
							name = " ",
							order = 14,
							width = "full"
						},
						grimfall = {
							type = "header",
							name = "Grimfall & Classless compatible by |cff89F559Lidless|r",
							order = 15
						},
						grimfallInfo = {
							type = "description",
							fontSize = "medium",
							name = "Made compatible with the Grimfall Conquest of Azeroth (CoA) realm with its custom classes, and with the classless realm. Class independent Tank / DPS / Healer role, role based threat warnings and the 'who is the mob attacking' line with [T] / [D] / [H] role letters.",
							order = 16,
							width = "full"
						}
					}
				}
			}
		}
	end
	local TotemOpts = {
		TotemSettings = {
			name = L["|cffffffffTotem Settings|r"],
			type = "group",
			order = 10,
			args = {
				Toggles = {
					name = L["Toggling"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						HideHealth = {
							name = L["Hide Healthbars"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = SetValue,
							arg = {"totemSettings", "hideHealthbar"}
						},
						Header1 = {
							type = "header",
							order = 2,
							name = ""
						},
						ShowEnemy = {
							name = L["Show Enemy Totems"],
							type = "toggle",
							order = 3,
							get = function()
								return (GetCVar("nameplateShowEnemyTotems") == "1")
							end,
							set = function()
								SetCVar("nameplateShowEnemyTotems", abs(GetCVar("nameplateShowEnemyTotems") - 1))
							end
						},
						ShowFriend = {
							name = L["Show Friendly Totems"],
							type = "toggle",
							order = 4,
							get = function()
								return (GetCVar("nameplateShowFriendlyTotems") == "1")
							end,
							set = function()
								SetCVar("nameplateShowFriendlyTotems", abs(GetCVar("nameplateShowFriendlyTotems") - 1))
							end
						}
					}
				},
				Icon = {
					name = L["Icon"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						Enable = {
							name = L["Enable"],
							type = "toggle",
							order = 1,
							set = SetValue,
							get = GetValue,
							arg = {"totemWidget", "ON"}
						},
						Options = {
							name = L["Options"],
							type = "group",
							inline = true,
							order = 2,
							disabled = function()
								return not db.totemWidget.ON
							end,
							set = SetValue,
							get = GetValue,
							args = {
								Header1 = {
									type = "header",
									order = 1,
									name = L["Placement"]
								},
								X = {
									name = L["X"],
									type = "range",
									order = 2,
									min = -120,
									max = 120,
									step = 1,
									arg = {"totemWidget", "x"}
								},
								Y = {
									name = L["Y"],
									type = "range",
									order = 3,
									min = -120,
									max = 120,
									step = 1,
									arg = {"totemWidget", "y"}
								},
								Anchor = {
									name = L["Anchor"],
									type = "select",
									order = 4,
									values = FullAlign,
									arg = {"totemWidget", "anchor"}
								},
								Header2 = {
									type = "header",
									order = 4,
									name = ""
								},
								Scale = {
									name = L["Icon Size"],
									type = "range",
									width = "double",
									order = 5,
									min = 0,
									max = 120,
									step = 1,
									arg = {"totemWidget", "scale"}
								}
							}
						}
					}
				},
				Alpha = {
					name = L["Alpha"],
					type = "group",
					order = 3,
					inline = true,
					get = GetValue,
					set = SetValue,
					args = {
						TotemAlpha = {
							name = L["Totem Alpha"],
							order = 1,
							type = "range",
							width = "double",
							arg = {"nameplate", "alpha", "Totem"},
							step = 0.05,
							min = 0,
							max = 1,
							isPercent = true
						}
					}
				},
				Scale = {
					name = L["Scale"],
					type = "group",
					order = 4,
					inline = true,
					get = GetValue,
					set = SetValue,
					args = {
						TotemAlpha = {
							name = L["Totem Scale"],
							order = 1,
							type = "range",
							width = "double",
							arg = {"nameplate", "scale", "Totem"},
							step = 0.05,
							min = 0.6,
							max = 1.3,
							isPercent = true
						}
					}
				}
			}
		}
	}
	local TotemOpts_OrderCnt = 30
	for k_c, v_c in ipairs(totemID) do
		local totemName = GetSpellInfo(totemID[k_c][1])
		TotemOpts[totemName] = {
			name = "|cff" .. totemID[k_c][3] .. totemName .. "|r",
			type = "group",
			order = TotemOpts_OrderCnt,
			args = {
				Header = {
					name = "> |cff" .. totemID[k_c][3] .. totemName .. "|r <",
					type = "header",
					order = 0
				},
				Enabled = {
					name = L["Enable"],
					type = "group",
					inline = true,
					order = 1,
					args = {
						Toggle = {
							name = L["Show Nameplate"],
							type = "toggle",
							set = SetValue,
							get = GetValue,
							arg = {"totemSettings", totemID[k_c][2], 1}
						}
					}
				},
				HealthColor = {
					name = L["Health Coloring"],
					type = "group",
					order = 2,
					inline = true,
					disabled = function()
						return not db.totemSettings[totemID[k_c][2]][1]
					end,
					args = {
						Enable = {
							name = L["Enable Custom Colors"],
							type = "toggle",
							order = 1,
							get = GetValue,
							set = SetValue,
							arg = {"totemSettings", totemID[k_c][2], 2}
						},
						Color = {
							name = L["Color"],
							type = "color",
							order = 2,
							get = GetColor,
							set = SetColor,
							disabled = function()
								return not (db.totemSettings[totemID[k_c][2]][1] and db.totemSettings[totemID[k_c][2]][2])
							end,
							arg = {"totemSettings", totemID[k_c][2], "color"}
						}
					}
				},
				Textures = {
					name = L["Textures"],
					type = "group",
					order = 3,
					inline = true,
					disabled = function()
						return not db.totemSettings[totemID[k_c][2]][1]
					end,
					args = {
						Icon = {
							name = "",
							type = "execute",
							width = "double",
							order = 0,
							image = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\TotemIconWidget\\" .. db.totemSettings[totemID[k_c][2]][7] .. "\\" .. totemID[k_c][2]
						},
						Style = {
							name = "",
							type = "select",
							order = 1,
							width = "double",
							get = GetValue,
							set = function(info, val)
								SetValue(info, val)
								options.args.NameplateSettings.args.Totems.args[totemName].args.Textures.args.Icon.image = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\TotemIconWidget\\" .. db.totemSettings[totemID[k_c][2]][7] .. "\\" .. totemID[k_c][2]
							end,
							values = {normal = "Normal", special = "Special"},
							arg = {"totemSettings", totemID[k_c][2], 7}
						}
					}
				}
			}
		}
		TotemOpts_OrderCnt = TotemOpts_OrderCnt + 10
	end
	options.args.NameplateSettings.args.Totems.args = TotemOpts

	do
		local arrows = {}
		options.args.Widgets.args.TargetArtWidget.args.Texture.values = arrows
		for i = 0, 72 do
			arrows["arrow" .. i] = "|TInterface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\TargetArtWidget\\arrow" .. i .. ".tga:45:45|t"
		end
	end

	return options
end

local intoptions = nil
local function GetIntOptions()
	if not intoptions then
		intoptions = {
			name = TidyPlatesThreat.title,
			handler = TidyPlatesThreat,
			type = "group",
			args = {
				note = {
					type = "description",
					name = L["You can access the "] .. TidyPlatesThreat.title .. L[" options by typing: /tptp"],
					order = 10
				},
				openoptions = {
					type = "execute",
					name = L["Open Config"],
					image = path .. "Logo",
					width = "double",
					imageWidth = 256,
					imageHeight = 32,
					func = function()
						TidyPlatesThreat:OpenOptions()
					end,
					order = 20
				}
			}
		}
	end
	return intoptions
end

-------------------------------------------------------------------------------
-- Help texts (Grimfall edition): a short explanation at the top of the groups
-- and next to the settings whose purpose is not obvious.
-------------------------------------------------------------------------------
local GROUP_HELP = {
	-- Nameplate Settings
	["NameplateSettings"] = "How the nameplates look: size, colors, texts, icons. These are the normal settings; in combat the |cff89F559Threat System|r can override alpha, scale and colors of mobs that fight you or your group.",
	["NameplateSettings.GeneralSettings.Hiding"] = "Untick a mob type to hide its nameplates completely.",
	["NameplateSettings.GeneralSettings.BlizzSettings"] = "The game's own nameplate switches (the same as in the game's Interface options). Friendly ones are under |cff89F559Nameplate Settings -> Friendly|r.",
	["NameplateSettings.EnemyNameplates"] = "Extra warnings on enemy nameplates: execute line, castbar highlight for important spells, a heal icon above enemy healers and quest marks on mobs you need.",
	["NameplateSettings.HealthBarTexture.Size"] = "Size of the health bar; the whole nameplate is built around it.",
	["NameplateSettings.HealthBarTexture.HealthBarGroup"] = "Look of the health bar. |cffffd100Target|r / |cffffd100Mouseover|r: highlight on the nameplate of your target / of the mob under the mouse.",
	["NameplateSettings.HealthBarTexture.Coloring"] = "Normal health bar colors. Order of priority: raid mark color > threat color (only in combat, |cff89F559Threat System -> Coloring|r) > the colors below.",
	["NameplateSettings.HealthBarTexture.Coloring.ThreatColors"] = "The glowing frame around the health bar for mobs that are |cffffd100not|r handled by the Threat System (a mob type you switched off there, or the Threat System is disabled). Low / Medium / High = your threat on that mob.",
	["NameplateSettings.HealthBarTexture.Coloring.CustomColors"] = "Use these colors instead of the game's colors. Friendly players have their own color: |cff89F559Nameplate Settings -> Friendly|r.",
	["NameplateSettings.HealthBarTexture.Coloring.RaidMarkColors"] = "A mob with a raid mark (skull, cross...) gets the color of its mark; this wins over every other color, also in combat.",
	["NameplateSettings.CastBarSettings"] = "The castbar under enemy nameplates while they cast.",
	["NameplateSettings.CastBarSettings.Coloring"] = "Different castbar colors for casts you can interrupt and for shielded (uninterruptible) casts.",
	["NameplateSettings.Alpha"] = "Transparency of nameplates when the Threat System does not change it (out of combat, or mob types without threat warnings). 1 = fully visible, 0 = invisible.",
	["NameplateSettings.Scale"] = "Size of nameplates when the Threat System does not change it. |cffffd100Target|r: size of your target's nameplate.",
	["NameplateSettings.Nametext"] = "The name of the unit on the nameplate.",
	["NameplateSettings.Healthtext"] = "Health as a number and / or percent on the health bar.",
	["NameplateSettings.SpellText"] = "Name of the spell the enemy is casting, on the castbar.",
	["NameplateSettings.Leveltext"] = "Level of the unit.",
	["NameplateSettings.EliteIcon"] = "Dragon icon on elite mobs.",
	["NameplateSettings.SkullIcon"] = "Skull icon on bosses and mobs far above your level.",
	["NameplateSettings.SpellIcon"] = "Icon of the spell being cast, next to the castbar.",
	["NameplateSettings.Raidmarks"] = "Raid target mark (skull, cross, star...) on the nameplate.",
	["NameplateSettings.Totems"] = "Nameplates of shaman totems: each totem can get its own icon and health bar color, or be hidden.",
	["NameplateSettings.Totems.TotemSettings.Toggles"] = "|cffffd100Hide Healthbars|r: show only the totem icon, without a health bar.",
	-- Threat System
	["ThreatOptions"] = "Threat warnings follow your |cff89F559Role|r. They work |cffffd100only in combat|r and only on mobs that fight you or your group: then the alpha, scale, colors and glowing frame set here |cffffd100override|r the Nameplate Settings. Out of combat the Nameplate Settings apply again.",
	["ThreatOptions.GeneralSettings"] = "These settings only work |cffffd100in combat|r: then they override the normal Nameplate Settings (alpha, scale, colors) of the mobs fighting you or your group. Out of combat the Nameplate Settings apply.\n\nHere: which mob types get threat warnings.",
	["ThreatOptions.Alpha"] = "How visible a warned nameplate is at each threat level (in combat). 1 = fully visible, lower = more transparent.\n|cff00ff00Tank|r: 'Low threat' is the bad state (mob not on you). |cffff0000DPS/Healing|r: 'High threat' is the bad state (mob on you).",
	["ThreatOptions.Scale"] = "How big a warned nameplate is at each threat level (in combat). Bigger = stands out more.\n|cff00ff00Tank|r: 'Low threat' is the bad state. |cffff0000DPS/Healing|r: 'High threat' is the bad state.",
	["ThreatOptions.Scale.TypeSpecific"] = "Extra size added on top of the above for normal, elite and boss mobs.",
	["ThreatOptions.Coloring"] = "Health bar colors at each threat level (in combat); they override the normal health bar colors. A fully transparent color (alpha 0) means: keep the normal color.",
	["ThreatOptions.Textures"] = "The glowing frame around warned nameplates (in combat).",
	["ThreatOptions.Alpha.Marked"] = "Mobs with a raid mark (e.g. crowd controlled ones) can be left out of the threat alpha change.",
	["ThreatOptions.Scale.Marked"] = "Mobs with a raid mark (e.g. crowd controlled ones) can be left out of the threat size change.",
	-- Widgets
	["Widgets"] = "Extra icons and texts on the nameplates.",
	["Widgets.ComboPointWidget"] = "Your combo points on your target's nameplate.",
	["Widgets.DebuffWidget.Filtering"] = "|cffffd100Mode|r: which debuffs are shown. |cffffd100All Debuffs|r = everything; |cffffd100(Mine)|r = only the ones you cast; |cffffd100White List|r = only the debuffs in your list; |cffffd100Black List|r = all except the ones in your list; |cffffd100By Prefix|r = each list line says All / My / No.",
	["Widgets.SocialWidget"] = "Spot your friends and guild members in a crowd (cities, battlegrounds): their nameplate gets a small friend or guild icon. |cffffd100Scale|r = icon size, |cffffd100Placement|r = where the icon sits next to the nameplate.",
	["Widgets.TargetArtWidget"] = "Extra highlight (arrows, frame...) around your current target's nameplate.",
}

local ITEM_HELP = {
	["ThreatOptions.Enable"] = "Master switch of all threat warnings.",
	["NameplateSettings.EnemyNameplates.Execute.Percent"] = "The mark is drawn at this health %.",
	["NameplateSettings.EnemyNameplates.CastHighlight.List"] = "One spell per line, name or spell ID. Interrupted spells are added here automatically if learning is on.",
	["NameplateSettings.Friendly.Players.Mode"] = "Health bar, or only the name (the bar appears while the player is damaged).",
	["NameplateSettings.Friendly.Effects.Dispel"] = "Tick what you can remove; crowd control of these types on group members blinks.",
	["NameplateSettings.HealthBarTexture.Coloring.ThreatColors.ThreatGlow"] = "Show the glowing threat frame around the health bar.",
	["NameplateSettings.HealthBarTexture.Coloring.CustomColors.Enable"] = "Use the colors below instead of the game's colors.",
	["NameplateSettings.HealthBarTexture.Coloring.RaidMarkColors.Enable"] = "Color the health bar of marked mobs by their mark.",
	["NameplateSettings.HealthBarTexture.Coloring.ColorByHPLevel"] = "Green at full health, turning red as health drops. Replaces the colors below.",
	["NameplateSettings.CastBarSettings.Toggles.CastbarToggle"] = "Show a castbar when an enemy casts.",
	["NameplateSettings.CastBarSettings.Coloring.Enable"] = "Color interruptible casts with the color below.",
	["NameplateSettings.CastBarSettings.Coloring.Enable2"] = "Color uninterruptible (shielded) casts with the color below.",
	["NameplateSettings.Alpha.BlizzFadeEnable.Adjustment"] = "How much more transparent the nameplates of non-target units get while you have a target.",
	["NameplateSettings.Totems.TotemSettings.Toggles.HideHealth"] = "Show only the totem icon, no health bar.",
	["Widgets.DebuffWidget.Filtering.Mode"] = "Which debuffs are shown (see the text above).",
	["Widgets.DebuffWidget.Filtering.DebuffList"] = "One spell name per line, then click Accept.",
}

local function FindOption(path)
	local node = options
	for key in string.gmatch(path, "[^%.]+") do
		node = node and node.args and node.args[key]
	end
	return node
end

local function AddHelpTexts()
	for path, text in pairs(GROUP_HELP) do
		local group = FindOption(path)
		if group and group.args then
			-- make room at the top: the help text goes first
			local minOrder
			for _, v in pairs(group.args) do
				if type(v.order) == "number" and v.order >= 0 and (not minOrder or v.order < minOrder) then
					minOrder = v.order
				end
			end
			if minOrder and minOrder <= 0 then
				for _, v in pairs(group.args) do
					if type(v.order) == "number" and v.order >= 0 then
						v.order = v.order + 1
					end
				end
				minOrder = minOrder + 1
			end
			group.args.GrimfallHelp = {
				type = "description",
				order = minOrder and (minOrder / 2) or 0,
				fontSize = "medium",
				name = text .. "\n"
			}
		end
	end
	for path, text in pairs(ITEM_HELP) do
		local item = FindOption(path)
		if item then
			item.desc = text
			if item.type == "toggle" then
				item.descStyle = "inline"
			end
		end
	end
end

function TidyPlatesThreat:OpenOptions(group)
	HideUIPanel(InterfaceOptionsFrame)
	HideUIPanel(GameMenuFrame)
	if not options then
		TidyPlatesThreat:SetUpOptions()
	end
	local dialog = LibStub("AceConfigDialog-3.0")
	dialog:Open("Tidy Plates: Threat Plates")
	if type(group) == "string" then
		dialog:SelectGroup("Tidy Plates: Threat Plates", group)
	end
end

function TidyPlatesThreat:ChatCommand(input)
	TidyPlatesThreat:OpenOptions()
end

function TidyPlatesThreat:ConfigRefresh()
	db = self.db.profile
	Update()
end

function TidyPlatesThreat:SetUpInitialOptions()
	self:RegisterChatCommand("tptp", "ChatCommand")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Tidy Plates: Threat Plates Dialog", GetIntOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Tidy Plates: Threat Plates Dialog", "Tidy Plates: Threat Plates")
end

function TidyPlatesThreat:SetUpOptions()
	db = self.db.profile

	GetOptions()
	AddHelpTexts()



	LibStub("AceConfig-3.0"):RegisterOptionsTable("Tidy Plates: Threat Plates", options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Tidy Plates: Threat Plates", 750, 600)
end