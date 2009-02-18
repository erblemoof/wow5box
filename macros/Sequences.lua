MacroSequence = {}

MacroSequence.sequences = {

-------------------------------------------------------------------
-- General
-------------------------------------------------------------------

	Invite = { [[
/invite Katator
/invite Ketator
/invite Kitator
/invite Kutator
	]] },

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
-- Targeting:
--      button 1 = offensive target
--      button 2 = healing target
--      button 3 = target main's target
--      button 4 = follow
-------------------------------------------------------------------

	SetOffensiveTarget = { [[
/click [dead][noexists][noharm] MultiBarBottomLeftButton1
/startattack [harm]
	]] },

	SetHealingTarget = { [[
/stopmacro [exists,help,nodead]
/click MultiBarBottomLeftButton1 RightButton
	]] },

	TargetMain = { [[
/click MultiBarBottomLeftButton1 Button3
	]] },

	FollowMain = { [[
/click MultiBarBottomLeftButton1 Button4
	]] },

    -- Set raid icons to match alt focus
	Focus0 = {
		reset = { combat = true, ctrl = true }, [[
/clearfocus [button:2]
/focus [button:2] target
/script SetRaidTarget('target', 1)
/targetenemy
        ]], [[
/script SetRaidTarget('target', 2)
/targetenemy
        ]], [[
/script SetRaidTarget('target', 3)
/targetenemy
        ]], [[
/script SetRaidTarget('target', 4)
/targetenemy
        ]]
    },

	Focus1 = {
		reset = { combat = true, ctrl = true }, [[
/clearfocus
/click SetOffensiveTarget
/focus target
        ]], "", "", ""
    },

	Focus2 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus", [[
/click SetOffensiveTarget
/focus target
        ]], "", ""
    },

	Focus3 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus",
        "", [[
/click SetOffensiveTarget
/clearfocus
/focus target
        ]], ""
    },

	Focus4 = {
		reset = { combat = true, ctrl = true },
        "/clearfocus",
        "", "", [[
/click SetOffensiveTarget
/clearfocus
/focus target
        ]]
    },

-------------------------------------------------------------------
-- Druid
-------------------------------------------------------------------

--/target Dark Iron Land Mine
	Wrath = { [[
/click SetOffensiveTarget
/cast [modifier:ctrl] Wrath(Rank 1); Wrath
	]] },
    
	Moonfire = { [[
/click SetOffensiveTarget
/cast [modifier:ctrl] Moonfire(Rank 1); Moonfire
	]] },
    
	HealingTouch = { [[
/click SetHealingTarget
/cast Healing Touch
/targetlasttarget
	]] },
	
	Rejuvenation = { [[
/click SetHealingTarget
/cast Rejuvenation
/targetlasttarget
	]] },
	
	Regrowth = { [[
/click SetHealingTarget
/cast Regrowth
/targetlasttarget
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
-- Racials
-------------------------------------------------------------------

	GiftOfTheNaaru = { [[
/click SetHealingTarget
/cast Gift of the Naaru
	]] },

-------------------------------------------------------------------
-- Leaders
-------------------------------------------------------------------

	AssistBeada = { [[
/assist [button:1] Beada
/stopmacro [button:1]
/target [button:2][button:3] Beada
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Beada
	]] },

	AssistBiza = { [[
/assist [button:1] Biza
/stopmacro [button:1]
/target [button:2][button:3] Biza
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Biza
	]] },

	AssistBlenda = { [[
/assist [button:1] Blenda
/stopmacro [button:1]
/target [button:2][button:3] Blenda
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Blenda
	]] },

	AssistByla = { [[
/assist [button:1] Byla
/stopmacro [button:1]
/target [button:2][button:3] Byla
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Byla
	]] },

	AssistIaggo = { [[
/assist [button:1] Iaggo
/stopmacro [button:1]
/target [button:2][button:3] Iaggo
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Iaggo
	]] },

	AssistKatator = { [[
/assist [button:1] Katator
/stopmacro [button:1]
/target [button:2][button:3] Katator
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Katator
	]] },

	AssistKetator = { [[
/assist [button:1] Ketator
/stopmacro [button:1]
/target [button:2][button:3] Ketator
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Ketator
	]] },

	AssistKitator = { [[
/assist [button:1] Kitator
/stopmacro [button:1]
/target [button:2][button:3] Kitator
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Kitator
	]] },

	AssistKutator = { [[
/assist [button:1] Kutator
/stopmacro [button:1]
/target [button:2][button:3] Kutator
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Kutator
	]] },

	AssistPawfoo = { [[
/assist [button:1] Pawfoo
/stopmacro [button:1]
/target [button:2][button:3] Pawfoo
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Pawfoo
	]] },

	AssistPewmew = { [[
/assist [button:1] Pewmew
/stopmacro [button:1]
/target [button:2][button:3] Pewmew
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Pewmew
	]] },

	AssistPieforu = { [[
/assist [button:1] Pieforu
/stopmacro [button:1]
/target [button:2][button:3] Pieforu
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Pieforu
	]] },

	AssistPumu = { [[
/assist [button:1] Pumu
/stopmacro [button:1]
/target [button:2][button:3] Pumu
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Pumu
	]] },

	AssistXalo = { [[
/assist [button:1] Xalo
/stopmacro [button:1]
/target [button:2][button:3] Xalo
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Xalo
	]] },

	AssistXiloh = { [[
/assist [button:1] Xiloh
/stopmacro [button:1]
/target [button:2][button:3] Xiloh
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Xiloh
	]] },

	AssistXulo = { [[
/assist [button:1] Xulo
/stopmacro [button:1]
/target [button:2][button:3] Xulo
/target [target=targettarget,button:2,help,nodead]
/stopmacro [button:2][button:3]
/follow Xulo
	]] }

}

-------------------------------------------------------------------
-- Bindings
-------------------------------------------------------------------

--SetBindingClick("CTRL-I", "Invite")
--SetBindingClick("F", "BongosActionButton61")
