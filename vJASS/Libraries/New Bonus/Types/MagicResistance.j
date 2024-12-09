scope MagicResistence
    globals
        integer BONUS_MAGIC_RESISTANCE
    endglobals
    
    private struct MagicResistence extends Bonus
        private static constant integer ability = 'Z00B'
        private static constant abilityreallevelfield field = ABILITY_RLF_DAMAGE_REDUCTION_ISR2
    
        method get takes unit u returns real
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
        endmethod

        method Set takes unit u, real value returns real
            if GetUnitAbilityLevel(u, ability) == 0 then
                call UnitAddAbility(u, ability)
                call UnitMakeAbilityPermanent(u, true, ability)
            endif
            
            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0, R2I(value)) then
                call IncUnitAbilityLevel(u, ability)
                call DecUnitAbilityLevel(u, ability)
            endif
        
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_MAGIC_RESISTANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope