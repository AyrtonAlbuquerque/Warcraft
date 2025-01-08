scope CriticalChance
    globals
        integer BONUS_CRITICAL_CHANCE
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals
    
    private struct CriticalChance extends Bonus
        private static constant integer ability = 'Z00C'
        private static constant abilityreallevelfield field = ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE
    
        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return GetUnitCriticalChance(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return SetUnitCriticalChance(u, value)
            else
                if GetUnitAbilityLevel(u, ability) == 0 then
                    call UnitAddAbility(u, ability)
                    call UnitMakeAbilityPermanent(u, true, ability)
                endif
                
                if BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0, value) then
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
            set BONUS_CRITICAL_CHANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope