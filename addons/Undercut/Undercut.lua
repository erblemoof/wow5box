local Undercut = LibStub("AceAddon-3.0"):NewAddon("Undercut", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

-- Returns an index to the input table
-- Example: IndexTable({ "a", "b", "c" }) -> { a=1, b=2, c=3 }
local function IndexTable(list)
    local index = {}
    for k,v in pairs(list) do
        index[v] = k
    end
    return index
end

function Undercut:OnInitialize()
end

function Undercut:OnEnable()
    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

function Undercut:Disable()
    self:UnregisterAllEvents()
end

function Undercut:AUCTION_HOUSE_SHOW(...)
    self:SecureHook(_G, "ContainerFrameItemButton_OnModifiedClick")
end

function Undercut:AUCTION_HOUSE_CLOSED(...)
    self:Unhook(_G, "ContainerFrameItemButton_OnModifiedClick")
end

function Undercut:ContainerFrameItemButton_OnModifiedClick(_, button)
    if (button ~= "LeftButton") or (not IsAltKeyDown()) then
        return
    end

    -- get info for the clicked item
    local bag, id = this:GetParent():GetID(), this:GetID()
    local itemLink = GetContainerItemLink(bag, id)
    if not itemLink then
        return
    end

    local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemLink)

    -- construct query
    self.byNameTypes = self.byNameTypes or IndexTable({ "Consumable", "Miscellaneous", "Trade Goods", "Quest" })
    if (self.byNameTypes[itemType]) then
	    BrowseName:SetText(itemName)
	    BrowseMinLevel:SetText("")
	    BrowseMaxLevel:SetText("")
    else
	    BrowseName:SetText("")
	    BrowseMinLevel:SetText(math.max(itemMinLevel - 3, 1))
	    BrowseMaxLevel:SetText(math.min(itemMinLevel + 3, 70))
	end

	IsUsableCheckButton:SetChecked(false)
	ShowOnPlayerCheckButton:SetChecked(false)

	-- major class
	local classIndex = self:GetAuctionItemClassIndex(itemType)
	if classIndex then
	    AuctionFrameBrowse.selectedClassIndex = classIndex
	    AuctionFrameBrowse.selectedClass = itemType
	
	    -- subclass
	    local subclassIndex = self:GetAuctionItemSubclassIndex(classIndex, itemSubType)
	    if subclassIndex then
	        AuctionFrameBrowse.selectedSubclassIndex = subclassIndex
	        AuctionFrameBrowse.selectedSubclass = "|cffffffff"..itemSubType.."|r" --itemSubType
	    end
	end

    AuctionFrameBrowse.selectedInvtypeIndex = self:GetAuctionItemSlotID(itemEquipLoc)

    -- limit quality to green for most item types
    self.qualityTypes = self.qualityTypes or IndexTable({ "Recipe" })
    local limitToGreen = (not self.qualityTypes[itemType])
    local qualityIndex = self:GetQualityIndex(itemRarity, limitToGreen)
    UIDropDownMenu_SetSelectedValue(BrowseDropDown, qualityIndex)

	-- update AuctionFrame
	UIDropDownMenu_Initialize(BrowseDropDown, BrowseDropDown_Initialize)
	AuctionFrameFilters_Update()
	UIDropDownMenu_Refresh(BrowseDropDown, false)

	-- search
    AuctionFrameTab1:Click()
	AuctionFrameBrowse_Search()
end

function Undercut:GetAuctionItemClassIndex(className)
    self.auctionItemClassIndex = self.auctionItemClassIndex or IndexTable({ GetAuctionItemClasses() })
    return assert(self.auctionItemClassIndex[className], "No index for "..className)
end

function Undercut:GetAuctionItemSubclassIndex(classIndex, subclassName)
    assert(type(classIndex) == "number")
    
    self.auctionItemSubclassIndex = self.auctionItemSubclassIndex or {}
    self.auctionItemSubclassIndex[classIndex] = self.auctionItemSubclassIndex[classIndex] or
        IndexTable({ GetAuctionItemSubClasses(classIndex) })
        
    local index = self.auctionItemSubclassIndex[classIndex][subclassName]
    return index
end

-- Converts a INVTYPE_* string from GetItemInfo to an inventory slot ID. Returns nil if no slot ID
-- should be used in the search.
-- See http://www.wowwiki.com/ItemEquipLoc
function Undercut:GetAuctionItemSlotID(itemEquipLoc)
    self.slotIndex = self.slotIndex or {
        INVTYPE_AMMO=0,
        INVTYPE_HEAD=1,
        INVTYPE_NECK=2,
        INVTYPE_SHOULDER=3,
        INVTYPE_BODY=4,
        INVTYPE_CHEST=5,
        INVTYPE_ROBE=5,
        INVTYPE_WAIST=6,
        INVTYPE_LEGS=7,
        INVTYPE_FEET=8,
        INVTYPE_WRIST=9,
        INVTYPE_HAND=10,
        INVTYPE_FINGER=11,
        INVTYPE_TRINKET=12,
        INVTYPE_CLOAK=13,
        INVTYPE_HOLDABLE=14,
        INVTYPE_WEAPON=16,
        INVTYPE_SHIELD=17,
        INVTYPE_2HWEAPON=16,
        INVTYPE_WEAPONMAINHAND=16,
        INVTYPE_WEAPONOFFHAND=17,
        INVTYPE_RANGED=18,
        INVTYPE_THROWN=18,
        INVTYPE_RANGEDRIGHT=18,
        INVTYPE_RELIC=18,
        INVTYPE_TABARD=19,
    }
    
    local index = self.slotIndex[itemEquipLoc]
    return index
end

-- Converts a rarity value from GetItemInfo to an AH Browse quality index
-- See http://www.wowwiki.com/API_TYPE_Quality
function Undercut:GetQualityIndex(quality, limitToGreen)
    local index = 1                     -- All
    if limitToGreen then
        index = math.min(quality, 2)    -- Green
    elseif (quality >= 2) then
        index = math.min(quality, 4)    -- Purple
    end
    return index
end
