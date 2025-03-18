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

local distance = tonumber(storage.distance) or 12
local lastCastTime = 0
local targetMonsters = {
    "Rokita",
    "Boruta",
    "Bekart Wojny",
    "Earth Stone",
    "Ice Stone",
    "Fire Stone",
    "Meteo",
    "Demoniczny Pomiot",
    "Tyran",
    "Clockwork",
    "Young Earth Stone",
    "Young Fire Stone",
    "Young Ice Stone",
    "Trener"
}

addTextEdit("distance", storage.distance or "12", function(widget, text)
    storage.distance = text
end)

local panel = setupUI([[  
Panel  
  height: 100  
  layout:  
    type: verticalBox  
    fit-children: true  
  Label  
    text: Wybierz profesję  
    text-align: center  
    margin-top: 6  
  ComboBox  
    id: playerVoc  
    height: 20  
    margin: 3  
]])

for _, voc in ipairs(vocationList) do
    panel.playerVoc:addOption(voc.name, voc.value)
end

panel.playerVoc:setCurrentOption(selectedVocation)
panel.playerVoc.onOptionChange = function(widget)
    storage.vocation = widget:getCurrentOption().data
    selectedVocation = storage.vocation
    spell = spells[selectedVocation] or 'exura'
    storage.spell = spell
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
    
    for _, creature in pairs(getSpectators()) do
        if creature:isMonster() and creature:canShoot() then
            local dist = getDistanceBetween(player:getPosition(), creature:getPosition())
            if dist <= distance then
                for _, targetName in ipairs(targetMonsters) do
                    if creature:getName() == targetName then
                        table.insert(validMonsters, creature)
                    end
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
