local Remoting = LibStub("AceAddon-3.0"):NewAddon("Remoting-0.3", "AceConsole-3.0", "AceEvent-3.0", "LibRpc-0.3", "LibRemoteEvent-0.3")

function Remoting:OnInitialize()
    local defaults = {
        global = {
            debug = false
        }
    }
	self.db = LibStub("AceDB-3.0"):New("RemotingDB", defaults, "global")

    -- TODO: Events - unreg, unregall, list
    -- ISSUE: Config GUI needs prettification
    -- TODO: WoW addon GUI (config cmd)
	local options = {
        name = "Remoting",
        handler = Remoting,
        type = "group",
        args = {
            call = {
                type = "input",
                name = "Procedure Call",
                desc = "Execute a remote procedure call",
                set = function(info, v) self:DoRemoteCall(v) end
            },
            debug = {
                type = "toggle",
                name = "Debug",
                desc = "Toggle debug mode",
                set = "SetDebug",
                get = "GetDebug"
            },
            regevent = {
                type = "input",
                name = "Register Event",
                desc = "Registers for a remote event",
                set = function(info, v) self:DoRegisterRemoteEvent(v) end
            },
        }
	}

    local cfg = LibStub("AceConfig-3.0")
    cfg:RegisterOptionsTable("Remoting-0.3", options, "remote")
	cfg:RegisterOptionsTable("Remoting-0.3", options, "remoting")
end

function Remoting:SetDebug(info, v)
    self.db.global.debug = not self:GetDebug()
    if self:GetDebug() then
        self:Print("Debug mode on")
    else
        self:Print("Debug mode off")
    end
end

function Remoting:GetDebug()
    return self.db.global.debug
end

function Remoting:DebugPrint(...)
    if self:GetDebug() then
        self:Print(...)
    end
end

-- TODO: Make this red or something
function Remoting:PrintError(...)
    self:Print(...)
end

-- Returns a table of all args from the input string
local function GetAllArgs(input)
    local startpos = 0
    local args = {}
    local nArgs = 0
    while startpos <= string.len(input) do
        nArgs = nArgs + 1
        args[nArgs], startpos = Remoting:GetArgs(input, 1, startpos)
        
        -- replace "nil" with nil
        if args[nArgs] == "nil" then args[nArgs] = nil end
    end

    return args
end

function Remoting:DoRemoteCall(input)
    local args = GetAllArgs(input)
    self:RemoteCall(unpack(args))
end

function Remoting:DoRegisterRemoteEvent(input)
    local args = GetAllArgs(input)
    args[#args + 1] = "Print"
    self:RegisterRemoteEvent(unpack(args))
end
