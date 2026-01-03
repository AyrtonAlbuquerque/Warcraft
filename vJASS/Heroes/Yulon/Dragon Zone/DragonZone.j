library DragonZone requires Spell, Utilities, CrowdControl, Modules optional NewBonus
    /* ---------------------- Dragon Zone v1.3 by Chopinski --------------------- */
    // Credits:
    //     AZ             - Model
    //     N-ix Studio    - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ability
        private constant integer ABILITY          = 'Yul5'
        // The raw code of the regen ability
        private constant integer REGEN_ABILITY    = 'Yul6'
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

    // The bonus regeneration
    private function GetBonusRegen takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25 * level + (0.05 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25 * level
        endif
    endfunction

    // The AOE
    private function GetAoE takes unit source, integer level returns real
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
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
    private struct DragonZone extends Spell
        private real x
        private real y
        private real aoe
        private unit unit
        private real knock
        private group group
        private real duration
        private player player
        
        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()
            
            set unit = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r creates a safe zone around himself. The zone heals any allied unit within it for |cff00ff00" + N2S(GetBonusRegen(source, level), 1) + " Health Regeneration|r bonus and knocks back any enemy unit that tries to get through it. |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r zone. Lasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u
            local real angle
            local real distance
            
            set duration = duration - PERIOD

            if duration > 0 then            
                call GroupEnumUnitsInRange(group, x, y, aoe, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) then
                            if not IsUnitKnockedBack(u) then
                                set angle = AngleBetweenCoordinates(x, y, GetUnitX(u), GetUnitY(u))
                                set distance = DistanceBetweenCoordinates(x, y, GetUnitX(u), GetUnitY(u))
                                
                                call KnockbackUnit(u, angle, aoe + 25 - distance, knock*(distance/aoe), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif

            return duration > 0
        endmethod
        
        private method onExpire takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
        endmethod
    
        private method onCast takes nothing returns nothing
            local unit dummy = DummyRetrieve(Spell.source.player, Spell.source.x, Spell.source.y, 0, 0)
            local ability spell
            
            set this = thistype.allocate()
            set x = Spell.source.x
            set y = Spell.source.y
            set unit = Spell.source.unit
            set player = Spell.source.player
            set group = CreateGroup()
            set aoe = GetAoE(unit, Spell.level)
            set duration = GetDuration(unit, Spell.level)
            set knock = GetMaxKnockBackDuration(unit, Spell.level)
            
            call DestroyEffectTimed(AddSpecialEffectEx(MODEL, x, y, 0, SCALE), duration)
            call UnitAddAbilityTimed(dummy, REGEN_ABILITY, duration, 1, true)
            set spell = BlzGetUnitAbility(dummy, REGEN_ABILITY)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED, 0, GetBonusRegen(unit, Spell.level))
            call IncUnitAbilityLevel(dummy, REGEN_ABILITY)
            call DecUnitAbilityLevel(dummy, REGEN_ABILITY)
            call DummyRecycleTimed(dummy, duration)
            call SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            call StartTimer(PERIOD, true, this, 0)
            call StartTimer(GetTimeScaleTime(unit, Spell.level), false, this, 0)
            
            set dummy = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary