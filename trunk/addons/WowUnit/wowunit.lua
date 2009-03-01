require("luaunit")

-----------------------------------------------------------------------
-- Additional global asserts
-----------------------------------------------------------------------

-- Asserts that a table is empty
function assertEmpty(t)
    assertEquals(type(t), "table")
    assertEquals(#t, 0)
end

-- Asserts that a table is not empty
function assertNotEmpty(t)
    assertEquals(type(t), "table")
    assertTrue(#t > 0)
end

-- Asserts that an arg is true
function assertTrue(arg)
    if arg ~= true then
        error("Value not true", 2)
    end
end

-- Asserts that an arg is false
function assertFalse(arg)
    if arg ~= false then
        error("Value not false", 2)
    end
end

-- Asserts that an arg is nil
function assertNil(arg)
    if arg ~= nil then
        error("Value not nil", 2)
    end
end

-- Asserts that an iterator returns the expected values
function assertIterEquals(iter, expected)
    if (type(iter) ~= "table") then error("Param #1 iter must be table containing the iterator return values", 2) end
    if (type(expected) ~= "table") then error("Param #2 expected must be a table", 2) end
    
    local iExp = 1
    for actual1, actual2 in unpack(iter) do
        assertEquals(actual1, expected[iExp])
        iExp = iExp + 1
        
        if actual2 ~= nil then
            assertEquals(actual2, expected[iExp])
            iExp = iExp + 1
        end
    end
end

-- Asserts that a table contains the expected values. Works w/ nested tables too.
function assertTableEquals(t, expected)
    if (type(t) ~= "table") then error("Param #1 t must be table", 2) end
    if (type(expected) ~= "table") then error("Param #2 expected must be a table", 2) end
    if (#t ~= #expected) then error("Table sizes do not match", 2) end

    for i, v in ipairs(t) do
        local expectedV = expected[i]
        if (type(v) ~= "table") then 
            assertEquals(v, expectedV)
        else
            assertTableEquals(v, expectedV)
        end
    end
end

-----------------------------------------------------------------------
-- WoW-specific APIs
-----------------------------------------------------------------------

WowUnit = {}

-- Loads libraries from the specified root
function WowUnit:LoadLibs(libs, libRoot)
    libRoot = libRoot or "../libs/"
    for _,v in pairs(libs) do
        dofile(libRoot .. v .. "/" .. v .. ".lua")
    end
end
