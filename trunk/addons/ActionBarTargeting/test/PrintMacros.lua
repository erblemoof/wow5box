dofile("wowunit/wowunit.lua")
dofile("wowunit/wow_api.lua")

local libs = { "LibStub", "CallbackHandler-1.0", "AceAddon-3.0", "AceConsole-3.0", "AceEvent-3.0" }
WowUnit:LoadLibs(libs)

dofile("../ActionBarTargeting.lua")

local ABT = LibStub("AceAddon-3.0"):GetAddon("ActionBarTargeting")

local macroNames = {
    "SetOffensiveTarget",
    "SetHealingTarget",
    "TargetMain",
    "TargetMainTarget",
    "FollowMain",
    "TargetToon"
}

local sampleTeam = { "Toon1", "Toon2", "Toon3" }
local sampleToonIndex = 1

for _, name in ipairs(macroNames) do
    print("*" .. name .. "*")

    local f = ABT["Create" .. name .. "Macro"]
    local macro = f(ABT, sampleTeam, sampleToonIndex)
    print(macro .. "\n")
end
