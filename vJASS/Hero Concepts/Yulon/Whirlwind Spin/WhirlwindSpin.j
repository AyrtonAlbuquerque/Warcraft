library WhirlwindSpin requires SpellEffectEvent, PluginSpellEffect, Utilities, CrowdControl
    /* --------------------- WhirlwindSpin v1.2 by Chopinski -------------------- */
    // Credits:
    //     AnsonRuk    - Icon
    //     Bribe       - SpellEffectEvent
    //     AZ          - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY          = 'A003'
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
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction

    // The Knock Back duration
    private function GetKnockBackDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The caster time scale. Speed or slow down aniamtions.
    private function GetTimeScale takes unit source, integer level returns real
        return 2.
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
    private struct WhirlwindSpin
        timer timer
        unit unit
    
        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call SetUnitTimeScale(unit, 1)
            call ReleaseTimer(timer)
            call deallocate()
            
            set timer = null
            set unit = null
        endmethod
    
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local real aoe = GetAoE(Spell.source.unit, Spell.level)
            local real damage = GetDamage(Spell.level)
            local real duration = GetKnockBackDuration(Spell.source.unit, Spell.level)
            local group g = CreateGroup()
            local real distance
            local real angle
            local unit u
            local real x
            local real y
            
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
            
            set timer = NewTimerEx(this)
            set unit = Spell.source.unit
            
            call SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            call TimerStart(timer, GetTimeScaleTime(unit, Spell.level), false, function thistype.onExpire)
            
            set g = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary