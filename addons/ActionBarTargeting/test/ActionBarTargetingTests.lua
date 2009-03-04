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
        return "SomeToon", nil
    end
end

function AbtTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------

function AbtTests:test_JoinLines()
    assertEquals(ABT:JoinLines(), "")
    assertEquals(ABT:JoinLines(""), "")

    assertEquals(ABT:JoinLines("abc"), "abc")
    assertEquals(ABT:JoinLines("abc", "def"), "abc\ndef")
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

function AbtTests:test_BarPairs()
    assertIterEquals({ ABT:BarPairs({}) }, {})
    assertIterEquals({ ABT:BarPairs({}, 1) }, {})
    assertIterEquals({ ABT:BarPairs({}, 0) }, {})

    assertIterEquals({ ABT:BarPairs({"A"}) }, {1, "A"})
    assertIterEquals({ ABT:BarPairs({"A"}, 2) }, {1, "A"})
    assertIterEquals({ ABT:BarPairs({"A"}, 1) }, {})

    -- Max actionbar index is 6, so max # bar pairs is also 6
    local bigteam = { "a", "b", "c", "d", "e", "f", "g", "h", "i" }
    assertIterEquals({ ABT:BarPairs(bigteam) }, {1, "a", 2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals({ ABT:BarPairs(bigteam, 1) }, {2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals({ ABT:BarPairs(bigteam, 2) }, {1, "a", 3, "c", 4, "d", 5, "e", 6, "f"})
    assertIterEquals({ ABT:BarPairs(bigteam, 6) }, {1, "a", 2, "b", 3, "c", 4, "d", 5, "e"})
    assertIterEquals({ ABT:BarPairs(bigteam, 7) }, {1, "a", 2, "b", 3, "c", 4, "d", 5, "e", 6, "f"})
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

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

LuaUnit:run("AbtTests")
