library BrillanceAura requires RegisterPlayerUnitEvent, Spell, Modules, Utilities
    /* -------------------- Brilliance Aura v1.2 by Chopinski ------------------- */
    // Credits
    //      Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY    = 'Jna3'
        // If true the bonus regen will stack with each cast
        private constant boolean STACK      = false
    endglobals

    // The bonus mana regen when an ability is cast
    private function GetBonusManaRegen takes unit source, integer level returns real
        return 1.5 * level
    endfunction

    // The duration of the bonus regen
    private function GetDuration takes unit source, integer level returns real
        return 2.5 * level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BrillianceAura extends Spell
        private unit unit
        private integer id
        private real bonus
        private integer levels
        private ability ability
        private abilityreallevelfield field

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == levels
                    call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) - bonus)
                    call IncUnitAbilityLevel(unit, ABILITY)
                    call DecUnitAbilityLevel(unit, ABILITY)
                set i = i + 1
            endloop

            set bonus = 0
            set unit = null
            set field = null
            set ability = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Jaina|r gives additional |cff00ffff" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_MANA_REGENERATION_INCREASE, level - 1), 1) + "|r |cff00ffffMana Regeneration|r to nearby friendly units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r. When she casts an ability the bonus |cff00ffffMana Regeneration|r is increased by |cff00ffff" + N2S(GetBonusManaRegen(source, level), 1) + "|r for a |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private static method onSpell takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer i = 0
            local thistype this

            if level > 0 then
                static if STACK then
                    set this = thistype.allocate()
                    set unit = source
                    set id = GetUnitUserData(source)
                    set field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                    set ability = BlzGetUnitAbility(source, ABILITY)
                    set levels = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
                    set bonus = GetBonusManaRegen(source, level)

                    loop
                        exitwhen i == levels
                            call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) + bonus)
                            call IncUnitAbilityLevel(source, ABILITY)
                            call DecUnitAbilityLevel(source, ABILITY)
                        set i = i + 1
                    endloop
                else
                    set this = GetTimerInstance(GetUnitUserData(source))

                    if this == 0 then
                        set this = thistype.allocate()
                        set bonus = 0
                        set unit = source
                        set id = GetUnitUserData(source)
                        set field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                        set ability = BlzGetUnitAbility(source, ABILITY)
                        set levels = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
                    endif
                    
                    if bonus == 0 then
                        set bonus = GetBonusManaRegen(source, level)

                        loop
                            exitwhen i == levels
                                call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) + bonus)
                                call IncUnitAbilityLevel(source, ABILITY)
                                call DecUnitAbilityLevel(source, ABILITY)
                            set i = i + 1
                        endloop
                    endif
                endif

                call StartTimer(GetDuration(source, level), false, this, id)
            endif

            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onSpell)
        endmethod
    endstruct
endlibrary