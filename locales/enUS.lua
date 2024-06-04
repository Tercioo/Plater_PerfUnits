do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "enUS")
    local L = languageTable

L["INSTALL_FAIL"] = "Plater Performance Units plugin failed to install."
L["ADD_NPC_FAIL"] = "Failed to add the npc id."
L["PERF_UNIT_WHATISIT"] = "When a unit is considered a performance unit, the nameplate won't show cast bars, run scripts and mods."
L["ENTER_NPCID"] = "Enter the NPC ID"


------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table")@
end