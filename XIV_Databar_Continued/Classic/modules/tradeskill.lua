local AddOnName, XIVBar = ...;
local _G = _G;
local xb = XIVBar;
local L = XIVBar.L;

local TradeskillModule = xb:NewModule("TradeskillModule", 'AceEvent-3.0')
local LibAddonCompat = LibStub("LibAddonCompat-1.0")

function TradeskillModule:GetName()
    return TRADESKILLS;
end

function TradeskillModule:OnInitialize()
    self.profIcons = {
        [164] = 'blacksmithing',
        [165] = 'leatherworking',
        [171] = 'alchemy',
        [182] = 'herbalism',
        [186] = 'mining',
        [202] = 'engineering',
        [333] = 'enchanting',
        [755] = 'jewelcrafting',
        [773] = 'inscription',
        [197] = 'tailoring',
        [393] = 'skinning'
    }
end

function TradeskillModule:OnEnable()
    if self.tradeskillFrame == nil then
        self.tradeskillFrame = CreateFrame("FRAME", nil, xb:GetFrame('bar'))
        xb:RegisterFrame('tradeskillFrame', self.tradeskillFrame)
    end

    self.tradeskillFrame:Show()

    self.firstProf = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }
    self.secondProf = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }
    self.arch = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }
    self.first_aid = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }
    self.fish = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }
    self.cook = {
        idx = nil,
        id = nil,
        name = nil,
        defIcon = nil,
        lvl = nil,
        maxLvl = nil,
        offset = nil
    }

    self:CreateFrames()
    self:RegisterFrameEvents()
    self:Refresh()
end

function TradeskillModule:OnDisable()
    self.tradeskillFrame:Hide()
    self:UnregisterEvent('TRADE_SKILL_DETAILS_UPDATE')
    self:UnregisterEvent('SPELLS_CHANGED')
    self:UnregisterEvent('UNIT_SPELLCAST_STOP')
end

function TradeskillModule:UpdateProfValues()
    -- update profession indexes before anything else or receive a million bugs when (un)learning professions
    if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
        self.firstProf.idx, self.secondProf.idx, self.arch.idx, self.fish.idx, self.cook.idx, self.first_aid.idx = GetProfessions() -- this is the most important line in the entire fucking module
    else
        self.firstProf.idx, self.secondProf.idx, self.arch.idx, self.fish.idx, self.cook.idx, self.first_aid.idx = LibAddonCompat:GetProfessions()
    end
    -- if firstProf.idx doesn't exist, the player hasn't learned any profession and thus the tradeskillFrame is hidden
    if not self.firstProf.idx then
        self.tradeskillFrame:Hide()
    else
        -- player has at least one profession, setting first one. show tradeskillFrame because it might've been hidden before
        self.tradeskillFrame:Show()
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.firstProf.idx)
            self.firstProf.name, self.firstProf.defIcon, self.firstProf.lvl, self.firstProf.maxLvl, self.firstProf.offset, self.firstProf.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.firstProf.idx)
            self.firstProf.name, self.firstProf.defIcon, self.firstProf.lvl, self.firstProf.maxLvl, self.firstProf.offset, self.firstProf.id = name, defIcon, lvl, maxLvl, offset, id
        end
        self.firstProfBar:SetMinMaxValues(1, self.firstProf.maxLvl)
        self.firstProfBar:SetValue(self.firstProf.lvl)
    end

    -- if secondProf.idx doesn't exist, hide the secondProfFrame 
    if not self.secondProf.idx then
        self.secondProfFrame:Hide()
    else
        -- player has two profession, setting second one. show secondProfFrame because it might've been hidden before
        self.secondProfFrame:Show()
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.secondProf.idx)
            self.secondProf.name, self.secondProf.defIcon, self.secondProf.lvl, self.secondProf.maxLvl, self.secondProf.offset, self.secondProf.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.secondProf.idx)
            self.secondProf.name, self.secondProf.defIcon, self.secondProf.lvl, self.secondProf.maxLvl, self.secondProf.offset, self.secondProf.id = name, defIcon, lvl, maxLvl, offset, id
        end
        self.secondProfBar:SetMinMaxValues(1, self.secondProf.maxLvl)
        self.secondProfBar:SetValue(self.secondProf.lvl)
    end

    -- update values for secondary professions if they exist (first aid / archaeology / fishing / cooking)
    -- update first aid
    if self.first_aid.idx then
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.first_aid.idx)
            self.first_aid.name, self.first_aid.defIcon, self.first_aid.lvl, self.first_aid.maxLvl, self.first_aid.offset, self.first_aid.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.first_aid.idx)
            self.first_aid.name, self.first_aid.defIcon, self.first_aid.lvl, self.first_aid.maxLvl, self.first_aid.offset, self.first_aid.id = name, defIcon, lvl, maxLvl, offset, id
        end
    end
    -- update archaeology
    if self.arch.idx then
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.arch.idx)
            self.arch.name, self.arch.defIcon, self.arch.lvl, self.arch.maxLvl, self.arch.offset, self.arch.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.arch.idx)
            self.arch.name, self.arch.defIcon, self.arch.lvl, self.arch.maxLvl, self.arch.offset, self.arch.id = name, defIcon, lvl, maxLvl, offset, id
        end
    end
    -- update fishing
    if self.fish.idx then
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.fish.idx)
            self.fish.name, self.fish.defIcon, self.fish.lvl, self.fish.maxLvl, self.fish.offset, self.fish.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.fish.idx)
            self.fish.name, self.fish.defIcon, self.fish.lvl, self.fish.maxLvl, self.fish.offset, self.fish.id = name, defIcon, lvl, maxLvl, offset, id
        end
    end
    -- update cooking
    if self.cook.idx then
        if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = GetProfessionInfo(self.cook.idx)
            self.cook.name, self.cook.defIcon, self.cook.lvl, self.cook.maxLvl, self.cook.offset, self.cook.id = name, defIcon, lvl, maxLvl, offset, id
        else
            local name, defIcon, lvl, maxLvl, _, offset, id, _ = LibAddonCompat:GetProfessionInfo(self.cook.idx)
            self.cook.name, self.cook.defIcon, self.cook.lvl, self.cook.maxLvl, self.cook.offset, self.cook.id = name, defIcon, lvl, maxLvl, offset, id
        end
    end
end

function TradeskillModule:Refresh()
    -- don't refresh anything while in combat because why the fuck would you?
    if InCombatLockdown() then
        return
    end
    -- do this before updating prof values or get rekt by bugs because refresh triggers a thousand times before anything is even loaded
    if self.tradeskillFrame == nil then
        return
    end
    -- similar reasons for the line above apply here
    local db = xb.db.profile
    if not db.modules.tradeskill.enabled then
        self:Disable()
        return
    end

    -- update before doing anything here mister addon creator. if we have no professions, why the fuck would we refresh anything?
    self:UpdateProfValues()
    -- get the hell out of this function if we have no professions
    if not self.firstProf.name then
        return
    end

    -- prepare tradeskillFrame bar width and profession icon size
    local iconSize = db.text.fontSize + db.general.barPadding
    local totalWidth = 0

    -- setting width and position for profession 1 frame
    self:StyleTradeskillFrame('firstProf')
    totalWidth = totalWidth + self.firstProfFrame:GetWidth()
    self.firstProfFrame:SetPoint('LEFT')

    -- setting width and position for profession 2 frame if it exists, otherwise its frame is hidden anyway
    if self.secondProf.idx then
        self:StyleTradeskillFrame('secondProf')
        totalWidth = totalWidth + self.secondProfFrame:GetWidth()
        self.secondProfFrame:SetPoint('LEFT', self.firstProfFrame, 'RIGHT', 5, 0)
    end

    -- final touches on our precious tradeskillFrame
    self.tradeskillFrame:SetSize(totalWidth, xb:GetHeight())
    local relativeAnchorPoint = 'RIGHT'
    local xOffset = db.general.moduleSpacing
    if not xb:GetFrame('clockFrame') or not xb:GetFrame('clockFrame'):IsVisible() then
        relativeAnchorPoint = 'LEFT'
        xOffset = 0
    end
    self.tradeskillFrame:SetPoint('LEFT', xb:GetFrame('clockFrame'), relativeAnchorPoint, xOffset, 0)
end

function TradeskillModule:StyleTradeskillFrame(prefix)
    local db = xb.db.profile
    local iconSize = db.text.fontSize + db.general.barPadding
    local icon = xb.constants.mediaPath .. 'profession\\' .. self.profIcons[self[prefix].id]

    local textHeight = floor((xb:GetHeight() - 4) / 2)
    if self[prefix].lvl == self[prefix].maxLvl then
        textHeight = db.text.fontSize
    end

    local barHeight = (iconSize - textHeight - 2)
    if barHeight < 3 then
        barHeight = 3
    end

    self[prefix .. 'Icon']:SetTexture(icon)
    self[prefix .. 'Icon']:SetSize(iconSize, iconSize)
    self[prefix .. 'Icon']:SetPoint('LEFT')
    self[prefix .. 'Icon']:SetVertexColor(xb:GetColor('normal'))

    self[prefix .. 'Text']:SetFont(xb:GetFont(textHeight))
    self[prefix .. 'Text']:SetTextColor(xb:GetColor('normal'))
    self[prefix .. 'Text']:SetText(string.upper(self[prefix].name))

    if self[prefix].lvl == self[prefix].maxLvl then
        self[prefix .. 'Text']:SetPoint('LEFT', self[prefix .. 'Icon'], 'RIGHT', 5, 0)
    else
        self[prefix .. 'Text']:SetPoint('TOPLEFT', self[prefix .. 'Icon'], 'TOPRIGHT', 5, 0)
        self[prefix .. 'Bar']:SetStatusBarTexture("Interface/BUTTONS/WHITE8X8")
        if db.modules.tradeskill.barCC then
            rPerc, gPerc, bPerc, argbHex = xb:GetClassColors()
            self[prefix .. 'Bar']:SetStatusBarColor(rPerc, gPerc, bPerc, 1)
        else
            self[prefix .. 'Bar']:SetStatusBarColor(xb:GetColor('normal'))
        end
        self[prefix .. 'Bar']:SetSize(self[prefix .. 'Text']:GetStringWidth(), barHeight)
        self[prefix .. 'Bar']:SetPoint('BOTTOMLEFT', self[prefix .. 'Icon'], 'BOTTOMRIGHT', 5, 0)

        self[prefix .. 'BarBg']:SetAllPoints()
        self[prefix .. 'BarBg']:SetColorTexture(db.color.inactive.r, db.color.inactive.g, db.color.inactive.b,
            db.color.inactive.a)
    end

    self[prefix .. 'Frame']:SetSize(iconSize + self[prefix .. 'Text']:GetStringWidth() + 5, xb:GetHeight())
end

function TradeskillModule:CreateFrames()
    self.firstProfFrame = self.firstProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame)
    self.firstProfIcon = self.firstProfIcon or self.firstProfFrame:CreateTexture(nil, 'OVERLAY')
    self.firstProfText = self.firstProfText or self.firstProfFrame:CreateFontString(nil, 'OVERLAY')
    self.firstProfBar = self.firstProfBar or CreateFrame('STATUSBAR', nil, self.firstProfFrame)
    self.firstProfBarBg = self.firstProfBarBg or self.firstProfBar:CreateTexture(nil, 'BACKGROUND')

    self.secondProfFrame = self.secondProfFrame or CreateFrame("BUTTON", nil, self.tradeskillFrame)
    self.secondProfIcon = self.secondProfIcon or self.secondProfFrame:CreateTexture(nil, 'OVERLAY')
    self.secondProfText = self.secondProfText or self.secondProfFrame:CreateFontString(nil, 'OVERLAY')
    self.secondProfBar = self.secondProfBar or CreateFrame('STATUSBAR', nil, self.secondProfFrame)
    self.secondProfBarBg = self.secondProfBarBg or self.secondProfBar:CreateTexture(nil, 'BACKGROUND')
end

function TradeskillModule:SetProfScripts(prefix)
    self[prefix .. 'Frame']:SetScript('OnMouseDown', function(_, button)
        if button == 'LeftButton' then
            -- workaround, toggling spellbooks for tailoring / engineering / inscription is bugged on blizzard's side
            -- i prefer this over the alternative of casting a spell via SecureActionButtonTemplate frames anyway
            if self[prefix].offset ~= nil then
                CastSpell(self[prefix].offset + 1, "Spell")
            end
        elseif button == 'RightButton' then 
            if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
                ToggleSpellBook(BOOKTYPE_PROFESSION) 
            end
        end
    end)

    self[prefix .. 'Frame']:SetScript('OnEnter', function()
        if InCombatLockdown() then
            return
        end
        self[prefix .. 'Text']:SetTextColor(unpack(xb:HoverColors()))
        if xb.db.profile.modules.tradeskill.showTooltip then
            self:ShowTooltip()
        end
    end)

    self[prefix .. 'Frame']:SetScript('OnLeave', function()
        if InCombatLockdown() then
            return;
        end
        local db = xb.db.profile
        self[prefix .. 'Text']:SetTextColor(xb:GetColor('normal'))
        if xb.db.profile.modules.tradeskill.showTooltip then
            GameTooltip:Hide()
        end
    end)
end

function TradeskillModule:RegisterFrameEvents()
    self.tradeskillFrame:SetScript('OnEvent', function()
        self:Refresh()
    end)
    self.tradeskillFrame:RegisterEvent('TRADE_SKILL_DETAILS_UPDATE')
    self.tradeskillFrame:RegisterEvent('SPELLS_CHANGED')
    self.tradeskillFrame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')

    self:SetProfScripts('firstProf')
    self:SetProfScripts('secondProf')

    self.tradeskillFrame:SetScript('OnEnter', function()
        if xb.db.profile.modules.tradeskill.showTooltip then
            self:ShowTooltip()
        end
    end)

    self.tradeskillFrame:SetScript('OnLeave', function()
        if xb.db.profile.modules.tradeskill.showTooltip then
            GameTooltip:Hide()
        end
    end)

    self:RegisterMessage('XIVBar_FrameHide', function(_, name)
        if name == 'clockFrame' then
            self:Refresh()
        end
    end)

    self:RegisterMessage('XIVBar_FrameShow', function(_, name)
        if name == 'clockFrame' then
            self:Refresh()
        end
    end)
end

function TradeskillModule:ShowTooltip()
    local r, g, b, _ = unpack(xb:HoverColors())
    GameTooltip:SetOwner(self.tradeskillFrame, 'ANCHOR_' .. xb.miniTextPosition)
    GameTooltip:AddLine("|cFFFFFFFF[|r" .. TRADE_SKILLS .. "|cFFFFFFFF]|r", r, g, b)
    GameTooltip:AddLine(" ")

    if self.firstProf.idx then
        self:ListTooltipProfession('firstProf', r, g, b)
    end
    if self.secondProf.idx then
        self:ListTooltipProfession('secondProf', r, g, b)
    end
    if self.cook.idx then
        self:ListTooltipProfession('cook', r, g, b)
    end
    if self.fish.idx then
        self:ListTooltipProfession('fish', r, g, b)
    end
    if self.arch.idx then
        self:ListTooltipProfession('arch', r, g, b)
    end
    if self.first_aid.idx then
        self:ListTooltipProfession('first_aid', r, g, b)
    end

    -- in case there's daily crafts in shadowlands, add a section under the professions for cooldowns
    -- probably works with: C_TradeSkillUI.GetRecipeInfo() and GetSpellCooldown()

    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine('<' .. L['Left-Click'] .. '>', L['Toggle Profession Frame'], r, g, b, 1, 1, 1)
    if LE_EXPANSION_LEVEL_CURRENT == (LE_EXPANSION_CATACLYSM or 3) then
        GameTooltip:AddDoubleLine('<'..L['Right-Click']..'>', L['Toggle Profession Spellbook'], r, g, b, 1, 1, 1)
    end
    GameTooltip:Show()
end

function TradeskillModule:ListTooltipProfession(prefix, r, g, b)
    local left = "|T" .. self[prefix].defIcon .. ":0|t " .. self[prefix].name
    local right = "|cFFFFFFFF" .. self[prefix].lvl .. "|r / " .. self[prefix].maxLvl
    GameTooltip:AddDoubleLine(left, right, 1, 1, 1, r, g, b)
end

function TradeskillModule:GetDefaultOptions()
    return 'tradeskill', {
        enabled = false,
        barCC = false,
        showTooltip = true
    }
end

function TradeskillModule:GetConfig()
    return {
        name = self:GetName(),
        type = "group",
        args = {
            enable = {
                name = ENABLE,
                order = 0,
                type = "toggle",
                get = function()
                    return xb.db.profile.modules.tradeskill.enabled;
                end,
                set = function(_, val)
                    xb.db.profile.modules.tradeskill.enabled = val
                    if val then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                width = "full"
            },
            barCC = {
                name = L['Use Class Colors'],
                order = 2,
                type = "toggle",
                get = function()
                    return xb.db.profile.modules.tradeskill.barCC;
                end,
                set = function(_, val)
                    xb.db.profile.modules.tradeskill.barCC = val;
                    self:Refresh();
                end
            },
            showTooltip = {
                name = L['Show Tooltips'],
                order = 3,
                type = "toggle",
                get = function()
                    return xb.db.profile.modules.tradeskill.showTooltip;
                end,
                set = function(_, val)
                    xb.db.profile.modules.tradeskill.showTooltip = val;
                    self:Refresh();
                end
            }
        }
    }
end