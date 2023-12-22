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
    childGroups = "tab",
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
            order = 1,
            args = {
                toggles = {
                    type = "group",
                    name = "",
                    inline = true,
                    args = {
                        frameAlpha = {
                            type = "range",
                            name = L["frameAlpha"],
                            desc = L["frameAlphaDesc"],
                            order = 2,
                            min = 0,
                            max = 1,
                            step = 0.01,
                            get = function()
                                return PDD.db.profile.combatText.frameAlpha or 1
                            end,
                            set = function(info, value)
                                PDD.db.profile.combatText.frameAlpha = value
                                core.CT:UpdateFrameAlpha(value)
                            end
                        },
                        toggle = {
                            type = "toggle",
                            name = L["enable"],
                            width = "full",
                            order = 1,
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
                            order = 3,
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
        },
        fontSettings = {
            type = "group",
            name = L["fontSettings"],
            order = 2,
            args = {
                fontColor = {
                    type = "color",
                    name = L["fontColor"],
                    desc = L["fontColorDesc"],
                    order = 2,
                    get = function()
                        return PDD.db.profile.combatText.fontColor.r, PDD.db.profile.combatText.fontColor.g,
                            PDD.db.profile.combatText.fontColor.b, PDD.db.profile.combatText.fontColor.a
                    end,
                    set = function(info, r, g, b, a)
                        PDD.db.profile.combatText.fontColor.r = r
                        PDD.db.profile.combatText.fontColor.g = g
                        PDD.db.profile.combatText.fontColor.b = b
                        PDD.db.profile.combatText.fontColor.a = a
                        core.CT:UpdateFontColor(r, g, b, a)
                    end
                },
                damageTextColorOptions = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 3,
                    args = {
                        damageTextColor = {
                            type = "color",
                            name = L["damageTextColor"],
                            desc = L["damageTextColorDesc"],
                            disabled = function()
                                return PDD.db.profile.combatText.damageTextColor.useDamageTypeColor
                            end,
                            get = function()
                                return PDD.db.profile.combatText.damageTextColor.r,
                                    PDD.db.profile.combatText.damageTextColor.g,
                                    PDD.db.profile.combatText.damageTextColor.b,
                                    PDD.db.profile.combatText.damageTextColor.a
                            end,
                            set = function(info, r, g, b, a)
                                PDD.db.profile.combatText.damageTextColor.r = r
                                PDD.db.profile.combatText.damageTextColor.g = g
                                PDD.db.profile.combatText.damageTextColor.b = b
                                PDD.db.profile.combatText.damageTextColor.a = a
                                core.CT:UpdateDamageTextColor(false, r, g, b, a)
                            end
                        },
                        useDamageTypeColor = {
                            type = "toggle",
                            name = L["useDamageTypeColor"],
                            get = function()
                                return PDD.db.profile.combatText.damageTextColor.useDamageTypeColor
                            end,
                            set = function(info, value)
                                PDD.db.profile.combatText.damageTextColor.useDamageTypeColor = value
                                local r = PDD.db.profile.combatText.damageTextColor.r
                                local g = PDD.db.profile.combatText.damageTextColor.g
                                local b = PDD.db.profile.combatText.damageTextColor.b
                                local a = PDD.db.profile.combatText.damageTextColor.a
                                core.CT:UpdateDamageTextColor(value, r, g, b, a)
                            end
                        }
                    }
                },
                healTextColorSettings = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 4,
                    args = {
                        healTextColor = {
                            type = "color",
                            name = L["healTextColor"],
                            desc = L["healTextColor"],
                            get = function()
                                return PDD.db.profile.combatText.healTextColor.r,
                                    PDD.db.profile.combatText.healTextColor.g,
                                    PDD.db.profile.combatText.healTextColor.b, PDD.db.profile.combatText.healTextColor.a
                            end,
                            set = function(info, r, g, b, a)
                                PDD.db.profile.combatText.healTextColor.r = r
                                PDD.db.profile.combatText.healTextColor.g = g
                                PDD.db.profile.combatText.healTextColor.b = b
                                PDD.db.profile.combatText.healTextColor.a = a
                                core.CT:UpdateHealTextColor(r, g, b, a)
                            end
                        }
                    }
                },
                damageTextFontSettings = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 5,
                    args = {
                        damageTextFontSize = {
                            type = "range",
                            name = L["damageTextFontSize"],
                            order = 5,
                            min = 5,
                            max = 30,
                            step = 1,
                            get = function()
                                return PDD.db.profile.combatText.damageTextFontSize
                            end,
                            set = function(info, value)
                                PDD.db.profile.combatText.damageTextFontSize = value
                                core.CT:UpdateDamageTextFontSize(value)
                            end
                        },
                        criticalDamageTextFontSize = {
                            type = "range",
                            name = L["criticalDamageTextFontSize"],
                            order = 5,
                            min = 5,
                            max = 30,
                            step = 1,
                            get = function()
                                return PDD.db.profile.combatText.criticalDamageTextFontSize
                            end,
                            set = function(info, value)
                                PDD.db.profile.combatText.criticalDamageTextFontSize = value
                            end
                        }
                    }
                },
                healTextFontSize = {
                    type = "range",
                    name = L["healTextFontSize"],
                    order = 5,
                    min = 5,
                    max = 30,
                    step = 1,
                    get = function()
                        return PDD.db.profile.combatText.healTextFontSize
                    end,
                    set = function(info, value)
                        PDD.db.profile.combatText.healTextFontSize = value
                        core.CT:UpdateHealTextFontSize(value)
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
            yOfs = 0,
            showTargetName = true,
            showCastingAnimation = true,
            autoHide = true,
            frameAlpha = 1,
            fontColor = {
                r = 1,
                g = 1,
                b = 1,
                a = 1
            },
            damageTextColor = {
                useDamageTypeColor = true,
                r = 1,
                g = 1,
                b = 1,
                a = 1
            },
            healTextColor = {
                r = 0,
                g = 1,
                b = 0,
                a = 1
            },
            damageTextFontSize = 12,
            criticalDamageTextFontSize = 14,
            healTextFontSize = 12
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
