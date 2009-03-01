dofile("wowunit.lua")

-----------------------------------------------------------------------
-- Test class
-----------------------------------------------------------------------

WowUnitTests = {
    globals = _G
}

local raid = {}
local party = {}

function WowUnitTests:setUp()
end

function WowUnitTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------

function WowUnitTests:test_assertEmpty()
    assertEmpty({})
    assertError(assertEmpty, { 1 })
end

function WowUnitTests:test_assertNotEmpty()
    assertNotEmpty({ 1 })
    assertError(assertNotEmpty, {})
end

function WowUnitTests:test_assertTrue()
    assertTrue(true)
    assertError(assertTrue, false)
end

function WowUnitTests:test_assertFalse()
    assertFalse(false)
    assertError(assertFalse, true)
    assertError(assertFalse, nil)
end

function WowUnitTests:test_assertNil()
    assertNil(nil)
    assertError(assertNil, 123)
    assertError(assertNil, false)
end

-- Test iterator that returns all of the values in a table
local function values(t)
    local i = 0
    return function()
        i = i + 1
        if i <= #t then return t[i] end
    end
end

function WowUnitTests:test_assertIterEquals()
    assertIterEquals({ values({}) }, {})
    assertIterEquals({ values({ 1 }) }, { 1 })
    assertIterEquals({ values({ 1, true, "abc" }) }, { 1, true, "abc" })
    
    assertIterEquals({ ipairs({}) }, {})
    assertIterEquals({ ipairs({ "a" }) }, { 1, "a" })
    assertIterEquals({ ipairs({ "a", 123 }) }, { 1, "a", 2, 123 })
end

function WowUnitTests:test_assertTableEquals()
    assertError(assertTableEquals, { 1 }, 1)
    assertError(assertTableEquals, 1, { 1 })
    assertError(assertTableEquals, { 1 }, {})
    assertError(assertTableEquals, {}, { 1 })
    
    assertTableEquals({}, {})
    assertTableEquals({ 1 }, { 1 })
    assertTableEquals({ 1, 2, 3 }, { 1, 2, 3 })
    
    assertError(assertTableEquals, { 1 }, { 2 })
    assertError(assertTableEquals, { 1, 2, 3 }, { 1, 2, "3" })
    
    assertTableEquals({ {} }, { {} })
    assertTableEquals({ 1, { 2, 3 } }, { 1, { 2, 3 } })
    assertTableEquals({ 1, { 2 }, 3 }, { 1, { 2 }, 3 })

    assertError(assertTableEquals, { 1, { 2, 3 } }, { "a", { 2, 3 } })
    assertError(assertTableEquals, { 1, { 2, 3 } }, { 1, { "b", 3 } })
end

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

LuaUnit:run("WowUnitTests")
