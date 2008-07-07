RemotingTestAddon = LibStub("AceAddon-3.0"):NewAddon("RemotingTestAddon", "AceConsole-3.0", "AceEvent-3.0", "LibRpc-0.3", "LibRemoteEvent-0.3")
AnotherAddon = LibStub("AceAddon-3.0"):NewAddon("AnotherAddon")

local libRpc = LibStub("LibRpc-0.3")

local player = UnitName("player")

local cocreate = coroutine.create
local coresume = coroutine.resume
local coyield = coroutine.yield

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

function print(...)
    RemotingTestAddon:Print(...)
end

function SetGlobal(var, value)
    _G[var] = value
end

local function RemoteCallSelf(...)
   RemotingTestAddon:RemoteCall(player, ...)
end

local function SetFoo(v)
    foo = v
end

-----------------------------------------------------------------------
-- Addon
-----------------------------------------------------------------------

function RemotingTestAddon:OnInitialize()
end

function RemotingTestAddon:OnEnable()
    self:RegisterChatCommand("rt", "RunTest")
    self:RegisterRemoteApi("SetFoo", SetFoo)
end

function RemotingTestAddon:OnDisable()
    self:UnregisterChatCommand("rt")
    self:UnregisterRemoteApi("SetFoo")
end

function RemotingTestAddon:RunTest(input)
    local name = RemotingTestAddon:GetArgs(input)
    local f = RemotingTestAddon[name] or RemotingTestAddon["test"..name]
    if type(f) ~= "function" then
        print("Test not found: " .. name)
        return
    end

    local success, err = pcall(function()
        RemotingTestAddon:setUp()
        f(RemotingTestAddon)
        RemotingTestAddon:tearDown()
    end)
    
    if success then
        self:Print("Test", name..":", "success!")
    else
        self:Print("Test", name..":", "failure :( -", err)
    end
end

function RemotingTestAddon:SetMember(var, value)
    self.var = value
end

-----------------------------------------------------------------------
-- Another Addon
-----------------------------------------------------------------------

function AnotherAddon:SetGlobal(...)
    SetGlobal(...)
end

-----------------------------------------------------------------------
-- Tests
-----------------------------------------------------------------------

function RemotingTestAddon:setUp()
    assertEquals(libRpc:GetNumPendingCalls(), 0)
    for _,v in pairs({ "foo", "bar", "kazoo" }) do
        _G[v] = 0
        self[v] = 0
    end
end

function RemotingTestAddon:tearDown()
end

function RemotingTestAddon:test1()
    RemoteCallSelf(function() assertEquals(foo, 1) end, "SetGlobal", "foo", 1)
    RemoteCallSelf("BULK", function() assertEquals(bar, 2) end, "SetGlobal", "bar", 2)
    RemoteCallSelf("NORMAL", function() assertEquals(kazoo, 3) end, "AnotherAddon:SetGlobal", "kazoo", 3)
end

function RemotingTestAddon:test2()
    RemoteCallSelf(function() assertEquals(foo, 4) end, "SetFoo", 4)
end

function RemotingTestAddon:test3()
    RemoteCallSelf(function() assertEquals(foo, 5) end, "loadstring", "foo = 5")

    RemoteCallSelf("loadstring", "NewGlobal = {}; function NewGlobal:SetBar(v) bar = v end")
    RemoteCallSelf("BULK", function() assertEquals(bar, 6) end, "NewGlobal:SetBar", 6)
end

function RemotingTestAddon:test4()
end
