scope Block
    globals
        integer BONUS_DAMAGE_BLOCK
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals
    
    private struct Block extends Bonus
        static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
            private static real array block
        else
            private static constant integer ability = 'Z00F'
            private static constant abilityreallevelfield field = ABILITY_RLF_IGNORED_DAMAGE
        endif

        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return block[GetUnitUserData(u)]
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                set block[GetUnitUserData(u)] = value

                return value
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

        private static method onDamage takes nothing returns nothing
            static if LIBRARY_DamageInterface then
                if Damage.isAttack and Damage.amount > 0 and block[Damage.target.id] > 0 then
                    if Damage.amount > block[Damage.target.id] then
                        set Damage.amount = Damage.amount - block[Damage.target.id]
                    else
                        set Damage.amount = 0
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_DAMAGE_BLOCK = RegisterBonus(thistype.allocate())

            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                call RegisterAnyDamageEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endscope