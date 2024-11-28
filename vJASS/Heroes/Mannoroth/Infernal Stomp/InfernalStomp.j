library InfernalStomp requires SpellEffectEvent, PluginSpellEffect, CrowdControl
    /* ------------------------------------- Infernal Stomp v1.0 ------------------------------------ */
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
    private function GetDamage takes integer level returns real
        return 200. + 0.*level
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
    private struct InfernalStomp extends array
        private static method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local unit source = Spell.source.unit
            local player owner = Spell.source.player
            local real duration = GetDuration(Spell.source.unit, Spell.level)
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.level)
            local unit u

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
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary