local MAJOR, MINOR = "LibRemoteHook-0.3", 1
local LibRemoteHook = LibStub:NewLibrary(MAJOR, MINOR)
if not LibRemoteHook then return end

LibRemoteHook.embeds = LibRpc.embeds or {}
return

local addon = LibStub("AceAddon-3.0"):NewAddon(MAJOR, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0")
local libTrust = LibStub("LibTrust-0.2")
if not libTrust then error(MAJOR .. " requires LibTrust-0.1") end

-- contruct a table with a unique prefix for each message type
local prefixes = {}
for k,v in pairs({ "call", "rval", "err" }) do
    prefixes[v] = MAJOR..v
end

-- callback tracking
local nextID = 1                    -- each call gets a unique ID based on a cunning system of ascending integers
local activeCallInfo = {}           -- table of info tables, see below
local minActiveID                   -- lowest call ID in the pending table
local maxActiveCalls = 100          -- max # pending calls allowed

-- misc
local playerName = UnitName("player")
local debugMode = false

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

local function DebugPrint(...)
    if debugMode then
        addon:Print(...)
    end
end

local function ChatCommand(input)
    -- extract target
    local target, startpos = addon:GetArgs(input)
    
    -- extract function args
    local args = {}
    while startpos <= string.len(input) do
        args[#args + 1], startpos = addon:GetArgs(input, 1, startpos)
    end

    -- make the function call
    if target == "debug" and #args == 0 then
        debugMode = not debugMode
        if debugMode then
            addon:Print("Debug mode on")
        else
            addon:Print("Debug mode off")
        end
    elseif target and #args >= 1 then
        LibRpc:RemoteCall(target, nil, unpack(args))
    else
        addon:Print("/rpc target fname [args]")
    end
end

-- TODO: Option for priority control
local function SendRpcMessage(prefix, msg, target)
    assert(prefix and msg and target)
    addon:SendCommMessage(prefix, msg, "WHISPER", target, "ALERT")
end

-- Check for excess pending calls and remove them from the info table
local function PruneDeadCalls()
    assert(minActiveID > 0)
    while minActiveID <= (nextID - maxActiveCalls) do
        activeCallInfo[minActiveID] = nil
        minActiveID = minActiveID + 1
    end
end

-- Gets the internal event name for a function hook
local function GetHookEventName(fname)
    return ("LibRpc_Hook_" .. fname)
end

-- Returns the function hook for an internal event name or nil if the event isn't for a hook
local function GetHookFromEventName(eventName)
    local pat = GetHookEventName("([^%s]+)")
    local fname = string.match(eventName, pat)
    DebugPrint("GetHookFromEventName:", eventName, "->", fname)
    return fname
end

-----------------------------------------------------------------------
-- Event handling
-----------------------------------------------------------------------

local sinkCallbackHandlers = {}     -- Table of event sink callback handlers, one per event source
local sourceCallbackHandler         -- Single event source callback handler

-- Gets the sink callback handler for a given source
local function GetSinkCallbackHandler(source)
    assert(type(source) == "string", "Invalid source: " .. source)
    return sinkCallbackHandlers[source]
end

-- Gets the sink callback handler for a given source or allocates a new one
local function CreateSinkCallbackHandler(source)
    local handler = GetSinkCallbackHandler(source)
    if not handler then
        handler = {}
        handler.events = LibStub("CallbackHandler-1.0"):New(handler)
        sinkCallbackHandlers[source] = handler
        DebugPrint("Sink callback handler created for " .. source)
    end
    
    return handler
end

-- Gets the unique source callback handler
local function GetSourceCallbackHandler()
    return sourceCallbackHandler
end

-- Gets the unique source callback handler or allocates a new one
local function CreateSourceCallbackHandler()
    local handler = GetSourceCallbackHandler()
    if not handler then
        handler = {}
        handler.events = LibStub("CallbackHandler-1.0"):New(handler)
        sourceCallbackHandler = handler
        
        -- set up the addon to relay events
        handler.events.OnUsed = function(self, target, event)
            DebugPrint("OnUsed:", self, target, event)
            local fname = GetHookFromEventName(event)
            if fname then
                addon:Hook(fname, function(...) handler.events:Fire(event, ...); DebugPrint("Fire", event) end)
                DebugPrint("Source callback handler hooked addon for " .. fname)
            else
                addon:RegisterEvent(event, function(...) handler.events:Fire(...); DebugPrint("Fire", event) end)
                DebugPrint("Source callback handler registered with addon for " .. event)
            end
        end
        handler.events.OnUnused = function(self, target, event)
            DebugPrint("OnUnused:", self, target, event)
            local fname = GetHookFromEventName(event)
            if fname then
                addon:Unhook(fname)
                DebugPrint("Source callback handler unhooked addon for " .. fname)
            else
                addon:UnregisterEvent(event)
                DebugPrint("Source callback handler unregistered with addon for " .. event)
            end
        end

        DebugPrint("Source callback handler created")
    end

    return handler
end

-- Registers an event at the source (called via RPC)
local function RegisterSourceEvent(event, sink)
    assert(type(event) == "string", "Invalid event name: " .. event)
    assert(type(sink) == "string", "Invalid sink: " .. sink)

    -- create remote callback
    local function f(eventName, ...)
        LibRpc:RemoteCall(sink, nil, "FireSinkEvent", eventName, playerName, ...)
        DebugPrint("Fired sink event " .. event .. " at " .. sink .. " via RPC")
    end

    -- register event
    local handler = CreateSourceCallbackHandler()
    handler.RegisterCallback(sink, event, f)
    DebugPrint(sink .. " registered for " .. event)
end

-- Unregisters an event at the source (called via RPC)
local function UnregisterSourceEvent(event, sink)
    local handler = GetSourceCallbackHandler()
    assert(handler, "No remote events registered")
    handler.UnregisterCallback(sink, event)
end

-- Unregisters all events at the source (called via RPC)
local function UnregisterAllSourceEvents(sink)
    local handler = GetSourceCallbackHandler()
    assert(handler, "No remote events registered")
    handler.UnregisterAllCallbacks(sink)
end

-- Fires an event an the sink (called via RPC)
local function FireSinkEvent(event, source, ...)
    assert(type(event) == "string", "Invalid event name: " .. event)
    assert(type(source) == "string", "Invalid source: " .. source)

    -- get the source callback handler
    local handler = GetSinkCallbackHandler(source)
    assert(handler, "Callback handler not found for source: " .. source)
    
    -- fire events to all lib clients
    handler.events:Fire(event, ...)
    DebugPrint("Fired sink event " .. event .. " from " .. source)
end

-----------------------------------------------------------------------
-- Function hooking
-----------------------------------------------------------------------

-- Hooks a function at the source (called via RPC)
local function HookAtSource(fname, sink)
    local event = GetHookEventName(fname)
    RegisterSourceEvent(event, sink)
end

-- ISSUE: This will unregister both hooks and events. Also seems to unregister for all addons.
-- Unregisters an event at the source (called via RPC)
local function UnhookAtSource(fname, sink)
    local event = GetHookEventName(fname)
    UnregisterSourceEvent(event, sink)
end

-- Unregisters all events at the source (called via RPC)
local function UnhookAllAtSource(sink)
    local event = GetHookEventName(fname)
    UnregisterAllSourceEvents(event, sink)
end

-----------------------------------------------------------------------
-- Private API: Table of local functions that can be called via RPC
-----------------------------------------------------------------------

local privateApi = {
    -- events
    RegisterSourceEvent=RegisterSourceEvent,
    UnregisterSourceEvent=UnregisterSourceEvent,
    UnregisterAllSourceEvents=UnregisterAllSourceEvents,
    FireSinkEvent=FireSinkEvent,
    
    -- hooks
    HookAtSource=HookAtSource,
    UnhookAtSource=UnhookAtSource,
    UnhookAllAtSource=UnhookAllAtSource
}

-----------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- API RemoteCall(target, callback, fname, ...)
-- - target     (string)    A character name
-- - callback   (function)  Function return message handler of the form f(info), where info is a table:
--                          the following fields:
--                              target      (string)    Call target
--                              callback    (function)  This function
--                              fname       (string)    Function name
--                              args        (table)     Function arguments
--                              rval        (table)     Return values
--                          Can be nil if for callback.
-- - fname      (string)    Name of a global function for the target to run
-- - ...        (any)       Function arguments. Any type handled by AceSerializer-3.0 is ok.

function LibRpc:RemoteCall(target, callback, fname, ...)
    assert(target and fname)

    -- get a unique ID for this call
    local id = nextID
    minActiveID = minActiveID or id
    nextID = nextID + 1

    -- save callback info if requested    
    if callback then
        assert(type(callback) == "function")
        activeCallInfo[id] = { target=target, callback=callback, fname=fname, args={...} }
    end

    -- send the call message
    local msg = addon:Serialize(id, fname, ...)
    SendRpcMessage(prefixes.call, msg, target)
    
    -- housekeeping
    PruneDeadCalls()
end

-----------------------------------------------------------------------
-- API RegisterRemoteEvent(target, event, method)

-- TODO: Should be able to specify remote function to run. Example: { "UnitName", "target" }
-- TODO: Message priority
function LibRpc:RegisterRemoteEvent(target, event, method)
    assert(type(target) == "string", "Invalid target: " .. target)
    assert(type(event) == "string", "Invalid event name: " .. event)
    assert(type(method) == "function", "Method not a function")

    -- if source registration succeeds, register sink with source callback handler
    local function f(info)
        local handler = CreateSinkCallbackHandler(target)
        handler.RegisterCallback(self, event, method)
    end

    -- register source event, callback f only called on success
    self:RemoteCall(target, f, "RegisterSourceEvent", event, playerName)
end

-----------------------------------------------------------------------
-- API UnregisterRemoteEvent(target, event)

function LibRpc:UnregisterRemoteEvent(target, event)
    assert(type(target) == "string", "Invalid target: " .. target)
    assert(type(event) == "string", "Invalid event name: " .. event)

    -- unregister source event
    self:RemoteCall(target, nil, "UnregisterSourceEvent", event, playerName)

    -- unregister sink with source callback handler
    local handler = GetSinkCallbackHandler(target)
    assert(handler, "No events registered for target: " .. target)
    handler.UnregisterCallback(self, event)
end

-----------------------------------------------------------------------
-- API UnregisterAllRemoteEvents(target)

function LibRpc:UnregisterAllRemoteEvents(target)
    assert(type(target) == "string", "Invalid target: " .. target)

    -- unregister source event
    self:RemoteCall(target, nil, "UnregisterAllSourceEvents", playerName)

    -- unregister sink with source callback handler
    local handler = GetSinkCallbackHandler(target)
    if handler then
        handler.UnregisterAllCallbacks(self)
    end
end

-----------------------------------------------------------------------
-- API RemoteHook(target, fname, handler)

-- ISSUE: Support for multiple forms of Hook, esp. self:Hook("functionName")
function LibRpc:RemoteHook(target, fname, handler)
    assert(type(target) == "string", "Invalid target: " .. target)
    assert(type(fname) == "string", "Invalid function name: " .. fname)
    assert(type(handler) == "function", "Invalid handler type: " .. type(handler))

    -- if source registration succeeds, register sink with source callback handler
    local function f(info)
        local cbh = CreateSinkCallbackHandler(target)
        local event = GetHookEventName(fname)
        cbh.RegisterCallback(self, event, handler)
        DebugPrint("Hooked " .. fname .. " on " .. target)
    end

    -- register source event, callback f only called on success
    self:RemoteCall(target, f, "HookAtSource", fname, playerName)
end

-----------------------------------------------------------------------
-- API UnhookAtSource

-----------------------------------------------------------------------
-- API UnhookAllAtSource

-----------------------------------------------------------------------
-- API LibRpc:Embed(target)
-- - target (object) - target object to embed in
--
-- Embeds lib into the target object, making its functions available on target
function LibRpc:Embed(target)
    local mixins = { "RemoteCall", "RegisterRemoteEvent", "UnregisterRemoteEvent",
        "UnregisterAllRemoteEvents" }

	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	
	self.embeds[target] = true
	return target
end

-----------------------------------------------------------------------
-- Addon
-----------------------------------------------------------------------

function addon:OnEnable()
    self:RegisterChatCommand("rpc", ChatCommand)
    for k,v in pairs(prefixes) do
        self:RegisterComm(v)
    end
end

function addon:OnDisable()
    self:UnregisterChatCommand("rpc")
    for k,v in pairs(prefixes) do
        self:UnregisterComm(v)
    end
end

function addon:OnCommReceived(prefix, msg, distribution, sender)
    -- TODO: Relax security for events, esp ones you registered for
    if not libTrust:IsAllowed(sender) then
        if libTrust:IsUnspecified(sender) then
            error("RPC message from untrusted sender: " .. sender)
        end
        return
    end

    ----------------------------------
    -- Receiver: Handle remote call
    ----------------------------------
    if (prefix == prefixes.call) then
        -- deserialize the message
        local args = { self:Deserialize(msg) }
        assert(#args >= 3)
        local success, id, fname = unpack(args,1,3)
        assert(success, "Deserialize failed: " .. msg)

        -- get the function
        -- TODO: allow "MBR.foo" via getfield, Prog in Lua: 130
        -- TODO: support loadstring
        local f = _G[fname] or privateApi[fname]
        success = f and (type(f) == "function")
        
        -- if the function exists make the call
        local results, err
        if success then
            local function f2()
                results = { f(unpack(args,4)) }
            end
            success, err = pcall(f2)
        else
            err = "Invalid function: " .. fname
        end
        
        -- send a return message
        if success then
            local resultsMsg = self:Serialize(id, unpack(results))
            SendRpcMessage(prefixes.rval, resultsMsg, sender)
        else
            local errMsg = "" .. err
            SendRpcMessage(prefixes.err, errMsg, sender)
        end
        
    ----------------------------------
    -- Sender: Handle return callbacks
    ----------------------------------
    elseif (prefix == prefixes.rval) then
        -- deserialize the message
        local args = { self:Deserialize(msg) }
        assert(#args >= 2)
        local id = args[2]
        local rval = { unpack(args,3) }
        DebugPrint("[" .. id .. "]", sender .. " ->", unpack(rval))

        -- invoke the callback function, if any
        local info = activeCallInfo[id]
        if info then
            activeCallInfo[id] = nil
            info.rval = rval
            info.callback(info)
        end
    elseif (prefix == prefixes.err) then
        error("Remote call failed: " .. msg)
        
    ----------------------------------
    -- Uh oh, LibRpc error
    ----------------------------------
    else
        error("unrecognized prefix: " .. prefix)
    end
end
