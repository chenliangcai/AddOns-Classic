local _;
local format = format;

local sIsFade;
local sIsFlashWhenLow;
local sIsWarnColor;
local sIsSwiftmend;
local sHotSetup;
local sHotCols;
local sHotSlots;
local sBarColors;
local sIsHotShowIcon;
local sHotSlotCfgs;
local sHotSlotBouquets;
local sIsChargesIcon;
local sClipL, sClipR, sClipT, sClipB = 0, 1, 0, 1;

local sIsPlayerKnowsSwiftmend = false;
local sSwiftmendUnits = { };
local sIsPlayerCanCastSwiftmend;
local sSwiftmendCooldown = {
	-- <cooldown start time>,
	-- <cooldown duration>,
};

VUHDO_UNIT_HOT_TYPE_MINE = 1;
VUHDO_UNIT_HOT_TYPE_OTHERS = 2;
VUHDO_UNIT_HOT_TYPE_BOTH = 3;
VUHDO_UNIT_HOT_TYPE_OTHERSHOTS = 4;

VUHDO_UNIT_HOT_INFOS = {
	-- [<unit ID>] = {
	--	[<aura instance ID>] = {
	--		<aura expiration time>,
	--		<aura stacks>,
	--		<aura icon>,
	--		<aura total duration>,
	--		<aura source is player: true|false>,
	--		<aura name>,
	--		<aura spell ID>,
	--	},
	-- },
};
local VUHDO_UNIT_HOT_INFOS = VUHDO_UNIT_HOT_INFOS;

VUHDO_UNIT_HOT_LISTS = {
	-- [<unit ID>] = {
	--	[<aura name|spell ID|OTHERS>] = {
	--		<VUHDO_UNIT_HOT_TYPE_MINE|OTHERS|BOTH|OTHERSHOTS> = {
	--			<aura instance ID list head> = {
	--				["auraInstanceId"] = <aura instance ID>,
	--				["prev"] = <prev aura>,
	--			},
	--			<aura count>,
	--		},
	--	},
	-- },
};
local VUHDO_UNIT_HOT_LISTS = VUHDO_UNIT_HOT_LISTS;

local VUHDO_ACTIVE_HOTS = { };
local VUHDO_ACTIVE_HOTS_OTHERS = { };
local sOthersHotsInfo = { };

local VUHDO_IGNORE_HOT_IDS = {
	[67358] = true, -- "Rejuvenating" proc has same name in russian and spanish as rejuvenation
	[126921] = true, -- "Weakened Soul" by Shao-Tien Soul-Render
	[109964] = true, -- "Spirit Shell" ability aura has the same name as the absorb aura itself
}

local VUHDO_CHARGE_TEXTURES = {
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks1", "Interface\\AddOns\\VuhDo\\Images\\hot_stacks2",
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks3", "Interface\\AddOns\\VuhDo\\Images\\hot_stacks4" };

local VUHDO_SHIELD_TEXTURES = {
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks1", "Interface\\AddOns\\VuhDo\\Images\\shield_stacks2",
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks3", "Interface\\AddOns\\VuhDo\\Images\\shield_stacks4" };

local VUHDO_CHARGE_COLORS = { "HOT_CHARGE_1", "HOT_CHARGE_2", "HOT_CHARGE_3", "HOT_CHARGE_4" };

local VUHDO_HOT_CFGS = { "HOT1", "HOT2", "HOT3", "HOT4", "HOT5", "HOT6", "HOT7", "HOT8", "HOT9", "HOT10", };


-- BURST CACHE -------------------------------------------------


local floor = floor;
local table = table;
local GetSpellCooldown = GetSpellCooldown or VUHDO_getSpellCooldown;
local GetSpellName = C_Spell.GetSpellName or VUHDO_getSpellName;
local GetTime = GetTime;
local strfind = strfind;
local pairs = pairs;
local twipe = table.wipe;
local tostring = tostring;
local ForEachAura = AuraUtil.ForEachAura or VUHDO_forEachAura;
local UnpackAuraData = AuraUtil.UnpackAuraData or VUHDO_unpackAuraData;

local _G = _G;

local VUHDO_getHealthBar;
local VUHDO_getBarRoleIcon;
local VUHDO_updateAllClusterIcons;
local VUHDO_shouldScanUnit;
local VUHDO_getShieldLeftCount;
local VUHDO_resolveVehicleUnit;
local VUHDO_isPanelVisible;
local VUHDO_getHealButton;
local VUHDO_getUnitButtons;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;
local VUHDO_getBarIconCounter;
local VUHDO_getBarIconCharge;
local VUHDO_getBarIconClockOrStub;
local VUHDO_backColor;
local VUHDO_textColor;

local VUHDO_PANEL_SETUP;
local VUHDO_CAST_ICON_DIFF;
local VUHDO_HEALING_HOTS;
local VUHDO_RAID;
local sIsClusterIcons;
local sIsOthersHots;

function VUHDO_customHotsInitLocalOverrides()

	-- variables
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_CAST_ICON_DIFF = _G["VUHDO_CAST_ICON_DIFF"];
	VUHDO_HEALING_HOTS = _G["VUHDO_HEALING_HOTS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_ACTIVE_HOTS = _G["VUHDO_ACTIVE_HOTS"];
	VUHDO_ACTIVE_HOTS_OTHERS = _G["VUHDO_ACTIVE_HOTS_OTHERS"];
	-- functions
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarRoleIcon = _G["VUHDO_getBarRoleIcon"];
	VUHDO_updateAllClusterIcons = _G["VUHDO_updateAllClusterIcons"];
	VUHDO_shouldScanUnit = _G["VUHDO_shouldScanUnit"];
	VUHDO_getShieldLeftCount = _G["VUHDO_getShieldLeftCount"];
	VUHDO_resolveVehicleUnit = _G["VUHDO_resolveVehicleUnit"];
	VUHDO_isPanelVisible = _G["VUHDO_isPanelVisible"];
	VUHDO_getHealButton = _G["VUHDO_getHealButton"];
	VUHDO_getBarIcon = _G["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = _G["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = _G["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconCharge = _G["VUHDO_getBarIconCharge"];
	VUHDO_getBarIconClockOrStub = _G["VUHDO_getBarIconClockOrStub"];
	VUHDO_backColor = _G["VUHDO_backColor"];
	VUHDO_textColor = _G["VUHDO_textColor"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	sHotCols = sBarColors["HOTS"];
	sIsFade = sHotCols["isFadeOut"];
	sIsFlashWhenLow = sHotCols["isFlashWhenLow"];
	sIsWarnColor = sHotCols["WARNING"]["enabled"];
	sHotSetup = VUHDO_PANEL_SETUP["HOTS"];
	sHotSlots = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"];
	sIsHotShowIcon = sHotSetup["iconRadioValue"] == 1;
	sIsChargesIcon = sHotSetup["stacksRadioValue"] == 3;
	sIsClusterIcons = VUHDO_INTERNAL_TOGGLES[16] or VUHDO_INTERNAL_TOGGLES[18]; -- -- VUHDO_UPDATE_NUM_CLUSTER -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
	sIsOthersHots = VUHDO_ACTIVE_HOTS["OTHER"];

	sHotSlotCfgs = { };
	sHotSlotBouquets = { };

	for tCnt = 1, 10 do
		sHotSlotCfgs[tCnt] = VUHDO_PANEL_SETUP["HOTS"]["SLOTCFG"][tostring(tCnt)];

		local tHotName = sHotSlots[tCnt];

		if tHotName and not VUHDO_strempty(tHotName) and strfind(tHotName, "BOUQUET_") then
			sHotSlotBouquets[tCnt] = true;
		end
	end

end

----------------------------------------------------



--
function VUHDO_hotsSetClippings(aLeft, aRight, aTop, aBottom)
	sClipL, sClipR, sClipT, sClipB = aLeft, aRight, aTop, aBottom;
end



--
function VUHDO_setKnowsSwiftmend(aKnowsSwiftmend)
	sIsPlayerKnowsSwiftmend = aKnowsSwiftmend;
end



--
local tCopy = { };
local function VUHDO_copyColor(aColor)
	tCopy["R"], tCopy["G"], tCopy["B"], tCopy["O"] = aColor["R"], aColor["G"], aColor["B"], aColor["O"];
	tCopy["TR"], tCopy["TG"], tCopy["TB"], tCopy["TO"] = aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"];
	tCopy["useBackground"], tCopy["useText"], tCopy["useOpacity"] = aColor["useBackground"], aColor["useText"], aColor["useOpacity"];
	return tCopy;
end



--
local tHotBar;
local function VUHDO_customizeHotBar(aButton, aRest, anIndex, aDuration, aColor)

	tHotBar = VUHDO_getHealthBar(aButton, anIndex + 3);

	if not tHotBar then
		return;
	end

	if aColor then
		tHotBar:SetVuhDoColor(aColor);
	end

	if (aDuration or 0) == 0 or not aRest then
		tHotBar:SetValue(0);
	else
		tHotBar:SetValue(aRest / aDuration);
	end

end



--
local tHotName;
local tDuration2;
local tChargeTexture;
local tIsChargeShown;
local tIcon;
local tTimer;
local tCounter;
local tClock;
local tDuration;
local tHotCfg;
local tIsChargeAlpha;
local tChargeColor;
local tStarted;
local tClockDuration;
local tOpacity, tTextOpacity;
local tHotColor;
local tTimes;
local function VUHDO_customizeHotIcons(aButton, aHotName, aRest, aTimes, anIcon, aDuration, aShieldCharges, aColor, anIndex, aClipL, aClipR, aClipT, aClipB)

	tHotCfg = sBarColors[VUHDO_HOT_CFGS[anIndex]];
	tIcon = VUHDO_getBarIcon(aButton, anIndex);
	
	-- Noch nicht erstellt von redraw
	if not tIcon then
		return;
	end

	local VUHDO_UIFrameFlash = (sIsFlashWhenLow or tHotCfg["isFlashWhenLow"]) and _G["VUHDO_UIFrameFlash"] or function() end;
	local VUHDO_UIFrameFlashStop = (sIsFlashWhenLow or tHotCfg["isFlashWhenLow"]) and _G["VUHDO_UIFrameFlashStop"] or function() end;

	if not aRest then
		VUHDO_UIFrameFlashStop(tIcon);
		VUHDO_getBarIconFrame(aButton, anIndex):Hide();

		return;
	else
		VUHDO_getBarIconFrame(aButton, anIndex):Show();
	end

	tTimer = VUHDO_getBarIconTimer(aButton, anIndex);
	tCounter = VUHDO_getBarIconCounter(aButton, anIndex);
	tClock = VUHDO_getBarIconClockOrStub(aButton, anIndex, tHotCfg["isClock"]);
	tChargeTexture = VUHDO_getBarIconCharge(aButton, anIndex);

	if aColor and aColor["useText"] and aColor["TR"] then
		tCounter:SetTextColor(VUHDO_textColor(aColor));
	end

	if anIcon and (sIsHotShowIcon or aColor) then
		if VUHDO_ATLAS_TEXTURES[anIcon] then
			tIcon:SetAtlas(anIcon);

		else
			tIcon:SetTexture(anIcon);
		end
	end

	tIcon:SetTexCoord(aClipL or sClipL, aClipR or sClipR, aClipT or sClipT, aClipB or sClipB);
	
	aTimes = aTimes or 0;
	tIsChargeShown = sIsChargesIcon and aTimes > 0;
	
	--@TESTING
	--aTimes = floor(aRest / 3.5);

	tTimes = aTimes > 4 and 4 or aTimes;

	tIsChargeAlpha = false;

	-- FIXME: useSlotColor no longer has a clear purpose
	if aColor and aColor["useSlotColor"] then
		tHotColor = VUHDO_copyColor(tHotCfg);
	elseif aColor and (not aColor["isDefault"] or not sIsHotShowIcon) then
		tHotColor = aColor;

		if tTimes > 1 and not aColor["noStacksColor"] then
			tChargeColor = sBarColors[VUHDO_CHARGE_COLORS[tTimes]];
			if sHotCols["useColorBack"] then
				tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]
					= tChargeColor["R"], tChargeColor["G"], tChargeColor["B"], tChargeColor["O"];
				tIsChargeAlpha = true;
			end
			if sHotCols["useColorText"] then
				tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]
					= tChargeColor["TR"], tChargeColor["TG"], tChargeColor["TB"], tChargeColor["TO"];
			end
		end

		if tHotColor["useText"] and not sIsHotShowIcon then
			tTimer:SetTextColor(VUHDO_textColor(tHotColor));
		end

	elseif sIsWarnColor and aRest < sHotCols["WARNING"]["lowSecs"] then
		tHotColor = sHotCols["WARNING"];
		tTimer:SetTextColor(VUHDO_textColor(tHotColor));
	else
		tHotColor = VUHDO_copyColor(tHotCfg);

		-- FIXME: color swatch should set isOpacity but doesn't
		if tHotColor["O"] then
			tHotColor["useOpacity"] = true;
		end

		if sIsHotShowIcon then
			if aColor then
				tHotColor = aColor;
			else
				tHotColor["R"], tHotColor["G"], tHotColor["B"] = 1, 1, 1;
			end
		elseif tTimes <= 1 or not sHotCols["useColorText"] then
			tTimer:SetTextColor(VUHDO_textColor(tHotColor));
		end

		if tTimes > 1 then
			tChargeColor = sBarColors[VUHDO_CHARGE_COLORS[tTimes]];
			if sHotCols["useColorBack"] then
				tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]
					= tChargeColor["R"], tChargeColor["G"], tChargeColor["B"], tChargeColor["O"];
				tIsChargeAlpha = true;
			end
			if sHotCols["useColorText"] then
				tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]
					= tChargeColor["TR"], tChargeColor["TG"], tChargeColor["TB"], tChargeColor["TO"];
				tTimer:SetTextColor(VUHDO_textColor(tHotColor));
			end
		end
	end

	if tHotColor and (tIsChargeAlpha or tHotColor["useOpacity"]) and tHotColor["O"] then
		tOpacity = tHotColor["O"];
		tTextOpacity = tHotColor["TO"];
	else
		tOpacity = nil;
		tTextOpacity = nil;
	end

	if tHotColor and tHotColor["useBackground"] and tHotColor["R"] then
		if tOpacity then
			tIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"], tOpacity);
		else
			tIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"]);
		end
	else
		if tOpacity then
			tIcon:SetVertexColor(1, 1, 1, tOpacity);
		else
			tIcon:SetVertexColor(1, 1, 1);
		end
	end

	if aRest == 999 then -- Other players' HoTs
		if aTimes > 0 then
			if tOpacity then
				tIcon:SetAlpha(tOpacity);
			end

			tCounter:SetText(aTimes > 1 and aTimes or "");
		else
			VUHDO_UIFrameFlashStop(tIcon);
			tIcon:SetAlpha(0);
			tCounter:SetText("");
		end
		
		tTimer:SetText("");
		tClock:SetAlpha(0);

		return;

	elseif aRest > 0 then
		if aRest < 10 or tHotCfg["isFullDuration"] then
			tDuration = (tHotCfg["countdownMode"] == 2 and aRest < sHotCols["WARNING"]["lowSecs"])
				and format("%.1f", aRest) or format("%d", aRest);
		elseif tIsChargeShown or (tOpacity and tOpacity > 0) then
			tDuration = "";
		else
			tDuration = "X";
		end

		tTimer:SetText(tDuration);

		tStarted = floor(10 * (GetTime() - aDuration + aRest) + 0.5) * 0.1;
		tClockDuration = tClock:GetCooldownDuration() * 0.001;

		if aDuration > 0 and 
			(tClock:GetAlpha() == 0 or (tClock:GetAttribute("started") or tStarted) ~= tStarted or 
			(tClock:IsVisible() and aDuration > tClockDuration)) then
			tClock:SetAlpha(1);
			tClock:SetCooldown(tStarted, aDuration);
			tClock:SetAttribute("started", tStarted);
		end

		if tOpacity then
			tIcon:SetAlpha(((sIsFade or tHotCfg["isFadeOut"]) and aRest < 10) and tOpacity * aRest * 0.1 or tOpacity);
		end

		if aRest > 5 then
			VUHDO_UIFrameFlashStop(tIcon);
			tTimer:SetTextColor(1, 1, 1, tTextOpacity or 1);
		else
			tDuration2 = aRest * 0.2;
			tTimer:SetTextColor(1, tDuration2, tDuration2, tTextOpacity or 1);
			VUHDO_UIFrameFlash(tIcon, 0.2, 0.1, 5, true, 0, 0.1);
		end

		tCounter:SetText(aTimes > 1 and aTimes or "");

	else
		VUHDO_UIFrameFlashStop(tIcon);
		tTimer:SetText("");
		tClock:SetAlpha(0);
		tCounter:SetText(aTimes > 1 and aTimes or "");

		if tOpacity then
			tIcon:SetAlpha(tOpacity);
		end
	end

	-- FIXME: this whole function needs refactored to logically group (and dedupe) setting the icon, timer and charges colors
	if aColor and (not aColor["isDefault"] or not sIsHotShowIcon) then
		-- respect the default timer text color set above based on remaining duration
	elseif sIsWarnColor and aRest < sHotCols["WARNING"]["lowSecs"] then
		tTimer:SetTextColor(VUHDO_textColor(tHotColor));
	else
		if not sIsHotShowIcon and (tTimes <= 1 or not sHotCols["useColorText"]) then
			tTimer:SetTextColor(VUHDO_textColor(tHotColor));
		end

		if tTimes > 1 and sHotCols["useColorText"] then
			tTimer:SetTextColor(VUHDO_textColor(tHotColor));
		end
	end

	if tIsChargeShown then
		tChargeTexture:SetTexture(VUHDO_CHARGE_TEXTURES[tTimes]);
		tChargeTexture:SetVertexColor(VUHDO_backColorWithFallback(tHotColor));
		
		tChargeTexture:Show();
	elseif aShieldCharges > 0 then
		if sIsHotShowIcon then
			tHotColor = tHotCfg;
		end

		tChargeTexture:SetTexture(VUHDO_SHIELD_TEXTURES[aShieldCharges]);
		
		if tHotColor and tHotColor["R"] then
			tChargeTexture:SetVertexColor(tHotColor["R"] + 0.15, tHotColor["G"] + 0.15, tHotColor["B"] + 0.15, tHotColor["O"]);
		end
		
		tChargeTexture:Show();
	else
		tChargeTexture:Hide();
	end

end



--
local tAllButtons;
local tShieldCharges, tShieldName;
local tIsMatch;
local tIsMine, tIsOthers;
local function VUHDO_updateHotIcons(aUnit, aHotName, aRest, aTimes, anIcon, aDuration, aMode, aColor, aHotSpellName, aClipL, aClipR, aClipT, aClipB)
	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));
	if not tAllButtons then return; end

	tShieldName = aHotSpellName or aHotName;

	if type(tonumber(tShieldName)) == "number" then
		tShieldName = GetSpellName(tonumber(tShieldName));
	end

	tShieldCharges = VUHDO_getShieldLeftCount(aUnit, tShieldName, aMode) or 0; -- if not our shield don't show remaining absorption

	for tIndex, tHotName in pairs(sHotSlots) do
		if aHotName == tHotName then

			if aMode == 0 or aColor then
				tIsMatch = true; -- Bouquet => aColor ~= nil
			else
				tIsMine, tIsOthers = sHotSlotCfgs[tIndex]["mine"], sHotSlotCfgs[tIndex]["others"];

				tIsMatch = (aMode == 1 and tIsMine and not tIsOthers)
					or (aMode == 2 and not tIsMine and tIsOthers)
					or (aMode == 3 and tIsMine and tIsOthers);
			end

			if tIsMatch then
				if tIndex >= 6 and tIndex <= 8 then
					for _, tButton in pairs(tAllButtons) do
						VUHDO_customizeHotBar(tButton, aRest, tIndex, aDuration, aColor);
					end
				else
					for _, tButton in pairs(tAllButtons) do
						VUHDO_customizeHotIcons(tButton, aHotName, aRest, aTimes, anIcon, aDuration, tShieldCharges, aColor, tIndex, aClipL, aClipR, aClipT, aClipB);
					end
				end
			end
		end
	end

end



--
local tHotIconFrame;
local function VUHDO_removeButtonHots(aButton)
	for tCnt = 1, 5 do
		VUHDO_UIFrameFlashStop(VUHDO_getBarIcon(aButton, tCnt));
		tHotIconFrame = VUHDO_getBarIconFrame(aButton, tCnt);
		if tHotIconFrame then tHotIconFrame:Hide(); end
	end

	for tCnt = 9, 10 do
		VUHDO_UIFrameFlashStop(VUHDO_getBarIcon(aButton, tCnt));
		tHotIconFrame = VUHDO_getBarIconFrame(aButton, tCnt);
		if tHotIconFrame then tHotIconFrame:Hide(); end
	end

	for tCnt = 9, 11 do
		VUHDO_getHealthBar(aButton, tCnt):SetValue(0);
	end
	VUHDO_getBarRoleIcon(aButton, 51):Hide(); -- Swiftmend indicator
end



--
function VUHDO_removeHots(aUnit)
	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		VUHDO_removeButtonHots(tButton);
	end
end
local VUHDO_removeHots = VUHDO_removeHots;



-- aura icon, expiration, stacks, duration, isMine, name, spell ID
local VUHDO_UNIT_HOT_INFO_DEFAULT = { nil, 0, 0, 0, nil, nil, nil };



--
local function VUHDO_addUnitHotInfo(aUnit, anAuraInstanceId, anIcon, anExpiry, aStacks, aDuration, anIsMine, aSpellName, aSpellId)

	if not aUnit or not anAuraInstanceId then
		return;
	end

	if not VUHDO_UNIT_HOT_INFOS[aUnit] then
		VUHDO_UNIT_HOT_INFOS[aUnit] = { };
	end

	if VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId] then
		if anIcon ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][1] = anIcon;
		end

		if anExpiry ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][2] = anExpiry;
		end

		if aStacks ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][3] = aStacks == 0 and 1 or aStacks;
		end

		if aDuration ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][4] = aDuration;
		end

		if anIsMine ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][5] = anIsMine;
		end

		if aSpellName ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][6] = aSpellName;
		end

		if aSpellId ~= nil then
			VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId][7] = aSpellId;
		end
	else
		VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId] = {
			anIcon or VUHDO_UNIT_HOT_INFO_DEFAULT[1],
			anExpiry or VUHDO_UNIT_HOT_INFO_DEFAULT[2],
			aStacks and (aStacks == 0 and 1 or aStacks) or VUHDO_UNIT_HOT_INFO_DEFAULT[3],
			aDuration or VUHDO_UNIT_HOT_INFO_DEFAULT[4],
			anIsMine or VUHDO_UNIT_HOT_INFO_DEFAULT[5],
			aSpellName or VUHDO_UNIT_HOT_INFO_DEFAULT[6],
			aSpellId or VUHDO_UNIT_HOT_INFO_DEFAULT[7]
		};
	end

end



--
local function VUHDO_removeUnitHotInfo(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return;
	end

	if not VUHDO_UNIT_HOT_INFOS[aUnit] or not VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId] then
		return;
	end

	VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId] = nil;

end



--
function VUHDO_getUnitHotInfos(aUnit)

	if not aUnit then
		return;
	end

	return VUHDO_UNIT_HOT_INFOS[aUnit];

end



--
function VUHDO_getUnitHotInfo(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId or not VUHDO_UNIT_HOT_INFOS[aUnit] then
		return;
	end

	return VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId];

end



--
local tUnitHotListPrev;
local tUnitHotPrevInfo;
local function VUHDO_addUnitHot(aUnit, aSpellName, aSourceType, anAuraInstanceId, anIsMine)

	if not aUnit or not aSpellName or not aSourceType or not anAuraInstanceId then
		return;
	end

	if not VUHDO_UNIT_HOT_LISTS[aUnit] then
		VUHDO_UNIT_HOT_LISTS[aUnit] = { };
	end

	if not VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName] then
		VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName] = {
			{ nil, 0 }, -- VUHDO_UNIT_HOT_TYPE_MINE
			{ nil, 0 }, -- VUHDO_UNIT_HOT_TYPE_OTHERS
			{ nil, 0 }, -- VUHDO_UNIT_HOT_TYPE_BOTH
			{ nil, 0 }, -- VUHDO_UNIT_HOT_TYPE_OTHERSHOTS
		};
	end

	tUnitHotListPrev = VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1];

	if tUnitHotListPrev and tUnitHotListPrev["auraInstanceId"] and
		aSourceType == VUHDO_UNIT_HOT_TYPE_BOTH and not anIsMine then
		tUnitHotPrevInfo = VUHDO_getUnitHotInfo(aUnit, tUnitHotListPrev["auraInstanceId"]);

		-- player auras take precedent over others auras
		if tUnitHotPrevInfo and tUnitHotPrevInfo[5] then
			VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1]["prev"] = {
				["auraInstanceId"] = anAuraInstanceId,
				["prev"] = tUnitHotListPrev["prev"],
			};
		else
			VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1] = {
				["auraInstanceId"] = anAuraInstanceId,
				["prev"] = tUnitHotListPrev,
			};
		end
	else
		VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1] = { ["auraInstanceId"] = anAuraInstanceId };

		if tUnitHotListPrev then
			VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1]["prev"] = tUnitHotListPrev;
		end
	end

	VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][2] = VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][2] + 1;

end



--
local tUnitHotList;
local tUnitHotListPrev;
local tUnitHotListNext;
local function VUHDO_removeUnitHot(aUnit, aSpellName, aSourceType, anAuraInstanceId)

	if not aUnit or not aSpellName or not aSourceType or not anAuraInstanceId then
		return;
	end

	if not VUHDO_UNIT_HOT_LISTS[aUnit] or
		not VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName] or not VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType] then
		return;
	end

	tUnitHotListNext = false;
	tUnitHotList = VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1];

	while tUnitHotList and tUnitHotList["auraInstanceId"] do
		if tUnitHotList["auraInstanceId"] == anAuraInstanceId then
			tUnitHotListPrev = tUnitHotList["prev"];

			if tUnitHotListPrev and not tUnitHotListNext then
				-- remove head
				VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1] = tUnitHotListPrev;
			elseif tUnitHotListPrev and tUnitHotListNext then
				-- remove link
				tUnitHotListNext["prev"] = tUnitHotListPrev;
			elseif not tUnitHotListPrev and tUnitHotListNext then
				-- remove tail
				tUnitHotListNext["prev"] = nil;
			else
				VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1] = nil;
			end

			VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][2] = VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][2] - 1;

			break;
		else
			tUnitHotListNext = tUnitHotList;
			tUnitHotList = tUnitHotList["prev"];
		end
	end

end



--
local tUnitHotList;
function VUHDO_getUnitHot(aUnit, aSpellName, aSourceType)

	if not aUnit or not aSpellName or not aSourceType then
		return;
	end

	if not VUHDO_UNIT_HOT_INFOS[aUnit] or not VUHDO_UNIT_HOT_LISTS[aUnit] or
		not VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName] or not VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType] then
		return;
	end

	tUnitHotList = VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][1];

	if not tUnitHotList then
		return;
	end

	return tUnitHotList, VUHDO_UNIT_HOT_LISTS[aUnit][aSpellName][aSourceType][2];

end



--
function VUHDO_getUnitHotLists(aUnit)

	if not aUnit then
		return;
	end

	return VUHDO_UNIT_HOT_LISTS[aUnit];

end



--
local tUnitHotCnt;
function VUHDO_hasUnitHot(aUnit, aSpellName, aSourceType)

	if not aUnit or not aSpellName then
		return;
	end

	if not aSourceType then
		aSourceType = VUHDO_UNIT_HOT_TYPE_MINE;
	end

	_, tUnitHotCount = VUHDO_getUnitHot(aUnit, aSpellName, aSourceType);

	if tUnitHotCount and tUnitHotCount > 0 then
		return true;
	else
		return false;
	end

end



--
local tOphEmpty = { nil, 0 };
local tUnitHot;
local tUnitHotCount;
local tUnitHotInfo;
function VUHDO_getOtherPlayersHotInfo(aUnit)

	if not aUnit then
		return;
	end

	tUnitHot, tUnitHotCount = VUHDO_getUnitHot(aUnit, "OTHER", VUHDO_UNIT_HOT_TYPE_OTHERSHOTS);

	if tUnitHot and tUnitHot["auraInstanceId"] then
		-- tUnitHotInfo: aura icon, expiration, stacks, duration, isMine, name, spell ID
		tUnitHotInfo = VUHDO_getUnitHotInfo(aUnit, tUnitHot["auraInstanceId"]);

		if tUnitHotInfo then
			return tUnitHotInfo[1], tUnitHotCount;
		end
	end

	return tOphEmpty;

end



--
local tUnitHotInfo;
local tIsCastByPlayer;
local tSpellName;
local tSpellId;
local tSpellIdStr;
function VUHDO_removeHot(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId or not VUHDO_UNIT_HOT_INFOS[aUnit] then
		return;
	end

	tUnitHotInfo = VUHDO_UNIT_HOT_INFOS[aUnit][anAuraInstanceId];

	if not tUnitHotInfo then
		return;
	end

	tIsCastByPlayer = tUnitHotInfo[5];
	tSpellName = tUnitHotInfo[6];
	tSpellId = tUnitHotInfo[7];

	tSpellIdStr = tostring(tSpellId or -1);

	if VUHDO_ACTIVE_HOTS[tSpellIdStr] then
		VUHDO_removeUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_BOTH, anAuraInstanceId);

		if tIsCastByPlayer then
			VUHDO_removeUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_MINE, anAuraInstanceId);
		else
			VUHDO_removeUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_OTHERS, anAuraInstanceId);
		end
	end

	if VUHDO_ACTIVE_HOTS[tSpellName] then
		VUHDO_removeUnitHot(aUnit, tSpellName, VUHDO_UNIT_HOT_TYPE_BOTH, anAuraInstanceId);

		if tIsCastByPlayer then
			VUHDO_removeUnitHot(aUnit, tSpellName, VUHDO_UNIT_HOT_TYPE_MINE, anAuraInstanceId);
		else
			VUHDO_removeUnitHot(aUnit, tSpellName, VUHDO_UNIT_HOT_TYPE_OTHERS, anAuraInstanceId);
		end
	end

	if not tIsCastByPlayer and VUHDO_HEALING_HOTS[tSpellName] and
		not VUHDO_ACTIVE_HOTS_OTHERS[tSpellName] and not VUHDO_ACTIVE_HOTS_OTHERS[tSpellIdStr] then
		VUHDO_removeUnitHot(aUnit, "OTHER", VUHDO_UNIT_HOT_TYPE_OTHERSHOTS, anAuraInstanceId);
	end

	if sIsPlayerKnowsSwiftmend and (VUHDO_SPELL_ID.REGROWTH == tSpellName or VUHDO_SPELL_ID.REJUVENATION == tSpellName) then
		sSwiftmendUnits[aUnit] = (sSwiftmendUnits[aUnit] or 1) - 1;
	end

	VUHDO_removeUnitHotInfo(aUnit, anAuraInstanceId);

end



--
local tAllButtons;
local tIcon;
local tBarIconFrame;
function VUHDO_removeHotIcon(aUnit, anIndex)

	if not aUnit or not anIndex then
		return;
	end

	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));

	if not tAllButtons then
		return;
	end

	if anIndex >= 6 and anIndex <= 8 then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeHotBar(tButton, nil, anIndex);
		end
	else
		for _, tButton in pairs(tAllButtons) do
			tIcon = VUHDO_getBarIcon(tButton, anIndex);

			if tIcon then
				VUHDO_UIFrameFlashStop(tIcon);
			end

			tBarIconFrame = VUHDO_getBarIconFrame(tButton, anIndex);

			if tBarIconFrame then
				tBarIconFrame:Hide();
			end
		end
	end

end



--
function VUHDO_initHots(aUnit)

	if not VUHDO_UNIT_HOT_INFOS[aUnit] then
		VUHDO_UNIT_HOT_INFOS[aUnit] = { };
	else
		for tAuraInstanceId, _ in pairs(VUHDO_UNIT_HOT_INFOS[aUnit]) do
			VUHDO_UNIT_HOT_INFOS[aUnit][tAuraInstanceId] = nil;
		end
	end

	if not VUHDO_UNIT_HOT_LISTS[aUnit] then
		VUHDO_UNIT_HOT_LISTS[aUnit] = { };
	else
		for tSpellName, _ in pairs(VUHDO_UNIT_HOT_LISTS[aUnit]) do
			VUHDO_UNIT_HOT_LISTS[aUnit][tSpellName] = nil;
		end
	end

	sSwiftmendUnits[aUnit] = 0;

end



--
local tNewDuration, tNewExpiry;
local tIsCastByPlayer;
local tIsHotInfoAdded;
local tSpellIdStr;
local tRest;
function VUHDO_updateHotPredicate(aUnit, aNow, anAuraInstanceId, aName, anIcon, aStacks, aDuration, anExpiry, aUnitCaster, aSpellId, anIsUpdate)

	if not anIcon then
		return;
	end

	if VUHDO_LibClassicDurations then
		tNewDuration, tNewExpiry = VUHDO_LibClassicDurations:GetAuraDurationByUnit(aUnit, aSpellId, aUnitCaster, aName);

		if aDuration == 0 and tNewDuration then 
			aDuration = tNewDuration;
			anExpiry = tNewExpiry;
		end
	end


	tIsHotInfoAdded = false;
	tIsCastByPlayer = aUnitCaster == "player" or aUnitCaster == VUHDO_PLAYER_RAID_ID;

	if not anIsUpdate and sIsPlayerKnowsSwiftmend and (VUHDO_SPELL_ID.REGROWTH == aName or VUHDO_SPELL_ID.REJUVENATION == aName) then
		VUHDO_addUnitHotInfo(aUnit, anAuraInstanceId, anIcon, anExpiry, aStacks, aDuration, tIsCastByPlayer, aName, aSpellId);
		tIsHotInfoAdded = true;

		sSwiftmendUnits[aUnit] = (sSwiftmendUnits[aUnit] or 0) + 1;
	end

	if (anExpiry or 0) == 0 then
		anExpiry = (aNow + 9999);
	end

	tSpellIdStr = tostring(aSpellId or -1);

	if not VUHDO_IGNORE_HOT_IDS[aSpellId] then
		if VUHDO_ACTIVE_HOTS[tSpellIdStr] or VUHDO_ACTIVE_HOTS[aName] then
			tRest = anExpiry - aNow;

			if tRest > 0 then
				if not tIsHotInfoAdded then
					VUHDO_addUnitHotInfo(aUnit, anAuraInstanceId, anIcon, anExpiry, aStacks, aDuration, tIsCastByPlayer, aName, aSpellId);
				end

				if not anIsUpdate then
					if VUHDO_ACTIVE_HOTS[tSpellIdStr] then
						VUHDO_addUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_BOTH, anAuraInstanceId, tIsCastByPlayer);

						if tIsCastByPlayer then
							VUHDO_addUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_MINE, anAuraInstanceId, tIsCastByPlayer);
						else
							VUHDO_addUnitHot(aUnit, tSpellIdStr, VUHDO_UNIT_HOT_TYPE_OTHERS, anAuraInstanceId, tIsCastByPlayer);
						end
					end

					if VUHDO_ACTIVE_HOTS[aName] then
						VUHDO_addUnitHot(aUnit, aName, VUHDO_UNIT_HOT_TYPE_BOTH, anAuraInstanceId, tIsCastByPlayer);

						if tIsCastByPlayer then
							VUHDO_addUnitHot(aUnit, aName, VUHDO_UNIT_HOT_TYPE_MINE, anAuraInstanceId, tIsCastByPlayer);
						else
							VUHDO_addUnitHot(aUnit, aName, VUHDO_UNIT_HOT_TYPE_OTHERS, anAuraInstanceId, tIsCastByPlayer);
						end
					end
				end
			end
		end
	end

	if not tIsCastByPlayer and VUHDO_HEALING_HOTS[aName] and
		not VUHDO_ACTIVE_HOTS_OTHERS[aName] and not VUHDO_ACTIVE_HOTS_OTHERS[tSpellIdStr] then
		if not tIsHotInfoAdded then
			VUHDO_addUnitHotInfo(aUnit, anAuraInstanceId, anIcon, anExpiry, aStacks, aDuration, tIsCastByPlayer, aName, aSpellId);
		end

		if not anIsUpdate then
			VUHDO_addUnitHot(aUnit, "OTHER", VUHDO_UNIT_HOT_TYPE_OTHERSHOTS, anAuraInstanceId, tIsCastByPlayer);
		end
	end

end



--
function VUHDO_hotBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB)

	VUHDO_updateHotIcons(aUnit, "BOUQUET_" .. (aBouquetName or ""), aTimer, aCounter, anIcon, aDuration, 0, aColor, aBuffName, aClipL, aClipR, aClipT, aClipB);

end



--
local tAllButtons;
local tUnitHot;
local tUnitHotCount;
local tUnitHotInfo;
local tRest;
local tStacks;
local tDuration;
local tShieldCharges;
local function VUHDO_updateHot(aUnit, anIndex, aSpellName, aSourceType, aNow)

	if not aUnit then
		return;
	end

	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));

	if not tAllButtons then
		return;
	end

	tUnitHot, tUnitHotCount = VUHDO_getUnitHot(aUnit, aSpellName, aSourceType);

	if tUnitHot and tUnitHot["auraInstanceId"] then
		-- tUnitHotInfo: aura icon, expiration, stacks, duration, isMine, name, spell ID
		tUnitHotInfo = VUHDO_getUnitHotInfo(aUnit, tUnitHot["auraInstanceId"]);

		if tUnitHotInfo then
			if aSourceType == VUHDO_UNIT_HOT_TYPE_OTHERSHOTS then
				tRest = 999;
				tDuration = nil;

				tStacks = tUnitHotCount;
			else
				tRest = tUnitHotInfo[2] - aNow;
				tDuration = tUnitHotInfo[4];

				if tUnitHotCount > 1 and (aSourceType == VUHDO_UNIT_HOT_TYPE_OTHERS or aSourceType == VUHDO_UNIT_HOT_TYPE_BOTH) then
					tStacks = tUnitHotCount;
				else
					tStacks = tUnitHotInfo[3];
				end
			end

			if anIndex >= 6 and anIndex <= 8 then
				for _, tButton in pairs(tAllButtons) do
					VUHDO_customizeHotBar(tButton, tRest, anIndex, tDuration, nil);
				end
			else
				-- if not our shield don't show remaining absorption
				tShieldCharges = VUHDO_getShieldLeftCount(aUnit, tUnitHotInfo[6], aSourceType) or 0;

				for _, tButton in pairs(tAllButtons) do
					VUHDO_customizeHotIcons(
						tButton,
						aSpellName,
						tRest,
						tStacks,
						tUnitHotInfo[1],
						tDuration,
						tShieldCharges,
						nil,
						anIndex,
						nil, nil, nil, nil
					);
				end
			end
		end
	elseif not sHotSlotBouquets[anIndex] then
		VUHDO_removeHotIcon(aUnit, anIndex);
	end

end



--
local tSpellIdStr;
local tNow;
local tSourceType;
local tIsMine;
local tIsOthers;
function VUHDO_updateHots(aUnit, anInfo, aSpellName, aSpellId)

	if not aUnit or not anInfo then
		return;
	end

	-- FIXME: should only do this once on vehicle entrance
	if anInfo["isVehicle"] then
		VUHDO_removeHots(aUnit);

		aUnit = anInfo["petUnit"];

		if not aUnit then
			return;
		end -- bei z.B. focus/target
	end

	if not VUHDO_UNIT_HOT_INFOS[aUnit] or not VUHDO_UNIT_HOT_LISTS[aUnit] then
		return;
	end

	if aSpellId then
		tSpellIdStr = tostring(aSpellId);
	end

	tNow = GetTime();

	for tIndex, tHotName in pairs(sHotSlots) do
		if not VUHDO_strempty(tHotName) and
			((aSpellId and tSpellIdStr == tHotName) or (aSpellName and aSpellName == tHotName) or
			(not aSpellName and not aSpellId and not sHotSlotBouquets[tIndex])) then
			tSourceType = 0;

			if sIsOthersHots and tHotName == "OTHER" then
				tSourceType = VUHDO_UNIT_HOT_TYPE_OTHERSHOTS;
			else
				tIsMine, tIsOthers = sHotSlotCfgs[tIndex]["mine"], sHotSlotCfgs[tIndex]["others"];

				if tIsMine and not tIsOthers then
					tSourceType = VUHDO_UNIT_HOT_TYPE_MINE;
				elseif not tIsMine and tIsOthers then
					tSourceType = VUHDO_UNIT_HOT_TYPE_OTHERS;
				elseif tIsMine and tIsOthers then
					tSourceType = VUHDO_UNIT_HOT_TYPE_BOTH;
				end
			end

			if tSourceType > 0 then
				VUHDO_updateHot(aUnit, tIndex, tHotName, tSourceType, tNow);
			end
		end
	end

end



--
local tIcon;
local tPanelNum;
function VUHDO_swiftmendIndicatorBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SWIFTMEND_INDICATOR"] == aBouquetName then
			if anIsActive and aColor then
				tIcon = VUHDO_getBarRoleIcon(tButton, 51);

				if VUHDO_ATLAS_TEXTURES[anIcon] then
					tIcon:SetAtlas(anIcon);
				else
					tIcon:SetTexture(anIcon);
				end

				tIcon:SetVertexColor(VUHDO_backColorWithFallback(aColor));

				tIcon:SetTexCoord(aClipL or 0, aClipR or 1, aClipT or 0, aClipB or 1);

				tIcon:Show();

				if VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["SWIFTMEND_INDICATOR"]["isBarGlow"] then
					VUHDO_LibCustomGlow.PixelGlow_Start(
						tButton,
						{
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["R"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["G"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["B"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["O"]
						},
						14,                             -- number of particles
						0.3,                            -- frequency
						8,                              -- length
						2,                              -- thickness
						0,                              -- x offset
						0,                              -- y offset
						false,                          -- border
						VUHDO_CUSTOM_GLOW_SWIFTMEND_FRAME_KEY
					);
				end

				if VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["SWIFTMEND_INDICATOR"]["isIconGlow"] then
					VUHDO_LibCustomGlow.PixelGlow_Start(
						tIcon,
						{
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["R"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["G"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["B"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["O"]
						},
						8,                                           -- number of particles
						0.3,                                         -- frequency
						6,                                           -- length
						2,                                           -- thickness
						0,                                           -- x offset
						0,                                           -- y offset
						false,                                       -- border
						VUHDO_CUSTOM_GLOW_SWIFTMEND_ICON_KEY
					);
				end
			else
				VUHDO_LibCustomGlow.PixelGlow_Stop(tButton, VUHDO_CUSTOM_GLOW_SWIFTMEND_FRAME_KEY);

				tIcon = VUHDO_getBarRoleIcon(tButton, 51);
				VUHDO_LibCustomGlow.PixelGlow_Stop(tIcon, VUHDO_CUSTOM_GLOW_SWIFTMEND_ICON_KEY);
				tIcon:Hide();
			end
		end
	end

end



--
local sIsSuspended = false;
function VUHDO_suspendHoTs(aFlag)
	sIsSuspended = aFlag;
end



--
function VUHDO_removeAllHots()
	local tButton;
	local tCnt2;
	for tCnt = 1, 10 do
		if VUHDO_getActionPanel(tCnt) then
			if VUHDO_isPanelVisible(tCnt) then

				tCnt2 = 1;
				while true do
					tButton = VUHDO_getHealButton(tCnt2, tCnt);
					if not tButton then break; end -- Auch nicht belegte buttons ausblenden
					VUHDO_removeButtonHots(tButton);
					tCnt2 = tCnt2 + 1;
				end

			end
		else
			break;
		end
	end

	VUHDO_updatePlayerTarget();
end



--
local tStart;
local tDuration;
local function VUHDO_updateSwiftmendCooldown()

	if not sIsPlayerKnowsSwiftmend then
		return;
	end

	if not sSwiftmendCooldown[0] or not sSwiftmendCooldown[1] then
		tStart, tDuration = GetSpellCooldown(VUHDO_SPELL_ID.SWIFTMEND);

		if (tStart == nil and tDuration == nil) or (tStart > 0 and tDuration > 1.5) then
			sSwiftmendCooldown[0], sSwiftmendCooldown[1] = tStart, tDuration;

			sIsPlayerCanCastSwiftmend = false;
		else
			sIsPlayerCanCastSwiftmend = true;
		end
	elseif (sSwiftmendCooldown[0] + sSwiftmendCooldown[1] - GetTime()) <= 0 then
		sSwiftmendCooldown[0], sSwiftmendCooldown[1] = nil, nil;

		sIsPlayerCanCastSwiftmend = true;
	else
		sIsPlayerCanCastSwiftmend = false;
	end

end



--
function VUHDO_isUnitSwiftmendable(aUnit)

	if sIsPlayerKnowsSwiftmend and sIsPlayerCanCastSwiftmend and ((sSwiftmendUnits[aUnit] or 0) > 0) then
		return true;
	else
		return false;
	end

end



--
function VUHDO_updateAllHoTs(aClustersOnly)

	if sIsSuspended then
		return;
	end

	VUHDO_updateSwiftmendCooldown();

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if not aClustersOnly then
			VUHDO_updateHots(tUnit, tInfo);
		end

		if VUHDO_shouldScanUnit(tUnit) then
			-- Clusters
			if sIsClusterIcons then
				VUHDO_updateAllClusterIcons(tUnit, tInfo);
			end
		end
	end

end