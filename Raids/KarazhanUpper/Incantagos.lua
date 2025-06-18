local module, L = BigWigs:ModuleDeclaration("Ley-Watcher Incantagos", "Karazhan")

-- module variables
module.revision = 30002
module.enabletrigger = module.translatedName
module.toggleoptions = { "leyline", "summonseeker", "summonwhelps", "affinity", "beam", "cursewarning", "proximity", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

-- module defaults
module.defaultDB = {
	leyline = true,
	summonseeker = true,
	summonwhelps = true,
	affinity = true,
	beam = true,
	cursewarning = true,
	proximity = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "Incantagos",

		leyline_cmd = "leyline",
		leyline_name = "Ley-Line Disturbance Alert",
		leyline_desc = "Warns when Ley-Watcher Incantagos casts Ley-Line Disturbance",

		summonseeker_cmd = "summonseeker",
		summonseeker_name = "Summon Ley-Seeker Alert",
		summonseeker_desc = "Warns when Ley-Watcher Incantagos summons Manascale Ley-Seeker",

		summonwhelps_cmd = "summonwhelps",
		summonwhelps_name = "Summon Whelps Alert",
		summonwhelps_desc = "Warns when Ley-Watcher Incantagos summons Manascale Whelps",

		affinity_cmd = "affinity",
		affinity_name = "Affinity Alert",
		affinity_desc = "Warns when players get an affinity that requires action",

		beam_cmd = "beam",
		beam_name = "Guided Ley-Beam Alert",
		beam_desc = "Warns when players are affected by Guided Ley-Beam",

		cursewarning_cmd = "cursewarning",
		cursewarning_name = "Curse of Manascale Warning",
		cursewarning_desc = "Warns when boss reaches 38%, as Curse of Manascale comes at 33%",

		proximity_cmd = "proximity",
		proximity_name = "Proximity Warning",
		proximity_desc = "Show Proximity Warning Frame",

		trigger_summonSeekerCast = "Watcher Incantagos begins to cast Summon Manascale Ley",
		bar_summonSeekerCast = "Ley-Seeker Summoning",
		msg_summonSeeker = "Manascale Ley-Seeker spawning in 2 sec!",

		trigger_summonWhelpsCast = "Watcher Incantagos begins to cast Summon Manascale Whelps",
		bar_summonWhelpsCast = "Whelps Summoning",
		msg_summonWhelps = "Manascale Whelps spawning in 2 sec!",

		trigger_leyLineCast = "Watcher Incantagos begins to cast (.+)Line Disturbance",
		bar_leyLineCast = "Ley-Line Disturbance casting",
		bar_leyLineCD = "Next Possible Ley-Line Disturbance",
		msg_leyLine = "Ley-Line Disturbance casting!",

		trigger_greenAffinityYou = "You gain Green Affinity",
		trigger_blackAffinityYou = "You gain Black Affinity",
		trigger_redAffinityYou = "You gain Red Affinity",
		trigger_blueAffinityYou = "You gain Blue Affinity",
		trigger_manaAffinityYou = "You gain Mana Affinity",
		trigger_crystalAffinityYou = "You gain Crystal Affinity",

		trigger_greenAffinityOther = "(.+) gains Green Affinity",
		trigger_blackAffinityOther = "(.+) gains Black Affinity",
		trigger_redAffinityOther = "(.+) gains Red Affinity",
		trigger_blueAffinityOther = "(.+) gains Blue Affinity",
		trigger_manaAffinityOther = "(.+) gains Mana Affinity",
		trigger_crystalAffinityOther = "(.+) gains Crystal Affinity",

		trigger_affinityDies = "(.+) Affinity dies",

		msg_greenAffinity = "GREEN AFFINITY - Shamans and Druids handle this!",
		msg_blackAffinity = "BLACK AFFINITY - Priests and Warlocks handle this!",
		msg_redAffinity = "RED AFFINITY - Mages and Warlocks handle this!",
		msg_blueAffinity = "BLUE AFFINITY - Mages handle this!",
		msg_manaAffinity = "MANA AFFINITY - Mages and Druids handle this!",
		msg_crystalAffinity = "CRYSTAL AFFINITY - Warriors, Rogues, Paladins and Hunters handle this!",

		bar_affinityKill = "Kill the Affinity",
		bar_greenAffinity = "Green Affinity (Shamans/Druids)",
		bar_blackAffinity = "Black Affinity (Priests/Warlocks)",
		bar_redAffinity = "Red Affinity (Mages/Warlocks)",
		bar_blueAffinity = "Blue Affinity (Mages)",
		bar_manaAffinity = "Mana Affinity (Mages/Druids)",
		bar_crystalAffinity = "Crystal Affinity (Melee/Hunters)",

		trigger_leyBeamGain = "(.+) gain.? Guided Ley",
		trigger_leyBeamAfflicted = "afflicted by Guided Ley",
		bar_leyBeam = "Guided Ley-Beam in",
		msg_leyBeam = "LEY-BEAM on %s - AVOID THEM!",
		msg_leyBeamYou = "LEY-BEAM on YOU - GET AWAY FROM OTHERS!",
		msg_leyBeamSay = "Guided Ley-Beam on me! STAY AWAY!",

		msg_curseWarning = "45% - CURSE OF MANASCALE coming at 40%!",

		warningSign_beam = "IN BEAM, MOVE",
	}
end)

-- timer and icon variables
local timer = {
	firstLeyLine = { 70, 80 }, -- 1:10 to 1:20
	leyLineCD = { 53, 63 },
	leyLineCast = 3,
	summonSeekerCast = 2,
	summonWhelpsCast = 2,
	affinity = 15,
	initalBeamCD = 28,
	beam = 13, -- 10 sec duration, starts 3 sec after initial targeting buff
}

local icon = {
	leyLine = "Spell_Arcane_PortalIronForge",
	greenAffinity = "Spell_Nature_AbolishMagic",
	blackAffinity = "Spell_Shadow_ShadowBolt",
	redAffinity = "Spell_Fire_FlameBolt",
	blueAffinity = "Spell_Frost_FrostBolt02",
	manaAffinity = "Spell_Nature_StarFall",
	crystalAffinity = "INV_Sword_04",
	beam = "Spell_Arcane_StarFire",
}

local color = {
	leyLine = "Blue",
	summonSeeker = "Yellow",
	summonWhelps = "Orange",
}

local syncName = {
	summonSeeker = "IncantagosSummonSeeker" .. module.revision,
	summonWhelps = "IncantagosSummonWhelps" .. module.revision,
	leyLine = "IncantagosLeyLine" .. module.revision,
	greenAffinity = "IncantagosGreenAffinity" .. module.revision,
	blackAffinity = "IncantagosBlackAffinity" .. module.revision,
	redAffinity = "IncantagosRedAffinity" .. module.revision,
	blueAffinity = "IncantagosBlueAffinity" .. module.revision,
	manaAffinity = "IncantagosManaAffinity" .. module.revision,
	crystalAffinity = "IncantagosCrystalAffinity" .. module.revision,
	affinity = "IncantagosAffinity" .. module.revision,
	affinityDies = "IncantagosAffinityDies" .. module.revision,
	beam = "IncantagosLeyBeam" .. module.revision,
}

affinityUpdateInterval = 0.2; -- How often the OnUpdate code will run (in seconds)
timeLastUpdate = GetTime()
monitoringAffinity = false

-- Proximity Plugin
module.proximityCheck = function(unit)
	return CheckInteractDistance(unit, 2)
end
module.proximitySilent = true

-- module functions
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "BeginsCastEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "BeginsCastEvent")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "BuffEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "BuffEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "BuffEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "BuffEvent")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "BuffEvent") --Affinity dies

	if SUPERWOW_VERSION then
		self:RegisterCastEventsForUnitName("Ley-Watcher Incantagos", "IncantagosCastEvent")
	end	

	self:ThrottleSync(5, syncName.summonSeeker)
	self:ThrottleSync(5, syncName.summonWhelps)
	self:ThrottleSync(5, syncName.leyLine)
	self:ThrottleSync(20, syncName.affinity)
	--self:ThrottleSync(20, syncName.greenAffinity)
	--self:ThrottleSync(20, syncName.blackAffinity)
	--self:ThrottleSync(20, syncName.redAffinity)
	--self:ThrottleSync(20, syncName.blueAffinity)
	--self:ThrottleSync(20, syncName.manaAffinity)
	--self:ThrottleSync(20, syncName.crystalAffinity)
	self:ThrottleSync(2, syncName.beam)
end

function module:OnSetup()
	self.started = nil
	self.curseWarned = nil
	self.bossHealth = 100
	monitoringAffinity = false
end

function module:OnEngage()
	if self.db.profile.leyline then
		self:IntervalBar(L["bar_leyLineCD"], timer.firstLeyLine[1], timer.firstLeyLine[2], icon.leyLine, true, color.leyLine)
	end

	if self.db.profile.beam then
		self:Bar(L["bar_leyBeam"], timer.initalBeamCD, icon.beam, true, color.leyLine)
	end

	if self.db.profile.proximity then
		self:Proximity()
	end

	self.curseWarned = nil
	self.bossHealth = 100

	BigWigsAffinity:AShow()

	-- Start health monitoring
	if self.db.profile.cursewarning then
		self:ScheduleRepeatingEvent("CheckBossHealth", self.CheckBossHealth, 1, self)
	end
	monitoringAffinity = false
end

function module:OnDisengage()
	self:RemoveProximity()

	if self:IsEventScheduled("CheckBossHealth") then
		self:CancelScheduledEvent("CheckBossHealth")
	end
	BigWigsAffinity:AClose()
	monitoringAffinity = false
end

function module:IncantagosCastEvent(casterGuid, targetGuid, eventType, spellId, castTime)
	if eventType == "CHANNEL" and spellId == 51175 then
		if IsRaidLeader() or IsRaidOfficer() then
			SetRaidTarget(targetGuid, 3)
		end
	end
end

function module:CheckBossHealth()
	for i = 1, GetNumRaidMembers() do
		local targetString = "raid" .. i .. "target"
		local targetName = UnitName(targetString)

		if targetName == module.translatedName then
			local health = UnitHealth(targetString)
			local healthMax = UnitHealthMax(targetString)

			if health > 0 and healthMax > 0 then
				self.bossHealth = math.ceil((health / healthMax) * 100)

				if self.bossHealth <= 45 and not self.curseWarned then
					self:Message(L["msg_curseWarning"], "Important", nil, "Alarm")
					self.curseWarned = true
				end
				break
			end
		end
	end
end

function module:BeginsCastEvent(msg)
	if string.find(msg, L["trigger_summonSeekerCast"]) then
		self:Sync(syncName.summonSeeker)
	elseif string.find(msg, L["trigger_summonWhelpsCast"]) then
		self:Sync(syncName.summonWhelps)
	elseif string.find(msg, L["trigger_leyLineCast"]) then
		self:Sync(syncName.leyLine)
	end
end

function module:BuffEvent(msg)
	if string.find(msg, L["trigger_greenAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_greenAffinityOther"])
		self:Sync(syncName.greenAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_blackAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_blackAffinityOther"])
		self:Sync(syncName.blackAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_redAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_redAffinityOther"])
		self:Sync(syncName.redAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_blueAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_blueAffinityOther"])
		self:Sync(syncName.blueAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_manaAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_manaAffinityOther"])
		self:Sync(syncName.manaAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_crystalAffinityOther"]) then
		local _,_,affinityPlayer,_ = string.find(msg, L["trigger_crystalAffinityOther"])
		self:Sync(syncName.crystalAffinity .. " " .. affinityPlayer)
	elseif string.find(msg, L["trigger_greenAffinityYou"]) then		
		self:Sync(syncName.greenAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_blackAffinityYou"]) then
		self:Sync(syncName.blackAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_redAffinityYou"]) then
		self:Sync(syncName.redAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_blueAffinityYou"]) then
		self:Sync(syncName.blueAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_manaAffinityYou"]) then
		self:Sync(syncName.manaAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_crystalAffinityYou"]) then
		self:Sync(syncName.crystalAffinity .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_affinityDies"]) then
		self:Sync(syncName.affinityDies)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS(msg)
	local _, _, player = string.find(msg, L["trigger_leyBeamGain"])
	if player then
		if player == "You" then player = UnitName("player") end
		self:Sync(syncName.beam .. " " .. player)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(msg)
	if string.find(msg, L["trigger_leyBeamAfflicted"]) then
		self:WarningSign(icon.beam, 5, true, L["warningSign_beam"])
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.summonSeeker then
		self:SummonSeeker()
	elseif sync == syncName.summonWhelps then
		self:SummonWhelps()
	elseif sync == syncName.leyLine then
		self:LeyLine()
	elseif sync == syncName.greenAffinity and rest and self.db.profile.affinity then
		self:GreenAffinity(rest)
	elseif sync == syncName.blackAffinity and rest and self.db.profile.affinity then
		self:BlackAffinity(rest)
	elseif sync == syncName.redAffinity and rest and self.db.profile.affinity then
		self:RedAffinity(rest)
	elseif sync == syncName.blueAffinity and rest and self.db.profile.affinity then
		self:BlueAffinity(rest)
	elseif sync == syncName.manaAffinity and rest and self.db.profile.affinity then
		self:ManaAffinity(rest)
	elseif sync == syncName.crystalAffinity and rest and self.db.profile.affinity then
		self:CrystalAffinity(rest)
	elseif sync == syncName.beam and self.db.profile.beam then
		self:LeyBeamStarted(rest)
	elseif sync == syncName.affinityDies then
		monitoringAffinity = false
		BigWigsAffinity:StopAffinityUpdate()
	end
end

function module:SummonSeeker()
	if self.db.profile.summonseeker then
		self:Message(L["msg_summonSeeker"], "Attention")
	end
end

function module:SummonWhelps()
	if self.db.profile.summonwhelps then
		self:Message(L["msg_summonWhelps"], "Attention")
	end
end

function module:LeyLine()
	if self.db.profile.leyline then
		self:Message(L["msg_leyLine"], "Important")
		self:RemoveBar(L["bar_leyLineCD"])
		self:Bar(L["bar_leyLineCast"], timer.leyLineCast, icon.leyLine, true, color.leyLine)
		--self:IntervalBar(L["bar_leyLineCD"], timer.leyLineCD[1], timer.leyLineCD[2], icon.leyLine, true, color.leyLine)
		self:DelayedBar(timer.leyLineCast, L["bar_affinityKill"], timer.affinity, color.leyLine)
	end
end

function module:GreenAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_greenAffinity"], "Important", true, "Alarm")
		self:WarningSign(icon.greenAffinity, 5, true, "SHAMAN/DRUID")
		BigWigsAffinity:StartAffinityUpdate("green")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_greenAffinity"], timer.affinity, icon.greenAffinity)
end

function module:BlackAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_blackAffinity"], "Important", true, "Alarm")
		self:WarningSign(icon.blackAffinity, 5, true, "PRIEST/WARLOCK")
		BigWigsAffinity:StartAffinityUpdate("black")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_blackAffinity"], timer.affinity, icon.blackAffinity)
end

function module:RedAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_redAffinity"], "Important", true, "Alarm")
		self:WarningSign(icon.redAffinity, 5, true, "MAGE/WARLOCK")
		BigWigsAffinity:StartAffinityUpdate("red")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_redAffinity"], timer.affinity, icon.redAffinity)
end

function module:BlueAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_blueAffinity"], "Important", true, "Alarm")
		self:WarningSign(icon.blueAffinity, 5, true, "MAGE")
		BigWigsAffinity:StartAffinityUpdate("blue")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_blueAffinity"], timer.affinity, icon.blueAffinity)
end

function module:ManaAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_manaAffinity"], "Important", true, "Alar")
		self:WarningSign(icon.manaAffinity, 5, true, "MAGE/DRUID")
		BigWigsAffinity:StartAffinityUpdate("mana")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_manaAffinity"], timer.affinity, icon.manaAffinity)
end

function module:CrystalAffinity(rest)
	if not monitoringAffinity then
		self:Message(L["msg_crystalAffinity"], "Important", true, "Alarm")
		self:WarningSign(icon.crystalAffinity, 5, true, "MELEE")	
		BigWigsAffinity:StartAffinityUpdate("crystal")
		monitoringAffinity = true
	end
	BigWigsAffinity:RemoveAffinityTarget(rest)
	--self:Bar(L["bar_crystalAffinity"], timer.affinity, icon.crystalAffinity)
end

function module:LeyBeamStarted(player)
	-- Combined self and other beam handling into one function
	if player == UnitName("player") then
		self:Message(L["msg_leyBeamYou"], "Important", true, "Alarm")
		self:WarningSign(icon.beam, 3, true, L["msg_leyBeamYou"])
		SendChatMessage(L["msg_leyBeamSay"], "SAY")
	else
		self:Message(string.format(L["msg_leyBeam"], player), "Important")
	end

	-- Add a timer bar for the beam duration
	self:Bar(player .. ": " .. L["beam_name"], timer.beam, icon.beam)
end

function module:Test()
	-- Initialize module state
	self:OnSetup()
	self:Engage()

	local events = {
		-- First Ley-Line around 1:15
		{ time = 4, func = function()
			print("Test: Ley-Watcher Incantagos begins to cast Ley-Line Disturbance")
			module:BeginsCastEvent("Ley-Watcher Incantagos begins to cast Ley-Line Disturbance.")
		end },
		{ time = 5, func = function()
			print("Test: You are afflicted by Guided Ley-Beam")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE("You are afflicted by Guided Ley-Beam (1).")
		end },
		{ time = 6, func = function()
			print("Test: simulate cast event")
			if SUPERWOW_VERSION then
				local _, guid = UnitExists("player")
				module:IncantagosCastEvent(nil, guid, "CHANNEL", 51175, 0)
			end
		end },

		-- Summon Seeker
		{ time = 7, func = function()
			print("Test: Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker")
			module:BeginsCastEvent("Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker.")
		end },
		-- Ley-Beam
		{ time = 10, func = function()
			print("Test: " .. UnitName("player") .. " gains Guided Ley-Beam")
			module:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS(UnitName("player") .. " gains Guided Ley-Beam (1).")

			-- clear skull
			if IsRaidLeader() or IsRaidOfficer() then
				SetRaidTarget("player", 0)
			end
		end },
		{ time = 15, func = function()
			print("Test: Stormhide gains Guided Ley-Beam")
			module:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS("Stormhide gains Guided Ley-Beam (1).")
		end },

		{ time = 20, func = function()
			print("Test: You gain Guided Ley-Beam")
			module:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS("You gain Guided Ley-Beam (1).")
		end },

		-- Summon Whelps
		{ time = 25, func = function()
			print("Test: Ley-Watcher Incantagos begins to cast Summon Manascale Whelps")
			module:BeginsCastEvent("Ley-Watcher Incantagos begins to cast Summon Manascale Whelps.")
		end },

		-- Affinities
		{ time = 26, func = function()
			print("Test: You gain Green Affinity")
			module:BuffEvent("You gain Green Affinity (1).")
			SendChatMessage("You gain Green Affinity (1).", "RAID")
		end },
		{ time = 27, func = function()
			print("Test: Multihealer gains Green Affinity")
			module:BuffEvent("Multihealer gains Green Affinity (1).")
			SendChatMessage("Multihealer gains Green Affinity (1).", "RAID")
		end },
		{ time = 27.5, func = function()
			print("Test: Pumpy gains Green Affinity")
			module:BuffEvent("Pumpy gains Green Affinity (1).")
			SendChatMessage("Pumpy gains Green Affinity (1).", "RAID")
		end },
		{ time = 29, func = function()
			print("Test: Green Affinity dies.")
			module:BuffEvent("Green Affinity dies.")
			SendChatMessage("Green Affinity dies.", "RAID")
		end },
		{ time = 38, func = function()
			print("Test: Player1 gains Black Affinity")
			module:BuffEvent("Player1 gains Black Affinity (1).")
		end },
		{ time = 43, func = function()
			print("Test: Black Affinity dies.")
			module:BuffEvent("Black Affinity dies.")
		end },
		{ time = 48, func = function()
			print("Test: Player1 gains Red Affinity")
			module:BuffEvent("Player1 gains Red Affinity (1).")
		end },
		{ time = 53, func = function()
			print("Test: Red Affinity dies.")
			module:BuffEvent("Red Affinity dies.")
		end },
		{ time = 58, func = function()
			print("Test: Player1 gains Blue Affinity")
			module:BuffEvent("Player1 gains Blue Affinity (1).")
		end },
		{ time = 63, func = function()
			print("Test: Blue Affinity dies.")
			module:BuffEvent("Blue Affinity dies.")
		end },
		{ time = 68, func = function()
			print("Test: Player1 gains Mana Affinity")
			module:BuffEvent("Player1 gains Mana Affinity (1).")
		end },
		{ time = 73, func = function()
			print("Test: Mana Affinity dies.")
			module:BuffEvent("Mana Affinity dies.")
		end },
		{ time = 78, func = function()
			print("Test: Player1 gains Crystal Affinity")
			module:BuffEvent("Player1 gains Crystal Affinity (1).")
		end },
		{ time = 83, func = function()
			print("Test: Crystal Affinity dies.")
			module:BuffEvent("Crystal Affinity dies.")
		end },

		-- Second Ley-Line about 55s after first one
		--{ time = 65, func = function()
		--	print("Test: Ley-Watcher Incantagos begins to cast Ley-Line Disturbance")
		--	module:BeginsCastEvent("Ley-Watcher Incantagos begins to cast Ley-Line Disturbance.")
		--end },

		{ time = 85, func = function()
			print("Test: Disengage")
			module:Disengage()
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("IncantagosTest" .. i, event.func, event.time)
	end

	self:Message("Ley-Watcher Incantagos test started", "Positive")
	return true
end

-- /run local m=BigWigs:GetModule("Ley-Watcher Incantagos"); BigWigs:SetupModule("Ley-Watcher Incantagos");m:Test();
