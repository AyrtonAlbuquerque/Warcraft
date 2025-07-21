library WhirlwindSpin requires Spell, Utilities, CrowdControl, Periodic optional NewBonus
    /* --------------------- WhirlwindSpin v1.3 by Chopinski -------------------- */
    // Credits:
    //     AnsonRuk    - Icon
    //     AZ          - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY          = 'A004'
        // The Model
        private constant string  MODEL            = "DragonSpin.mdl"
        // The model scale
        private constant real    SCALE            = 0.6
        // The knock back model
        private constant string  KNOCKBACK_MODEL  = "WindBlow.mdl"
        // The knock back attachment point
        private constant string  ATTACH_POINT     = "origin"
    endglobals

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. + 50. * level + (0.9 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50. * level
        endif
    endfunction

    // The Knock Back duration
    private function GetKnockBackDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The caster time scale. Speed or slow down aniamtions.
    private function GetTimeScale takes unit source, integer level returns real
        return 3.
    endfunction
    
    // The amoount of time until time scale is reset
    private function GetTimeScaleTime takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WhirlwindSpin extends Spell
        private unit unit
    
        method destroy takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
            call deallocate()
            
            set unit = null
        endmethod
    
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r violently spins around it's location creating an outward force that deals |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r Magic damage. and pushes all enemy units back. Additionaly, |cffffcc00Whirlwind Spin|r resets |cffffcc00Dragon Dash|r cooldown."
        endmethod

        private method onCast takes nothing returns nothing
            local real x
            local real y
            local unit u
            local real angle
            local real distance
            local group g = CreateGroup()
            local real damage = GetDamage(Spell.source.unit, Spell.level)
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real duration = GetKnockBackDuration(Spell.source.unit, Spell.level)

            static if LIBRARY_DragonDash then
                call ResetUnitAbilityCooldown(Spell.source.unit, DragonDash_ABILITY)
            endif

            call DestroyEffect(AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE))
            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(Spell.source.player, u) then
                        set x = GetUnitX(u)
                        set y = GetUnitY(u)
                        set angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                        set distance = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                        
                        if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call KnockbackUnit(u, angle, aoe - distance, duration, KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)
            
            set this = thistype.allocate()
            set unit = Spell.source.unit
            
            call SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            call StartTimer(GetTimeScaleTime(unit, Spell.level), false, this, 0)
            
            set g = null
        endmethod
        
        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary