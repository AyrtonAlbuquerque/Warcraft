library Mimic requires Spell, RegisterPlayerUnitEvent, MirrorImage, optional WindWalk, optional Bladestorm
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

    // The level at which illsuions will start to mimic Wind Walk
    private constant function GetWindWalkMimicLevel takes nothing returns integer
        return 1
    endfunction

    // The level at which illsuions will start to mimic Bladestorm
    private constant function GetBladestormMimicLevel takes nothing returns integer
        return 3
    endfunction

    // The level at which mimic will double wind walk bonus damage
    private constant function GetWindWalkDoubleLevel takes nothing returns integer
        return 2
    endfunction

    // The level at which mimic will double Bladestorm damage per second
    private constant function GetBladestormDoubleLevel takes nothing returns integer
        return 4
    endfunction

    // The Wind Walk/Bladestorm new damage based on original value
    private function GetNewDamage takes integer id, real original returns real
        static if LIBRARY_WindWalk and LIBRARY_Bladestorm then
            if id == WindWalk_ABILITY then
                return 2.*original
            elseif id == Bladestorm_ABILITY then
                return 2.*original
            else
                return 2.*original
            endif
        else
            return 2.*original
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Mimic extends Spell
        private static method update takes unit source, integer id, abilityreallevelfield field returns nothing
            local integer i = 0
            local ability spell = BlzGetUnitAbility(source, id)
            local integer levels = BlzGetAbilityIntegerField(spell, ABILITY_IF_LEVELS)

            loop
                exitwhen i >= levels
                    call BlzSetAbilityRealLevelField(spell, field, i, GetNewDamage(id, BlzGetAbilityRealLevelField(spell, field, i)))
                    call IncUnitAbilityLevel(source, id)
                    call DecUnitAbilityLevel(source, id)
                set i = i + 1
            endloop

            set spell = null
        endmethod

        private static method mimic takes unit source, integer skill, integer level, real mana, abilityreallevelfield field, string order returns nothing
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsOfPlayer(g, GetOwningPlayer(source), null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                        call SetUnitState(u, UNIT_STATE_MANA, mana)
                        call UnitRemoveAbility(u, skill)
                        call UnitAddAbility(u, skill)
                        call SetUnitAbilityLevel(u, skill, level)
                        call BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, skill), field, level - 1, BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, skill), field, level - 1))
                        call IssueImmediateOrder(u, order)
                        call BlzUnitHideAbility(u, skill, true)
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
            set u = null
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            if level == GetWindWalkDoubleLevel() then
                static if LIBRARY_WindWalk then
                    call update(source, WindWalk_ABILITY, ABILITY_RLF_BACKSTAB_DAMAGE)
                endif
            elseif level == GetBladestormDoubleLevel() then
                static if LIBRARY_Bladestorm then
                    call update(source, Bladestorm_ABILITY, ABILITY_RLF_DAMAGE_PER_SECOND_OWW1)
                endif
            endif
        endmethod

        private static method onSpell takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
        
            static if LIBRARY_WindWalk then
                if level >= GetWindWalkMimicLevel() and skill == WindWalk_ABILITY and not IsUnitIllusionEx(source) then
                    call mimic(source, skill, GetUnitAbilityLevel(source, skill), GetUnitState(source, UNIT_STATE_MANA), ABILITY_RLF_BACKSTAB_DAMAGE, "windwalk")
                endif
            endif

            static if LIBRARY_Bladestorm then
                if level >= GetBladestormMimicLevel() and skill == Bladestorm_ABILITY and not IsUnitIllusionEx(source) then
                    call mimic(source, skill, GetUnitAbilityLevel(source, skill), GetUnitState(source, UNIT_STATE_MANA), ABILITY_RLF_DAMAGE_PER_SECOND_OWW1, "whirlwind")
                endif
            endif
        
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onSpell)
        endmethod
    endstruct
endlibrary