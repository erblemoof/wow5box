require("wowunit")
dofile("../../Ace3/tests/wow_api.lua")

local function fileExists(path)
    local f = io.open(path)
	if f then io.close(f) end
	return f ~= nil
end

-- loads an external from either an embedded or non-embedded location
local function LoadExternal(name, searchPaths)
    if pcall(function() dofile(name) end) then
        print("Loaded "..name)
        return
    end
    
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

local libs = { "CallbackHandler-1.0", "AceGUI-3.0", "AceAddon-3.0", "AceBucket-3.0", "ChatThrottleLib", "AceComm-3.0",
    "AceDB-3.0", "AceConfigRegistry-3.0", "AceConfigCmd-3.0", "AceConfigDialog-3.0", "AceConfig-3.0", 
    "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0" }
for _,v in ipairs(libs) do
    LoadExternal(v)
end

dofile("../LibRpc-0.3/LibRpc-0.3.lua")
dofile("../../MultiboxRoster/Core.lua")
dofile("../../MultiboxRoster/Options.lua")
--dofile("../../MultiboxRoster/PublicApi.lua")

-- simulate game start
WoWAPI_FireEvent("ADDON_LOADED", "MultiboxRoster")
WoWAPI_FireEvent("PLAYER_LOGIN")

local libRpc = LibStub("LibRpc-0.3")

-----------------------------------------------------------------------
-- WoW API fakery
-----------------------------------------------------------------------

	-- Replace ChatThrottleLib with a dummy passthrough for testing purposes
	function ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName)
		self.ORIG_SendAddonMessage(prefix, text, chattype, target)
	end
	function ChatThrottleLib:SendChatMessage(prio, prefix,   text, chattype, language, destination, queueName)
		self.ORIG_SendChatMessage(text, chattype, language, destination)
	end


-----------------------------------------------------------------------
-- Test class
-----------------------------------------------------------------------

LibRpcTests = {
    globals = _G
}

function LibRpcTests:setUp()
end

function LibRpcTests:tearDown()
    _G = self.globals
end

-----------------------------------------------------------------------
-- Core Tests
-----------------------------------------------------------------------

function DummyFunc()
    n = 10
end

function LibRpcTests:test1()
    local n = 0
    libRpc:RemoteCall("player", function() n = 1 end, "DummyFunc")
    assertEquals(n, 0)
end

-----------------------------------------------------------------------
-- Go!
-----------------------------------------------------------------------

LuaUnit:run("LibRpcTests")
