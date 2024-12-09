scope Mana
    globals
        integer BONUS_MANA
    endglobals
    
    private struct Mana extends Bonus
        private static constant integer ability = 'Z005'
        private static constant abilityintegerlevelfield field = ABILITY_ILF_MAX_MANA_GAINED
    
        method get takes unit u returns real
            return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ability), field, 0))
        endmethod

        method Set takes unit u, real value returns real
            local real percentage = GetUnitManaPercent(u)

            call BlzSetUnitMaxMana(u, R2I(BlzGetUnitMaxMana(u) - get(u)))
            call BlzSetUnitMaxMana(u, R2I(BlzGetUnitMaxMana(u) + value))
            call SetUnitManaPercentBJ(u, percentage)

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
            set BONUS_MANA = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope