library DwarfEndurance requires Spell, DamageInterface, Periodic, Utilities
    /* -------------------- Dwarf Endurance v1.3 by Chopinski ------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Magtheridon96  - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Dwarf Endurance ability
        private constant integer ABILITY        = 'A007'
        // The period at which health is restored
        private constant real    PERIOD         = 0.1
        // The model used
        private constant string  HEAL_EFFECT    = "GreenHeal.mdl"
        // The attachment point
        private constant string  ATTACH_POINT   = "origin"
    endglobals

    // The time necessary for muradin to not take damage until the ability activates
    private constant function GetCooldown takes nothing returns real
        return 4.
    endfunction

    // The heal per second
    private function GetHeal takes integer level returns real
        return 25. + 25.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DwarfEndurance extends Spell
        private unit unit
        private integer id
        private real cooldown
        private effect effect

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "When |cffffcc00Muradin|r stops taking damage for |cffffcc00" + N2S(GetCooldown(), 1) + "|r seconds, |cff00ff00Health Regeneration|r is increased by |cff00ff00" + N2S(GetHeal(level), 0) + "|r per second."
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(unit, ABILITY)
                    
            if level > 0 then
                if cooldown <= 0 then
                    if UnitAlive(unit) then
                        call SetWidgetLife(unit, GetWidgetLife(unit) + GetHeal(level) * PERIOD)
                    endif
                else
                    set cooldown = cooldown - PERIOD

                    if effect != null then
                        call DestroyEffect(effect)
                        set effect = null
                    endif

                    if cooldown <= 0 then
                        set effect = AddSpecialEffectTarget(HEAL_EFFECT, unit, ATTACH_POINT)
                    endif
                endif
            endif

            return level > 0
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)
        
            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set this.id = id
                set cooldown = 0
                set unit = source
                set effect = AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT)

                call StartTimer(PERIOD, true, this, id)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = GetTimerInstance(Damage.target.id)
        
            if this != 0 then
                set cooldown = GetCooldown()
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary