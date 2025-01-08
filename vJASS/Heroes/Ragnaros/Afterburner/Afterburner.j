library Afterburner requires Ability, Periodic, DamageInterface, Utilities, optional NewBonus
    /* ---------------------- Afterburner v1.6 by Chopinski --------------------- */
    // Credits:
    //     PrinceYaser - icon.
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        //The raw code of the Afternurner Ability
        private constant integer    ABILITY         = 'A003'
        //The raw code of the Afternurner Prox Ability
        private constant integer    AFTERBURN_PROXY = 'A007'
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE     = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC
    endglobals

    //function responsible to determine the duration of the Afterburn
    //By default, it uses the Cooldown value in the Object Editor
    private function GetDuration takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
    endfunction

    //function responsible to determine the AoE of the Afterburn
    //By default, it uses the AoE value in the Object Editor
    private function GetAoE takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    //The damage per interval of the Afterburn
    private function GetDamage takes unit u, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. * level + 0.6 * GetUnitBonus(u, BONUS_SPELL_POWER)
        else
            return 25. * level
        endif
    endfunction

    //The damage interval of the Afterburn
    private function GetDamageInterval takes unit u, integer level returns real
        return 1.0
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Afterburner extends Ability
        private static integer array array

        private unit unit
        private unit dummy
        private integer id

        method destroy takes nothing returns nothing
            call DummyRecycle(dummy)
            call deallocate()

            set unit = null
            set dummy = null
            set array[id] = 0
        endmethod

        static method create takes real x, real y, real damage, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability skill
    
            set unit = source
            set dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set id = GetUnitUserData(dummy)
            set array[id] = this

            call UnitAddAbility(dummy, AFTERBURN_PROXY)
            set skill = BlzGetUnitAbility(dummy, AFTERBURN_PROXY)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            call IncUnitAbilityLevel(dummy, AFTERBURN_PROXY)
            call DecUnitAbilityLevel(dummy, AFTERBURN_PROXY)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call StartTimer(duration + 0.05, false, this, -1)
            
            set skill = null

            return this
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Ragnaros|r spells leave a trail of fire after cast that burns enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r range for |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage every |cffffcc00" + N2S(GetDamageInterval(source, level), 1) + "|r seconds.\n\nLasts |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod 

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.source.id]

            if this != 0 and Damage.amount > 0 then
                set Damage.source = unit
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod
    endstruct

    function Afterburn takes real x, real y, unit source returns nothing
        local integer level = GetUnitAbilityLevel(source, ABILITY)

        if level > 0 then
            call Afterburner.create(x, y, GetDamage(source, level), GetDuration(source, level), GetAoE(source, level), GetDamageInterval(source, level), source)
        endif
    endfunction
endlibrary