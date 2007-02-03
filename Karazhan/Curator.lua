------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["The Curator"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local enrageannounced

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Curator",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for berserk after 12min.",

	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Warn for enrage at 10%.",

	weaken_cmd = "weaken",
	weaken_name = "Weaken",
	weaken_desc = "Alert when The Curator is weakened.",

	weaktime_cmd = "weaktime",
	weaktime_name = "Weaken Countdown",
	weaktime_desc = "Countdown warning and bar untill next weaken.",

	weaken_trigger = "The Curator is afflicted by Evocation.",
	weaken_message = "Evocation - Weakened for 20sec!",
	weaken_bar = "Evocation",
	weaken_fade_message = "Evocation Finished - Weakened Gone!",
	weaken_fade_warning = "Evocation over in 5sec!",

	weaktime_message1 = "Evocation in ~10 seconds",
	weaktime_message2 = "Evocation in ~30 seconds",
	weaktime_message3 = "Evocation in ~70 seconds",
	weaktime_bar = "Next Evocation",

	berserk_trigger = "The Menagerie is for guests only.",
	berserk_message = "Curator engaged, 12min to berserk!",
	berserk_bar = "Berserk",

	enrage_trigger = "", --wtb a message? did he even enrage? need verification, i didn't notice this happen.
	enrage_message = "Enrage!",
	enrage_warning = "Enrage soon!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsCurator = BigWigs:NewModule(boss)
BigWigsCurator.zonename = AceLibrary("Babble-Zone-2.2")["Karazhan"]
BigWigsCurator.enabletrigger = boss
BigWigsCurator.toggleoptions = {"weaken", "weaktime", "berserk", "enrage", "bosskill"}
BigWigsCurator.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsCurator:OnEnable()
	enrageannounced = nil

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsCurator:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["berserk_trigger"] and self.db.profile.berserk then
		self:TriggerEvent("BigWigs_Message", L["berserk_message"], "Attention")
		self:TriggerEvent("BigWigs_StartBar", self, L["berserk_bar"], 720, "Interface\\Icons\\INV_Shield_01")
	elseif msg == L["berserk_trigger"] and self.db.profile.weaktime then
		self:Evoc()
	end
end

function BigWigsCurator:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if msg == L["weaken_trigger"] and self.db.profile.weaken then
		self:TriggerEvent("BigWigs_Message", L["weaken_message"], "Important", nil, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["weaken_bar"], 20, "Interface\\Icons\\Spell_Nature_Purge")
		self:ScheduleEvent("BigWigs_Message", 15, L["weaken_fade_warning"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 20, L["weaken_fade_message"], "Important", nil, "Alarm")
		self:Evoc()
	end
end

function BigWigsCurator:Evoc()
	if self.db.profile.weaktime then
		self:TriggerEvent("BigWigs_StartBar", self, L["weaktime_bar"], 109, "Interface\\Icons\\Spell_Nature_Purge")
		self:ScheduleEvent("BigWigs_Message", 39, L["weaktime_message3"], "Positive")
		self:ScheduleEvent("BigWigs_Message", 79, L["weaktime_message2"], "Attention")
		self:ScheduleEvent("BigWigs_Message", 99, L["weaktime_message1"], "Urgent")
	end
end

function BigWigsCurator:UNIT_HEALTH(msg)
	if not self.db.profile.enrage then return end
	if UnitName(msg) == boss then
		local health = UnitHealth(msg)
		if health > 10 and health <= 13 and not enrageannounced then
			self:TriggerEvent("BigWigs_Message", L["enrage_warning"], "Positive")
			enrageannounced = true
		elseif health > 50 and enrageannounced then
			enrageannounced = false
		end
	end
end
