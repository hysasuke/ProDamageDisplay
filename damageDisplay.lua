local L = LibStub("AceLocale-3.0"):GetLocale("PDD")
local _, core = ...; -- Namespace

local CT = {};

core.CT = CT;

local CASTING_BAR_HEIGHT = 20;

local function CreateCastingBar(i, parent)
    local frame = CreateFrame("Frame", "CombatTextFrame" .. i, parent);
    -- frame:SetSize(300, 20);
    frame:SetHeight(CASTING_BAR_HEIGHT);
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, CASTING_BAR_HEIGHT)
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, CASTING_BAR_HEIGHT)
    frame:SetFrameStrata("MEDIUM");
    frame:SetFrameLevel(2);
    frame.order = 0;
    frame:SetAlpha(0);
    SetAnimation(frame);

    -- Store combat log event data
    frame.logData = nil;

    -- Spell icon
    frame.icon = frame:CreateTexture(nil, "OVERLAY");
    frame.icon:SetSize(CASTING_BAR_HEIGHT, CASTING_BAR_HEIGHT);
    frame.icon:SetPoint("LEFT", frame, "LEFT", 0, 0);

    -- Spell Name
    frame.spellNameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    frame.spellNameText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.spellNameText:SetTextColor(1, 1, 1, 1)
    frame.spellNameText:SetPoint("LEFT", frame.icon, "RIGHT", 5, 0);
    frame.spellNameText:SetJustifyH("LEFT");
    frame.spellNameText:SetJustifyV("MIDDLE");

    -- Target 
    frame.generalInfoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    frame.generalInfoText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.generalInfoText:SetTextColor(1, 1, 1, 1)
    frame.generalInfoText:SetPoint("LEFT", frame.spellNameText, "RIGHT", 0, 0);
    frame.generalInfoText:SetJustifyH("LEFT");
    frame.generalInfoText:SetJustifyV("MIDDLE");

    -- Damage amount
    frame.damageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    frame.damageText:SetPoint("RIGHT", frame, "RIGHT", -5, 0);
    frame.damageText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.damageText:SetTextColor(1, 1, 1, 1)
    frame.damageText:SetJustifyH("RIGHT");
    frame.damageText:SetJustifyV("MIDDLE");

    -- Heal amount
    frame.healText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    frame.healText:SetPoint("RIGHT", frame, "RIGHT", -5, 0);
    frame.healText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.healText:SetTextColor(1, 1, 1, 1)
    frame.healText:SetJustifyH("RIGHT");
    frame.healText:SetJustifyV("MIDDLE");
    frame.healText:SetTextColor(0, 1, 0, 1);

    -- Casting bar
    frame.castingBar = CreateFrame("StatusBar", "CombatTextFrame" .. i .. "CastingBar", frame);
    frame.castingBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, 0);
    frame.castingBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);
    -- frame.castingBar:SetSize(275, 20);
    frame.castingBar:SetStatusBarTexture("UI-CastingBar-Filling-Background");
    frame.castingBar:SetFrameStrata("HIGH");
    frame.castingBar:SetFrameLevel(1);
    -- Set spark
    frame.castingBar.Spark = frame.castingBar:CreateTexture(nil, "OVERLAY");
    frame.castingBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
    frame.castingBar.Spark:SetBlendMode("ADD");
    frame.castingBar.Spark:SetSize(CASTING_BAR_HEIGHT, CASTING_BAR_HEIGHT + 10);
    frame.castingBar.Spark:SetPoint("CENTER", frame.castingBar:GetStatusBarTexture(), "RIGHT", 0, 0);

    -- DEBUG INFO -- 
    -- frame.indexText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    -- frame.indexText:SetPoint("CENTER", frame, "CENTER", 0, 0);
    -- frame.indexText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    -- frame.indexText:SetTextColor(1, 0, 0, 1)
    -- frame.indexText:SetJustifyH("MIDDLE");
    -- frame.indexText:SetJustifyV("MIDDLE");
    -- frame.indexText:SetText(i);
    -- frame.orderText = frame:CreateFontString(nil, "OVERLAY", "
    -- frame.orderText:SetPoint("CENTER", frame, "CENTER", 10, 0);
    -- frame.orderText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    -- frame.orderText:SetTextColor(1, 0, 0, 1)
    -- frame.orderText:SetJustifyH("MIDDLE");
    -- frame.orderText:SetJustifyV("MIDDLE");
    -- frame.orderText:SetText(frame.order);
    -- DEBUG INFO --

    SetAnimation(frame.castingBar)
    return frame;
end

local function RegernerateFrames(pool, container)
    local currentFrames = #pool;
    local containerHeight = container:GetHeight();
    local targetFrames = math.ceil(containerHeight / CASTING_BAR_HEIGHT);
    local removingIndexes = {};
    if (currentFrames < targetFrames) then
        for i = 1, targetFrames do
            if (pool[i] == nil) then
                local frame = CreateCastingBar(i, container);
                tinsert(pool, frame);
            end
        end
    elseif (currentFrames > targetFrames) then
        for i = 1, currentFrames do
            local tmp = pool[i];
            if (tmp.order >= targetFrames) then
                tinsert(removingIndexes, i);
            end
        end

        for i = #removingIndexes, 1, -1 do
            local index = removingIndexes[i];
            local frame = pool[index];
            frame:Hide();
            table.remove(pool, index);
        end

    end
end

local function CreateCombatTextFrame()
    local f = CreateFrame("Frame", "CombatTextFrame", UIParent);
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START");
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
    f:RegisterEvent("UNIT_SPELLCAST_SENT");
    f:RegisterEvent("UNIT_SPELLCAST_START");
    f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");

    f:SetScript("OnEvent", CT.COMBAT_LOG_EVENT_UNFILTERED);
    f:SetSize(300, 100);

    -- Make the frame resizable
    f:SetResizeBounds(300, 100, 3000, 1000)

    local savedFramePoints = core:GetFramePoints("combatTextFrame");
    if savedFramePoints then
        f:SetPoint(savedFramePoints.point, savedFramePoints.relativeTo, savedFramePoints.relativePoint,
            savedFramePoints.xOfs, savedFramePoints.yOfs);
        f:SetSize(savedFramePoints.containerWidth, savedFramePoints.containerHeight);
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    end
    f:SetFrameStrata("MEDIUM");
    f:SetFrameLevel(1);
    f:RegisterForDrag("LeftButton");
    f:SetScript("OnDragStart", f.StartMoving);
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        SaveFramePoints(f, "combatText", "combatTextFrame");
    end);

    -- Background
    f.background = f:CreateTexture(nil, "BACKGROUND");
    f.background:SetAllPoints(f);
    f.background:SetColorTexture(0, 0, 0, 0.5);

    -- Create edit mode frame mask
    local editModeFrameMask = CreateFrame("Frame", nil, f)
    f.editModeFrameMask = editModeFrameMask
    editModeFrameMask:SetAllPoints(f)
    editModeFrameMask:SetFrameLevel(100)
    local editModeFrameMaskTexture = editModeFrameMask:CreateTexture(nil, "OVERLAY")
    editModeFrameMaskTexture:SetAllPoints(editModeFrameMask)
    editModeFrameMaskTexture:SetColorTexture(0, 0, 0, 0.8)
    editModeFrameMaskTexture:SetBlendMode("BLEND")
    local editModeFrameMaskText = editModeFrameMask:CreateFontString(nil, "OVERLAY")
    editModeFrameMaskText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    editModeFrameMaskText:SetPoint("CENTER", editModeFrameMask, "CENTER", 0, 0)
    editModeFrameMaskText:SetTextColor(1, 1, 1, 1)
    editModeFrameMaskText:SetJustifyH("CENTER")
    editModeFrameMaskText:SetJustifyV("MIDDLE")
    editModeFrameMaskText:SetText(L["combatText"])
    editModeFrameMask:Hide()

    -- Add a resize button
    f.resizeButton = CreateFrame("Button", nil, editModeFrameMask)
    f.resizeButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    f.resizeButton:SetSize(16, 16)
    f.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    f.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    f.resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            f:StartSizing("BOTTOMRIGHT")
            self:GetHighlightTexture():Hide() -- Hide highlight texture while sizing
        end
    end)

    f.resizeButton:SetScript("OnMouseUp", function(self, button)
        f:StopMovingOrSizing()
        self:GetHighlightTexture():Show()
        -- Save the new size here
        RegernerateFrames(f.framePool, f);
        SaveFramePoints(f, "combatText", "combatTextFrame");
    end)

    f.resizeButton:Hide();

    -- Frames
    f.framePool = {};
    local numberOfFrames = f:GetHeight() / CASTING_BAR_HEIGHT;
    for i = 1, numberOfFrames do
        local frame = CreateCastingBar(i, f);
        tinsert(f.framePool, frame);
    end
    return f;
end

function CT:Toggle(value)
    if (not value) then
        self.frame:Hide();
    else
        self.frame:Show();
    end
end

function CT:ToggleBackground(value)
    if (not value) then
        self.frame.background:SetAlpha(0);
    else
        self.frame.background:SetAlpha(1);
    end
end

function CT:ToggleTargetName(value)
    if (not value) then
        for i = 1, #self.frame.framePool do
            self.frame.framePool[i].generalInfoText:Hide();
        end
    else
        for i = 1, #self.frame.framePool do
            self.frame.framePool[i].generalInfoText:Show();
        end
    end
end

function CT:ToggleCastingAnimation(value)
    if (not value) then
        for i = 1, #self.frame.framePool do
            self.frame.framePool[i].castingBar:Hide();
        end
    else
        for i = 1, #self.frame.framePool do
            self.frame.framePool[i].castingBar:Show();
        end
    end
end

function CT:Initialize()
    self.frame = CreateCombatTextFrame();
    if not PDD.db.profile.combatText.enable then
        self:Toggle(false);
    end
    if not PDD.db.profile.combatText.showBackground then
        self:ToggleBackground(false);
    end
    if not PDD.db.profile.combatText.showTargetName then
        self:ToggleTargetName(false);
    end
    if not PDD.db.profile.combatText.showCastingAnimation then
        self:ToggleCastingAnimation(false);
    end
end

function CT:FindNextAvailableLogIndex()
    for i = 1, #self.frame.framePool do
        if (self.frame.framePool[i].order == 0) then
            return i;
        end
    end
    return 1;
end

function CT:HandleSpellSentEvent(frameIndex, castGUID, spellID, destName)
    local spellName = GetSpellInfo(spellID);
    local frame = CT.frame.framePool[frameIndex];
    frame.logData = {
        eventType = "SPELL_SENT",
        castGUID = castGUID,
        spellId = spellID,
        spellName = spellName,
        destName = destName,
        amount = 0,
        healAmount = 0,
        destGUIDs = {},
        spellCastType = "cast"
    }
end

function CT:HandleStartCastEvent(castGUID, spellId, spellCastType)
    local frame, frameIndex = CT:FindTargetFrameByEvent("SPELL_SENT", castGUID, spellId);
    if not frame then
        return;
    end
    local name, startTimeMS, endTimeMS, castID = UnitChannelInfo("player");
    if castID ~= nil and spellCastType ~= "empower" then
        spellCastType = "channel";
    end

    frame.logData.eventType = "SPELL_CAST_START"
    frame.logData.spellCastType = spellCastType
    local destName = frame.logData.destName;
    local spellName = frame.logData.spellName;
    frame.spellNameText:SetText(spellName);
    frame.icon:SetTexture(GetSpellTexture(spellId));
    if destName then
        frame.generalInfoText:SetText(" -> " .. destName);
    end
    frame.damageText:SetText("");
    frame.healText:SetText("");
    frame.order = 1;
    frame:SetAlpha(1);
    frame:StartAnimation(20, 0, 0.2, function(value)
        frame:SetPoint("TOPLEFT", 0, value);
    end)
    -- frame:StartAnimation(0, 1, 0.2, function(value)
    --     frame:SetAlpha(value);
    -- end)
    -- frame:SetPoint("TOPLEFT", 0, 0);
    -- Setup bar and animation
    -- local spellCastTime = select(4, GetSpellInfo(spellId));
    local _, _, _, startTime, endTime = UnitCastingInfo("player");
    if (spellCastType == "channel" or spellCastType == "empower") then
        _, _, _, startTime, endTime = UnitChannelInfo("player");
    end

    -- Handle channeling UI styles
    frame.castingBar:SetFillStyle(spellCastType == "channel" and "REVERSE" or "STANDARD");
    frame.castingBar.Spark:SetPoint("CENTER", frame.castingBar:GetStatusBarTexture(),
        spellCastType == "channel" and "LEFT" or "RIGHT", 0, 0);

    local spellCastTime = (endTime and startTime) and (endTime - startTime) or 0;
    frame.castingBar:SetMinMaxValues(0, 100);
    frame.castingBar:SetValue(0);
    frame.castingBar:SetAlpha(1);
    frame.castingBar:StartAnimation(0, 100, spellCastTime / 1000, function(value)
        frame.castingBar:SetValue(value);
    end, function()
        frame.castingBar:SetAlpha(0);
    end);
    if spellCastTime == 0 then
        frame.castingBar:SetAlpha(0);
    end

    for i = 1, #self.frame.framePool do
        if (i ~= frameIndex and self.frame.framePool[i].order ~= 0) then
            local newOrder = self.frame.framePool[i].order + 1 > #self.frame.framePool - 1 and 0 or
                                 self.frame.framePool[i].order + 1;
            self.frame.framePool[i].order = newOrder;
            local y = -20 * (self.frame.framePool[i].order - 1);
            local currentY = select(5, self.frame.framePool[i]:GetPoint());
            self.frame.framePool[i]:StartAnimation(currentY, y, 0.2, function(value)
                self.frame.framePool[i]:SetPoint("TOPLEFT", 0, value);
            end)

            -- self.frame.framePool[i].orderText:SetText(newOrder);

            if newOrder == 0 then
                self.frame.framePool[i]:SetAlpha(0);
                self.frame.framePool[i].logData = nil;
            end
        end
    end

    -- Sort the frame pool by order
    -- table.sort(self.frame.framePool, function(a, b)
    --     return a.order < b.order;
    -- end);
    return frame
end

function CT:FindTargetFrameByEvent(eventType, castGUID, spellId, targetCastType)
    local outputFrame = nil;
    local index = -1;
    local numberOfFrames = #self.frame.framePool;
    for i = 1, numberOfFrames do
        local frame = self.frame.framePool[i];
        if (frame.logData ~= nil and frame.logData.eventType == eventType and
            (frame.logData.castGUID == castGUID or frame.logData.spellId == spellId or frame.logData.spellName ==
                spellId)) then
            if not targetCastType or (targetCastType and frame.logData.spellCastType == targetCastType) then
                if (index == -1 or frame.order < outputFrame.order) then
                    outputFrame = frame;
                    index = i;
                end
            end
        end
    end
    return outputFrame, index;
end

function CT:HandleCastFailedEvent(castGUID, spellID, spellCastType)
    -- Find the failed cast event in the frame pool
    local frame, index = CT:FindTargetFrameByEvent("SPELL_CAST_START", castGUID, spellID, spellCastType);
    if frame then
        frame.logData.eventType = "SPELL_CAST_FAILED";
        frame.castingBar:StopAnimation();
        frame.castingBar:SetValue(0);
        frame.castingBar:SetAlpha(0);
        frame:SetAlpha(0.5);
    end
end

function CT:HandleCastSuccessEvent(castGUID, spellID, shouldStopAnimation, spellCastType)
    -- Find the failed cast event in the frame pool
    local frame = CT:FindTargetFrameByEvent("SPELL_CAST_START", castGUID, spellID, spellCastType);
    if frame then
        if shouldStopAnimation then
            frame.castingBar:StopAnimation();
            frame.castingBar:SetAlpha(0);
        end
        frame.castingBar:SetValue(100);
        frame.logData.eventType = "SPELL_CAST_SUCCESS";
    else
        frame = CT:HandleStartCastEvent(castGUID, spellID, spellCastType);
        if frame then
            frame.logData.eventType = "SPELL_CAST_SUCCESS";
        end
    end
end

function CT:HandleSpellDamageEvent(spellName, spellSchool, amount, isCritical, destGUID, destName)
    local frame = CT:FindTargetFrameByEvent("SPELL_CAST_SUCCESS", nil, spellName);
    if frame then
        frame.logData.amount = frame.logData.amount + amount;
        if not tContains(frame.logData.destGUIDs, destGUID) then
            tinsert(frame.logData.destGUIDs, destGUID);
        end
        local spellColor = GetSpellSchoolColor(spellSchool);
        frame.damageText:SetTextColor(spellColor.r, spellColor.g, spellColor.b, 1);
        frame.damageText:SetText(frame.logData.amount);
        if #frame.logData.destGUIDs > 1 then
            local text = " -> " .. destName .. " + " .. #frame.logData.destGUIDs - 1;
            frame.generalInfoText:SetText(text);
        end
        if isCritical then
            frame.damageText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE,THICK");
        end
    end
end

function CT:HandleSpellHealEvent(spellName, spellSchool, amount, isCritical, destGUID, destName)
    local frame = CT:FindTargetFrameByEvent("SPELL_CAST_SUCCESS", nil, spellName);
    if frame then
        frame.logData.healAmount = frame.logData.healAmount + amount;
        if not tContains(frame.logData.destGUIDs, destGUID) then
            tinsert(frame.logData.destGUIDs, destGUID);
        end
        if frame.logData.amount > 0 then
            frame.damageText:SetPoint("RIGHT", frame.healText, "LEFT", -1, 0);
            frame.healText:SetFont(frame.healText:GetFont(), 10, "OUTLINE");
        else
            frame.damageText:SetPoint("RIGHT", frame, "RIGHT", -5, 0);
            frame.healText:SetFont(frame.healText:GetFont(), 12, "OUTLINE");
        end
        frame.healText:SetText(frame.logData.healAmount);
        if #frame.logData.destGUIDs > 1 then
            local text = " -> " .. destName .. " + " .. #frame.logData.destGUIDs - 1;
            frame.generalInfoText:SetText(text);
        end
    end
end

local FILTERED_SPELL_ID_LIST = {397374}

function CT:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID,
            destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted,
            blocked, absorbed, critical = CombatLogGetCurrentEventInfo();
        -- if (eventType == "SPELL_CAST_START") then
        --     if (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
        --         local frameIndex = CT:FindNextAvailableLogIndex();
        --         destGUID = UnitGUID("target");
        --         destName = UnitName("target");
        --         CT:HandleStartCastEvent(frameIndex, spellId, destGUID, destName, "cast");
        --     end
        -- end

        -- if (eventType == "SPELL_CAST_FAILED") then
        --     if (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
        --         CT:HandleCastFailedEvent(spellId, destGUID);
        --     end
        -- end

        -- if (eventType == "SPELL_CAST_SUCCESS") then
        --     if (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
        --         CT:HandleCastSuccessEvent(spellId, spellName, destGUID, destName, false);
        --     end
        -- end

        if (eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE") then
            if (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
                CT:HandleSpellDamageEvent(spellName, spellSchool, amount, critical, destGUID, destName);
            end
        end

        if (eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL") then
            if (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
                CT:HandleSpellHealEvent(spellName, spellSchool, amount, critical, destGUID, destName);
            end
        end
    end
    if event == "UNIT_SPELLCAST_SENT" then
        local unit, target, castGUID, spellID = ...;
        if unit == "player" and (not tContains(FILTERED_SPELL_ID_LIST, spellID)) then
            local frameIndex = CT:FindNextAvailableLogIndex();
            CT:HandleSpellSentEvent(frameIndex, castGUID, spellID, target);
        end
    end

    if event == "UNIT_SPELLCAST_START" then
        local unit, castGUID, spellID = ...;
        if unit == "player" then
            CT:HandleStartCastEvent(castGUID, spellID, "cast");
        end
    end

    if event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, castGUID, spellID = ...;
        if unit == "player" then
            CT:HandleCastFailedEvent(castGUID, spellID);
        end
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellID = ...;
        if unit == "player" and (not tContains(FILTERED_SPELL_ID_LIST, spellID)) then
            local shouldStopAnimation = true
            local name, startTimeMS, endTimeMS, castID = UnitChannelInfo("player");
            if castID ~= nil then
                shouldStopAnimation = false
            end
            CT:HandleCastSuccessEvent(castGUID, spellID, shouldStopAnimation);
        end
    end

    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, castGUID, spellID = ...;
        if unit == "player" then
            local frameIndex = CT:FindNextAvailableLogIndex();
            CT:HandleStartCastEvent(frameIndex, spellID, nil, nil, "channel");
        end
    end

    if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit, castGUID, spellID, success = ...;
        if unit == "player" then
            CT:HandleCastFailedEvent(spellID, nil);
        end
    end

    if event == "UNIT_SPELLCAST_EMPOWER_START" then
        local unit, castGUID, spellID = ...;
        if unit == "player" then
            CT:HandleStartCastEvent(castGUID, spellID, "empower");
        end
    end

    if event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local unit, castGUID, spellID, success = ...;
        if unit == "player" then
            if success then
                CT:HandleCastSuccessEvent(castGUID, spellID, true, "empower");
            else
                CT:HandleCastFailedEvent(castGUID, spellID, "empower");
            end
        end
    end
end

function CT:ToggleEditMode(value)
    if value then
        local frame = self.frame;
        self:ToggleBackground(false)
        frame:SetAlpha(1);
        frame.editModeFrameMask:Show()
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetResizable(true)
        frame.resizeButton:Show()
    else
        local frame = self.frame;
        frame.editModeFrameMask:Hide()
        frame:EnableMouse(false)
        frame:SetMovable(false)
        frame:SetResizable(false)
        frame.resizeButton:Hide()
        if PDD.db.profile.combatText.showBackground then
            self:ToggleBackground(true);
        end
        if not PDD.db.profile.combatText.enable then
            self:Toggle(false);
        end
    end
end

PDD:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    CT:PLAYER_REGEN_DISABLED();
    CT.playerInCombat = true;
end);

PDD:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    CT:PLAYER_REGEN_ENABLED();
    CT.playerInCombat = false;
end);

function CT:PLAYER_REGEN_DISABLED(event, ...)
    if PDD.db.profile.combatText.autoHide then
        self.frame:Show();
    end
end

function CT:PLAYER_REGEN_ENABLED(event, ...)
    if PDD.db.profile.combatText.autoHide then
        self.frame:Hide();
    end
end

function CT:ToggleAutoHide(value)
    if value then
        if not CT.playerInCombat then
            self.frame:Hide();
        end
    else
        self.frame:Show();
    end
end
