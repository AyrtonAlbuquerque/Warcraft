scope SwordOfDomination
    struct SwordOfDomination extends Item
        static constant integer code = 'I09X'
        static integer array attack

        real damage = 2000
        real criticalChance = 0.35
        real criticalDamage = 3.5
        real spellPower = 500

        private static method onDamage takes nothing returns nothing
            local group g

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1

                if attack[Damage.source.id] >= 5 then
                    set attack[Damage.source.id] = 0
                    set g = GetEnemyUnitsInRange(Damage.source.player, Damage.target.x, Damage.target.y, 300, false, true)

                    if BlzGroupGetSize(g) > 1 then
                        call DestroyEffect(AddSpecialEffect("Thunder Slam.mdl", Damage.target.x, Damage.target.y))
                        call UnitDamageGroup(Damage.source.unit, g, 2*Damage.amount, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, "", "", true)
                    elseif BlzGroupGetSize(g) == 1 then
                        set Damage.amount = 4*Damage.amount
                        call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + Damage.amount)
                        call DestroyGroup(g)
                        call DestroyEffect(AddSpecialEffect("Thunder Slam.mdl", Damage.target.x, Damage.target.y))
                    else
                        call DestroyGroup(g)
                    endif
                endif 
            endif

            set g = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, RedemptionSword.code, 0, 0, 0, 0)
        endmethod
    endstruct
endscope