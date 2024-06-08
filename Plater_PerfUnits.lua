
---@class performanceunits_plugin
---@field UniqueName string
---@field Name string
---@field Frame performanceunits_frame
---@field Icon string
---@field OnEnable fun()
---@field OnDisable fun()

---@class performanceunits_settings

---@class performanceunits_frame : frame
---@field GridScrollBox df_gridscrollbox

---@class performanceunits_grid_button : df_button
---@field IconTexture df_image
---@field NpcNameLabel df_label
---@field NpcIdLabel df_label
---@field HighlightTexture texture
---@field CloseButton df_button

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

--unique name of the plugin, this will tell Plater if the plugin is already installed
local uniqueName = "PERFORMANCE_UNITS_PLUGIN"
--localized name of the plugin, this is shown in the plugin list on Plater
local pluginName = "Performance Units"
--create a frame, this frame will be attached to the plugins tab on Plater, all plugins for Plater require a frame object in the .Frame member
local frameName = "Plater_PerfUnitsFrame"

local roundedInformatioFrameSettings = {
    centerOffset = -40,
    height = 32,
    paddingFromTop = -10,
}

local removeButtonSize = 20
local highlightTextureAlpha = 0.1
local buttonHighlightTexture = [[Interface\AddOns\Plater_PerfUnits\assets\textures\button-highlight.png]]

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

    platerPerfUnits.FillNameCache()
    
    frame:SetScript("OnShow", platerPerfUnits.CreatePluginWidgets)
end

-- translation and helpers
local npcNameCache = {}
function platerPerfUnits.FillNameCache()
    local maxPerFrame = 10
    local translateTimer = 0.1
    
    local function GetCreatureNameFromID(npcID)
        if C_TooltipInfo then
            local info = C_TooltipInfo.GetHyperlink(("unit:Creature-0-0-0-0-%d"):format(npcID))
            local leftText = info and info.lines and info.lines[1] and info.lines[1].leftText
            if leftText and leftText ~= _G.UNKNOWN then
                return leftText
            end
        else
            local tooltipFrame = GetCreatureNameFromIDFinderTooltip or CreateFrame ("GameTooltip", "GetCreatureNameFromIDFinderTooltip", nil, "GameTooltipTemplate")
            tooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
            tooltipFrame:SetHyperlink (("unit:Creature-0-0-0-0-%d"):format(npcID))
            local npcNameLine = _G ["GetCreatureNameFromIDFinderTooltipTextLeft1"]
            return npcNameLine and npcNameLine:GetText()
        end
    end
    
    local fill_npc_name_cache
    fill_npc_name_cache	= function()
        if InCombatLockdown() then
            C_Timer.After(5, fill_npc_name_cache)
            return
        end
        
        local count = 0
        local leftOvers = true -- late init for perf units
        local npcDatabase = Plater.db.profile.npc_cache
        for id, _ in pairs(Plater.PerformanceUnits) do
            leftOvers = false
            local entry = npcDatabase[id]
            if (not entry or not entry[3]) or not npcNameCache[id] then
                count = count + 1
                local npcName = GetCreatureNameFromID(id)
                if npcName then
                    npcNameCache[id] = npcName
                else
                    leftOvers = true -- could not be translated
                end
            end
            
            if count >= maxPerFrame then
                leftOvers = true
                break
            end
        end
        
        if leftOvers then
            C_Timer.After(translateTimer, fill_npc_name_cache)
        end
        
        local pluginFrame = platerPerfUnits:GetPluginFrame()
        if pluginFrame and pluginFrame.GridScrollBox then
            pluginFrame.GridScrollBox:RefreshMe()
        end
    end
    fill_npc_name_cache()
end

function platerPerfUnits.CreatePluginWidgets()
    if (not platerPerfUnits.createdFrames) then
        platerPerfUnits.createdFrames = true
    else
        local pluginFrame = platerPerfUnits:GetPluginFrame()
        pluginFrame.GridScrollBox:RefreshMe()
        return
    end

    local pluginFrame = platerPerfUnits:GetPluginFrame()
    local width, height = pluginFrame:GetSize()

    --create a rounded block in the top of the frame informing what a performance unit is
    local roundedInformationFrame = CreateFrame("frame", "$parentRoundedInfoFrame", pluginFrame)
    roundedInformationFrame:SetSize(width + roundedInformatioFrameSettings.centerOffset, roundedInformatioFrameSettings.height)
    roundedInformationFrame:SetPoint("top", pluginFrame, "top", 0, roundedInformatioFrameSettings.paddingFromTop)
    --add rounded corners to the frame
    detailsFramework:AddRoundedCornersToFrame(roundedInformationFrame, roundedFramePreset)
    --create a label to show te information text
    local bShouldRegister = true
    local locTable = detailsFramework.Language.CreateLocTable(addonId, "PERF_UNIT_WHATISIT", bShouldRegister)
    local informationLabel = detailsFramework:CreateLabel(roundedInformationFrame, locTable, 12, "orange")
    informationLabel:SetPoint("center", roundedInformationFrame, "center", 0, 0)

    --create a rounded text entry for npcId input
    local entryLabel = detailsFramework:CreateLabel(pluginFrame, detailsFramework.Language.CreateLocTable(addonId, "ENTER_NPCID", bShouldRegister))
    entryLabel:SetPoint("topleft", roundedInformationFrame, "bottomleft", 0, -10)
    local npcIDTextEntry = detailsFramework:CreateTextEntry(pluginFrame, function()end, 174, 32, "")
    npcIDTextEntry:SetPoint("topleft", entryLabel, "bottomleft", 0, -2)
    npcIDTextEntry:SetTextInsets(5, 5, 0, 0)
    npcIDTextEntry.align = "left"
    npcIDTextEntry:SetBackdropColor(0, 0, 0, 0)
    npcIDTextEntry:SetBackdropBorderColor(0, 0, 0, 0)
    npcIDTextEntry:SetScript("OnEnter", nil)
    npcIDTextEntry:SetScript("OnLeave", nil)
    local file, size, flags = npcIDTextEntry:GetFont()
    npcIDTextEntry:SetFont(file, 12, flags)
    detailsFramework:AddRoundedCornersToFrame(npcIDTextEntry.widget, roundedFramePreset)

    --function to be called when the user click on the add button
    local addNpcIDCallback = function()
        local npcId = tonumber(npcIDTextEntry:GetText())
        if (not npcId) then
            print(LOC.ADD_NPC_FAIL)
            return
        end
        Plater.AddPerformanceUnits(npcId)
        platerPerfUnits.FillNameCache()
        npcIDTextEntry:SetText("")
        pluginFrame.GridScrollBox:RefreshMe()
    end

    local removeNpcIDCallback = function(dfButton, button, npcId)
        if (not npcId) then
            return
        end
        Plater.RemovePerformanceUnits(npcId)
        pluginFrame.GridScrollBox:RefreshMe()
    end

    --create a button to add the npcId to the list
    local addNpcButton = detailsFramework:CreateButton(pluginFrame, addNpcIDCallback, 60, 32, "Add")
    addNpcButton:SetPoint("left", npcIDTextEntry, "right", 5, 0)
    detailsFramework:AddRoundedCornersToFrame(addNpcButton.widget, roundedFramePreset)

    --create the scroll to display the npcs added into the performance list

    ---@type df_button[]
    local allGridFrameButtons = {}

    --grid scroll box to display the npcs already in the list
    ---@type df_gridscrollbox_options
    local gridScrollBoxOptions = {
        width = width - 49,
        height = height - 116,
        line_amount = 13, --amount of horizontal lines
        line_height = 32,
        columns_per_line = 5,
        vertical_padding = 5,
    }

    ---when the scroll is refreshing the line, the line will call this function for each selection button on it
    ---@param dfButton performanceunits_grid_button
    ---@param npcId number
    local refreshNpcButtonInTheGrid = function(dfButton, npcId)
        dfButton.NpcIdLabel.text = tostring(npcId)

        local npcData = Plater.db.profile.npc_cache[npcId]
        if (npcData) then
            dfButton.NpcNameLabel.text = npcData[1] --[1] npc name [2] location name [3] language
        else
            dfButton.NpcNameLabel.text = npcNameCache[npcId] or _G.UNKNOWN
        end

        dfButton.CloseButton:SetClickFunction(removeNpcIDCallback, npcId)

        --print("npcData", npcData, npcData and npcData[1])
    end
    
    local npc3DFrame = CreateFrame ("playermodel", "", nil, "ModelWithControlsTemplate")
    npc3DFrame:SetSize (200, 250)
    npc3DFrame:EnableMouse (false)
    npc3DFrame:EnableMouseWheel (false)
    npc3DFrame:Hide()
    
    --when the user hover over an npc button
    local onenter_npc_button = function (self, _)
        local npcID = tonumber(self.MyObject.NpcIdLabel.text)
        if npcID then
            GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink (("unit:Creature-0-0-0-0-%d"):format(npcID))
            GameTooltip:AddLine (" ")
            if Plater.db.profile.npc_cache[npcID] then
                GameTooltip:AddLine (Plater.db.profile.npc_cache[npcID][2] or "???")
                GameTooltip:AddLine (" ")
            end
            npc3DFrame:SetCreature(npcID)
            npc3DFrame:SetParent(GameTooltip)
            npc3DFrame:SetPoint ("top", GameTooltip, "bottom", 0, -10)
            npc3DFrame:Show()
            GameTooltip:Show()
        end
        --self:SetBackdropColor (.3, .3, .3, 0.7)
    end

    --when the user leaves an npc button from a hover over
    local onleave_npc_button = function (self)
        npc3DFrame:SetParent(nil)
        npc3DFrame:ClearAllPoints()
        npc3DFrame:Hide()
        GameTooltip:Hide()
        --self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
    end

    --each line has more than 1 selection button, this function creates these buttons on each line
    local createNpcButton = function(line, lineIndex, columnIndex)
        local buttonWidth = gridScrollBoxOptions.width / gridScrollBoxOptions.columns_per_line - 5
        local buttonHeight = gridScrollBoxOptions.line_height
        if (not buttonHeight) then
            buttonHeight = 30
        end

        --create the button
        ---@type performanceunits_grid_button
        local button = detailsFramework:CreateButton(line, function()end, buttonWidth, buttonHeight)
        detailsFramework:AddRoundedCornersToFrame(button.widget, roundedFramePreset)
        button.textsize = 11

        --create an icon
        local iconTexture = detailsFramework:CreateTexture(button, [[Interface\ICONS\INV_MouseHearthstone]], buttonHeight - 6, buttonHeight - 6, "artwork")
        detailsFramework:SetMask(iconTexture, [[Interface\AddOns\Plater_PerfUnits\assets\textures\rounded-mask.png]])
        iconTexture:SetPoint("left", button, "left", 2, 0)
        iconTexture:SetTexCoord(0.9, 0.1, 0.1, 0.9)

        --create a label for the npc name
        local npcNameLabel = detailsFramework:CreateLabel(button, "", "ORANGE_FONT_TEMPLATE")
        npcNameLabel:SetPoint("left", iconTexture, "right", 5, 5)

        --create a label for the npcId
        local npcIdLabel = detailsFramework:CreateLabel(button, "", "SMALL_SILVER")
        npcIdLabel:SetPoint("left", iconTexture, "right", 5, -5)

        --create a close button to represent the remove button
        local closeButton = detailsFramework:CreateButton(button, removeNpcIDCallback, removeButtonSize, removeButtonSize, "X")
        closeButton:SetPoint("right", button, "right", 0, 0)

        --create a highlight texture for the button
        local highlightTexture = button:CreateTexture("$parentHighlight", "highlight")
        highlightTexture:SetAlpha(highlightTextureAlpha)
        highlightTexture:SetTexture(buttonHighlightTexture)
        highlightTexture:SetAllPoints()

        button.IconTexture = iconTexture
        button.NpcNameLabel = npcNameLabel
        button.NpcIdLabel = npcIdLabel
        button.HighlightTexture = highlightTexture
        button.CloseButton = closeButton
        
        button:SetScript ("OnEnter", onenter_npc_button)
        button:SetScript ("OnLeave", onleave_npc_button)

        --add the button into a list of buttons created
        allGridFrameButtons[#allGridFrameButtons+1] = button
        return button
    end

    local tbdData = {}
    local gridScrollBox = detailsFramework:CreateGridScrollBox(pluginFrame, "$parentNpcsAdded", refreshNpcButtonInTheGrid, tbdData, createNpcButton, gridScrollBoxOptions)
    pluginFrame.GridScrollBox = gridScrollBox
    gridScrollBox:SetPoint("topleft", npcIDTextEntry.widget, "bottomleft", 0, -10)
    gridScrollBox:SetBackdrop({})
    gridScrollBox:SetBackdropColor(0, 0, 0, 0)
    gridScrollBox:SetBackdropBorderColor(0, 0, 0, 0)
    gridScrollBox.__background:Hide()
    gridScrollBox:Show()

    --create a search bar to filter the auras
    local searchText = ""

    local onSearchTextChangedCallback = function(self, ...)
        local text = self:GetText()
        searchText = string.lower(text)
        gridScrollBox:RefreshMe()
    end

    local searchBox = detailsFramework:CreateTextEntry(pluginFrame, onSearchTextChangedCallback, 220, 26)
    searchBox:SetPoint("topright", roundedInformationFrame, "bottomright", 0, -35)
    searchBox:SetAsSearchBox()
    searchBox:SetTextInsets(25, 5, 0, 0)
    searchBox:SetBackdrop(nil)
    searchBox:SetHook("OnTextChanged", onSearchTextChangedCallback)
    local file, size, flags = searchBox:GetFont()
    searchBox:SetFont(file, 12, flags)
    searchBox.ClearSearchButton:SetAlpha(0)

    searchBox.BottomLineTexture = searchBox:CreateTexture(nil, "border")
    searchBox.BottomLineTexture:SetPoint("bottomleft", searchBox.widget, "bottomleft", -15, 0)
    searchBox.BottomLineTexture:SetPoint("bottomright", searchBox.widget, "bottomright", 0, 0)
    searchBox.BottomLineTexture:SetAtlas("common-slider-track")
    searchBox.BottomLineTexture:SetHeight(8)

    function gridScrollBox:RefreshMe()
        --transform the hash table into an array
        local listOfNpcs = {}

        if (searchText ~= "") then
            local npcDatabase = Plater.db.profile.npc_cache
            for npcId in pairs(Plater.PerformanceUnits) do
                local npcData = npcDatabase[npcId]
                if (npcData and string.find(string.lower(npcData[1]), searchText)) then
                    listOfNpcs[#listOfNpcs+1] = npcId
                end
            end
        else
            for npcId in pairs(Plater.PerformanceUnits) do
                listOfNpcs[#listOfNpcs+1] = npcId
            end
        end

        gridScrollBox:SetData(listOfNpcs)
        gridScrollBox:Refresh()
    end

    --do the first refresh
    gridScrollBox:RefreshMe()
end