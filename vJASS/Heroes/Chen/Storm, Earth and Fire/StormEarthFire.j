library StormEarthFire requires Spell, Zap, LightningAttack, Fissure, BreathOfFire, NewBonus, Utilities, Modules
    /* ----------------- Storm, Earth and Fire v1.5 by Chopinski ---------------- */
    // Credits:
    //     Blizazrd    - Icon
    //     Bribe       - SpellEffectEvent, UnitIndexerGUI
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Storm, Earth and Fire ability
        private constant integer ABILITY       = 'Chn9'
        // The raw code of Storm unit
        private constant integer STORM         = 'uch1'
        // The raw code of Earth unit
        private constant integer EARTH         = 'uch2'
        // The raw code of Fire unit
        private constant integer FIRE          = 'uch0'
        // The raw code Fire Immolation ability
        private constant integer IMMOLATION    = 'ChnA'
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
            return R2I(25 * level + GetUnitBonus(source, BONUS_DAMAGE)*0.8)
        elseif unitId == EARTH then
            return R2I(100 * level + GetUnitBonus(source, BONUS_DAMAGE)*0.5)
        else  
            return R2I(75 * level + GetUnitBonus(source, BONUS_DAMAGE)*1.5)
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

    // The attack damage block for Earth spitir
    private function GetDamageBlock takes integer level returns real
        return 50. * level + GetUnitBonus(null, BONUS_DAMAGE_BLOCK)
    endfunction

    // The Immolation damage
    private function GetImmolationDamage takes unit source, integer level returns real
        return 75. * level + (0.1 * level * GetUnitBonus(source, BONUS_SPELL_POWER))
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct StormEarthFire extends Spell
        private unit unit
        private group group
        private player player
        private integer level

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u
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
                        call SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(unit, BONUS_SPELL_POWER))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                    elseif id == EARTH then
                        call SetUnitAbilityLevel(u, KegSmash_ABILITY, GetUnitAbilityLevel(unit, KegSmash_ABILITY))
                        call SetUnitAbilityLevel(u, Fissure_ABILITY, GetUnitAbilityLevel(unit, Fissure_ABILITY))
                        call BlzSetUnitMaxHP(u, GetHealth(id, level, unit))
                        call BlzSetUnitMaxMana(u, GetMana(id, level, unit))
                        call BlzSetUnitBaseDamage(u, GetDamage(id, level, unit), 0)
                        call BlzSetUnitArmor(u, GetArmor(id, level, unit))
                        call AddUnitBonus(u, BONUS_DAMAGE_BLOCK, GetDamageBlock(level))
                        call SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(unit, BONUS_SPELL_POWER))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                    elseif id == FIRE then
                        call SetUnitAbilityLevel(u, BreathOfFire_ABILITY, GetUnitAbilityLevel(unit, BreathOfFire_ABILITY))
                        call SetUnitAbilityLevel(u, IMMOLATION, level)
                        call BlzSetUnitMaxHP(u, GetHealth(id, level, unit))
                        call BlzSetUnitMaxMana(u, GetMana(id, level, unit))
                        call BlzSetUnitBaseDamage(u, GetDamage(id, level, unit), 0)
                        call BlzSetUnitArmor(u, GetArmor(id, level, unit))
                        call SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(unit, BONUS_SPELL_POWER))
                        call SetUnitLifePercentBJ(u, 100)
                        call SetUnitManaPercentBJ(u, 100)
                        call BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, IMMOLATION), ABILITY_RLF_DAMAGE_PER_INTERVAL, level - 1, GetImmolationDamage(unit, level))
                        call IncUnitAbilityLevel(u, IMMOLATION)
                        call DecUnitAbilityLevel(u, IMMOLATION)
                    endif
                call GroupRemoveUnit(group, u)
            endloop
        endmethod   

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set player = Spell.source.player
            set unit = Spell.source.unit
            set level = Spell.level
            set group = CreateGroup()

            call StartTimer(0, false, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary