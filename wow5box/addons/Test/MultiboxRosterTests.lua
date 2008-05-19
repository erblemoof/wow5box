require("wowunit")
dofile("../../Ace3/tests/wow_api.lua")

local function fileExists(path)
    local f = io.open(path)
	if f then io.close(f) end
	return f ~= nil
end

-- loads an external from either an embedded or non-embedded location
local function LoadExternal(name, searchPaths)
    local up = "../"
    local subdir = name .. "/" .. name .. ".lua"
    searchPaths = searchPaths or {
        up .. up .. name,
        up .. up .. subdir,
        up .. up .. "Ace3/" .. subdir,
        up .. up .. "Ace3/AceConfig-3.0/" .. subdir,
        "Libs/" .. name,
        "Libs/" .. name .. subdir
    }
    
    for _, v in pairs(searchPaths) do
        if fileExists(v) then
            dofile(v)
            WoWAPI_FireEvent("ADDON_LOADED", name)
            return
        end
    end
    error("LoadExternal failed: " .. name)
end

dofile("../LibStub.lua")

local libs = { "CallbackHandler-1.0", "AceGUI-3.0", "AceAddon-3.0", "AceBucket-3.0", "AceDB-3.0", "AceConfigRegistry-3.0",
    "AceConfigCmd-3.0", "AceConfigDialog-3.0", "AceConfig-3.0", "AceConsole-3.0", "AceEvent-3.0" }
for _,v in pairs(libs) do
    LoadExternal(v)
end

dofile("../Core.lua")
dofile("../Options.lua")
dofile("../PublicApi.lua")

-- simulate game start
WoWAPI_FireEvent("ADDON_LOADED", "MultiboxRoster")
-- WoWAPI_FireEvent("PLAYER_LOGIN")

local MultiboxRoster = LibStub("AceAddon-3.0"):GetAddon("MultiboxRoster")

-----------------------------------------------------------------------
-- WoW API fakery
-----------------------------------------------------------------------

local worldToons= { "Iaggo", "Katator", "Kitator", "Ketator", "Kutator", "Akishâ", "Xoot" }
local worldMobs = { "Hogger", "Edwin VanCleef" }
local partyToons = { "Katator", "Kitator" }

local function UnitInList(unit, list)
    for k in pairs(list) do
        if k == unit then return true end
    end
    return false
end

function UnitIsPlayer(unit)
    return UnitInList(unit, worldToons)
end

function UnitIsEnemy(unit)
    return UnitInList(unit, worldMobs)
end

function UnitExists(unit)
    return UnitIsPlayer(unit) or UnitIsEnemy(unit)
end

function GetNumPartyMembers()
    return #partyToons
end

-----------------------------------------------------------------------
-- Test class
-----------------------------------------------------------------------

MultiboxRosterTests = {
    globals = _G
}

function MultiboxRosterTests:setUp()
    MultiboxRoster:Clear()
end

function MultiboxRosterTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Core Tests
-----------------------------------------------------------------------

function MultiboxRosterTests:test_AddCharacter()
    MultiboxRoster:AddCharacter("Mewpew")
    assertTrue(MultiboxRoster:IncludesCharacter("Mewpew"))
    MultiboxRoster:AddCharacter("Akishâ")
    assertTrue(MultiboxRoster:IncludesCharacter("Akishâ"))
    
    assertNotEmpty(MultiboxRoster:GetRoster())
end

function MultiboxRosterTests:test_RemoveCharacter()
    MultiboxRoster:AddCharacter("Akishâ")
    MultiboxRoster:AddCharacter("Mewpew")

    MultiboxRoster:RemoveCharacter("Akishâ")
    assertFalse(MultiboxRoster:IncludesCharacter("Akishâ"))

    MultiboxRoster:RemoveCharacter("Mewpew")
    assertFalse(MultiboxRoster:IncludesCharacter("Mewpew"))
    assertEmpty(MultiboxRoster:GetRoster())
end

function MultiboxRosterTests:test_Clear()
    MultiboxRoster:AddCharacter("Mewpew")
    MultiboxRoster:AddCharacter("Akishâ")
    MultiboxRoster:Clear()
    assertEmpty(MultiboxRoster:GetRoster())
    assertFalse(MultiboxRoster:IncludesCharacter("Mewpew"))
    assertFalse(MultiboxRoster:IncludesCharacter("Akishâ"))
end

function MultiboxRosterTests:test_Trust()
    assertFalse(MultiboxRoster:IsTrusted("Mewpew"))
    assertFalse(MultiboxRoster:IsTrusted("Akishâ"))

    MultiboxRoster:AddCharacter("Mewpew")
    assertTrue(MultiboxRoster:IsTrusted("Mewpew"))
    MultiboxRoster:AddCharacter("Akishâ")
    assertTrue(MultiboxRoster:IsTrusted("Akishâ"))
    
    MultiboxRoster:Clear()
    assertFalse(MultiboxRoster:IsTrusted("Mewpew"))
    assertFalse(MultiboxRoster:IsTrusted("Akishâ"))
end

-----------------------------------------------------------------------
-- Options Tests
-----------------------------------------------------------------------

function MultiboxRosterTests:test_UnitToName()
    assertEquals(MultiboxRoster:UnitToName("Ĩaggó"), "Ĩaggó")

    assertError(function() MultiboxRoster:UnitToName(nil) end)
    assertError(function() MultiboxRoster:UnitToName("") end)

    assertEquals(MultiboxRoster:UnitToName("Iaggo"), "Iaggo")
    assertEquals(MultiboxRoster:UnitToName("Ĩaggó"), "Ĩaggó")
    assertEquals(MultiboxRoster:UnitToName("ĩaggó"), "ĩaggó")
    assertEquals(MultiboxRoster:UnitToName("Ĩĩ煞煟煠煢"), "Ĩĩ煞煟煠煢")
end

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

--LuaUnit.result.verbosity = 0
LuaUnit:run("MultiboxRosterTests")
