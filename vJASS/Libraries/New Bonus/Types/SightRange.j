scope SightRange
    globals
        integer BONUS_SIGHT_RANGE
    endglobals
    
    private struct SightRange extends Bonus
        private static constant integer ability = 'Z00A'
        private static constant abilityintegerlevelfield field = ABILITY_ILF_SIGHT_RANGE_BONUS
    
        method get takes unit u returns real
            return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ability), field, 0))
        endmethod

        method Set takes unit u, real value returns real
            call BlzSetUnitRealField(u, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(u, UNIT_RF_SIGHT_RADIUS) - get(u)))
            call BlzSetUnitRealField(u, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(u, UNIT_RF_SIGHT_RADIUS) + value))

            if GetUnitAbilityLevel(u, ability) == 0 then
                call UnitAddAbility(u, ability)
                call UnitMakeAbilityPermanent(u, true, ability)
            endif
            
            if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ability), field, 0, R2I(value)) then
                call IncUnitAbilityLevel(u, ability)
                call DecUnitAbilityLevel(u, ability)
            endif
        
            return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ability), field, 0))
        endmethod

        method add takes unit u, real value returns real
            local real current = get(u)

            set value = overflow(current, R2I(value))

            call Set(u, current + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_SIGHT_RANGE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope