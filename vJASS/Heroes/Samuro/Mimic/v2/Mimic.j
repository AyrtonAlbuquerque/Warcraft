library Mimic requires Spell, RegisterPlayerUnitEvent, MirrorImage, NewBonus, Periodic, Utilities optional Bladestorm
    /* ------------------------- Mimic v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     CRAZYRUSSIAN   - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Critical Strike ability
        private constant integer ABILITY  = 'A004'
    endglobals

    // The bonus damage every level up
    private function GetBonusDamage takes integer level returns real
        return 25. * level
    endfunction

    // The level at which illsuions will start to mimic Bladestorm
    private function GetBonusArmor takes integer level returns real
        return 2. * level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Mimic extends Spell
        private unit unit
        private group group

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Samuro|r Illusions mimic him perfectly. When |cffffcc00Samuro|r uses |cffffcc00Bladestorm|r, so will his illusions. In addintion, |cffffcc00Samuro|r gains |cffff0000" + N2S(GetBonusDamage(level), 0) + "|r |cffff0000Damage|r and |cff808080" + N2S(GetBonusArmor(level), 0) + "|r |cff808080Armor|r while casting |cffffcc00Bladestorm|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer i = 0
            local integer size

            static if LIBRARY_Bladestorm then
                if GetUnitAbilityLevel(unit, Bladestorm_BUFF) == 0 then
                    set size = BlzGroupGetSize(group)

                    if size > 0 then
                        loop
                            exitwhen i == size
                                call UnitRemoveAbility(BlzGroupUnitAt(group, i), Bladestorm_BUFF)
                            set i = i + 1
                        endloop
                    endif

                    return false
                endif

                return true
            endif

            return false
        endmethod

        private static method onSpell takes nothing returns nothing
            local unit u
            local group g
            local thistype this
            local unit source = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local integer level = GetUnitAbilityLevel(source, ABILITY)

            static if LIBRARY_Bladestorm then
                if skill == Bladestorm_ABILITY and not IsUnitIllusionEx(source) and not HasStartedTimer(GetUnitUserData(source)) and GetUnitAbilityLevel(source, ABILITY) > 0 then
                    set this = thistype.allocate()
                    set unit = source
                    set group = CreateGroup()
                    set g = CreateGroup()

                    call LinkBonusToBuff(source, BONUS_ARMOR, GetBonusArmor(level), Bladestorm_BUFF)
                    call LinkBonusToBuff(source, BONUS_DAMAGE, GetBonusDamage(level), Bladestorm_BUFF)
                    call GroupEnumUnitsOfPlayer(g, GetOwningPlayer(source), null)

                    loop
                        set u = FirstOfGroup(g)
                        exitwhen u == null
                            if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                                call GroupAddUnit(group, u)
                                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA))
                                call UnitRemoveAbility(u, Bladestorm_ABILITY)
                                call UnitAddAbility(u, Bladestorm_ABILITY)
                                call SetUnitAbilityLevel(u, Bladestorm_ABILITY, level)
                                call IssueImmediateOrder(u, "manashieldon")
                                call BlzUnitHideAbility(u, Bladestorm_ABILITY, true)
                                call LinkBonusToBuff(u, BONUS_ARMOR, GetBonusArmor(level), Bladestorm_BUFF)
                                call LinkBonusToBuff(u, BONUS_DAMAGE, GetBonusDamage(level), Bladestorm_BUFF)
                            endif
                        call GroupRemoveUnit(g, u)
                    endloop

                    call DestroyGroup(g)
                    call StartTimer(0.25, true, this, GetUnitUserData(source))
                endif
            endif
        
            set g = null
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onSpell)
        endmethod
    endstruct
endlibrary