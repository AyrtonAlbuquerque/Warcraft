--[[ requires SpellEffectEvent, PluginSpellEffect, Zap, LightningAttack, Fissure, BreathOfFire, NewBonus
    /* ----------------- Storm, Earth and Fire v1.2 by Chopinski ---------------- */
    // Credits:
    //     Blizazrd    - Icon
    //     Bribe       - SpellEffectEvent, UnitIndexerGUI
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of Storm, Earth and Fire ability
    local ABILITY       = FourCC('A007')
    -- The raw code of Storm unit
    local STORM         = FourCC('n002')
    -- The raw code of Earth unit
    local EARTH         = FourCC('n003')
    -- The raw code of Fire unit
    local FIRE          = FourCC('n001')
    -- The raw code Earth hardened skin ability
    local HARDENED_SKIN = FourCC('A00C')
    -- The raw code Fire Immolation ability
    local IMMOLATION    = FourCC('A00A')

    -- The max hp of each element
    local function GetHealth(unittype, level, source)
        if unittype == STORM then
            return R2I(500*level + BlzGetUnitMaxHP(source)*0.5)
        elseif unittype == EARTH then
            return R2I(2000*level  + BlzGetUnitMaxHP(source))
        else
            return R2I(1000*level + BlzGetUnitMaxHP(source)*0.8)
        end
    end

    -- The max mana of each element
    local function GetMana(unittype, level, source)
        if unittype == STORM then
            return R2I(500*level + BlzGetUnitMaxMana(source))
        elseif unittype == EARTH then
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.5)
        else 
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.8)
        end
    end

    -- The base damage of each element
    local function GetDamage(unittype, level, source)
        if unittype == STORM then
            return R2I(25 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.8)
        elseif unittype == EARTH then
            return R2I(100 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.5)
        else  
            return R2I(75 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*1.5)
        end
    end

    -- The base armor of each element
    local function GetArmor(unittype, level, source)
        if unittype == STORM then
            return 0.*level  + GetUnitBonus(source, BONUS_ARMOR)*0.3
        elseif unittype == EARTH then
            return 5.*level + GetUnitBonus(source, BONUS_ARMOR)
        else  
            return 2.*level + GetUnitBonus(source, BONUS_ARMOR)*0.8
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local player = Spell.source.player
            local level = Spell.level
            local unit = Spell.source.unit
            local group = CreateGroup()

            TimerStart(timer, 0, false, function()
                GroupEnumUnitsOfPlayer(group, player, nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local unit = BlzGroupUnitAt(group, i)
                    local unittype = GetUnitTypeId(unit)
                    
                    if unittype == STORM then
                        SetUnitAbilityLevel(unit, Zap_ABILITY, level)
                        SetUnitAbilityLevel(unit, LightningAttack_ABILITY, level)
                        BlzSetUnitMaxHP(unit, GetHealth(unittype, level, unit))
                        BlzSetUnitMaxMana(unit, GetMana(unittype, level, unit))
                        BlzSetUnitBaseDamage(unit, GetDamage(unittype, level, unit), 0)
                        BlzSetUnitArmor(unit, GetArmor(unittype, level, unit))
                        SetUnitLifePercentBJ(unit, 100)
                        SetUnitManaPercentBJ(unit, 100)
                    elseif unittype == EARTH then
                        SetUnitAbilityLevel(unit, Fissure_ABILITY, level)
                        SetUnitAbilityLevel(unit, HARDENED_SKIN, level)
                        BlzSetUnitMaxHP(unit, GetHealth(unittype, level, unit))
                        BlzSetUnitMaxMana(unit, GetMana(unittype, level, unit))
                        BlzSetUnitBaseDamage(unit, GetDamage(unittype, level, unit), 0)
                        BlzSetUnitArmor(unit, GetArmor(unittype, level, unit))
                        SetUnitLifePercentBJ(unit, 100)
                        SetUnitManaPercentBJ(unit, 100)
                    elseif unittype == FIRE then
                        SetUnitAbilityLevel(unit, BreathOfFire_ABILITY, level)
                        SetUnitAbilityLevel(unit, IMMOLATION, level)
                        BlzSetUnitMaxHP(unit, GetHealth(unittype, level, unit))
                        BlzSetUnitMaxMana(unit, GetMana(unittype, level, unit))
                        BlzSetUnitBaseDamage(unit, GetDamage(unittype, level, unit), 0)
                        BlzSetUnitArmor(unit, GetArmor(unittype, level, unit))
                        SetUnitLifePercentBJ(unit, 100)
                        SetUnitManaPercentBJ(unit, 100)
                    end
                end
                DestroyGroup(group)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end)
end