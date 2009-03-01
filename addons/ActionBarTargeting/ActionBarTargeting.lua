local ADDON_NAME = "ActionBarTargeting"
local ABT = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")

local tconcat = table.concat
local tremove = table.remove

-- Binding variables
BINDING_HEADER_ABT = ADDON_NAME;
_G["BINDING_NAME_CLICK FollowMain:LeftButton"] = "Follow"
_G["BINDING_NAME_CLICK TargetMainTarget:LeftButton"] = "Target main's target"

function ABT:OnInitialize()
    local options = {
        name = ADDON_NAME,
        handler = ABT,
        type = "group",
        args = {
            print = {
                type = "execute",
                name = "Print",
                desc = "Print button macros",
                func = "PrintButtonMacros"
            }
        }
	}

    local cfg = LibStub("AceConfig-3.0")
	cfg:RegisterOptionsTable(ADDON_NAME, options, "abt")
end

function ABT:OnEnable()
    self:RegisterMessage("MultiboxRoster_TeamChanged", "OnTeamChanged")
end

function ABT:OnDisable()
    self:UnregisterMessage("MultiboxRoster_TeamChanged")
end

function ABT:OnTeamChanged(msgName, team, name)
    if (team ~= nil and #team > 0) then
        self:CreateAllButtons(team, name)
    end
end

-- Concatenates input arguments to create macro text
function ABT:CreateMacro(...)
    local text = {}
    for i, v in ipairs{...} do
        local t = type(v)
        if t == "string" or t == "number" then
            text[i] = v
        elseif type(v) == "function" then
            text[i] = v()
        else
            error("Unexpected type for arg " .. i .. ": " .. type(v))
        end
    end
    
    return tconcat(text)
end

-- Returns the max actionbar page used by a given team
function ABT:MaxBar(team)
    if (#team > 6) then
        return 6
    end
    return #team
end

-- Returns the index of the first item in table t
function ABT:FirstIndexOf(item, t)
    for i,v in ipairs(t) do
        if v == item then
            return i
        end
    end
end

function ABT:PlayerIndex(team)
    local name = UnitName("player")
    return ABT:FirstIndexOf(name, team)
end

-- Returns an iterator over all of the actionbar index / toon pairs for a team
function ABT:BarPairs(team, exclude)
    local i = 0
    local n = ABT:MaxBar(team)

    return function()
        i = i + 1

        -- Skip the excluded position
        if i == exclude then
            i = i + 1
        end

        -- Return the bar index and toon
        if i <= n then
            return i, team[i]
        end
    end
end

-- Returns an actionbar condition string like so: "[bar:1] toon1"
function ABT:BarCondition(team, toonIndex)
    if toonIndex > ABT:MaxBar(team) then
        error("Toon index too large: " .. toonIndex)
    end
    
    return "[bar:" .. toonIndex .. "] " .. team[toonIndex]
end

-- Returns an actionbar condition string like so: "[bar:1] toon1; [bar:2] toon2; ..."
function ABT:JoinBarConditions(team, exclude)
    local text = {}
    for toonIndex, _ in ABT:BarPairs(team, exclude) do
        text[1 + #text] = ABT:BarCondition(team, toonIndex)
    end
    return tconcat(text, "; ")
end

-- Helper function to validate external API parameters
local function ValidateMacroParams(team, toonIndex)
    if type(team) ~= "table" or #team < 1 then
        error("Invalid team")
    end

    if type(toonIndex) ~= "number" then
        error("Invalid toon index")
    end
end

-- Creates a macro to set the offensive target on followers
function ABT:CreateOffensiveTargetMacro(team, toonIndex)
    toonIndex = toonIndex or ABT:PlayerIndex(team)
    ValidateMacroParams(team, toonIndex)
    
    return ABT:CreateMacro(
        --"/stopmacro [exists,harm,nodead]\n",
        "/assist " .. ABT:JoinBarConditions(team, toonIndex) .. "\n",
        "/startattack [harm]\n"
    )
end

-- Creates a macro to set the healing target on followers
function ABT:CreateHealingTargetMacro(team, toonIndex)
    toonIndex = toonIndex or ABT:PlayerIndex(team)
    ValidateMacroParams(team, toonIndex)
    
    local nobar = ""
    if toonIndex < ABT:MaxBar(team) then
        nobar = "nobar:" .. toonIndex .. ","
    end
    
    return ABT:CreateMacro(
        "/targetexact " .. ABT:JoinBarConditions(team, toonIndex) .. "\n",
        "/target [" .. nobar .. "help,nodead] targettarget\n"
    )
end

-- Creates a macro to target the current main
function ABT:CreateTargetMainMacro(team, toonIndex)
    toonIndex = toonIndex or ABT:PlayerIndex(team)
    ValidateMacroParams(team, toonIndex)
    
    return ABT:CreateMacro(
        "/targetexact " .. ABT:JoinBarConditions(team, toonIndex) .. "\n"
    )
end

-- Creates a macro to target the current main's target
function ABT:CreateTargetMainTargetMacro(team, toonIndex)
    toonIndex = toonIndex or ABT:PlayerIndex(team)
    ValidateMacroParams(team, toonIndex)
    
    return ABT:CreateMacro(
        "/stopmacro [bar:" .. toonIndex .. "]\n",
        "/targetexact " .. ABT:JoinBarConditions(team, toonIndex) .. "\n",
        "/target targettarget\n"
    )
end

-- Creates a macro to follow the current main
function ABT:CreateFollowMacro(team, toonIndex)
    toonIndex = toonIndex or ABT:PlayerIndex(team)
    ValidateMacroParams(team, toonIndex)
    
    return ABT:CreateMacro(
        "/stopmacro [bar:" .. toonIndex .. "]\n",
        "/targetexact " .. ABT:JoinBarConditions(team, toonIndex) .. "\n",
        "/follow\n"
    )
end

-- Creates a macro button
function ABT:CreateButton(name, macro)
    -- Create the button
    self.buttonParent = self.buttonParent or CreateFrame("Frame", nil, UIParent)
    local button = CreateFrame("Button", name, self.buttonParent, "SecureActionButtonTemplate")
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", macro)
end

-- Creates all of the buttons
function ABT:CreateAllButtons(team, name)
    local toonIndex = ABT:PlayerIndex(team)
    if toonIndex == nil then
        error("Player must be in team")
    end
    
    ABT:CreateButton("SetOffensiveTarget", ABT:CreateOffensiveTargetMacro(team, toonIndex))
    ABT:CreateButton("SetHealingTarget", ABT:CreateHealingTargetMacro(team, toonIndex))
    ABT:CreateButton("TargetMain", ABT:CreateTargetMainMacro(team, toonIndex))
    ABT:CreateButton("TargetMainTarget", ABT:CreateTargetMainTargetMacro(team, toonIndex))
    ABT:CreateButton("FollowMain", ABT:CreateFollowMacro(team, toonIndex))
    
    name = name or "unknown"
    self:Print("Buttons created for team " .. name .. " - " .. tconcat(team, ", "))
end

-- Convenience global function for use in macros
function ABT_CreateAllButtons(team)
    ABT:CreateAllButtons(team)
end

-- Prints all of the button macros
function ABT:PrintButtonMacros()
    if self.buttonParent == nil then
        ABT:Print("No buttons created")
    else
        local kids = { self.buttonParent:GetChildren() }
        for _, button in ipairs(kids) do
            self:Print(button:GetName())
            self:Print(button:GetAttribute("macrotext"))
        end
    end
end