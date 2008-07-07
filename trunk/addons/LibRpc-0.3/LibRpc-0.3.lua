local MAJOR, MINOR = "LibRpc-0.3", 1
local LibRpc = LibStub:NewLibrary(MAJOR, MINOR)
if not LibRpc then return end

LibRpc.embeds = LibRpc.embeds or {}

local serializer = LibStub("AceSerializer-3.0")
local comm = LibStub("AceComm-3.0")
comm:Embed(LibRpc)

-- callback tracking: each call gets a unique ID based on a cunning system of ascending integers
local maxID = 1e6                   -- max allowable call ID before rolling back to start
local nextID = math.random(maxID)   -- start at a different place each time for security
local activeCallInfo = {}           -- table of info tables, see below
local activeCallCount = {}          -- per-target count of active calls
local minActiveID                   -- lowest call ID in the pending table
local maxActiveCalls = 100          -- max # pending calls allowed

-- misc
local console                       -- Remoting addon, used for chat output
local consoleLoaded = false         -- delayed loading
local prefixes = {}                 -- table with a unique prefix for each message type
local trustProviders = {}           -- list of addons that provide IsTrusted(name,api), e.g., MultiboxRoster
local remoteApis = {}               -- hashtable of remotable functions

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

local function DebugPrint(...)
    if not consoleLoaded then
        local aceAddon = LibStub("AceAddon-3.0", true)
        if aceAddon then console = aceAddon:GetAddon("Remoting-0.3", true) end
        consoleLoaded = true
    end
    if console then console:DebugPrint(MAJOR..":", ...) end
end

local function SendRpcMessage(prefix, msg, target, prio)
    assert(prefix and msg and target)
    LibRpc:SendCommMessage(prefix, msg, "WHISPER", target, prio)
end

local function RemoveActiveCall(id)
    assert(type(id) == "number" and id > 0)
    local info = activeCallInfo[id]
    if not info then return end

    -- decrement the target count
    local targetCount, newCount = activeCallCount[info.target]
    if not targetCount then
        DebugPrint("activeCallCount == 0 for active target:", info.target)
        newCount = nil
    elseif targetCount > 1 then
        newCount = targetCount - 1
    else
        newCount = nil
    end
    activeCallCount[info.target] = newCount
    
    -- remove the call info
    activeCallInfo[id] = nil
    if id == minActiveID then
        minActiveID = id + 1
    end
end

-- Check for excess pending calls and remove them from the info table
local function PruneDeadCalls()
    assert(minActiveID > 0)
    for i = (minActiveID - 1), (nextID - maxActiveCalls - 1) do
        local id = i % maxID + 1
        RemoveActiveCall(id)
    end
end

local function IsTrustedPlayer(name)
    assert(type(name) == "string")
    assert(#trustProviders > 0, "No trust provider registered")

    for _,provider in ipairs(trustProviders) do
        if provider:IsTrustedPlayer(name) then return true end
    end
    return false
end

local function IsTrustedApi(name, api)
    assert(type(name) == "string")
    assert(type(api) == "string")
    assert(#trustProviders > 0, "No trust provider registered")

    for _,provider in ipairs(trustProviders) do
        if provider:IsTrustedApi(name, api) then return true end
    end
    return false
end

-----------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------

function LibRpc:RegisterTrustProvider(provider)
    assert(type(provider) == "table", "Expected table, got "..type(provider))
    assert(type(provider["IsTrustedPlayer"]) == "function", "Missing required API: IsTrustedPlayer")
    assert(type(provider["IsTrustedApi"]) == "function", "Missing required API: IsTrustedApi")

    for _,p in ipairs(trustProviders) do
        if provider == p then
            error("Provider is already registered")
        end
    end
    trustProviders[#trustProviders + 1] = provider
end

function LibRpc:UnregisterTrustProvider(provider)
    for i,p in ipairs(trustProviders) do
        if provider == p then
            table.remove(trustProviders, i)
            return
        end
    end
    error("Provider not registered")
end

function LibRpc:RegisterRemoteApi(name, f)
    assert(nil == remoteApis[name], "Conflicting remote API already registered: " .. name)
    remoteApis[name] = f
end

function LibRpc:UnregisterRemoteApi(name)
    assert(remoteApis[name], "No such remote API registered: " .. name)
    remoteApis[name] = nil
end

-----------------------------------------------------------------------
-- API RemoteCall(target, [prio,] [callback,] fname, ...)
-- - target     (string)    A character name
-- - prio       (string)    Message priority: "BULK", "NORMAL" or "ALERT" (default)
-- - callback   (function)  Return message handler of the form f(info) where info is a table with the following fields:
--                              target      (string)    Call target
--                              callback    (function)  This function
--                              fname       (string)    Function name
--                              args        (table)     Function arguments
--                              rval        (table)     Return values
--                          Can be nil for no callback.
-- - fname      (string)    Name of a function or method ("Object:Method") for the target to run
-- - ...        (any)       Function arguments. Any type handled by AceSerializer-3.0 is ok.

function LibRpc:RemoteCall(target, prio, callback, fname, ...)
    assert(type(target) == "string", "Expected string for target, got " .. type(target))
    local fargs = { ... }

    -- If prio is missing shift args
    if (prio ~= "BULK") and (prio ~= "NORMAL") and (prio ~= "ALERT") then
        callback, fname, fargs = prio, callback, { fname, ... }
        prio = "ALERT"
    end
    
    -- If callback is missing shift args
    if type(callback) == "string" then
        fname, fargs = callback, { fname, ... }
        callback = nil
    end
    
    assert(type(fname) == "string", "Expected string for fname, got " .. type(fname))

    -- get a unique ID for this call
    local id = nextID
    minActiveID = minActiveID or id
    nextID = nextID % maxID + 1

    -- save call info
    assert((nil == callback) or (type(callback) == "function"), "Expected function for callback, got " .. type(callback))
    activeCallInfo[id] = { target=target, callback=callback, fname=fname, args=fargs }
    
    -- increment the target's active call count
    local targetCount = activeCallCount[target] or 0
    activeCallCount[target] = targetCount + 1

    -- send the call message
    local msg = serializer:Serialize(id, fname, unpack(fargs))
    SendRpcMessage(prefixes.call, msg, target, prio)
    
    -- housekeeping
    PruneDeadCalls()
end

-----------------------------------------------------------------------
-- API LibRpc:Embed(target)
-- - target (object) - target object to embed in
--
-- Embeds lib into the target object, making its functions available on target
function LibRpc:Embed(target)
    local mixins = { "RemoteCall", "RegisterRemoteApi", "UnregisterRemoteApi" }
	for _,v in pairs(mixins) do
		target[v] = self[v]
	end
	
	self.embeds[target] = true
	return target
end

function LibRpc:GetNumPendingCalls()
    return #activeCallInfo
end

function LibRpc:OnCallReceived(prefix, msg, distribution, sender)
    assert(IsTrustedPlayer(sender), "Remote call from untrusted sender: " .. sender)

    -- deserialize the message
    local args = { serializer:Deserialize(msg) }
    assert(#args >= 3)
    local success, id, fname = unpack(args,1,3)
    assert(success, "Deserialize failed: " .. msg)
    assert(IsTrustedApi(sender, fname), "Player "..sender.." tried to call untrusted API "..fname)

    -- get the function
    local f, f2, results, err
    local objname, method = string.match(fname, "^([%w%d_]+):([%w%d_]+)")
    if objname ~= nil then
        local obj = _G[objname]
        f = (type(obj) == "table") and obj[method]
        f2 = function() results = { f(obj, unpack(args,4)) } end
    elseif "loadstring" == fname then
        f = assert(loadstring(unpack(args,4)), "Loadstring failed")
        f2 = function() results = { f() } end
    else
        f = _G[fname] or remoteApis[fname]
        f2 = function() results = { f(unpack(args,4)) } end
    end
    success = (type(f) == "function")
    
    -- if the function exists make the call
    if success then
        success, err = pcall(f2)
    else
        err = "Invalid function: " .. fname
    end
        
    -- send a return message
    if success then
        local resultsMsg = serializer:Serialize(id, unpack(results))
        SendRpcMessage(prefixes.rval, resultsMsg, sender)
    else
        local errMsg = serializer:Serialize(id, "" .. err)
        SendRpcMessage(prefixes.err, errMsg, sender)
    end
end
        
function LibRpc:OnRvalReceived(prefix, msg, distribution, sender)
    if not activeCallCount[sender] then
        DebugPrint("Rval received for sender with no active calls: ", sender)
        return
    end

    -- deserialize the message
    local args = { serializer:Deserialize(msg) }
    assert(#args >= 2)
    local id = args[2]
    local rval = { unpack(args,3) }
    DebugPrint("[" .. id .. "]", sender .. " ->", unpack(rval))

    -- invoke the callback function, if any
    local info = activeCallInfo[id]
    if not info then
        DebugPrint("Rval received for inactive call id:", id, "(sender = "..sender..")")
    else
        if info.callback then
            info.rval = rval
            info.callback(info)
        end
        RemoveActiveCall(id)
    end
end

function LibRpc:OnErrReceived(prefix, msg, distribution, sender)
    if not activeCallCount[sender] then
        DebugPrint("Err received for sender with no active calls: ", sender)
        return
    end

    local _, id, err = serializer:Deserialize(msg)
    RemoveActiveCall(id)
    error("Remote call failed: " .. err .. " [" ..id .."]")
end

-- register prefixes
for k,v in pairs({ "call", "rval", "err" }) do
    prefixes[v] = MAJOR..v
end

LibRpc:RegisterComm(prefixes.call, "OnCallReceived")
LibRpc:RegisterComm(prefixes.rval, "OnRvalReceived")
LibRpc:RegisterComm(prefixes.err, "OnErrReceived")
