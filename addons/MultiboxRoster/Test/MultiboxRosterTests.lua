dofile("wowunit/wowunit.lua")
dofile("wowunit/wow_api.lua")

local libs = { "LibStub", "CallbackHandler-1.0", "AceAddon-3.0", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0" }
WowUnit:LoadLibs(libs)

dofile("../MultiboxRoster.lua")
dofile("../Teams.lua")

local MBR = LibStub("AceAddon-3.0"):GetAddon("MultiboxRoster")

-----------------------------------------------------------------------
-- WoW API fakery
-----------------------------------------------------------------------

local player, raid, party

GetNumPartyMembers = function() return #party end
GetNumRaidMembers = function() return #raid end
UnitInParty = function(id) return true end
UnitInRaid = function(id) return true end
GetRaidRosterInfo = function(i) return raid[i] end

function UnitName(id)
    if (id == "player") then
        return player, nil
    elseif (string.match(id, "^party") ~= nil) then
        local i = 0 + string.match(id, "%d$")
        return party[i], nil
    end
end

-----------------------------------------------------------------------
-- Test class
-----------------------------------------------------------------------

MbrTests = {
    globals = _G,
    player = "SomeToon",
    raid = {},
    party = {},
    teams = {
        team1 = { "Crockpot", "Pawfoo", "Pewmew", "Pieforu", "Pumu" },
        team2 = { "Axo", "Xalo" },
        team3 = { "Axo", "Xalo", "Xiloh" },
        team4 = { "Axo" },
        dks = { "’ı", "”Ú" }
    }
}

function MbrTests:setUp()
    player = MbrTests.player
    raid = MbrTests.raid
    party = MbrTests.party
    MBR.teams = MbrTests.teams
end

function MbrTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------

function MbrTests:test_UnitName()
    assertEquals(UnitName("player"), "SomeToon")
    player = "foo"
    assertEquals(UnitName("player"), "foo")
    
    assertNil(UnitName("party1"))
    party = { "A", "B", "C" }
    assertEquals(UnitName("party1"), "A")
    assertEquals(UnitName("party3"), "C")
    assertNil(UnitName("party4"))
    
    party = MBR.teams["dks"]
    assertEquals(UnitName("party1"), "’ı")
end

function MbrTests:test_Teams()
    assertEquals(MBR.teams["team1"][1], "Crockpot")
    assertEquals(MBR.teams["team1"][5], "Pumu")
    assertEquals(MBR.teams["team1"][6], nil)
    assertEquals(MBR.teams["team2"][1], "Axo")
    assertEquals(MBR.teams["bogus"], nil)
    assertEquals(MBR.teams["dks"][1], "’ı")
end

function MbrTests:test_GetPartyMembers()
    party = {}
    assertTableEquals(MBR:GetPartyMembers(), { player })
    party = { "a" }
    assertTableEquals(MBR:GetPartyMembers(), { player, "a" })
    party = { "a", "b" }
    assertTableEquals(MBR:GetPartyMembers(), { player, "a", "b" })
end

function MbrTests:test_GetRaidMembers()
    raid = {}
    assertTableEquals(MBR:GetRaidMembers(), raid)
    raid = { "a" }
    assertTableEquals(MBR:GetRaidMembers(), raid)
    raid = { "a", "b" }
    assertTableEquals(MBR:GetRaidMembers(), raid)
end

local function AssertDetectTeam(group, expectedName)
    local name, team = MBR:DetectTeam(group)
    assertEquals(name, expectedName)
    if (expectedName ~= nil) then
        assertTableEquals(team, MBR.teams[name])
    end
end

function MbrTests:test_DetectTeam()
    assertError(MBR.DetectTeam, MBR, {})

    AssertDetectTeam({ "Axo", "Xalo" }, "team2")
    AssertDetectTeam({ "Xalo", "Axo" }, "team2")
    AssertDetectTeam({ "Whoever", "Axo", "Nope", "Xalo", "Someotherguy" }, "team2")

    AssertDetectTeam({ "Xalo" }, nil)

    AssertDetectTeam({ "Axo", "Xalo", "Xiloh" }, "team3")
    AssertDetectTeam({ "Xalo", "Axo", "Xiloh" }, "team3")
    
    AssertDetectTeam({ "’ı", "”Ú" }, "dks")
end

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

LuaUnit:run("MbrTests")
