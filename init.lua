local _, core = ...; -- Namespace
local AceGUI = LibStub("AceGUI-3.0")
PDD = LibStub("AceAddon-3.0"):NewAddon("PDD", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PDD")
core.CT = {}
core.config = {};
PDD.options = {
    name = "Pro Damage Display",
    handler = PDD,
    type = "group",
    args = {
        editMode = {
            type = "toggle",
            name = L["editMode"],
            desc = L["editModeDesc"],
            get = "isEditMode",
            set = "setEditMode"
        },
        PDD = {
            type = "group",
            name = L["combatText"],
            args = {
                toggle = {
                    type = "toggle",
                    name = L["enable"],
                    get = function()
                        return PDD.db.profile.combatText.enable
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.enable = value
                        core.CT:Toggle(value)
                    end
                },
                showBackground = {
                    type = "toggle",
                    name = L["showBackground"],
                    get = function()
                        return PDD.db.profile.combatText.showBackground
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.showBackground = value
                        core.CT:ToggleBackground(value)
                    end
                },
                showTargetName = {
                    type = "toggle",
                    name = L["showTargetName"],
                    get = function()
                        return PDD.db.profile.combatText.showTargetName
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.showTargetName = value
                        core.CT:ToggleTargetName(value)
                    end
                },
                showCastingAnimation = {
                    type = "toggle",
                    name = L["showCastingAnimation"],
                    get = function()
                        return PDD.db.profile.combatText.showCastingAnimation
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.showCastingAnimation = value
                        core.CT:ToggleCastingAnimation(value)
                    end
                },
                autoHide = {
                    type = "toggle",
                    name = L["autoHide"],
                    desc = L["autoHideDesc"],
                    get = function()
                        return PDD.db.profile.combatText.autoHide
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.autoHide = value
                        core.CT:ToggleAutoHide(value)
                    end
                }
            }
        }
    }
}

local defaultConfigs = {
    profile = {
        savedFramePoints = {},
        combatText = {
            enable = true,
            showBackground = true,
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0
        }
    }
}

function SaveFramePoints(frame, type, name)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    PDD.db.profile.savedFramePoints[name] = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
        containerWidth = frame:GetWidth(),
        containerHeight = frame:GetHeight()
    }
end

function core:GetFramePoints(name)
    return PDD.db.profile.savedFramePoints[name]
end

SLASH_PDDOPTIONS1 = '/pdd';
function SlashCmdList.PDDOPTIONS(msg, editBox)
    InterfaceOptionsFrame_OpenToCategory("PDD");
    InterfaceOptionsFrame_OpenToCategory("PDD");
end

-- Setting Functions
function PDD:isEditMode()
    return core.isEditMode
end

function PDD:setEditMode(info, value)
    core.isEditMode = value

    if core.CT then
        core.CT:ToggleEditMode(value)
    end
end

function PDD:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PDDDB", defaultConfigs, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("PDD", PDD.options)
    SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
    SlashCmdList.RELOADUI = ReloadUI;
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PDD", "Pro Damage Display")

    core.CT:Initialize();
end

-- PDD:RegisterEvent("PLAYER_ENTERING_WORLD");
