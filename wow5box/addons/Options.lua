local MultiboxRoster = LibStub("AceAddon-3.0"):GetAddon("MultiboxRoster")

local lower = string.lower
local upper = string.upper

-----------------------------------------------------------------------
-- Helper functions
-----------------------------------------------------------------------

-- ISSUE: Don't really want this to be public, better way to expose to unit tests
function MultiboxRoster:UnitToName(unit)
    assert(type(unit) == "string", "Unit must be string")
    assert(#unit >= 3, "Invalid unit: " .. unit)

    -- try to convert the unit id to a player name
    if UnitExists(unit) then
        assert(UnitIsPlayer(unit), "Unit is not a player: " .. unit)
        local name, realm = UnitName(unit)
        assert(name ~= nil, "Unknown unit: " .. unit)
        assert(not realm, "Unit is from a different realm")
        return name
    end
    
    -- Otherwise assume that the unit is the name of an offline char. Don't try to fixup
    -- the name because it might be a Unicode string, which LUA can't really handle.
    return unit
end

local function ListRoster()
    local names = MultiboxRoster:GetRosterNames()
    if #names == 0 then
        MultiboxRoster:Print("Roster =", "<empty>")
    else
        MultiboxRoster:Print("Roster =", unpack(names)) 
    end
end

local function AddUnit(info, unit)
    local status, err = pcall(function()
        local name = MultiboxRoster:UnitToName(unit)
        MultiboxRoster:AddCharacter(name)
    end)
    
    if status then
        ListRoster()
    else
        MultiboxRoster:Print(err)
    end
end

local function AddParty()
    local status, err = pcall(function()
        for i = 1,GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if not MultiboxRoster:IncludesCharacter(name) then
                MultiboxRoster:AddCharacter(name)
            end
        end
    end)
    
    if status then
        ListRoster()
    else
        MultiboxRoster:Print(err)
    end
end

local function RemoveUnit(info, unit)
    local status, err = pcall(function()
        local name = MultiboxRoster:UnitToName(unit)
        MultiboxRoster:RemoveCharacter(name)
    end)
    
    if status then
        ListRoster()
    else
        MultiboxRoster:Print(err)
    end
end

-----------------------------------------------------------------------
-- Options
-----------------------------------------------------------------------

function MultiboxRoster:InitOptions()
    local defaults = {
        factionrealm = {
            roster = {}             -- hash table w/ key = char name
        }
    }
	self.db = LibStub("AceDB-3.0"):New("MultiboxRosterDB", defaults, "factionrealm")

	local options = {
        name = "MultiboxRoster",
        handler = MultiboxRoster,
        type = "group",
        args = {
            add = {
                type = "input",
                name = "Add unit",
                desc = "Adds a unit to the roster",
                usage = "name | unitid",
                set = AddUnit
            },
            addparty = {
                type = "execute",
                name = "Add Party",
                desc = "Adds current party to the roster",
                func = AddParty
            },
            clear = {
                type = "execute",
                name = "Clear",
                desc = "Clear roster",
                func = function() self:Clear(); ListRoster() end
            },
            remove = {
                type = "input",
                name = "Remove unit",
                desc = "Removes a unit from the roster",
                usage = "name | unitid",
                set = RemoveUnit
            },
            list = {
                type = "execute",
                name = "List",
                desc = "List trust settings",
                func = ListRoster
            },
        }
	}

    local cfg = LibStub("AceConfig-3.0")
    cfg:RegisterOptionsTable("MultiboxRoster", options, "multiboxroster")
	cfg:RegisterOptionsTable("MultiboxRoster", options, "mbr")
end
