library DraconicDischarge requires SpellEffectEvent, PluginSpellEffect, Utilities, LineSegmentEnumeration
    /* ------------------ Draconic Discharge v1.1 by Chopinski ------------------ */
    // Credits:
    //     N-ix Studio      - Icon
    //     Bribe            - SpellEffectEvent
    //     IcemanBo, AGD    - LineSegmentEnumeration
    //     Wood             - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY          = 'A005'
        // The Model
        private constant string  MODEL            = "Discharge.mdl"
        // The model scale
        private constant real    SCALE            = 1
        // The model offset
        private constant real    OFFSET           = 200
    endglobals

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Damage dealt
    private function GetDamage takes unit source, integer level returns real
        return 250.*level
    endfunction

    // The blast range
    private function GetRange takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction
    
    // The stun duration
    private function GetStunDuration takes unit source, integer level returns real
        return 1. + 1.*level
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DraconicDischarge extends array
        private static method onCast takes nothing returns nothing
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real range = GetRange(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.source.unit, Spell.level)
            local real duration = GetStunDuration(Spell.source.unit, Spell.level)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real minX = Spell.source.x + OFFSET*Cos(angle)
            local real minY = Spell.source.y + OFFSET*Sin(angle)
            local real maxX = Spell.source.x + (OFFSET + range)*Cos(angle)
            local real maxY = Spell.source.y + (OFFSET + range)*Sin(angle)
            local effect e = AddSpecialEffectEx(MODEL, minX, minY, 65, SCALE)
            local group g = CreateGroup()
            local unit u
            
            call QueueUnitAnimation(Spell.source.unit, "Stand")
            call BlzSetUnitFacingEx(Spell.source.unit, angle*bj_RADTODEG)
            call BlzSetSpecialEffectYaw(e, angle)
            call LineSegment.EnumUnitsEx(g, minX, minY, maxX, maxY, aoe, true)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(Spell.source.player, u) then
                        if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call StunUnit(u, duration)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop
            call DestroyEffect(e)
            call DestroyGroup(g)
            
            set g = null
            set e = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary