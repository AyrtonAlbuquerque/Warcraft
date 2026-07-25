library Mimic requires Spell, RegisterPlayerUnitEvent, MirrorImage, NewBonus, Modules, Utilities optional Bladestorm
    /* ------------------------- Mimic v1.4 by Chopinski ------------------------ */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     CRAZYRUSSIAN   - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Critical Strike ability
        private constant integer ABILITY  = 'Smr4'
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
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Samuro|r Illusions mimic him perfectly. When |cffffcc00Samuro|r uses |cffffcc00Bladestorm|r, so will his illusions. In addintion, |cffffcc00Samuro|r gains |cffff0000" + N2S(GetBonusDamage(level), 0) + "|r |cffff0000Damage|r and |cff808080" + N2S(GetBonusArmor(level), 0) + "|r |cff808080Armor|r while casting |cffffcc00Bladestorm|r."
        endmethod

        private static method onSpell takes nothing returns nothing
            local unit u
            local group g
            local real duration
            local integer level
            local unit source = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()

            static if LIBRARY_Bladestorm then
                if skill == Bladestorm_ABILITY and not IsUnitIllusionEx(source) and GetUnitAbilityLevel(source, ABILITY) > 0 then
                    set g = CreateGroup()
                    set level = GetUnitAbilityLevel(source, Bladestorm_ABILITY)
                    set duration = Bladestorm_GetDuration(source, level)

                    call AddUnitBonusTimed(source, BONUS_ARMOR, GetBonusArmor(level), duration)
                    call AddUnitBonusTimed(source, BONUS_DAMAGE, GetBonusDamage(level), duration)
                    call GroupEnumUnitsOfPlayer(g, GetOwningPlayer(source), null)

                    loop
                        set u = FirstOfGroup(g)
                        exitwhen u == null
                            if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA))
                                call UnitRemoveAbility(u, Bladestorm_ABILITY)
                                call UnitAddAbility(u, Bladestorm_ABILITY)
                                call SetUnitAbilityLevel(u, Bladestorm_ABILITY, level)
                                call IssueImmediateOrder(u, "whirlwind")
                                call BlzUnitHideAbility(u, Bladestorm_ABILITY, true)
                                call AddUnitBonusTimed(u, BONUS_ARMOR, GetBonusArmor(level), duration)
                                call AddUnitBonusTimed(u, BONUS_DAMAGE, GetBonusDamage(level), duration)
                            endif
                        call GroupRemoveUnit(g, u)
                    endloop

                    call DestroyGroup(g)
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