function assertEmpty(arg)
    assertEquals(#arg, 0)
end

function assertNotEmpty(arg)
    if #arg > 0 then
        error("Value not empty", 2)
    end
end

function assertTrue(arg)
    if arg ~= true then
        error("Value not true", 2)
    end
end

function assertFalse(arg)
    if arg ~= false then
        error("Value not false", 2)
    end
end

function assertNil(arg)
    if arg ~= nil then
        error("Value not nil", 2)
    end
end
