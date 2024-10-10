library DragonZone requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Utilities, CrowdControl
    /* ---------------------- Dragon Zone v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Bribe          - SpellEffectEvent
    //     AZ             - Model
    //     N-ix Studio    - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ability
        private constant integer ABILITY          = 'A006'
        // The raw code of the regen ability
        private constant integer REGEN_ABILITY    = 'A007'
        // The raw code of the Yu'lon unit in the editor
        private constant integer YULON_ID         = 'H000'
        // The Model
        private constant string  MODEL            = "DragonZone.mdl"
        // The model scale
        private constant real    SCALE            = 2.5
        // The knock back model
        private constant string  KNOCKBACK_MODEL  = "WindBlow.mdl"
        // The knock back attachment point
        private constant string  ATTACH_POINT     = "origin"
        // The pdate period
        private constant real    PERIOD           = 0.1
    endglobals

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Damage dealt
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction

    // The maximum Knock Back duration
    private function GetMaxKnockBackDuration takes unit source, integer level returns real
        return 0.5 + 0.*level
    endfunction
    
    // The spell duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The caster time scale. Speed or slow down aniamtions.
    private function GetTimeScale takes unit source, integer level returns real
        return 1.5
    endfunction
    
    // The amoount of time until time scale is reset
    private function GetTimeScaleTime takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
    endfunction

    // The Unit Filter.
    private function UnitFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DragonZone
        timer t
        timer timer
        unit unit
        group group
        player player
        real duration
        real knock
        real aoe
        real x
        real y
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real distance
            local real angle
            local real ux
            local real uy
            local unit u
            
            if duration > 0 then
                set duration = duration - PERIOD
                
                call GroupEnumUnitsInRange(group, x, y, aoe, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) then
                            if not IsUnitKnockedBack(u) then
                                set ux = GetUnitX(u)
                                set uy = GetUnitY(u)
                                set angle = AngleBetweenCoordinates(x, y, ux, uy)
                                set distance = DistanceBetweenCoordinates(x, y, ux, uy)
                                
                                call KnockbackUnit(u, angle, aoe + 25 - distance, knock*(distance/aoe), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            else
                call ReleaseTimer(t)
                call DestroyGroup(group)
                call deallocate()
                
                set t = null
                set group = null
                set player = null
            endif
        endmethod
        
        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call SetUnitTimeScale(unit, 1)
            call ReleaseTimer(timer)
            
            set timer = null
            set unit = null
        endmethod
    
        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()
            local unit dummy = DummyRetrieve(Spell.source.player, Spell.source.x, Spell.source.y, 0, 0)
            
            set t = NewTimerEx(this)
            set timer = NewTimerEx(this)
            set unit = Spell.source.unit
            set player = Spell.source.player
            set x = Spell.source.x
            set y = Spell.source.y
            set aoe = GetAoE(unit, Spell.level)
            set duration = GetDuration(unit, Spell.level)
            set knock = GetMaxKnockBackDuration(unit, Spell.level)
            set group = CreateGroup()
            
            call DestroyEffectTimed(AddSpecialEffectEx(MODEL, x, y, 0, SCALE), duration)
            call UnitAddAbilityTimed(dummy, REGEN_ABILITY, duration, Spell.level, true)
            call DummyRecycleTimed(dummy, duration)
            call SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            call TimerStart(timer, GetTimeScaleTime(unit, Spell.level), false, function thistype.onExpire)
            call TimerStart(t, PERIOD, true, function thistype.onPeriod)
            
            set dummy = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary