library StormEarthFire requires SpellEffectEvent, PluginSpellEffect, Zap, LightningAttack, Fissure, BreathOfFire, NewBonus
    /* ----------------- Storm, Earth and Fire v1.2 by Chopinski ---------------- */
    // Credits:
    //     Blizazrd    - Icon
    //     Bribe       - SpellEffectEvent, UnitIndexerGUI
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Storm, Earth and Fire ability
        private constant integer ABILITY       = 'A007'
        // The raw code of Storm unit
        private constant integer STORM         = 'n002'
        // The raw code of Earth unit
        private constant integer EARTH         = 'n003'
        // The raw code of Fire unit
        private constant integer FIRE          = 'n001'
        // The raw code Earth hardened skin ability
        private constant integer HARDENED_SKIN = 'A00C'
        // The raw code Fire Immolation ability
        private constant integer IMMOLATION    = 'A00A'
    endglobals

    // The max hp of each element
    private function GetHealth takes integer unitId, integer level, unit source returns integer
        if unitId == STORM then
            return R2I(500*level + BlzGetUnitMaxHP(source)*0.5)
        elseif unitId == EARTH then
            return R2I(2000*level  + BlzGetUnitMaxHP(source))
        else
            return R2I(1000*level + BlzGetUnitMaxHP(source)*0.8)
        endif
    endfunction

    // The max mana of each element
    private function GetMana takes integer unitId, integer level, unit source returns integer
        if unitId == STORM then
            return R2I(500*level + BlzGetUnitMaxMana(source))
        elseif unitId == EARTH then
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.5)
        else   
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.8)
        endif
    endfunction

    // The base damage of each element
    private function GetDamage takes integer unitId, integer level, unit source returns integer
        if unitId == STORM then
            return R2I(25 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.8)
        elseif unitId == EARTH then
            return R2I(100 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.5)
        else  
            return R2I(75 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*1.5)
        endif
    endfunction

    // The base armor of each element
    private function GetArmor takes integer unitId, integer level, unit source returns real
        if unitId == STORM then
            return 0.*level  + GetUnitBonus(source, BONUS_ARMOR)*0.3
        elseif unitId == EARTH then
            return 5.*level + GetUnitBonus(source, BONUS_ARMOR)
        else   
            return 2.*level + GetUnitBonus(source, BONUS_ARMOR)*0.8
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct StormEarthFire
        timer timer
        unit unit
        group group
        player player
        integer level

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit    u
            local integer id

            call GroupEnumUnitsOfPlayer(group, player, null)
            loop
                set u  = FirstOfGroup(group)
                set id = GetUnitTypeId(u)
                exitwhen u == null
                    if id == STORM then
                        call SetUnitAbilityLevel(u, Zap_ABILITY, level)
                        call SetUnitAbilityLevel(u, LightningAttack_ABILITY, level)
                        call BlzSetUnitMaxHP(u, GetHealth(id, level, unit))
                        call BlzSetUnitMaxMana(u, GetMana(id, level, unit))
                        call BlzSetUnitBaseDamage(u, GetDamage(id, level, unit), 0)
                        call BlzSetUnitArmor(u, GetArmor(id, level, unit))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_FLAT, GetUnitBonus(unit, BONUS_SPELL_POWER_FLAT))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_PERCENT, GetUnitBonus(unit, BONUS_SPELL_POWER_PERCENT))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                    elseif id == EARTH then
                        call SetUnitAbilityLevel(u, Fissure_ABILITY, level)
                        call SetUnitAbilityLevel(u, HARDENED_SKIN, level)
                        call BlzSetUnitMaxHP(u, GetHealth(id, level, unit))
                        call BlzSetUnitMaxMana(u, GetMana(id, level, unit))
                        call BlzSetUnitBaseDamage(u, GetDamage(id, level, unit), 0)
                        call BlzSetUnitArmor(u, GetArmor(id, level, unit))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_FLAT, GetUnitBonus(unit, BONUS_SPELL_POWER_FLAT))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_PERCENT, GetUnitBonus(unit, BONUS_SPELL_POWER_PERCENT))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                    elseif id == FIRE then
                        call SetUnitAbilityLevel(u, BreathOfFire_ABILITY, GetUnitAbilityLevel(unit, BreathOfFire_ABILITY))
                        call SetUnitAbilityLevel(u, IMMOLATION, level)
                        call BlzSetUnitMaxHP(u, GetHealth(id, level, unit))
                        call BlzSetUnitMaxMana(u, GetMana(id, level, unit))
                        call BlzSetUnitBaseDamage(u, GetDamage(id, level, unit), 0)
                        call BlzSetUnitArmor(u, GetArmor(id, level, unit))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_FLAT, GetUnitBonus(unit, BONUS_SPELL_POWER_FLAT))
                        call SetUnitBonus(u, BONUS_SPELL_POWER_PERCENT, GetUnitBonus(unit, BONUS_SPELL_POWER_PERCENT))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call deallocate()

            set unit = null
            set timer = null
            set group = null
            set player = null
        endmethod   

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer = NewTimerEx(this)
            set player = Spell.source.player
            set unit = Spell.source.unit
            set level = Spell.level
            set group = CreateGroup()

            call TimerStart(timer, 0, false, function thistype.onExpire)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary