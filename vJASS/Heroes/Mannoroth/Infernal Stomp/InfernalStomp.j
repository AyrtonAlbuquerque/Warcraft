library InfernalStomp requires Ability, CrowdControl, optional NewBonus
    /* ------------------------------------- Infernal Stomp v1.1 ------------------------------------ */
    // Credits:
    //     Bribe         - SpellEffectEvent
    /* ---------------------------------------- By Chopinksi ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Infernal Stomp ability
        private constant integer ABILITY = 'A00D'
        // The stun model
        private constant string  MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attach point
        private constant string  POINT   = "overhead"
    endglobals

    // The damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 200. + 0. * level + 1. * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 200. + 0. * level
        endif
    endfunction

    // The stun duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The stomp aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The unit filter
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct InfernalStomp extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Slams the ground, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to nearby enemy land units and stunning them for |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r second."
        endmethod

        private method onCast takes nothing returns nothing
            local unit u
            local group g = CreateGroup()
            local unit source = Spell.source.unit
            local player owner = Spell.source.player
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real duration = GetDuration(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.source.unit, Spell.level)

            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call StunUnit(u, duration, MODEL, POINT, false)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
            set owner = null
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary