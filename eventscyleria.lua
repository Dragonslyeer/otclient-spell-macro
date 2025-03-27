local spells = {
    ['knight'] = 'Exori hur',
    ['elite knight'] = 'inception',
    ['sorcerer'] = 'Exori frigo',
    ['master sorcerer'] = 'arcane fire',
    ['paladin'] = 'Exori san',
    ['royal paladin'] = 'dark illusion',
    ['druid'] = 'Exori frigo',
    ['elder druid'] = 'demonic surge'
}

local vocationColors = {
    ['knight'] = '#A52A2A', -- Brązowy
    ['elite knight'] = '#8B0000', -- Ciemnoczerwony
    ['sorcerer'] = '#FF0000', -- Czerwony
    ['master sorcerer'] = '#8B008B', -- Fioletowy
    ['paladin'] = '#FFFF00', -- Żółty
    ['royal paladin'] = '#FFD700', -- Złoty
    ['druid'] = '#008000', -- Zielony
    ['elder druid'] = '#006400' -- Ciemnozielony
}

local vocationList = {
    {name = "Knight", value = "knight"},
    {name = "Elite Knight", value = "elite knight"},
    {name = "Sorcerer", value = "sorcerer"},
    {name = "Master Sorcerer", value = "master sorcerer"},
    {name = "Paladin", value = "paladin"},
    {name = "Royal Paladin", value = "royal paladin"},
    {name = "Druid", value = "druid"},
    {name = "Elder Druid", value = "elder druid"}
}

local selectedVocation = storage.vocation or string.lower(player:getVocation())
local defaultSpell = spells[selectedVocation] or 'exura'
local spell = storage.spell or defaultSpell

local lastCastTime = 0
local targetMonsters = {
    "Rokita", "Boruta", "Bekart Wojny", "Earth Stone", "Ice Stone", 
    "Fire Stone", "Meteo", "Demoniczny Pomiot", "Tyran", "Clockwork",
    "Young Earth Stone", "Young Fire Stone", "Young Ice Stone",
    "Fardos", "Trener"
}

local panel = setupUI([[  
Panel  
  height: 100  
  layout:  
    type: verticalBox  
    fit-children: true  
  Label  
    id: vocLabel
    text: Wybierz profesje  
    text-align: center  
    margin-top: 6  
  ComboBox  
    id: playerVoc  
    height: 20  
    margin: 3  
]])

local playerVoc = panel:getChildById("playerVoc")
local vocLabel = panel:getChildById("vocLabel") -- Pobranie etykiety

for _, voc in ipairs(vocationList) do
    playerVoc:addOption(voc.name, voc.value)
end

local function updateColors()
    local color = vocationColors[selectedVocation] or '#FFFFFF' -- Domyślnie biały
    vocLabel:setColor(color) -- Zmiana koloru etykiety
end

playerVoc:setCurrentOptionByData(selectedVocation) -- ✅ Ustawia zapamiętaną profesję w ComboBox
updateColors() -- ✅ Aktualizuje kolor od razu po załadowaniu

playerVoc.onOptionChange = function(widget)
    storage.vocation = widget:getCurrentOption().data
    selectedVocation = storage.vocation
    spell = spells[selectedVocation] or 'exura'
    storage.spell = spell
    updateColors()
end

addTextEdit("spell", storage.spell or defaultSpell, function(widget, text)
    storage.spell = text
    spell = text
end)

macro(50, "EVENTY", function()
    if isInPz() then return end
    if os.time() - lastCastTime < 0.2 then return end

    local validMonsters = {}
    local currentTarget = g_game.getAttackingCreature()

    for _, creature in ipairs(getSpectators()) do
        if creature:isMonster() then
            local creatureName = creature:getName()
            for _, targetName in ipairs(targetMonsters) do
                if creatureName == targetName then
                    table.insert(validMonsters, creature)
                    break
                end
            end
        end
    end

    if #validMonsters > 0 then
        local weakest = validMonsters[1]
        for _, mob in ipairs(validMonsters) do
            if mob:getHealthPercent() < weakest:getHealthPercent() then
                weakest = mob
            end
        end
        
        if not currentTarget or currentTarget:getId() ~= weakest:getId() then
            g_game.attack(weakest)
        end
        
        say(spell)
        lastCastTime = os.time()
    end
end)
