MacroSequence = {}

MacroSequence.sequences = {

-------------------------------------------------------------------
-- General
-------------------------------------------------------------------

	Accept = { [[
/script AcceptGroup();
/script AcceptQuest();
/script AcceptTrade();
/script RetrieveCorpse();
/script RepopMe();
	]] },
	
	BigButton = { [[
/click [nocombat] SmartBuff_KeyButton
/click FollowMain
	]] },
	
	LodLow = { [[
/say detail: low
/console groundEffectDensity 16
/console groundEffectDist 1
/console horizonfarclip 1305
/console farclip 177
/console characterAmbient 1
/console smallcull 1
/console skycloudlod 1
/console detailDoodadAlpha 1
	]] },

	LodMedium = { [[
/say detail: medium
/console groundEffectDensity 136
/console groundEffectDist 70
/console horizonfarclip 3765
/console farclip 477
/console characterAmbient 1
/console smallcull 1
/console skycloudlod 2
/console detailDoodadAlpha 1
	]] },

	LodHigh = { [[
/say detail: high
/console farclip 777
/console horizonfarclip 6226
/console groundeffectdensity 256
/console groundeffectdist 140
/console smallcull 0
/console skycloudlod 3
/console characterambient 0
/console detailDoodadAlpha 100
	]] },

-------------------------------------------------------------------
-- Focus:
--      button 1 = focus target
--      button 2 = main also acts as focus1
-------------------------------------------------------------------

	Focus0 = { [[
/click [combat,button:1] ClearFocus0
/click [combat,button:2] ClearFocus0 RightButton
/click [nocombat,button:1] SetFocus0
/click [nocombat,button:2] SetFocus0 RightButton
	]] },

	Focus1 = { [[
/click [combat] ClearFocus1; SetFocus1
	]] },

	Focus2 = { [[
/click [combat] ClearFocus2; SetFocus2
	]] },

	Focus3 = { [[
/click [combat] ClearFocus3; SetFocus3
	]] },

	Focus4 = { [[
/click [combat] ClearFocus4; SetFocus4
	]] },

	SetFocus0 = {
		reset = { combat = true, ctrl = true }, [[
/clearfocus [button:2]
/focus [button:2] target
/script SetRaidTarget('target', 1)
        ]], [[
/script SetRaidTarget('target', 2)
        ]], [[
/script SetRaidTarget('target', 3)
        ]], [[
/script SetRaidTarget('target', 4)
        ]]
    },

	SetFocus1 = {
		reset = { combat = true, ctrl = true }, [[
/clearfocus
/click TargetMainTarget
/focus target
/cleartarget
        ]], "", "", ""
    },

	SetFocus2 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus", [[
/click TargetMainTarget
/focus target
/cleartarget
        ]], "", ""
    },

	SetFocus3 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus",
        "", [[
/click TargetMainTarget
/focus target
/cleartarget
        ]], ""
    },

	SetFocus4 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus",
        "", "", [[
/click TargetMainTarget
/focus target
/cleartarget
        ]]
    },

	ClearFocus0 = {
		reset = { combat = true, ctrl = true }, [[
/clearfocus [button:2]
/script SetRaidTarget('target', 0)
        ]], [[
/script SetRaidTarget('target', 0)
        ]], [[
/script SetRaidTarget('target', 0)
        ]], [[
/script SetRaidTarget('target', 0)
        ]]
    },

	ClearFocus1 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus", "", "", ""
    },

	ClearFocus2 = {
		reset = { combat = true, ctrl = true },
        "", "/clearfocus", "", ""
    },

	ClearFocus3 = {
		reset = { combat = true, ctrl = true },
        "", "", "/clearfocus", ""
    },

	ClearFocus4 = {
		reset = { combat = true, ctrl = true },
        "", "", "", "/clearfocus"
    },
    
-------------------------------------------------------------------
-- Druid
-------------------------------------------------------------------

--/target Dark Iron Land Mine
	Wrath = { [[
/click SetOffensiveTarget
/cast [mod:ctrl] Wrath(Rank 1); Wrath
	]] },
    
	Moonfire = { [[
/click SetOffensiveTarget
/cast [harm,nodead] Moonfire
	]] },
    
	HealingTouch = { [[
/click SetHealingTarget
/cast Healing Touch
	]] },
	
	Rejuvenation = { [[
/click SetHealingTarget
/cast [help,nodead] Rejuvenation
	]] },
	
	Regrowth = { [[
/click SetHealingTarget
/castsequence reset=21/target/ctrl Regrowth, Rejuvenation
	]] },
	
	EntanglingRoots = { [[
/stopmacro [target=focus,noexists][target=focus,dead][target=focus,noharm]
/stopcasting
/cast [target=focus] Entangling Roots
	]] },

	Hibernate = { [[
/stopmacro [target=focus,noexists][target=focus,dead][target=focus,noharm]
/stopcasting
/cast [target=focus] Hibernate
	]] },

-------------------------------------------------------------------
-- Mage
-------------------------------------------------------------------

	Fireball = { [[
/click SetOffensiveTarget
/cast Fireball
	]] },
    
	FireBlast = { [[
/click SetOffensiveTarget
/stopcasting
/cast Fire Blast
	]] },
    
	Frostbolt = { [[
/click SetOffensiveTarget
/cast [modifier:ctrl] Frostbolt(Rank 1); Frostbolt
	]] },
    
	Polymorph = { [[
/stopmacro [target=focus,noexists][target=focus,dead][target=focus,noharm]
/stopcasting
/cast [target=focus] Polymorph
	]] },
    
-------------------------------------------------------------------
-- Paladin
-------------------------------------------------------------------

	PallyPull = { [[
/startattack
/castsequence reset=30/target/combat/ctrl Seal of the Crusader, Judgement, Seal of Righteousness
	]] },
	
	Judgement = { [[
/stopmacro [noexists][dead][noharm]
/startattack
/cast Judgement
/stopmacro [dead]
/cast [button:1] Seal of Righteousness; [button:2] Seal of Justice; [button:3] Seal of Light; [button:4] Seal of Wisdom
	]] },

	HolyLight = { [[
/click SetHealingTarget
/cast Holy Light
	]] },

-------------------------------------------------------------------
-- Rogue
-------------------------------------------------------------------

	SinisterStrike = { [[
/click SetOffensiveTarget
/cast Sinister Strike
	]] },
    
-------------------------------------------------------------------
-- Shaman
-------------------------------------------------------------------

--/target Dark Iron Land Mine
	LightningBolt = { [[
/click SetOffensiveTarget
/cast [modifier:ctrl] Lightning Bolt(Rank 1); Lightning Bolt
	]] },
	
	ChainLightning = { [[
/click SetOffensiveTarget
/cast Chain Lightning
	]] },
	
	EarthShock = { [[
/stopcasting
/click SetOffensiveTarget
/cast Earth Shock
	]] },

	FlameShock = { [[
/stopcasting
/click SetOffensiveTarget
/cast Flame Shock
	]] },
	
	FrostShock = { [[
/stopcasting
/click SetOffensiveTarget
/cast Frost Shock
	]] },
	
	WindShock = { [[
/stopcasting
/click SetOffensiveTarget
/cast Wind Shock
	]] },

	ShockSequence1 = {
		reset = { seconds = 6 },
		"/click [button:1] EarthShock; /click [button:2] FrostShock", "", "", ""
	},

	ShockSequence2 = {
		reset = { seconds = 6 },
		"", "/click [button:1] EarthShock; /click [button:2] FrostShock", "", ""
	},

	ShockSequence3 = {
		reset = { seconds = 6 },
		"", "", "/click [button:1] EarthShock; /click [button:2] FrostShock", ""
	},

	ShockSequence4 = {
		reset = { seconds = 6 },
		"", "", "", "/click [button:1] EarthShock; /click [button:2] FrostShock"
	},

	HealingWave = { [[
/click SetHealingTarget
/cast [dead] Ancestral Spirit; Healing Wave
	]] },
	
	LesserHealingWave = { [[
/click SetHealingTarget
/cast Lesser Healing Wave
	]] },
	
	ChainHeal = { [[
/click SetHealingTarget
/cast Chain Heal
	]] },
	
	Totem1 = {
		reset = { seconds = 60, combat = true },
		"/cast Grounding Totem",
		"/cast Stoneskin Totem",
		"/cast Healing Stream Totem",
		"/cast Searing Totem",
		"/cast Searing Totem",
		"/cast Searing Totem"
	},
	
	Totem2 = {
		reset = { seconds = 60, combat = true },
		"/cast Strength of Earth Totem",
		"/cast Healing Stream Totem",
		"/cast Grounding Totem",
		"/cast Searing Totem",
		"/cast Searing Totem",
		"/cast Searing Totem"
	},
	
	Totem3 = {
		reset = { seconds = 60, combat = true },
		"/cast Tremor Totem",
		"/cast Grounding Totem",
		"/cast Healing Stream Totem",
		"/cast Searing Totem",
		"/cast Searing Totem",
		"/cast Searing Totem"
	},
	
	Totem4 = {
		reset = { seconds = 60, combat = true },
		"/cast Mana Spring Totem",
		"/cast Tremor Totem",
		"/cast Grounding Totem",
		"/cast Searing Totem",
		"/cast Searing Totem",
		"/cast Searing Totem"
	},
	
-------------------------------------------------------------------
-- Warrior
-------------------------------------------------------------------

--
--/stopcasting
-- 
	Charge = { [[
/click SetOffensiveTarget
/cast [nocombat,nostance:1] Battle Stance; [nostance:1] Bloodrage
/castsequence [stance:1] reset=combat Charge, Rend, Bloodrage
        ]] },

	WarriorPull = { [[
/click SetOffensiveTarget
/cast [nocombat,nostance:2,equipped:shields] Defensive Stance
/cast [nocombat,equipped:thrown] Throw; [nocombat] Shoot; Bloodrage
        ]] },
	
	Block = { [[
/click SetOffensiveTarget
/cast [nostance:2] Defensive Stance; Shield Block
        ]] },

-------------------------------------------------------------------
-- Racials
-------------------------------------------------------------------

	GiftOfTheNaaru = { [[
/click SetHealingTarget
/cast Gift of the Naaru
	]] },

}
