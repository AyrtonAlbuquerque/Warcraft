library Switch requires SpellEffectEvent, PluginSpellEffect, TimerUtils, MirrorImage
    /* ------------------------ Switch v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Bribe          - SpellEffectEvent
    //     Vexorian       - TimerUtils
    //     CheckeredFlag  - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Switch ability
        public  constant integer ABILITY       = 'A006'
        // The switch effect
        private constant string  SWITCH_EFFECT = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Switch
        unit unit
        group group
        timer timer

        static method after takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit v

            call PauseUnit(unit, false)
            call ShowUnit(unit, true)
            loop
                set v = FirstOfGroup(group)
                exitwhen v == null
                    call PauseUnit(v, false)
                    call ShowUnit(v, true)
                call GroupRemoveUnit(group, v)
            endloop
            call DestroyGroup(group)
            call SelectUnit(unit, true)
            call SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
            call ReleaseTimer(timer)

            set timer = null
            set unit = null
            set group = null

            call deallocate()
        endmethod

        private static method switch takes unit source, unit target returns group
            local real sFacing = GetUnitFacing(source)
            local real tFacing = GetUnitFacing(target)
            local real x = GetUnitX(source)
            local real y = GetUnitY(source)
            local group g1 = CreateGroup()
            local group g2 = CreateGroup()
            local unit v

            call PauseUnit(source, true)
            call ShowUnit(source, false)
            call DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, x, y))
            call GroupEnumUnitsOfPlayer(g1, GetOwningPlayer(source), null)
            loop
                set v = FirstOfGroup(g1)
                exitwhen v == null
                    if GetUnitTypeId(v) == GetUnitTypeId(source) and IsUnitIllusionEx(v) then
                        call PauseUnit(v, true)
                        call ShowUnit(v, false)
                        call DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, GetUnitX(v), GetUnitY(v)))
                        call GroupAddUnit(g2, v)
                    endif
                call GroupRemoveUnit(g1, v)
            endloop
            call DestroyGroup(g1)
            call SetUnitPosition(source, GetUnitX(target), GetUnitY(target))
            call SetUnitFacing(source, tFacing)
            call SetUnitPosition(target, x, y)
            call SetUnitFacing(target, sFacing)
            set g1 = null

            return g2
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this
        
            if GetUnitTypeId(Spell.source.unit) == GetUnitTypeId(Spell.target.unit) and IsUnitIllusionEx(Spell.target.unit) then
                set this = thistype.allocate()
                set unit = Spell.source.unit
                set group = switch(Spell.source.unit, Spell.target.unit)
                set timer = NewTimerEx(this)

                call TimerStart(timer, 0.25, false, function thistype.after)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary