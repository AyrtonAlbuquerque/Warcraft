library Mimic requires RegisterPlayerUnitEvent, MirrorImage, optional WindWalk, optional Bladestorm
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
    private struct Mimic extends array
        private static method update takes unit source, integer id, abilityreallevelfield field returns nothing
            local ability a      = BlzGetUnitAbility(source, id)
            local integer i      = 0
            local integer levels = BlzGetAbilityIntegerField(a, ABILITY_IF_LEVELS)
            local real    damage

            loop
                exitwhen i >= levels
                    set damage = BlzGetAbilityRealLevelField(a, field, i)
                    call BlzSetAbilityRealLevelField(a, field, i, GetNewDamage(id, damage))
                    call IncUnitAbilityLevel(source, id)
                    call DecUnitAbilityLevel(source, id)
                set i = i + 1
            endloop

            set a = null
        endmethod

        private static method mimic takes unit source, integer skill, integer level, real mana, abilityreallevelfield field, string order returns nothing
            local group   g = CreateGroup()
            local integer i = 0
            local integer size
            local real    damage
            local ability a
            local unit    u

            call GroupEnumUnitsOfPlayer(g, GetOwningPlayer(source), null)
            set size  = BlzGroupGetSize(g)
            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(g, i)
                    if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                        call SetUnitState(u, UNIT_STATE_MANA, mana)
                        call UnitRemoveAbility(u, skill)
                        call UnitAddAbility(u, skill)
                        call SetUnitAbilityLevel(u, skill, level)
                        set a = BlzGetUnitAbility(u, skill)
                        set damage = BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, skill), field, level - 1)
                        call BlzSetAbilityRealLevelField(a, field, level - 1, damage)
                        call IssueImmediateOrder(u, order)
                        call BlzUnitHideAbility(u, skill, true)
                    endif
                set i = i + 1
            endloop
            call DestroyGroup(g)

            set g = null
            set a = null
            set u = null
        endmethod

        static method onCast takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)
            local integer skill  = GetSpellAbilityId()
        
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

        private static method onLevelUp takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)
            local integer skill  = GetLearnedSkill()
            
            if skill == ABILITY then
                if level == GetWindWalkDoubleLevel() then
                    static if LIBRARY_WindWalk then
                        call update(source, WindWalk_ABILITY, ABILITY_RLF_BACKSTAB_DAMAGE)
                    endif
                elseif level == GetBladestormDoubleLevel() then
                    static if LIBRARY_Bladestorm then
                        call update(source, Bladestorm_ABILITY, ABILITY_RLF_DAMAGE_PER_SECOND_OWW1)
                    endif
                endif
            endif
        
            set source = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevelUp)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endlibrary