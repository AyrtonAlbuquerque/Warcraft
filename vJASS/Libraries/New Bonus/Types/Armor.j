scope Armor
    globals
        integer BONUS_ARMOR
    endglobals
    
    private struct Armor extends Bonus
        private static constant integer ability = 'Z002'
        private static constant abilityintegerlevelfield field = ABILITY_ILF_DEFENSE_BONUS_IDEF
    
        method get takes unit u returns real
            return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, ability), field, 0))
        endmethod

        method Set takes unit u, real value returns real
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
            set BONUS_ARMOR = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope