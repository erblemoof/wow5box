local MAJOR, MINOR = "LibRemoteEvent-0.3", 1
local LibRemoteEvent = LibStub:NewLibrary(MAJOR, MINOR)
if not LibRemoteEvent then return end

local function DebugPrint(...)
    DEFAULT_CHAT_FRAME:AddMessage(table.concat({...}, " "))
end

local RemoteCallbackHandler = LibStub:GetLibrary("RemoteCallbackHandler-0.3")

LibRemoteEvent.frame = LibRemoteEvent.frame or CreateFrame("Frame", MAJOR.."_Frame")
LibRemoteEvent.embeds = LibRemoteEvent.embeds or {}

-- APIs and registry for blizzard events, using RemoteCallbackHandler lib
if not LibRemoteEvent.events then
    LibRemoteEvent.events = RemoteCallbackHandler:New(LibRemoteEvent, MAJOR.."_events", "RegisterRemoteEvent",
        "UnregisterRemoteEvent", "UnregisterAllRemoteEvents")
end

function LibRemoteEvent.events:OnUsed(target, eventname) 
	LibRemoteEvent.frame:RegisterEvent(eventname)
end

function LibRemoteEvent.events:OnUnused(target, eventname) 
	LibRemoteEvent.frame:UnregisterEvent(eventname)
end

-- APIs and registry for addon messages, using RemoteCallbackHandler lib
if not LibRemoteEvent.messages then
    LibRemoteEvent.messages = RemoteCallbackHandler:New(LibRemoteEvent, MAJOR.."_messages", "RegisterRemoteMessage",
        "UnregisterRemoteMessage", "UnregisterAllRemoteMessages")
    LibRemoteEvent.SendRemoteMessage = LibRemoteEvent.messages.Fire
end

function LibRemoteEvent:Embed(target)
    local mixins = { "RegisterRemoteEvent", "UnregisterRemoteEvent", "UnregisterAllRemoteEvents",
        "RegisterRemoteMessage", "UnregisterRemoteMessage", "UnregisterAllRemoteMessages", "SendRemoteMessage" }
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- Script to fire blizzard events into the event listeners
LibRemoteEvent.frame:SetScript("OnEvent", function(this, event, ...)
	LibRemoteEvent.events:Fire(event, ...)
end)
