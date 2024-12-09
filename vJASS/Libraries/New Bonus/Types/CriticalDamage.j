scope CriticalDamage
    globals
        integer BONUS_CRITICAL_DAMAGE
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals
    
    private struct CriticalDamage extends Bonus
        private static constant integer ability = 'Z00C'
        private static constant abilityreallevelfield field = ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2
    
        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return GetUnitCriticalMultiplier(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return SetUnitCriticalMultiplier(u, value)
            else
                if value == 0 then
                    set value = 1
                endif

                if GetUnitAbilityLevel(u, ability) == 0 then
                    call UnitAddAbility(u, ability)
                    call UnitMakeAbilityPermanent(u, true, ability)
                endif
                
                if BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0, R2I(value)) then
                    call IncUnitAbilityLevel(u, ability)
                    call DecUnitAbilityLevel(u, ability)
                endif
            
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_CRITICAL_DAMAGE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope