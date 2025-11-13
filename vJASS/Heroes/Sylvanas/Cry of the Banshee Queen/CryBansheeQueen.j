library BansheeCry requires Spell, Utilities, CrowdControl, optional BlackArrow
    /* -------------------------------- Cry of the Banshee Queen v1.5 ------------------------------- */
    // Credits:
    //     Darkfang      - Void Curse Icon
    //     Mythic        - Call of the Dread model (edited by me)
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Cry of the Banshee Queen ability
        private constant integer ABILITY       = 'Svn2'
        // The fear model
        private constant string  FEAR_MODEL    = "Fear.mdl"
        // The the fear attachment point
        private constant string  ATTACH_FEAR   = "overhead"
        // The scream spammable model
        private constant string  SCREAM_MODEL  = "Call of Dread Purple.mdl"
        // The the scream attachment point
        private constant string  ATTACH_SCREAM = "origin"
    endglobals

    // The fear/slow duration
    private function GetDuration takes unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        endif
    endfunction

    // The slow amount
    private function GetSlow takes unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.5 + 0.*level
        else
            return 0.5 + 0.*level
        endif
    endfunction

    // The AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // Filter for effects
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct BansheeCry extends Spell
        private method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local unit u

            call SpamEffectUnit(Spell.source.unit, SCREAM_MODEL, ATTACH_SCREAM, 0.1, 5)
            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    static if LIBRARY_BlackArrow then
                        if Filtered(Spell.source.player, u) then
                            call FearUnit(u, GetDuration(u, Spell.level), FEAR_MODEL, ATTACH_FEAR, false)
                            call SlowUnit(u, GetSlow(u, Spell.level), GetDuration(u, Spell.level), null, null, false)
                        elseif GetOwningPlayer(u) == Spell.source.player and (GetUnitTypeId(u) == BlackArrow_SKELETON_WARRIOR or GetUnitTypeId(u) == BlackArrow_SKELETON_ARCHER) then
                            call ShowUnit(u, false)
                            call UnitApplyTimedLife(ReplaceUnit(u, GetUnitTypeId(u), bj_UNIT_STATE_METHOD_ABSOLUTE), 'BTLF', BlackArrow_GetSkeletonDuration(GetUnitAbilityLevel(u, BlackArrow_ABILITY)))
                        elseif GetOwningPlayer(u) == Spell.source.player and GetUnitTypeId(u) == BlackArrow_SKELETON_ELITE then
                            call ShowUnit(u, false)
                            call UnitApplyTimedLife(ReplaceUnit(u, GetUnitTypeId(u), bj_UNIT_STATE_METHOD_ABSOLUTE), 'BTLF', BlackArrow_GetEliteDuration(GetUnitAbilityLevel(u, BlackArrow_ABILITY)))
                        endif
                    else
                        if Filtered(Spell.source.player, u) then
                            call FearUnit(u, GetDuration(u, Spell.level), FEAR_MODEL, ATTACH_FEAR, false)
                            call SlowUnit(u, GetSlow(u, Spell.level), GetDuration(u, Spell.level), null, null, false)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
        endmethod   

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary