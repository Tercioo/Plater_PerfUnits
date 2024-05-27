do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "enUS")
    local L = languageTable

L["INSTALL_FAIL"] = "Plater Performance Units plugin failed to install."
L["PERF_UNIT_WHATISIT"] = "When a unit is considered a performance unit, the nameplate won't show cast bars, run scripts and mods."

L["OPTIONS_"] = ""



------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table")@
end