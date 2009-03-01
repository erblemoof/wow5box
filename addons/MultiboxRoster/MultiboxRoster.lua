local MBR = LibStub("AceAddon-3.0"):NewAddon("MultiboxRoster", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0")

local tsort = table.sort

function MBR:OnInitialize()
	self.activeTeam = nil
	self.activeTeamName = nil
	self.activeToons = {}
end

function MBR:OnEnable()
    self:InitOptions()
    self:RegisterBucketEvent("PARTY_MEMBERS_CHANGED", 0.2, "OnPartyMembersChanged")
    self:RegisterBucketEvent("RAID_ROSTER_UPDATE", 0.2, "OnRaidRosterUpdate")
    self:DetectGroupAndTeam()
end

function MBR:OnDisable()
    self:UnregisterBucket("PARTY_MEMBERS_CHANGED")
    self:UnregisterBucket("RAID_ROSTER_UPDATE")
end

function MBR:OnPartyMembersChanged()
    self:DoGroupChanged(MBR:GetPartyMembers())
end

function MBR:OnRaidRosterUpdate()
    self:DoGroupChanged(MBR:GetRaidMembers())
end

-- Handle party or raid changed events
function MBR:DoGroupChanged(group)
    local name, team, activeToons = MBR:DetectTeam(group)
    
    if (name ~= self.activeTeamName) then
        self:SendMessage("MultiboxRoster_TeamChanged", team, name)
        self:Print(team, name)
        
        self.activeTeamName = name
        self.activeTeam = team
        self.activeToons = activeToons
        self:ListTeam()
    end
end

-- Returns all of the toons in a party
function MBR:GetPartyMembers()
    local party = {}
    
    if UnitInParty("player") then
        party[1] = UnitName("player")
        for i = 1, GetNumPartyMembers() do
            party[i+1] = UnitName("party"..i)
        end
    end
    
    return party
end

-- Returns all of the toons in a raid, including battlegrounds
function MBR:GetRaidMembers()
    local raid = {}
    
    if UnitInRaid("player") then
        -- GetNumRaidMembers *includes* the player
        for i = 1, GetNumRaidMembers() do
            raid[i] = GetRaidRosterInfo(i)
        end
    end
    
    return raid
end

-- Returns the team from a group of toons (either a party or raid), or nil if no
-- matching team is found
function MBR:DetectTeam(group)
    assert(type(group) == "table")
    assert(#group > 0)
    
    -- Make hashtable of the group toons and active toons
    local groupToons = {}
    for _, toon in ipairs(group) do
        groupToons[toon] = true
    end
    
    local activeToons = {}
    
    -- Find a team w/ all members in the group. If more than one team matches return the largest.
    local bestTeam = nil
    local bestTeamName = nil
    local bestTeamSize = 0
    for name, team in pairs(MBR.teams) do
        local teamSize = #team
        if (teamSize > bestTeamSize) then
            local match = true
            for _, toon in ipairs(team) do
                match = (groupToons[toon] ~= nil)
                if (not match) then break end
                activeToons[toon] = true
            end
            
            if (match) then
                bestTeam = team
                bestTeamName = name
                bestTeamSize = teamSize
            end
        end
    end
    
    -- Copy the activeToon keys to a flat list and sort
    local activeToonsSorted = {}
    for k,_ in pairs(activeToons) do
        activeToonsSorted[1 + #activeToonsSorted] = k
    end
    tsort(activeToonsSorted)
    
    return bestTeamName, bestTeam, activeToonsSorted
end

-- Detect the group type and then the team
function MBR:DetectGroupAndTeam()
    if UnitInParty("player") then
        self:OnPartyMembersChanged()
    elseif UnitInRaid("player") then
        self:OnRaidMembersChanged()
    else
        self.activeTeam = nil
        self.activeTeamName = nil
        self:ListTeam(true)
    end
end

--[[
function MBR:CheckTeam(name)
    team = self.teams[name]
    if (team == nil) then
        self:Print("Invalid team")
    else
        local test = function() return false end
        if UnitInParty("player") then
            test = UnitInParty
        elseif UnitInRaid("player") then
            test = UnitInRaid
        end

        for _, toon in ipairs(team) do
            self:Print(toon .. " - " .. test(toon))
        end
    end
end
]]--

function MBR:InitOptions()
	local options = {
        name = "MultiboxRoster",
        handler = MBR,
        type = "group",
        args = {
            detect = {
                type = "execute",
                name = "Detect",
                desc = "Detect team",
                func = "DetectTeam"
            },
            list = {
                type = "execute",
                name = "List",
                desc = "List active team",
                func = "ListTeam"
            },
        }
	}

    local cfg = LibStub("AceConfig-3.0")
	cfg:RegisterOptionsTable("MultiboxRoster", options, "mbr")
end

function MBR:ListTeam(showDetails)
    self:Print("Active team - " .. (self.activeTeamName or "<none>"))
    
    if showDetails then
        if (self.activeTeam ~= nil) then
            for _, toon in ipairs(self.activeTeam) do
                self:Print("    " .. toon)
            end
        end
    end
end