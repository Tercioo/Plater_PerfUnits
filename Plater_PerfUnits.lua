
---@class performanceunits_plugin
---@field UniqueName string
---@field Name string
---@field Frame performanceunits_frame
---@field Icon string
---@field OnEnable fun()
---@field OnDisable fun()

---@class performanceunits_settings

---@class performanceunits_frame : frame

---@class platerperfunits : table
---@field createdFrames boolean
---@field pluginObject performanceunits_plugin
---@field OnLoad fun(self:platerperfunits, profile:performanceunits_settings)
---@field OnInit fun(self:platerperfunits, profile:performanceunits_settings)
---@field GetPluginObject fun(self:platerperfunits):performanceunits_plugin
---@field GetPluginFrame fun(self:platerperfunits):performanceunits_frame

local addonId, pPU = ...
local _ = nil

local Plater = _G.Plater
---@type detailsframework
local detailsFramework = DetailsFramework
local _

--localization
local LOC = detailsFramework.Language.GetLanguageTable(addonId)

--rounded frame preset
local roundedFramePreset = {
    color = {.075, .075, .075, 1},
    border_color = {.2, .2, .2, 1},
    roundness = 8,
}


---@type performanceunits_settings
local defaultSettings = {}

local platerPerfUnits = detailsFramework:CreateNewAddOn(addonId, "PlaterPerfUnitsDB", defaultSettings)

function platerPerfUnits.OnLoad(self, profile) --fired at ADDON_LOADED

end

function platerPerfUnits.GetPluginObject(self)
    return self.pluginObject
end

function platerPerfUnits.GetPluginFrame(self)
    return self:GetPluginObject().Frame
end

function platerPerfUnits.OnInit(self, profile) --fired at PLAYER_LOGIN
    --unique name of the plugin, this will tell Plater if the plugin is already installed
    local uniqueName = "PERFORMANCE_UNITS_PLUGIN"

    --localized name of the plugin, this is shown in the plugin list on Plater
    local pluginName = "Performance Units"

    --create a frame, this frame will be attached to the plugins tab on Plater, all plugins for Plater require a frame object in the .Frame member
    local frameName = "Plater_PerfUnitsFrame"
    local frameParent = UIParent
    ---@type performanceunits_frame
    local frame = CreateFrame("frame", frameName)

    --this function will run when the user click the checkbox to enable the plugin
    local onEnable = function(pluginUniqueName)

    end

    --this function will run when the user click the checkbox to disable the plugin
    local onDisable = function(pluginUniqueName)

    end

    --craete a table to host all functions, methods and members for the plugin, this table then is sent to Plater to install the plugin
    ---@type performanceunits_plugin
    local ppuObject = {
        Icon = [[]],
        UniqueName = uniqueName,
        Name = pluginName,
        Frame = frame,
        OnEnable = onEnable,
        OnDisable = onDisable
    }

    platerPerfUnits.pluginObject = ppuObject

    local bIsSilent = false
    local bInstallSuccess = Plater.InstallPlugin(ppuObject, bIsSilent)

    if (not bInstallSuccess) then
        print(LOC.INSTALL_FAIL)
    end

    frame:SetScript("OnShow", platerPerfUnits.CreatePluginWidgets)
end

function platerPerfUnits.CreatePluginWidgets()
    if (not platerPerfUnits.createdFrames) then
        platerPerfUnits.createdFrames = true
    else
        return
    end

    local pluginFrame = platerPerfUnits:GetPluginFrame()

    local paddingFromTop = -10
    local width, height = pluginFrame:GetSize()

    --create a rounded block in the top of the frame informing what a performance unit is
    local roundedInformationFrame = CreateFrame("frame", "$parentRoundedInfoFrame", pluginFrame)
    roundedInformationFrame:SetSize(width - 40, 40)
    roundedInformationFrame:SetPoint("top", pluginFrame, "top", 0, paddingFromTop)
    --add rounded corners to the frame
    detailsFramework:AddRoundedCornersToFrame(roundedInformationFrame, roundedFramePreset)

    --create a label to show te information text
    local bShouldRegister = true
    local locTable = detailsFramework.Language.CreateLocTable(addonId, "PERF_UNIT_WHATISIT", bShouldRegister)
    local informationLabel = detailsFramework:CreateLabel(roundedInformationFrame, locTable, 12, "orange")
    informationLabel:SetPoint("center", roundedInformationFrame, "center", 0, 0)


end