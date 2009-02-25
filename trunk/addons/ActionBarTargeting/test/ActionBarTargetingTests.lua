dofile("wowunit/wowunit.lua")
dofile("wowunit/wow_api.lua")

local libs = { "LibStub", "CallbackHandler-1.0", "AceAddon-3.0", "AceConsole-3.0", "AceEvent-3.0" }
WowUnit:LoadLibs(libs)

dofile("../ActionBarTargeting.lua")

local ABT = LibStub("AceAddon-3.0"):GetAddon("ActionBarTargeting")

-----------------------------------------------------------------------
-- Test class
-----------------------------------------------------------------------

AbtTests = {
    globals = _G
}

function AbtTests:setUp()
    UnitName = function()
        return "SomeToon"
    end
end

function AbtTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------

function AbtTests:test_CreateMacro()
    assertEquals(ABT:CreateMacro(), "")
    assertEquals(ABT:CreateMacro(""), "")
    assertEquals(ABT:CreateMacro("", nil), "")

    assertEquals(ABT:CreateMacro("abc"), "abc")
    assertEquals(ABT:CreateMacro("abc", "def"), "abcdef")
    assertEquals(ABT:CreateMacro(1, 2), "12")
    assertEquals(ABT:CreateMacro("the value is: ", 12), "the value is: 12")
    
    assertEquals(ABT:CreateMacro(function() return "abc" end), "abc")
    assertEquals(ABT:CreateMacro("/target party", function() return 1 end), "/target party1")
end

function AbtTests:test_MaxBar()
    assertEquals(ABT:MaxBar({}), 0)
    assertEquals(ABT:MaxBar({1}), 1)
    assertEquals(ABT:MaxBar({1, 2, 3, 4, 5}), 5)
    assertEquals(ABT:MaxBar({1, 2, 3, 4, 5, 6}), 6)
    assertEquals(ABT:MaxBar({1, 2, 3, 4, 5, 6, 7}), 6)
end

function AbtTests:test_FirstIndexOf()
    assertEquals(ABT:FirstIndexOf(1, {}), nil)
    assertEquals(ABT:FirstIndexOf(1, {1, 2, 3}), 1)
    assertEquals(ABT:FirstIndexOf(1, {1, 2, 1}), 1)
    assertEquals(ABT:FirstIndexOf(3, {1, 2, 3}), 3)
    assertEquals(ABT:FirstIndexOf(4, {1, 2, 3}), nil)
end

function AbtTests:test_PlayerIndex()
    assertEquals(ABT:PlayerIndex({}), nil)
    assertEquals(ABT:PlayerIndex({ "a", "b", "c" }), nil)
    assertEquals(ABT:PlayerIndex({ "SomeToon", "b", "c" }), 1)
end

function values(t)
    local i = 0
    return function()
        i = i + 1
        if i > #t then
            return nil
        else
            return i, t[i]
        end
    end
end

local function assertIterEquals(iter, expected)
    local iExp = 1
    for bar, toon in iter do
        local expBar, expToon = expected[iExp], expected[iExp + 1]
        assertEquals(bar, expBar)
        assertEquals(toon, expToon)
        iExp = iExp + 2
    end
end

function AbtTests:test_BarPairs()
    assertIterEquals(ABT:BarPairs({}), {})
    assertIterEquals(ABT:BarPairs({}, 1), {})
    assertIterEquals(ABT:BarPairs({}, 0), {})

    assertIterEquals(ABT:BarPairs({"A"}), {1, "A"})
    assertIterEquals(ABT:BarPairs({"A"}, 2), {1, "A"})
    assertIterEquals(ABT:BarPairs({"A"}, 1), {})

    -- Max actionbar index is 6, so max # bar pairs is also 6
    local bigteam = { "a", "b", "c", "d", "e", "f", "g", "h", "i" }
    assertIterEquals(ABT:BarPairs(bigteam), {1, "a", 2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals(ABT:BarPairs(bigteam, 1), {2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals(ABT:BarPairs(bigteam, 2), {1, "a", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals(ABT:BarPairs(bigteam, 6), {1, "a", 2, "b", 3, "c", 4, "d", 5, "e"})
    assertIterEquals(ABT:BarPairs(bigteam, 7), {1, "a", 2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
end

function AbtTests:test_JoinBarConditions()
    assertEquals(ABT:JoinBarConditions({}), "")
    assertEquals(ABT:JoinBarConditions({}, 1), "")

    assertEquals(ABT:JoinBarConditions({ "toon1" }), "[bar:1] toon1")
    assertEquals(ABT:JoinBarConditions({ "toon1" }, 0), "[bar:1] toon1")
    assertEquals(ABT:JoinBarConditions({ "toon1" }, 1), "")
    assertEquals(ABT:JoinBarConditions({ "toon1" }, 2), "[bar:1] toon1")

    local team = { "a", "b", "c", "d", "e" }
    assertEquals(ABT:JoinBarConditions(team), "[bar:1] a; [bar:2] b; [bar:3] c; [bar:4] d; [bar:5] e")
    assertEquals(ABT:JoinBarConditions(team, 1), "[bar:2] b; [bar:3] c; [bar:4] d; [bar:5] e")
    assertEquals(ABT:JoinBarConditions(team, 2), "[bar:1] a; [bar:3] c; [bar:4] d; [bar:5] e")
    assertEquals(ABT:JoinBarConditions(team, 5), "[bar:1] a; [bar:2] b; [bar:3] c; [bar:4] d")
end

function AbtTests:test_CreateOffensiveTargetMacro()
    local team = { "a", "b", "c" }
    assertEquals(ABT:CreateOffensiveTargetMacro(team, 1), [[
/stopmacro [exists,harm,nodead]
/assist [bar:2] b; [bar:3] c
/startattack [harm]
]])
end

function AbtTests:test_CreateHealingTargetMacro()
    local team = { "a", "b", "c" }
    assertEquals(ABT:CreateHealingTargetMacro(team, 1), [[
/targetexact [bar:2] b; [bar:3] c
/target [nobar:1,help,nodead] targettarget
]])
end

function AbtTests:test_CreateTargetMainMacro()
    local team = { "a", "b", "c" }
    assertEquals(ABT:CreateTargetMainMacro(team, 1), [[
/targetexact [bar:2] b; [bar:3] c
]])
end

function AbtTests:test_CreateTargetMainTargetMacro()
    local team = { "a", "b", "c" }
    assertEquals(ABT:CreateTargetMainTargetMacro(team, 1), [[
/stopmacro [bar:1]
/targetexact [bar:2] b; [bar:3] c
/target targettarget
]])
end

function AbtTests:test_CreateFollowMacro()
    local team = { "a", "b", "c" }
    assertEquals(ABT:CreateFollowMacro(team, 1), [[
/stopmacro [bar:1]
/targetexact [bar:2] b; [bar:3] c
/follow
]])
end

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

LuaUnit:run("AbtTests")
