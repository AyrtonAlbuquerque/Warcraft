scope LifeSteal
    globals
        integer BONUS_LIFE_STEAL
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals
    
    private struct LifeSteal extends Bonus
        static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
            readonly static real array steal
            readonly static string effect = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
        else
            private static constant integer ability = 'Z00E'
            private static constant abilityreallevelfield field = ABILITY_RLF_LIFE_STOLEN_PER_ATTACK
        endif

        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return steal[GetUnitUserData(u)]
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                set steal[GetUnitUserData(u)] = value

                return value
            else
                if value == 0 then
                    call UnitRemoveAbility(u, ability)
                    return 0.
                else
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
            endif
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onDamage takes nothing returns nothing
            static if LIBRARY_DamageInterface then
                if Damage.amount > 0 and Damage.isAttack and steal[Damage.source.id] > 0 and not Damage.target.isStructure then
                    call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * steal[Damage.source.id])))
                    call DestroyEffect(AddSpecialEffectTarget(effect, Damage.source.unit, "origin"))
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_LIFE_STEAL = RegisterBonus(thistype.allocate())

            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                call RegisterAnyDamageEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endscope