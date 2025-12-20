library FlowingWater requires RegisterPlayerUnitEvent, Utilities, Spell
    /* --------------------- Flowing Water v1.0 by Chopinski -------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY = 'Jna4'
        // The effect model
        private constant string  EFFECT  = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        // The effect model attach point
        private constant string  ATTACH  = "origin"
    endglobals

    // The trigger chance
    private function GetChance takes unit source, integer level returns real
        return 0.2 + 0.1 * level
    endfunction

    // The reduction percentage
    private function GetReduction takes unit source, integer level returns real
        return 0.4 + 0.1 * level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct FlowingWater extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "When casting an |cffffcc00Active|r ability |cffffcc00Jaina|r has |cffffcc00" + N2S(GetChance(source, level) * 100, 0) + "%|r chance to reduce the casted ability cooldown by |cffffcc00" + N2S(GetReduction(source, level) * 100, 0) + "%|r."
        endmethod

        private static method onSpell takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)

            if level > 0 then
                if GetRandomReal(0, 1) <= GetChance(Spell.source.unit, level) then
                    if Spell.cooldown > 0 then
                        call DestroyEffect(AddSpecialEffectTarget(EFFECT, Spell.source.unit, ATTACH))
                        call StartUnitAbilityCooldown(Spell.source.unit, Spell.id, (1 - GetReduction(Spell.source.unit, level)) * Spell.cooldown)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onSpell)
        endmethod
    endstruct
endlibrary