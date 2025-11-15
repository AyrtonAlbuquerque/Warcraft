library DraconicDischarge requires Spell, Utilities, LineSegmentEnumeration, CrowdControl optional NewBonus
    /* ------------------ Draconic Discharge v1.4 by Chopinski ------------------ */
    // Credits:
    //     N-ix Studio      - Icon
    //     IcemanBo, AGD    - LineSegmentEnumeration
    //     Wood             - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY     = 'Yul3'
        // The Model
        private constant string  MODEL       = "Discharge.mdl"
        // The model scale
        private constant real    SCALE       = 1
        // The model offset
        private constant real    OFFSET      = 200
        // The stun model
        private constant string  STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attach point
        private constant string  STUN_ATTACH = "overhead"
    endglobals

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 125. * level + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 125. * level
        endif
    endfunction

    // The blast range
    private function GetRange takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction
    
    // The stun duration
    private function GetStunDuration takes unit source, integer level returns real
        return 1. + 0.25*level
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DraconicDischarge extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r discharges a powerful enegy blast towards the targeted direction, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r Magic|r damage and stunning enemy units caught in its radius for |cffffcc00" + N2S(GetStunDuration(source, level), 0) + "|r seconds. |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r, |cffffcc00" + N2S(GetRange(source, level), 0) + "|r blast range."
        endmethod

        private method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real range = GetRange(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.source.unit, Spell.level)
            local real duration = GetStunDuration(Spell.source.unit, Spell.level)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real minX = Spell.source.x
            local real minY = Spell.source.y
            local real maxX = Spell.source.x + range * Cos(angle)
            local real maxY = Spell.source.y + range * Sin(angle)
            local effect e = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET * Cos(angle), Spell.source.y + OFFSET * Sin(angle), 65, SCALE)
            local unit u
            
            call BlzSetSpecialEffectYaw(e, angle)
            call QueueUnitAnimation(Spell.source.unit, "Stand")
            call BlzSetUnitFacingEx(Spell.source.unit, angle*bj_RADTODEG)
            call LineSegment.EnumUnitsEx(g, minX, minY, maxX, maxY, aoe, true)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(Spell.source.player, u) then
                        if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call StunUnit(u, duration, STUN_MODEL, STUN_ATTACH, false)
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
            call RegisterSpell(thistype.allocate() ,ABILITY)
        endmethod
    endstruct
endlibrary