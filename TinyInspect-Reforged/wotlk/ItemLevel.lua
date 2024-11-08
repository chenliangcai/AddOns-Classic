local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibItemGem = LibStub:GetLibrary("LibItemGem.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")
local LibItemInfo = LibStub:GetLibrary("LibItemInfo.7000")

local GetContainerItemLink = C_Container.GetContainerItemLink

local ARMOR = ARMOR or "Armor"
local WEAPON = WEAPON or "Weapon"
local MOUNTS = MOUNTS or "Mount"
local RELICSLOT = RELICSLOT or "Relic"
local ARTIFACT_POWER = ARTIFACT_POWER or "Artifact"
if (GetLocale():sub(1,2) == "zh") then ARTIFACT_POWER = "能量" end

local GetLootInfoByIndex = EJ_GetLootInfoByIndex
if (C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex) then
    GetLootInfoByIndex = C_EncounterJournal.GetLootInfoByIndex
end

local function GetItemLevelFrame(self, category)
    if (not self.ItemLevelFrame) then
        local fontAdjust = GetLocale():sub(1,2) == "zh" and 0 or -3
        local anchor, w, h = self.IconBorder or self, self:GetSize()
        local ww, hh = anchor:GetSize()
        if (ww == 0 or hh == 0) then
            anchor = self.Icon or self.icon or self
            w, h = anchor:GetSize()
        else
            w, h = min(w, ww), min(h, hh)
        end
        self.ItemLevelFrame = CreateFrame("Frame", nil, self)
        self.ItemLevelFrame:SetScale(max(0.75, h<32 and h/32 or 1))
        self.ItemLevelFrame:SetFrameLevel(8)
        self.ItemLevelFrame:SetSize(w, h)
        self.ItemLevelFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        self.ItemLevelFrame.slotString = self.ItemLevelFrame:CreateFontString(nil, "OVERLAY")
        self.ItemLevelFrame.slotString:SetFont(STANDARD_TEXT_FONT, 10+fontAdjust, "OUTLINE")
        self.ItemLevelFrame.slotString:SetPoint("BOTTOMRIGHT", 1, 2)
        self.ItemLevelFrame.slotString:SetTextColor(1, 1, 1)
        self.ItemLevelFrame.slotString:SetJustifyH("RIGHT")
        self.ItemLevelFrame.slotString:SetWidth(30)
        self.ItemLevelFrame.slotString:SetHeight(0)
        self.ItemLevelFrame.levelString = self.ItemLevelFrame:CreateFontString(nil, "OVERLAY")
        self.ItemLevelFrame.levelString:SetFont(STANDARD_TEXT_FONT, 14+fontAdjust, "OUTLINE")
        self.ItemLevelFrame.levelString:SetPoint("TOP")
        self.ItemLevelFrame.levelString:SetTextColor(1, 0.82, 0)
        LibEvent:trigger("ITEMLEVEL_FRAME_CREATED", self.ItemLevelFrame, self)
    end
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.EnableItemLevel) then
        self.ItemLevelFrame:Show()
        LibEvent:trigger("ITEMLEVEL_FRAME_SHOWN", self.ItemLevelFrame, self, category or "")
    else
        self.ItemLevelFrame:Hide()
    end
    if (category) then
        self.ItemLevelCategory = category
    end
    return self.ItemLevelFrame
end

local function SetItemLevelString(self, text, quality, link)
    if (quality and TinyInspectReforgedDB and TinyInspectReforgedDB.ShowColoredItemLevelString) then
        local r, g, b, hex = GetItemQualityColor(quality)
        text = format("|c%s%s|r", hex, text)
    end
--    if (TinyInspectReforgedDB and TinyInspectReforgedDB.ShowCorruptedMark and link and IsCorruptedItem(link)) then
--        text = text .. "|cffFF3300★|r"
--    end
    self:SetText(text)
end

local function SetItemSlotString(self, class, equipSlot, link)
    local slotText = ""
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.ShowItemSlotString) then
        if (equipSlot and string.find(equipSlot, "INVTYPE_")) then
            slotText = _G[equipSlot] or ""
        elseif (class == ARMOR) then
            slotText = class
--        elseif (link and IsArtifactPowerItem(link)) then
--            slotText = ARTIFACT_POWER
--        elseif (link and IsArtifactRelicItem(link)) then
--            slotText = RELICSLOT
        end
    end
    self:SetText(slotText)
end

local function SetItemLevelScheduled(button, ItemLevelFrame, link)
    if (not string.match(link, "item:(%d+):")) then return end
    LibSchedule:AddTask({
        identity  = link,
        elasped   = 1,
        expired   = GetTime() + 3,
        frame     = ItemLevelFrame,
        button    = button,
        onExecute = function(self)
            local count, level, _, _, quality, _, _, class, _, _, equipSlot = LibItemInfo:GetItemInfo(self.identity)
            if (count == 0) then
                SetItemLevelString(self.frame.levelString, level > 0 and level or "", quality)
                SetItemSlotString(self.frame.slotString, class, equipSlot, link)
                self.button.OrigItemLevel = (level and level > 0) and level or ""
                self.button.OrigItemQuality = quality
                self.button.OrigItemClass = class
                self.button.OrigItemEquipSlot = equipSlot
                return true
            end
        end,
    })
end

local function SetItemLevel(self, link, category, BagID, SlotID)
    if (not self) then return end
    local frame = GetItemLevelFrame(self, category)
    if (self.OrigItemLink == link) then
        SetItemLevelString(frame.levelString, self.OrigItemLevel, self.OrigItemQuality, link)
        SetItemSlotString(frame.slotString, self.OrigItemClass, self.OrigItemEquipSlot, self.OrigItemLink)
    else
        local level = ""
        local _, count, quality, class, subclass, equipSlot, linklevel
        if (link and string.match(link, "item:(%d+):")) then
            if (BagID and SlotID and (category == "Bag" or category == "AltEquipment")) then
                count, level = LibItemInfo:GetContainerItemLevel(BagID, SlotID)
                _, _, quality, linklevel, _, class, subclass, _, equipSlot = GetItemInfo(link)
                if (count == 0 and level == 0) then
                    level = linklevel
                end
            else
                count, level, _, _, quality, _, _, class, subclass, _, equipSlot = LibItemInfo:GetItemInfo(link)
            end
            if (equipSlot == "INVTYPE_BAG") then
                level = ""
            end
            if ((equipSlot and string.find(equipSlot, "INVTYPE_"))
                or (subclass and string.find(subclass, RELICSLOT))) then else
                level = ""
            end
            if (subclass and subclass == MOUNTS) then
                class = subclass
            end
            if (count > 0) then
                SetItemLevelString(frame.levelString, "...")
                return SetItemLevelScheduled(self, frame, link)
            else
                if (tonumber(level) == 0) then level = "" end
                SetItemLevelString(frame.levelString, level, quality, link)
                SetItemSlotString(frame.slotString, class, equipSlot, link)
            end
        else
            SetItemLevelString(frame.levelString, "")
            SetItemSlotString(frame.slotString)
        end
        self.OrigItemLink = link
        self.OrigItemLevel = level
        self.OrigItemQuality = quality
        self.OrigItemClass = class
        self.OrigItemEquipSlot = equipSlot
    end
end

hooksecurefunc("SetItemButtonQuality", function(self, quality, itemIDOrLink, suppressOverlays)
    if (self.ItemLevelCategory or self.isBag) then return end
    local frame = GetItemLevelFrame(self)
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableItemLevelOther) then
        return frame:Hide()
    end
    if (not itemIDOrLink) then
        local link
        --Artifact
--        if (IsArtifactRelicItem(itemIDOrLink) or IsArtifactPowerItem(itemIDOrLink)) then
--            SetItemLevel(self)
        --QuestInfo
-- else
        if (self.type and self.objectType == "item") then
            if (QuestInfoFrame and QuestInfoFrame.questLog) then
                link = LibItemInfo:GetQuestItemlink(self.type, self:GetID())
            else
                link = GetQuestItemLink(self.type, self:GetID())
            end
            -- if (not link) then
            --    link = select(2, GetItemInfo(itemIDOrLink))
            -- end
            if link then -- 暫時修正
				SetItemLevel(self, link)
			end
        --EncounterJournal
        elseif (self.encounterID and self.link) then
            local itemInfo = GetLootInfoByIndex(self.index)
            SetItemLevel(self, itemInfo.link or self.link)
        --EmbeddedItemTooltip
        elseif (self.Tooltip) then
            link = select(2, self.Tooltip:GetItem())
            SetItemLevel(self, link)
        else
            SetItemLevelString(frame.levelString, "")
            SetItemSlotString(frame.slotString)
        end
    else
        SetItemLevelString(frame.levelString, "")
        SetItemSlotString(frame.slotString)
    end
end)

-- Bag
hooksecurefunc("ContainerFrame_Update", function(self)
    local id = self:GetID()
    local name = self:GetName()
    local button
    for i = 1, self.size do
        button = _G[name.."Item"..i]
        SetItemLevel(button, GetContainerItemLink(id, button:GetID()), "Bag", id, button:GetID())
    end
end)

-- Bank
hooksecurefunc("BankFrameItemButton_Update", function(self)
    if (self.isBag) then return end
    SetItemLevel(self, GetContainerItemLink(self:GetParent():GetID(), self:GetID()), "Bank")
end)

-- Merchant
hooksecurefunc("MerchantFrameItem_UpdateQuality", function(self, link)
    SetItemLevel(self.ItemButton, link, "Merchant")
end)

-- Trade
hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
    SetItemLevel(_G["TradePlayerItem"..id.."ItemButton"], GetTradePlayerItemLink(id), "Trade")
end)
hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
    SetItemLevel(_G["TradeRecipientItem"..id.."ItemButton"], GetTradeTargetItemLink(id), "Trade")
end)

-- Loot
hooksecurefunc("LootFrame_UpdateButton", function(index)
    local button = _G["LootButton"..index]
    local numLootItems = LootFrame.numLootItems
    local numLootToShow = LOOTFRAME_NUMBUTTONS
    if (numLootItems > LOOTFRAME_NUMBUTTONS) then
		numLootToShow = numLootToShow - 1
	end
    local slot = (numLootToShow * (LootFrame.page - 1)) + index
    if (button:IsShown()) then
        SetItemLevel(button, GetLootSlotLink(slot), "Loot")
    end
end)

-- GuildBank
local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_GuildBankUI") then
        hooksecurefunc(GuildBankFrame, "Update", function(self)
            if (self.mode == "bank") then
                local tab = GetCurrentGuildBankTab()
                local button, index, column
                for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
                    index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
                    if (index == 0) then
                        index = NUM_SLOTS_PER_GUILDBANK_GROUP
                    end
                    column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
                    button = self.Columns[column].Buttons[index]
                    SetItemLevel(button, GetGuildBankItemLink(tab, i), "GuildBank")
                end
            end
        end)
    end
end)

-- ALT
if (EquipmentFlyout_DisplayButton) then
    hooksecurefunc("EquipmentFlyout_DisplayButton", function(button, paperDollItemSlot)
        local location = button.location
        if (not location) then return end
        local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
        if (not player and not bank and not bags and not voidStorage) then return end
        if (voidStorage) then
            SetItemLevel(button, nil, "AltEquipment")
        elseif (bags) then
            local link = GetContainerItemLink(bag, slot)
            SetItemLevel(button, link, "AltEquipment", bag, slot)
        else
            local link = GetInventoryItemLink("player", slot)
            SetItemLevel(button, link, "AltEquipment")
        end
    end)
end

-- ForAddons: Bagnon Combuctor LiteBag ArkInventory
LibEvent:attachEvent("PLAYER_LOGIN", function()
    -- For Bagnon
    if (Bagnon and Bagnon.Item and Bagnon.Item.Update) then
        hooksecurefunc(Bagnon.Item, "Update", function(self)
            SetItemLevel(self, self:GetItem(), "Bag", self:GetBag(), self:GetID())
        end)
    elseif (Bagnon and Bagnon.ItemSlot and Bagnon.ItemSlot.Update) then
        hooksecurefunc(Bagnon.ItemSlot, "Update", function(self)
            SetItemLevel(self, self:GetItem(), "Bag", self:GetBag(), self:GetID())
        end)
    end
    -- For Combuctor
    if (Combuctor and Combuctor.ItemSlot and Combuctor.ItemSlot.Update) then
        hooksecurefunc(Combuctor.ItemSlot, "Update", function(self)
            SetItemLevel(self, self:GetItem(), "Bag", self:GetBag(), self:GetID())
        end)
    elseif (Combuctor and Combuctor.Item and Combuctor.Item.Update) then
        hooksecurefunc(Combuctor.Item, "Update", function(self)
            SetItemLevel(self, self.GetItem and self:GetItem() or self.hasItem, "Bag", self.GetBag and self:GetBag() or self.bag, self.GetID and self:GetID())
        end)
    end
    -- For LiteBag
    if (LiteBag_RegisterHook) then
        LiteBag_RegisterHook("LiteBagItemButton_Update", function(self)
            SetItemLevel(self, GetContainerItemLink(self:GetParent():GetID(), self:GetID()), "Bag", self:GetParent():GetID(), self:GetID())
        end)
    elseif (LiteBagItemButton_UpdateItem) then
        hooksecurefunc("LiteBagItemButton_UpdateItem", function(self)
            SetItemLevel(self, GetContainerItemLink(self:GetParent():GetID(), self:GetID()), "Bag", self:GetParent():GetID(), self:GetID())
        end)
    end
    -- For ArkInventory
    if (ArkInventory and ArkInventory.Frame_Item_Update_Texture) then
        hooksecurefunc(ArkInventory, "Frame_Item_Update_Texture", function(button)
            local i = ArkInventory.Frame_Item_GetDB(button)
            if (i) then
                SetItemLevel(button, i.h, "Bag")
            end
        end)
    end
end)

-- For Addon: BaudBag
if (BaudBag and BaudBag.CreateItemButton) then
    local BaudBagCreateItemButton = BaudBag.CreateItemButton
    BaudBag.CreateItemButton = function(self, subContainer, slotIndex, buttonTemplate)
        local ItemButton = BaudBagCreateItemButton(self, subContainer, slotIndex, buttonTemplate)
        local Prototype = getmetatable(ItemButton).__index
        local UpdateContent = Prototype.UpdateContent
        Prototype.UpdateContent = function(self, useCache, slotCache)
            local link, cacheEntry = UpdateContent(self, useCache, slotCache)
            SetItemLevel(self.Frame, link)
            return link, cacheEntry
        end
        setmetatable(ItemButton, {__index=Prototype})
        return ItemButton
    end
end

-- GuildNews
LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_Communities" and GuildNewsButton_SetText) then
        GuildNewsItemCache = {}
        hooksecurefunc("GuildNewsButton_SetText", function(button, text_color, text, text1, text2, ...)
            if (not TinyInspectReforgedDB or 
                not TinyInspectReforgedDB.EnableItemLevel or 
                not TinyInspectReforgedDB.EnableItemLevelGuildNews) then
              return
            end
            if (text2 and type(text2) == "string") then
                local link = string.match(text2, "|H(item:%d+:.-)|h.-|h")
                if (link) then
                    local level = GuildNewsItemCache[link] or select(2, LibItemInfo:GetItemInfo(link))
                    if (level > 0) then
                        GuildNewsItemCache[link] = level
                        text2 = text2:gsub("(%|Hitem:%d+:.-%|h%[)(.-)(%]%|h)", "%1"..level..":%2%3")
                        button.text:SetFormattedText(text, text1, text2, ...)
                    end
                end
            end
        end)
    end
end)

-------------------
--   PaperDoll  --
-------------------

local function SetPaperDollItemLevel(self, unit)
    if (not self) then return end
    local id = self:GetID()
    local frame = GetItemLevelFrame(self, "PaperDoll")
    if (unit and GetInventoryItemTexture(unit, id)) then
        local link = GetInventoryItemLink(unit, id)
        local name, link, quality, level, minLevel, class, SubType, StackCount, equipSlot, itemTexture = GetItemInfo(link)
        SetItemLevelString(frame.levelString, level > 0 and level or "", quality, link)
        SetItemSlotString(frame.slotString, class, equipSlot, link)
        if (id == 16 or id == 17) then
            local _, mlevel, _, _, mquality = LibItemInfo:GetUnitItemInfo(unit, 16)
            local _, olevel, _, _, oquality = LibItemInfo:GetUnitItemInfo(unit, 17)
            if (mlevel > 0 and olevel > 0 and (mquality == 6 or oquality == 6)) then
                SetItemLevelString(frame.levelString, max(mlevel,olevel), mquality or oquality, link)
            end
        end
    else
        SetItemLevelString(frame.levelString, "")
        SetItemSlotString(frame.slotString)
    end
  --  if (unit == "player") then
  --      SetItemSlotString(frame.slotString)
  --  end
end

hooksecurefunc("PaperDollItemSlotButton_OnShow", function(self, isBag)
    SetPaperDollItemLevel(self, "player")
end)

hooksecurefunc("PaperDollItemSlotButton_OnEvent", function(self, event, id, ...)
    if (event == "PLAYER_EQUIPMENT_CHANGED" and self:GetID() == id) then
        SetPaperDollItemLevel(self, "player")
    end
end)

LibEvent:attachTrigger("UNIT_INSPECT_READY", function(self, data)
    if (InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == data.guid) then
        for _, button in ipairs({
             InspectHeadSlot,InspectNeckSlot,InspectShoulderSlot,InspectBackSlot,InspectChestSlot,InspectWristSlot,
             InspectHandsSlot,InspectWaistSlot,InspectLegsSlot,InspectFeetSlot,InspectFinger0Slot,InspectFinger1Slot,
             InspectTrinket0Slot,InspectTrinket1Slot,InspectMainHandSlot,InspectSecondaryHandSlot
             , InspectShirtSlot, InspectTabardSlot, InspectRangedSlot
            }) do
            SetPaperDollItemLevel(button, InspectFrame.unit)
        end
    end
end)

LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_InspectUI") then
        hooksecurefunc(InspectFrame, "Hide", function()
            for _, button in ipairs({
                 InspectHeadSlot,InspectNeckSlot,InspectShoulderSlot,InspectBackSlot,InspectChestSlot,InspectWristSlot,
                 InspectHandsSlot,InspectWaistSlot,InspectLegsSlot,InspectFeetSlot,InspectFinger0Slot,InspectFinger1Slot,
                 InspectTrinket0Slot,InspectTrinket1Slot,InspectMainHandSlot,InspectSecondaryHandSlot
                 , InspectShirtSlot, InspectTabardSlot, InspectRangedSlot
                }) do
                SetPaperDollItemLevel(button)
            end
        end)
    end
end)

----------------------
--  Chat ItemLevel  --
----------------------

local Caches = {}

local function ChatItemLevel(Hyperlink)
    if (Caches[Hyperlink]) then
        return Caches[Hyperlink]
    end
    local link = string.match(Hyperlink, "|H(.-)|h")
    local count, level, name, _, quality, _, _, class, subclass, _, equipSlot = LibItemInfo:GetItemInfo(link)
    if (tonumber(level) and level > 0) then
        if (equipSlot == "INVTYPE_CLOAK" or equipSlot == "INVTYPE_TRINKET" or equipSlot == "INVTYPE_FINGER" or equipSlot == "INVTYPE_NECK") then
            level = format("%s(%s)", level, _G[equipSlot] or equipSlot)
        elseif (equipSlot and string.find(equipSlot, "INVTYPE_")) then
            level = format("%s(%s-%s)", level, subclass or "", _G[equipSlot] or equipSlot)
        elseif (class == ARMOR) then
            level = format("%s(%s-%s)", level, subclass or "", class)
        elseif (subclass and string.find(subclass, RELICSLOT)) then
            level = format("%s(%s)", level, RELICSLOT)
        else
            level = nil
        end
        if (level) then
            local n, stats = 0, GetItemStats(link)
            for key, num in pairs(stats) do
                if (string.find(key, "EMPTY_SOCKET_")) then
                    n = n + num
                end
            end
            local gem = string.rep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic:0|t", n)
            if (quality == 6 and class == WEAPON) then gem = "" end
            Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h["..level..":"..name.."]|h"..gem)
        end
        Caches[Hyperlink] = Hyperlink
    elseif (subclass and subclass == MOUNTS) then
        Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h[("..subclass..")%1]|h")
        Caches[Hyperlink] = Hyperlink
    elseif (count == 0) then
        Caches[Hyperlink] = Hyperlink
    end
    return Hyperlink
end

local function filter(self, event, msg, ...)
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.EnableItemLevelChat) then
        msg = msg:gsub("(|Hitem:%d+:.-|h.-|h)", ChatItemLevel)
    end
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)

function firstLootKeystone(Hyperlink)
    local map, level = string.match(Hyperlink, "|Hitem:180653::::::::%d*:%d*:%d*:%d*:%d*:(%d+):(%d+):")
    if (map and level) then
        local name = C_ChallengeMode.GetMapUIInfo(map)
        if name then
            Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h["..format(CHALLENGE_MODE_KEYSTONE_HYPERLINK, name, level).."]|h")
        end
    end
    return Hyperlink
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, msg, ...)
    if (string.find(msg, "item:180653:")) then
        msg = msg:gsub("(|Hitem:180653:.-|h.-|h)", firstLootKeystone)
    end
    return false, msg, ...
end)

LibEvent:attachTrigger("ITEMLEVEL_FRAME_SHOWN", function(self, frame, parent, category)
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB["EnableItemLevel"..category]) then
        return frame:Hide()
    end
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.PaperDollItemLevelOutsideString) then
        return
    end
    local anchorPoint = TinyInspectReforgedDB and TinyInspectReforgedDB.ItemLevelAnchorPoint
    if (frame.anchorPoint ~= anchorPoint) then
        frame.anchorPoint = anchorPoint
        frame.levelString:ClearAllPoints()
        frame.levelString:SetPoint(anchorPoint or "TOP")
    end
end)

-- OutsideString For PaperDoll ItemLevel
LibEvent:attachTrigger("ITEMLEVEL_FRAME_CREATED", function(self, frame, parent)
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.PaperDollItemLevelOutsideString) then
        local name = parent:GetName()
        if (name and string.match(name, "^[IC].+Slot$")) then
            local id = parent:GetID()
            frame:ClearAllPoints()
            frame.levelString:ClearAllPoints()
            if (id <= 5 or id == 9 or id == 15 or id == 19) then
                frame:SetPoint("LEFT", parent, "RIGHT", 7, -1)
                frame.levelString:SetPoint("TOPLEFT")
                frame.levelString:SetJustifyH("LEFT")
            elseif (id == 17) then
                frame:SetPoint("LEFT", parent, "RIGHT", 5, 1)
                frame.levelString:SetPoint("TOPLEFT")
                frame.levelString:SetJustifyH("LEFT")
            elseif (id == 16) then
                frame:SetPoint("RIGHT", parent, "LEFT", -5, 1)
                frame.levelString:SetPoint("TOPRIGHT")
                frame.levelString:SetJustifyH("RIGHT")
            else
                frame:SetPoint("RIGHT", parent, "LEFT", -7, -1)
                frame.levelString:SetPoint("TOPRIGHT")
                frame.levelString:SetJustifyH("RIGHT")
            end
        end
    end
end)
