local MultiboxRoster = LibStub("AceAddon-3.0"):NewAddon("MultiboxRoster", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0")

function MultiboxRoster:OnInitialize()
    self:InitOptions()
    
	self.activeRoster = {}
end

function MultiboxRoster:OnEnable()
    self.rosterChangeEvents = { "RAID_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED" }
    self:RegisterBucketEvent(self.rosterChangeEvents, 0.2, "ScanActiveRoster")

    local libRpc = LibStub("LibRpc-0.3", true)
    if libRpc then
        libRpc:RegisterTrustProvider(self)
    else
        self:Print("LibRpc not installed")
    end
end

function MultiboxRoster:OnDisable()
    self:UnregisterBucket(self.rosterChangeEvents)

    local libRpc = LibStub("LibRpc-0.3", true)
    if libRpc then
        libRpc:UnregisterTrustProvider(self)
    end
end

-----------------------------------------------------------------------
-- Roster functions
-----------------------------------------------------------------------

-- Adds a character to the roster
function MultiboxRoster:AddCharacter(name)
    assert(type(name) == "string", "Expected string for character name, got " .. type(name))
    local roster = self:GetRoster()
    assert(roster[name] == nil, "Character already in roster: " .. name)
    roster[name] = true
    self:ScanActiveRoster()
end

-- Removes a unit from the roster
function MultiboxRoster:RemoveCharacter(name)
    assert(type(name) == "string", "Expected string for character name, got " .. type(name))
    local roster = self:GetRoster()
    assert(roster[name] ~= nil, "Character not in roster: " .. name)
    roster[name] = nil
    self:ScanActiveRoster()
end

function MultiboxRoster:IncludesCharacter(name)
    assert(type(name) == "string", "Expected string for character name, got " .. type(name))
    local roster = self:GetRoster()
    return (roster[name] ~= nil)
end

function MultiboxRoster:Clear()
    self.db.factionrealm.roster = {}
    self:ScanActiveRoster()
end

function MultiboxRoster:GetRoster()
    return self.db.factionrealm.roster
end

function MultiboxRoster:GetRosterNames()
    local names = {}
    for k in pairs(self:GetRoster()) do
        names[#names+1] = k
    end
    
    if #names > 0 then table.sort(names) end
    return names
end

-----------------------------------------------------------------------
-- Active roster
-----------------------------------------------------------------------

-- TODO: Roster sharing via RPC (w/ option to control)
function MultiboxRoster:ScanActiveRoster()
    -- scan the party/raid for multibox chars
	local newActiveRoster = {}
	if UnitInRaid("player") then
	    for i = 1,GetNumRaidMembers() do
	        local name = GetRaidRosterInfo(i)
	        if self:IncludesCharacter(name) then
	            newActiveRoster[name] = true
	        end
	    end
	elseif UnitInParty("player") then
	    for i = 1,GetNumPartyMembers() do
	        local name = UnitName("party"..i)
	        if self:IncludesCharacter(name) then
	            newActiveRoster[name] = true
	        end
	    end
	end

	-- report additions from the previous active roster
	local changed = false
	for name in pairs(newActiveRoster) do
	    if not self.activeRoster[name] then
	        self.activeRoster[name] = true
	        changed = true
	        self:SendMessage("MultiboxRoster_ActiveRosterAddition", name)
	    end
	end
	
	-- report removals from the previous active roster
	local changed = false
	for name in pairs(self.activeRoster) do
	    if not newActiveRoster[name] then
	        self.activeRoster[name] = nil
	        changed = true
	        self:SendMessage("MultiboxRoster_ActiveRosterRemoval", name)
	    end
	end
	
	-- send a general update message
	if changed then
		self:SendMessage("MultiboxRoster_ActiveRosterUpdated", self.activeRoster)
	end
end

-----------------------------------------------------------------------
-- Trust provider API
-----------------------------------------------------------------------

MultiboxRoster.IsTrustedPlayer = MultiboxRoster.IncludesCharacter
MultiboxRoster.IsTrustedApi = MultiboxRoster.IncludesCharacter
