TidyPlatesThreat = LibStub("AceAddon-3.0"):NewAddon("TidyPlatesThreat", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TidyPlatesThreat", false)
local DB

local PlayerClass = select(2, UnitClass("player"))
local HEX_CLASS_COLOR = {
	SHAMAN = "2459FF",
	MAGE = "69CCF0",
	WARLOCK = "9482C9",
	HUNTER = "ABD473",
	ROGUE = "FFF569",
	PRIEST = "FFFFFF",
	DRUID = "FF7D0A",
	DEATHKNIGHT = "C41F3B",
	WARRIOR = "C79C6E",
	PALADIN = "F58CBA"
}
-- Custom-class safe class color (Grimfall CoA has non-standard class tokens)
local function ClassHex(class)
	class = class or PlayerClass
	if class and HEX_CLASS_COLOR[class] then
		return HEX_CLASS_COLOR[class]
	end
	local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	if c and c.r and c.g and c.b then
		return string.format("%02X%02X%02X", math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
	end
	return "FFFFFF"
end
--

TidyPlatesThemeList = TidyPlatesThemeList or {}
TidyPlatesThemeList["Threat Plates"] = {}

-- Callback Functions
function TidyPlatesThreat:ProfChange()
	TidyPlatesThreat:ConfigRefresh()
end

-----------------------------------------------------------------------------
-- Role selection (class independent: Tank / DPS / Healer)
-----------------------------------------------------------------------------
local VALID_ROLES = {TANK = true, DPS = true, HEALER = true}
TidyPlatesThreat.ROLE_COLOR = {
	TANK = {r = 0.25, g = 1, b = 0.25, hex = "40FF40"}, -- green
	DPS = {r = 1, g = 0.65, b = 0.1, hex = "FFA61A"}, -- orange
	HEALER = {r = 1, g = 0.2, b = 0.2, hex = "FF3333"} -- red: a mob on the healer is the biggest danger
}
TidyPlatesThreat.ROLE_LETTER = {TANK = "T", HEALER = "H", DPS = "D"}
TidyPlatesThreat.ROLE_NAME = {TANK = "Tank", HEALER = "Healer", DPS = "DPS"}

function TidyPlatesThreat:GetRole()
	local char = self.db and self.db.char
	local role = char and char.role
	if not VALID_ROLES[role] then
		role = "DPS"
	end
	return role
end

function TidyPlatesThreat:SetRole(role, silent)
	role = role and string.upper(role)
	if role == "HEAL" or role == "HEALS" then
		role = "HEALER"
	end
	if not VALID_ROLES[role] then
		return
	end
	local char = self.db.char
	char.role = role
	char.roleChosen = true
	char.threat.tanking = (role == "TANK")
	self.db.profile.threat.ON = true
	if self.RoleChanged then
		self.RoleChanged() -- lets group members know (TargetOfWidget.lua)
	end
	if self.UpdateMinimapButton then
		self:UpdateMinimapButton()
	end
	if not silent and self.db.profile.verbose then
		print("|cff89F559Threat Plates|r: your role is now " .. self:roleText() .. ".")
	end
	if TidyPlates and TidyPlates.ForceUpdate then
		TidyPlates:ForceUpdate()
	end
end

function TidyPlatesThreat:roleText()
	local role = self:GetRole()
	return "|cff" .. self.ROLE_COLOR[role].hex .. self.ROLE_NAME[role] .. "|r"
end

function TidyPlatesThreat:OnInitialize()
	local defaults = {
		char = {
			welcome = false,
			role = "DPS", -- TANK / DPS / HEALER, chosen by the player (/tptp -> Role)
			roleChosen = false,
			threat = {tanking = false}
		},
		profile = {
			cache = {},
			OldSetting = true,
			verbose = true,
			blizzFade = {toggle = true, amount = -0.3},
			healthColorChange = false,
			customColor = true,
			allowClass = true,
			friendlyClass = false,
			friendlyNameOnly = false,
			friendlyClickThrough = false,
			friendlyClassIcon = true,
			cacheClass = false,
			castbarColor = {toggle = true, r = 1, g = 0, b = 0.8549019607843137, a = 1},
			castbarColorShield = {toggle = true, r = 0.1019607843137255, g = 0.09803921568627451, b = 0.7294117647058823, a = 1},
			aHPbarColor = {r = 0, g = 1, b = 0},
			bHPbarColor = {r = 1, g = 0, b = 0},
			fHPbarColor = {r = 0.2862745098039216, g = 0.8352941176470589, b = 0.4431372549019608},
			nHPbarColor = {r = 1, g = 0.9058823529411765, b = 0.196078431372549},
			HPbarColor = {r = 1, g = 0.2627450980392157, b = 0.2941176470588235},
			tHPbarColor = {r = 0, g = 0.5, b = 1},
			totemSettings = {
				hideHealthbar = true,
				-- Air Totems
				["A1"] = {true, true, true, nil, nil, nil, "special", color = {r = 0.67, g = 1, b = 1}},
				["A2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				["A6"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.67, g = 1, b = 1}},
				-- Earth Totems
				["E1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.7, b = 0.12}},
				["E6"] = {true, true, true, nil, nil, nil, "special", color = {r = 1, g = 0.7, b = 0.12}},
				-- Fire Totems
				["F1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F5"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				["F6"] = {true, true, true, nil, nil, nil, "normal", color = {r = 1, g = 0.4, b = 0.4}},
				-- Water Totems
				["W1"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W2"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W3"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W4"] = {true, true, true, nil, nil, nil, "normal", color = {r = 0.58, g = 0.72, b = 1}},
				["W5"] = {true, true, true, nil, nil, nil, "special", color = {r = 0.58, g = 0.72, b = 1}}
			},
			uniqueSettings = {
				list = {},
				["**"] = {
					name = "",
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 1, b = 1}
				},
				[1] = {
					name = L["Shadow Fiend"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = false,
					overrideScale = true,
					overrideAlpha = true,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U1",
					scale = 0.9,
					alpha = 0.9,
					color = {r = 0.61, g = 0.40, b = 0.86}
				},
				[2] = {
					name = L["Spirit Wolf"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = true,
					overrideAlpha = true,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U2",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.32, g = 0.7, b = 0.89}
				},
				[3] = {
					name = L["Ebon Gargoyle"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U3",
					scale = 0.45,
					alpha = 1,
					color = {r = 1, g = 0.71, b = 0}
				},
				[4] = {
					name = L["Water Elemental"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = true,
					overrideAlpha = true,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U4",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.33, g = 0.72, b = 0.44}
				},
				[5] = {
					name = L["Treant"],
					showNameplate = true,
					showIcon = true,
					useStyle = true,
					useColor = false,
					allowMarked = true,
					overrideScale = true,
					overrideAlpha = true,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U5",
					scale = 0.45,
					alpha = 1,
					color = {r = 1, g = 0.71, b = 0}
				},
				[6] = {},
				[7] = {},
				[8] = {
					name = L["Army of the Dead Ghoul"],
					showNameplate = false,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U7",
					scale = 0.45,
					alpha = 1,
					color = {r = 0.87, g = 0.78, b = 0.88}
				},
				[9] = {
					name = L["Shadowy Apparition"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U8",
					scale = 1,
					alpha = 1,
					color = {r = 0.62, g = 0.19, b = 1}
				},
				[10] = {
					name = L["Shambling Horror"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U9",
					scale = 1,
					alpha = 1,
					color = {r = 0.69, g = 0.26, b = 0.25}
				},
				[11] = {
					name = L["Web Wrap"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U10",
					scale = 0.75,
					alpha = 1,
					color = {r = 1, g = 0.39, b = 0.96}
				},
				[12] = {
					name = L["Immortal Guardian"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U11",
					scale = 1,
					alpha = 1,
					color = {r = 0.33, g = 0.33, b = 0.33}
				},
				[13] = {
					name = L["Marked Immortal Guardian"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U12",
					scale = 1,
					alpha = 1,
					color = {r = 0.75, g = 0, b = 0.02}
				},
				[14] = {
					name = L["Empowered Adherent"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U13",
					scale = 1,
					alpha = 1,
					color = {r = 0.29, g = 0.11, b = 1}
				},
				[15] = {
					name = L["Deformed Fanatic"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U14",
					scale = 1,
					alpha = 1,
					color = {r = 0.55, g = 0.7, b = 0.29}
				},
				[16] = {
					name = L["Reanimated Adherent"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U15",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 0.88, b = 0.61}
				},
				[17] = {
					name = L["Reanimated Fanatic"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U15",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 0.88, b = 0.61}
				},
				[18] = {
					name = L["Bone Spike"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U16",
					scale = 1,
					alpha = 1,
					color = {r = 1, g = 1, b = 1}
				},
				[19] = {
					name = L["Onyxian Whelp"],
					showNameplate = false,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U17",
					scale = 1,
					alpha = 1,
					color = {r = 0.33, g = 0.28, b = 0.71}
				},
				[20] = {
					name = L["Gas Cloud"],
					showNameplate = false,
					showIcon = true,
					useStyle = true,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U18",
					scale = 1,
					alpha = 1,
					color = {r = 0.96, g = 0.56, b = 0.07}
				},
				[21] = {
					name = L["Volatile Ooze"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U19",
					scale = 1,
					alpha = 1,
					color = {r = 0.36, g = 0.95, b = 0.33}
				},
				[22] = {
					name = L["Darnavan"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U20",
					scale = 1,
					alpha = 1,
					color = {r = 0.78, g = 0.61, b = 0.43}
				},
				[23] = {
					name = L["Val'kyr Shadowguard"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U21",
					scale = 1,
					alpha = 1,
					color = {r = 0.47, g = 0.89, b = 1}
				},
				[24] = {
					name = L["Kinetic Bomb"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U22",
					scale = 1,
					alpha = 1,
					color = {r = 0.91, g = 0.71, b = 0.1}
				},
				[25] = {
					name = L["Lich King"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U23",
					scale = 1,
					alpha = 1,
					color = {r = 0.77, g = 0.12, b = 0.23}
				},
				[26] = {
					name = L["Raging Spirit"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U24",
					scale = 1,
					alpha = 1,
					color = {r = 0.77, g = 0.27, b = 0}
				},
				[27] = {
					name = L["Drudge Ghoul"],
					showNameplate = true,
					showIcon = false,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U25",
					scale = 0.85,
					alpha = 1,
					color = {r = 0.43, g = 0.43, b = 0.43}
				},
				[28] = {
					name = L["Living Inferno"],
					showNameplate = true,
					showIcon = true,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U27",
					scale = 1,
					alpha = 1,
					color = {r = 0, g = 1, b = 0}
				},
				[29] = {
					name = L["Living Ember"],
					showNameplate = true,
					showIcon = false,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\UniqueIconWidget\\U28",
					scale = 0.60,
					alpha = 0.75,
					color = {r = 0.25, g = 0.25, b = 0.25}
				},
				[30] = {
					name = L["Fanged Pit Viper"],
					showNameplate = false,
					showIcon = false,
					useStyle = false,
					useColor = true,
					allowMarked = true,
					overrideScale = false,
					overrideAlpha = false,
					icon = "",
					scale = 0,
					alpha = 0,
					color = {r = 1, g = 1, b = 1}
				},
				[31] = {},
				[32] = {},
				[33] = {},
				[34] = {},
				[35] = {},
				[36] = {},
				[37] = {},
				[38] = {},
				[39] = {},
				[40] = {},
				[41] = {},
				[42] = {},
				[43] = {},
				[44] = {},
				[45] = {},
				[46] = {},
				[47] = {},
				[48] = {},
				[49] = {},
				[50] = {}
			},
			text = {
				amount = true,
				percent = true,
				full = false,
				max = false,
				deficit = false,
				truncate = true
			},
			totemWidget = {
				ON = true,
				scale = 35,
				x = 0,
				y = 35,
				level = 1,
				anchor = "CENTER"
			},
			debuffWidget = {
				ON = false,
				x = 32,
				y = 32,
				mode = "all",
				scale = 1,
				anchor = "CENTER",
				filter = {}
			},
			uniqueWidget = {
				ON = true,
				scale = 35,
				x = 0,
				y = 35,
				level = 1,
				anchor = "CENTER"
			},
			classWidget = {
				ON = false,
				scale = 15,
				x = -70,
				y = 0,
				theme = "default",
				anchor = "CENTER"
			},
			targetWidget = {
				ON = false,
				theme = "arrow0",
				width = 30,
				height = 30,
				r = 1,
				g = 0.8509803921568627,
				b = 0.2666666666666667,
				a = 1,
				inverted = true
			},
			minimap = {
				hide = false,
				angle = 225
			},
			targetOfWidget = {
				ON = true,
				x = 0,
				y = -28,
				size = 11,
				anchor = "CENTER"
			},
			threatWidget = {
				ON = false,
				x = 0,
				y = 26,
				anchor = "CENTER"
			},
			tankedWidget = {
				ON = false,
				scale = 16,
				x = 65,
				y = 6,
				anchor = "CENTER"
			},
			comboWidget = {
				ON = false,
				scale = 64,
				x = 0,
				y = -8
			},
			eliteWidget = {
				ON = true,
				theme = "default",
				scale = 15,
				x = 64,
				y = 9,
				anchor = "CENTER"
			},
			socialWidget = {
				ON = false,
				scale = 16,
				x = 75,
				y = 0,
				anchor = "CENTER"
			},
			clickthrough = {
				friendly = false,
				enemy = false,
			},
			settings = {
				frame = {
					y = 0,
					x = 0,
					width = 124
				},
				highlight = {
					texture = "TP_HealthBarHighlight",
					width = 260
				},
				target = {
					texture = "TP_Target"
				},
				elitehealthborder = {
					texture = "TP_HealthBarEliteOverlay",
					show = true
				},
				healthborder = {
					texture = "TP_HealthBarOverlay",
					backdrop = "",
					show = true,
					width = 260
				},
				threatborder = {
					show = false,
					width = 260
				},
				healthbar = {
					texture = "ElvUI Norm",
					width = 120,
					height = 10
				},
				castnostop = {
					texture = "TP_CastBarLock",
					x = 0,
					y = -15,
					show = true,
					width = 260
				},
				castborder = {
					texture = "TP_CastBarOverlay",
					x = 0,
					y = -15,
					show = true,
					width = 260
				},
				castbar = {
					texture = "Solid",
					x = 0,
					y = -15,
					show = true,
					width = 120
				},
				name = {
					typeface = "Expressway",
					width = 200,
					height = 14,
					size = 11,
					x = 0,
					y = 10,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "OUTLINE",
					color = {
						r = 1,
						g = 1,
						b = 1
					},
					show = true
				},
				level = {
					typeface = "Expressway",
					size = 12,
					width = 20,
					height = 15,
					x = 50,
					y = 0,
					align = "RIGHT",
					vertical = "TOP",
					shadow = true,
					flags = "OUTLINE",
					show = true
				},
				eliteicon = {
					show = true,
					theme = "default",
					scale = 15,
					x = 70,
					y = 10,
					level = 22,
					anchor = "CENTER"
				},
				customtext = {
					typeface = "Accidental Presidency",
					size = 12,
					width = 110,
					height = 14,
					x = 0,
					y = 1,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "NONE",
					show = false
				},
				spelltext = {
					typeface = "Expressway",
					size = 10,
					width = 120,
					height = 14,
					x = 0,
					y = -14,
					align = "CENTER",
					vertical = "CENTER",
					shadow = true,
					flags = "OUTLINE",
					show = true
				},
				raidicon = {
					scale = 35,
					x = -35,
					y = 0,
					anchor = "LEFT",
					hpColor = false,
					show = true,
					hpMarked = {
						STAR = {r = 0.85, g = 0.81, b = 0.27},
						MOON = {r = 0.60, g = 0.75, b = 0.85},
						CIRCLE = {r = 0.93, g = 0.51, b = 0.06},
						SQUARE = {r = 0, g = 0.64, b = 1},
						DIAMOND = {r = 0.7, g = 0.06, b = 0.84},
						CROSS = {r = 0.82, g = 0.18, b = 0.18},
						TRIANGLE = {r = 0.14, g = 0.66, b = 0.14},
						SKULL = {r = 0.89, g = 0.83, b = 0.74}
					}
				},
				spellicon = {
					scale = 15,
					x = -75,
					y = -14,
					anchor = "CENTER",
					show = true
				},
				customart = {
					scale = 22,
					x = -74,
					y = -7,
					anchor = "CENTER",
					show = true
				},
				skullicon = {
					scale = 16,
					x = 70,
					y = -5,
					anchor = "CENTER",
					show = true
				},
				unique = {
					threatcolor = {
						LOW = {r = 0, g = 0, b = 0, a = 0},
						MEDIUM = {r = 0, g = 0, b = 0, a = 0},
						HIGH = {r = 0, g = 0, b = 0, a = 0}
					}
				},
				totem = {
					threatcolor = {
						LOW = {r = 0, g = 0, b = 0, a = 0},
						MEDIUM = {r = 0, g = 0, b = 0, a = 0},
						HIGH = {r = 0, g = 0, b = 0, a = 0}
					}
				},
				normal = {
					threatcolor = {
						LOW = {r = 1, g = 1, b = 1, a = 1},
						MEDIUM = {r = 1, g = 1, b = 0, a = 1},
						HIGH = {r = 1, g = 0.2549019607843137, b = 0.2313725490196079, a = 1}
					}
				},
				dps = {
					threatcolor = {
						LOW = {r = 1, g = 0.9058823529411765, b = 0, a = 0},
						MEDIUM = {r = 1, g = 0.6039215686274509, b = 0, a = 1},
						HIGH = {r = 1, g = 0.1450980392156863, b = 0.1607843137254902, a = 1}
					}
				},
				tank = {
					threatcolor = {
						LOW = {r = 1, g = 0.1450980392156863, b = 0.1607843137254902, a = 1},
						MEDIUM = {r = 1, g = 1, b = 0, a = 1},
						HIGH = {r = 0, g = 1, b = 0, a = 1}
					}
				}
			},
			threat = {
				ON = true,
				nonCombat = true,
				hideNonCombat = false,
				useType = true,
				useScale = true,
				useAlpha = true,
				useHPColor = true,
				art = {
					ON = true,
					theme = "default"
				},
				scaleType = {
					["Normal"] = -0.2,
					["Elite"] = 0,
					["Boss"] = 0.2
				},
				toggle = {
					["Boss"] = true,
					["Elite"] = true,
					["Normal"] = true,
					["Neutral"] = true
				},
				dps = {
					scale = {
						LOW = 1,
						MEDIUM = 1.15,
						HIGH = 1.35
					},
					alpha = {
						LOW = 1,
						MEDIUM = 1,
						HIGH = 1
					}
				},
				tank = {
					scale = {
						LOW = 1.25,
						MEDIUM = 0.9,
						HIGH = 0.8
					},
					alpha = {
						LOW = 1,
						MEDIUM = 0.85,
						HIGH = 0.75
					}
				},
				marked = {
					alpha = false,
					art = false,
					scale = false
				}
			},
			nameplate = {
				toggle = {
					["Boss"] = true,
					["Elite"] = true,
					["Normal"] = true,
					["Neutral"] = true,
					["Totem"] = true
				},
				scale = {
					["Totem"] = 0.75,
					["Boss"] = 0.95,
					["Elite"] = 0.95,
					["Normal"] = 0.95,
					["Target"] = 1,
					["Neutral"] = 0.95,
					["Marked"] = 1
				},
				alpha = {
					["Totem"] = 1,
					["Boss"] = 0.9,
					["Elite"] = 0.7,
					["Normal"] = 0.7,
					["Neutral"] = 0.7,
					["Marked"] = 1
				}
			}
		}
	}
	local db = LibStub("AceDB-3.0"):New("ThreatPlatesDB", defaults, "Default")
	self.db = db

	-- dual spec profiles

	local RegisterCallback = db.RegisterCallback

	RegisterCallback(self, "OnProfileChanged", "ProfChange")
	RegisterCallback(self, "OnProfileCopied", "ProfChange")
	RegisterCallback(self, "OnProfileReset", "ProfChange")

	self:SetUpInitialOptions()
end

local UnitInGroup = TidyPlatesUtility.UnitInGroup
local TotemNameFallback = TidyPlatesUtility.TotemNameFallback
-- Unit Classification
function TidyPlatesThreat.UnitType(unit)
	DB = TidyPlatesThreat.db.profile
	local totem = TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]

	-- a totem?
	if totem then
		return "Totem"
	end

	-- a unique unit?
	local unique = tContains(DB.uniqueSettings.list, unit.name)
	if unique then
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if k_v == unit.name then
				if DB.uniqueSettings[k_c].useStyle then
					return "Unique"
				else
					if (unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Boss"
					elseif (unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Elite"
					elseif (not unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
						return "Normal"
					elseif unit.reaction == "NEUTRAL" then
						return "Neutral"
					end
				end
			end
		end
	end

	-- a group member with hidden nameplates?
	if (tContains(DB.uniqueSettings.list, "GROUP") and unit.name and UnitInGroup(unit.name)) then
		if DB.friendlyNameOnly then
			return "Normal", true
		end
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if k_v == "GROUP" then
				if DB.uniqueSettings[k_c].useStyle then
					return "Unique", true
				else
					return "Normal", true
				end
			end
		end
	end

	-- aboss?
	if (unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Boss"
	end

	-- an elite?
	if (unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Elite"
	end

	-- just an oridinary unit?
	if (not unit.isElite and not unit.isDangerous and (unit.reaction == "FRIENDLY" or unit.reaction == "HOSTILE")) then
		return "Normal"
	end

	-- a neutral unit?
	if unit.reaction == "NEUTRAL" then
		return "Neutral"
	end

	-- well, fallback to normal.
	return "Normal"
end

function TidyPlatesThreat.SetStyle(unit)
	DB = TidyPlatesThreat.db.profile
	local T, custom = TidyPlatesThreat.UnitType(unit)
	if T == "Totem" then
		local tS = DB.totemSettings[TPtotemList[unit.name] or TPtotemList[TotemNameFallback(unit.name)]]
		if tS[1] then
			if DB.totemSettings.hideHealthbar then
				return "etotem"
			else
				return "totem"
			end
		else
			return "empty"
		end
	elseif T == "Unique" then
		for k_c, k_v in pairs(DB.uniqueSettings.list) do
			if custom and k_v == "GROUP" then
				if DB.friendlyNameOnly then
					return "text"
				elseif DB.uniqueSettings[k_c].showNameplate then
					return "unique", true
				else
					return "empty", true
				end
			elseif k_v == unit.name then
				if DB.uniqueSettings[k_c].showNameplate then
					return "unique"
				else
					return "empty"
				end
			end
		end
	elseif T then
		if unit.reaction == "HOSTILE" or unit.reaction == "NEUTRAL" then
			if DB.nameplate.toggle[T] then
				if DB.threat.toggle[T] and DB.threat.ON and unit.class == "UNKNOWN" and InCombatLockdown() then
					if DB.threat.nonCombat then
						if unit.isInCombat or (unit.health < unit.healthmax) then
							if TidyPlatesThreat.db.char.threat.tanking then
								return "tank"
							else
								return "dps"
							end
						else
							if not DB.threat.hideNonCombat then
								return "normal"
							else
								return "empty"
							end
						end
					else
						if TidyPlatesThreat.db.char.threat.tanking then
							return "tank"
						else
							return "dps"
						end
					end
				else
					return "normal"
				end
			else
				return "empty"
			end
		elseif unit.reaction == "FRIENDLY" then
			if DB.friendlyNameOnly then
				return "text"
			elseif DB.nameplate.toggle[T] then
				return "normal"
			else
				return "empty"
			end
		else
			return "empty"
		end
	else
		return "empty"
	end
end

local function ShowConfigPanel()
	TidyPlatesThreat:OpenOptions()
end
------------
-- EVENTS --
------------
function TidyPlatesThreat:StartUp()
	local char = self.db.char
	-- This addon is the theme: always use Threat Plates in Tidy Plates (both specs), no question asked.
	-- Runs before PLAYER_ENTERING_WORLD, when Tidy Plates loads the selected theme.
	if TidyPlatesOptions and (TidyPlatesOptions.primary ~= "Threat Plates" or TidyPlatesOptions.secondary ~= "Threat Plates") then
		TidyPlatesOptions.primary = "Threat Plates"
		TidyPlatesOptions.secondary = "Threat Plates"
		print("|cff89F559Threat Plates|r: set as the Tidy Plates theme.")
	end
	-- Role is chosen by the player, independent of class/talents/stances
	char.threat.tanking = (self:GetRole() == "TANK")

	-- Welcome Setup / Display
	if not char.welcome then
		char.welcome = true
		if self.db.profile.verbose then
			print("|cff89f559Welcome to |rTidy Plates: |cff89f559Threat Plates!|r")
			print(L["|cff89f559Additional options can be found by typing |r'/tptp'|cff89F559.|r"])
		end
		if GetCVar("ShowVKeyCastbar") == "1" then
			self.db.profile.settings.castbar.show = true
		else
			self.db.profile.settings.castbar.show = false
		end
	end

	self:RoleReminder()
end

-- Reminds the player to pick a role until they did (DPS is the default)
function TidyPlatesThreat:RoleReminder()
	if not self.db.char.roleChosen then
		print("|cff89F559Threat Plates|r: you have not chosen a role yet, using the default: " .. self:roleText() .. ". Choose |cff40FF40Tank|r, |cffFFA61ADPS|r or |cffFF3333Healer|r in |cff89F559/tptp|r -> Role, or type |cff89F559/tptprole tank||dps||heal|r. Help: |cff89F559/tptp|r -> Help.")
	end
end
--
local f = CreateFrame("Frame")
local function EventHandler(self, event, ...)
	DB = TidyPlatesThreat.db.profile
	local CharDB = TidyPlatesThreat.db.char
	local arg1, arg2 = ...
	if event == "ADDON_LOADED" then
		if arg1 == "TidyPlates_ThreatPlates" then
			local setup = {
				SetStyle = TidyPlatesThreat.SetStyle,
				SetScale = TidyPlatesThreat.SetScale,
				SetAlpha = TidyPlatesThreat.SetAlpha,
				SetCustomText = TidyPlatesThreat.SetCustomText,
				SetNameColor = TidyPlatesThreat.SetNameColor,
				SetThreatColor = TidyPlatesThreat.SetThreatColor,
				SetCastbarColor = TidyPlatesThreat.SetCastbarColor,
				SetHealthbarColor = TidyPlatesThreat.SetHealthbarColor,
				ShowConfigPanel = ShowConfigPanel
			}
			TidyPlatesThemeList["Threat Plates"] = setup
		end
		f:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		TidyPlatesThreat:StartUp()
		if GetCVar("nameplateShowEnemyTotems") == "1" then
			DB.nameplate.toggle["Totem"] = true
		else
			DB.nameplate.toggle["Totem"] = false
		end
		SetCVar("ShowClassColorInNameplate", 1)

		if CharDB.welcome and ((TidyPlatesOptions.primary == "Threat Plates") or (TidyPlatesOptions.secondary == "Threat Plates")) and DB.verbose then
			print(L["|cff89f559Threat Plates:|r Welcome back |cff"] .. ClassHex() .. (UnitName("player") or "") .. "|r!! Role: " .. TidyPlatesThreat:roleText())
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		local iType = select(2, IsInInstance())
		if iType == "arena" or iType == "pvp" then
			DB.threat.ON = false
		elseif iType == "party" or iType == "raid" or iType == "none" then
			DB.threat.ON = DB.OldSetting
		end
		DB.cache = {}
		CharDB.threat.tanking = (TidyPlatesThreat:GetRole() == "TANK")
		-- remind again when entering a dungeon / raid without a chosen role
		if iType == "party" or iType == "raid" then
			TidyPlatesThreat:RoleReminder()
		end
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		if DB.threat.ON and (GetCVar("threatWarning") ~= 3) then
			SetCVar("threatWarning", 3)
		elseif not DB.threat.ON and (GetCVar("threatWarning") ~= 0) then
			SetCVar("threatWarning", 0)
		end
	elseif event == "PLAYER_LOGOUT" then
		DB.cache = {}
	elseif event == "RAID_TARGET_UPDATE" then
		TidyPlates:Update()
	end
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("RAID_TARGET_UPDATE")
f:SetScript("OnEvent", EventHandler)