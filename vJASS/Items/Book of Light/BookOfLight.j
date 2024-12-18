scope BookOfLight
    struct BookOfLight extends Item
        static constant integer code = 'I06K'
        static constant integer unit = 'o006'

        // Attributes
        real manaRegen = 200
        real intelligence = 250
        real spellPower = 600

        private static integer array burst

        private integer index

        method destroy takes nothing returns nothing
            set burst[index] = 0
            call super.destroy()
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit attacker = GetAttacker()
            local integer id = GetUnitUserData(attacker)
            local thistype this

            if GetUnitTypeId(attacker) == unit then
                if burst[id] == 0 then
                    call AddUnitBonus(attacker, BONUS_ATTACK_SPEED, 4)
                elseif burst[id] == 11 then
                    set this = thistype.new()
                    set index = id

                    call StartTimer(30, false, this, -1)
                    call AddUnitBonus(attacker, BONUS_ATTACK_SPEED, -4)
                endif
        
                set burst[id] = burst[id] + 1
            endif
        endmethod
        
        private static method onDamage takes nothing returns nothing
            local real damage = Damage.amount

            if GetUnitTypeId(Damage.source.unit) == unit and Damage.isAlly and Damage.amount > 0 then
                set Damage.amount = 0

                call SetWidgetLife(Damage.target.unit, GetWidgetLife(Damage.target.unit) + damage)
                call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), Damage.target.unit)
                call DestroyEffect(AddSpecialEffectTarget("HolyLight.mdx", Damage.target.unit, "origin"))
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call thistype.allocate(code, SummoningBook.code, SphereOfDivinity.code, 0, 0, 0)
        endmethod
    endstruct
endscope