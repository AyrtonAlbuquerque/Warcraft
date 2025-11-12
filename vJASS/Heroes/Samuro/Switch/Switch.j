library Switch requires Spell, Modules, MirrorImage
    /* ------------------------ Switch v1.5 by Chopinski ------------------------ */
    // Credits:
    //     CheckeredFlag  - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Switch ability
        public  constant integer ABILITY       = 'Smr0'
        // The switch effect
        private constant string  SWITCH_EFFECT = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Switch extends Spell
        private unit unit
        private group group

        method destroy takes nothing returns nothing
            set unit = null
            set group = null

            call deallocate()
        endmethod

        private static method switch takes unit source, unit target returns group
            local real x = GetUnitX(source)
            local real y = GetUnitY(source)
            local group g1 = CreateGroup()
            local group g2 = CreateGroup()
            local real sourceFace = GetUnitFacing(source)
            local real targetFace = GetUnitFacing(target)
            local unit u

            call PauseUnit(source, true)
            call ShowUnit(source, false)
            call DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, x, y))
            call GroupEnumUnitsOfPlayer(g1, GetOwningPlayer(source), null)

            loop
                set u = FirstOfGroup(g1)
                exitwhen u == null
                    if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                        call PauseUnit(u, true)
                        call ShowUnit(u, false)
                        call DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, GetUnitX(u), GetUnitY(u)))
                        call GroupAddUnit(g2, u)
                    endif
                call GroupRemoveUnit(g1, u)
            endloop

            call DestroyGroup(g1)
            call SetUnitPosition(source, GetUnitX(target), GetUnitY(target))
            call SetUnitFacing(source, targetFace)
            call SetUnitPosition(target, x, y)
            call SetUnitFacing(target, sourceFace)
            set g1 = null

            return g2
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u

            call PauseUnit(unit, false)
            call ShowUnit(unit, true)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    call PauseUnit(u, false)
                    call ShowUnit(u, true)
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)
            call SelectUnit(unit, true)
            call SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
        endmethod

        private method onCast takes nothing returns nothing
            if GetUnitTypeId(Spell.source.unit) == GetUnitTypeId(Spell.target.unit) and IsUnitIllusionEx(Spell.target.unit) then
                set this = thistype.allocate()
                set unit = Spell.source.unit
                set group = switch(Spell.source.unit, Spell.target.unit)

                call StartTimer(0.25, false, this, 0)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary