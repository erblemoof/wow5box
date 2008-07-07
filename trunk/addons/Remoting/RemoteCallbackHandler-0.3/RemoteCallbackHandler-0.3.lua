local MAJOR, MINOR = "RemoteCallbackHandler-0.3", 1
local RemoteCallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)
if not RemoteCallbackHandler then return end

-- No embeds by design. RCH is not explicitly embeddable, like CH

-- TODO: Remove LibRpc dependency?
local libRpc = LibStub("LibRpc-0.3")

local sinkCallbackHandlers = {}     -- Table of event sink callback handlers, one per event source
local sourceCallbackHandler         -- Single event source callback handler

-- misc
local playerName = UnitName("player")
local gmatch = string.gmatch
local console                       -- Remoting addon, used for chat output

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

local function DebugPrint(...)
    if nil == console then
        local aceAddon = LibStub("AceAddon-3.0", true)
        if aceAddon then console = aceAddon:GetAddon("Remoting-0.3", true) end
        console = console or false
    end
    if console then console:DebugPrint(MAJOR..":", ...) end
end

local function assertType(arg, typelist, argname)
    -- check for a type match
    local argType = type(arg)
    for typename in gmatch(typelist, "%a+") do
        if (argType == typename) then return end
    end

    -- no match, throw an error
    argname = argname or "<argument>"
    error("Expected " .. typelist .. " for " .. argname .. ", got " .. argType)
end

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

        handler.events.OnUsed = function(self, target, event)
            DebugPrint("OnUsed:", self, target, event)
            -- OnSinkUsed(self, target, event)
        end
        handler.events.OnUnused = function(self, target, event)
            DebugPrint("OnUnused:", self, target, event)
            -- OnSinkUnused(self, target, event)
        end
        
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
        
        handler.events.OnUsed = function(self, target, event)
            DebugPrint("OnUsed:", self, target, event)
            -- OnSourceUsed(self, target, event)
        end
        handler.events.OnUnused = function(self, target, event)
            DebugPrint("OnUnused:", self, target, event)
            -- OnSourceUnused(self, target, event)
        end

        DebugPrint("Source callback handler created")
    end

    return handler
end

-----------------------------------------------------------------------
-- Private Remote APIs
-----------------------------------------------------------------------

-- Registers an event at the source (called via RPC)
local function RegisterSourceEvent(event, sink)
    assertType(event, "string")
    assertType(sink, "string")

    -- create remote callback
    local function f(eventName, ...)
        libRpc:RemoteCall(sink, nil, MAJOR.."_FireSinkEvent", eventName, playerName, ...)
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

libRpc:RegisterRemoteApi(MAJOR.."_RegisterSourceEvent", RegisterSourceEvent)
libRpc:RegisterRemoteApi(MAJOR.."_UnregisterSourceEvent", UnregisterSourceEvent)
libRpc:RegisterRemoteApi(MAJOR.."_UnregisterAllSourceEvents", UnregisterAllSourceEvents)
libRpc:RegisterRemoteApi(MAJOR.."_FireSinkEvent", FireSinkEvent)

-----------------------------------------------------------------------
-- Registry
-----------------------------------------------------------------------

local CallbackRegistry = {}

function CallbackRegistry:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CallbackRegistry:RegisterCallback(target, event, method, ...)
    assertType(target, "string", "target")
    assertType(event, "string", "event")
    assertType(method, "string|function", "method")
    
    -- if source registration succeeds, register sink with source callback handler
    local function f(info)
        local handler = CreateSinkCallbackHandler(target)
        handler.RegisterCallback(self, event, method)
    end

    -- register source event, callback f only called on success
    libRpc:RemoteCall(target, f, MAJOR.."_RegisterSourceEvent", event, playerName)
end

function CallbackRegistry:UnregisterCallback(target, event)
    assertType(target, "string", "target")
    assertType(event, "string", "event")
    
    -- unregister source event
    libRpc:RemoteCall(target, nil, MAJOR.."_UnregisterSourceEvent", event, playerName)

    -- unregister sink with source callback handler
    local handler = GetSinkCallbackHandler(target)
    assert(handler, "No events registered for target: " .. target)
    handler.UnregisterCallback(self, event)
end

function CallbackRegistry:UnregisterAllCallbacks(target)
    assertType(target, "string", "target")
    
    -- unregister source event
    libRpc:RemoteCall(target, nil, MAJOR.."_UnregisterAllSourceEvents", playerName)

    -- unregister sink with source callback handler
    local handler = GetSinkCallbackHandler(target)
    if handler then
        handler.UnregisterAllCallbacks(self)
    end
end

function CallbackRegistry:Fire(event, ...)
    assertType(event, "string", "event")
end

--------------------------------------------------------------------------
-- RemoteCallbackHandler:New
--
--   embedTarget       - target object to embed public APIs in
--   embedID           - string ID used to identify the embedTarget remotely
--   RegisterName      - name of the callback registration API, default "RegisterCallback"
--   UnregisterName    - name of the callback unregistration API, default "UnregisterCallback"
--   UnregisterAllName - name of the API to unregister all callbacks, default "UnregisterAllCallbacks". false == don't publish this API.

function RemoteCallbackHandler:New(embedTarget, embedID, RegisterName, UnregisterName, UnregisterAllName)
    assertType(embedTarget, "table")
    assertType(embedID, "string")
    assertType(RegisterName, "string|nil")
    assertType(UnregisterName, "string|nil")
    assertType(UnregisterAllName, "string|nil|boolean")
    
	RegisterName = RegisterName or "RegisterRemoteCallback"
	UnregisterName = UnregisterName or "UnregisterRemoteCallback"
	if (nil == UnregisterAllName) then      -- TRICKY: false means "don't want this method"
		UnregisterAllName = "UnregisterAllRemoteCallbacks"
	end

	-- Create the registry object
	-- ISSUE: embedID has to be registered on but sides. ok, right?
	local registry = CallbackRegistry:New({ embedID=embedID })

	embedTarget["Fire"] = registry.Fire
	embedTarget[RegisterName] = registry.RegisterCallback
	embedTarget[UnregisterName] = registry.UnregisterCallback

	if UnregisterAllName then
		embedTarget[UnregisterAllName] = registry.UnregisterAllCallbacks
	end

	return registry
end
