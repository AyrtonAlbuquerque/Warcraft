library DragonBurst requires Spell, Utilities, CrowdControl optional NewBonus
    /* --------------------- Dragon Burst v1.3 by Chopinski --------------------- */
    // Credits:
    //     Blizzard, TheKaldorei - Icon
    //     AZ                    - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY          = 'Yul1'
        // The Model
        private constant string  MODEL            = "DragonBurst.mdl"
        // The model scale
        private constant real    SCALE            = 0.75
        // The knock back model
        private constant string  KNOCKBACK_MODEL  = "WindBlow.mdl"
        // The knock back attachment point
        private constant string  ATTACH_POINT     = "origin"
    endglobals

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Center AOE for Knock Up
    private function GetCenterAoE takes unit source, integer level returns real
         return 100. + 0.*level
    endfunction

    // The Damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 100. + 50.*level + (0.8 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100. + 50.*level
        endif
    endfunction

    // The Knock Up duration
    private function GetKnockUpDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The Knock Up height
    private function GetKnockUpHeight takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The Knock Back duration
    private function GetKnockBackDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DragonBurst extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r creates an eruption at the target location, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r damage to all nearby enemy units. Units at the center of the eruption are |cffffcc00Knocked Up|r for |cffffcc00" + N2S(GetKnockUpDuration(source, level), 2) + "|r seconds and units further away from the center are |cffffcc00Knocked Back|r away from the center."
        endmethod
        
        private method onCast takes nothing returns nothing
            local real x
            local real y
            local unit u
            local real angle
            local real distance
            local group g = CreateGroup()
            local real height = GetKnockUpHeight(Spell.level)
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.source.unit, Spell.level)
            local real center = GetCenterAoE(Spell.source.unit, Spell.level)
            
            call DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
            call GroupEnumUnitsInRange(g, Spell.x, Spell.y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(Spell.source.player, u) then
                        set x = GetUnitX(u)
                        set y = GetUnitY(u)
                        set angle = AngleBetweenCoordinates(Spell.x, Spell.y, x, y)
                        set distance = DistanceBetweenCoordinates(Spell.x, Spell.y, x, y)
                        
                        if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            if distance > center then
                                call KnockbackUnit(u, angle, aoe - distance, GetKnockBackDuration(Spell.source.unit, Spell.level), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                            else
                                call KnockupUnit(u, height, GetKnockUpDuration(Spell.source.unit, Spell.level), null, null, false)
                            endif
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