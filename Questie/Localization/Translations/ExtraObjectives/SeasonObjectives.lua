---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local seasonObjectiveLocals = {
    ["Use the Rowboat to reach the eastern shore."] = { -- 79242
        ["ptBR"] = "Use o barco a remo para alcançar a margem leste.",
        ["ruRU"] = "Используйте лодку с веслами, чтобы добраться до восточного берега.",
        ["deDE"] = "Benutze das Ruderboot, um zur Ostküste zu gelangen.",
        ["koKR"] = false,
        ["esMX"] = "Usa el bote de remos para llegar a la orilla este.",
        ["enUS"] = true,
        ["frFR"] = "Utilisez la chaloupe pour atteindre la rive est.",
        ["esES"] = "Usa el bote de remos para llegar a la orilla este.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Drink the Squall-breakers Potion and talk to Nyse."] = { -- 79366
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Defeat enough enemies to call forth the Shadowy Figure and talk to her to receive a Mote of Darkness."] = { -- 79982
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Besiege genug Feinde, um die Schattenhafte Gestalt herbeizurufen und sprich mit ihr, um einen Partikel der Dunkelheit zu erhalten.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Use the Holy Spring Water next to the Holy Spring, while you have two meditation buffs active. Then loot the rune from the fountain."] = { -- 79731
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Benutze das Wasser der Heiligen Quelle neben der Heiligen Quelle, während du zwei Meditation-Buffs aktiv hast. Plündere dann die Rune aus dem Brunnen.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Alyssian Windcaller to the Dream Portal"] = { -- 81783
        ["ptBR"] = "Escolte Alíssian Clamaventos até o portal para o Sonho Esmeralda.",
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = "Escolta a Alyssian Clamavientos al portal del Sueño Esmeralda.",
        ["enUS"] = true,
        ["frFR"] = "Escortez Imploratrice céleste Alyssian jusqu'au portail du Rêve d'émeraude.",
        ["esES"] = "Escolta a Alyssian Clamavientos al portal al Sueño Esmeralda.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Doran Dreambough to the Dream Portal"] = { -- 81784
        ["ptBR"] = "Escolte Doran Ramonírico até o portal para o Sonho Esmeralda.",
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = "Escolta a Doran Onirirrama al portal del Sueño Esmeralda.",
        ["enUS"] = true,
        ["frFR"] = "Escortez Doran Branchonirique jusqu'au portail du Rêve d'émeraude.",
        ["esES"] = "Escolta a Doran Ramaoniria al portal al Sueño Esmeralda.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Maseara Autumnmoon to the Dream Portal"] = { -- 81785
        ["ptBR"] = "Escolte Maseara Lunautumna até o portal para o Sonho Esmeralda.",
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = "Escolta a Maseara Lunaotoño al portal del Sueño Esmeralda.",
        ["enUS"] = true,
        ["frFR"] = "Escortez Maseara Lune-d'Automne jusqu'au portail du Rêve d'émeraude.",
        ["esES"] = "Escolta a Maseara Lunaotoñal al portal al Sueño Esmeralda.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Kroll Mountainshade to the Dream Portal"] = { -- 81745
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Alara Grovemender to the Dream Portal"] = { -- 81746
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Elenora Marshwalker to the Dream Portal"] = { -- 81747
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Mellias Earthtender to the Dream Portal"] = { -- 81872
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Nerene Brooksinger to the Dream Portal"] = { -- 81873
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Jamniss Treemender to the Dream Portal"] = { -- 81874
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Elianar Shadowdrinker to the Dream Portal"] = { -- 81850
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Serlina Starbright to the Dream Portal"] = { -- 81851
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Escort Veanna Cloudsleeper to the Dream Portal"] = { -- 81852
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Talk to the Injured Gnome"] = { -- 82022
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Swim south till you reach a small island. You need to use your Guided Buoyancy Accelerant or any other swim speed increase."] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Schwimme südlich bis du eine kleine Insel erreichst. Du musst deinen Gelenkter Auftriebbeschleuniger oder Ähnliches verwenden.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Teleport to either Westfall (Alliance) or Tirisfal Glades (Horde)."] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Teleportiere entweder nach Westfall (Allianz) oder Tirisfal Glades (Horde).",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Form a proper group and click on the Console to summon Harvest Golem V000-A."] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Bilde eine geeignete Gruppe und klicke auf die Konsole, um Erntegolem V000-A zu beschwören.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Keep up Disarm and Demoralizing Shout to greatly reduce the damage of the golem."] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Halte Entwaffnen und Demoralisierender Ruf aufrecht, um den Schaden des Golems enorm zu reduzieren.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Phase 1: Interrupt"] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Phase 1: Unterbrechen",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Phase 2: Kite"] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Phase 2: Kiten",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Phase 3: Use Shield Wall and survive"] = {
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Phase 3: Schildwall ziehen und überlegen.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
}

for k, v in pairs(seasonObjectiveLocals) do
    l10n.translations[k] = v
end