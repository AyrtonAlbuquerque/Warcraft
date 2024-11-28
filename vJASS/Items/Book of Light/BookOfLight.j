scope BookOfLight
    struct BookOfLight extends Item
        static constant integer code = 'I06K'
        static constant integer unit = 'o006'

        private static integer array burst

        private timer timer
        private integer index

        // Attributes
        real manaRegen = 200
        real intelligence = 250
        real spellPowerFlat = 600

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call ReleaseTimer(timer)

            set burst[index] = 0
            set timer = null

            call super.destroy()
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit attacker = GetAttacker()
            local integer idx = GetUnitUserData(attacker)
            local thistype this

            if GetUnitTypeId(attacker) == unit then
                if burst[idx] == 0 then
                    call AddUnitBonus(attacker, BONUS_ATTACK_SPEED, 4)
                elseif burst[idx] == 11 then
                    set this = thistype.new()
                    set timer = NewTimerEx(this)
                    set index = idx

                    call AddUnitBonus(attacker, BONUS_ATTACK_SPEED, -4)
                    call TimerStart(timer, 30, false, function thistype.onExpire)
                endif
        
                set burst[idx] = burst[idx] + 1
            endif
        endmethod
        
        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if GetUnitTypeId(Damage.source.unit) == unit and Damage.isAlly and damage > 0 then
                call BlzSetEventDamage(0)
                call SetWidgetLife(Damage.target.unit, GetWidgetLife(Damage.target.unit) + damage)
                call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), Damage.target.unit)
                call DestroyEffect(AddSpecialEffectTarget("HolyLight.mdx", Damage.target.unit, "origin"))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call thistype.allocate(code, SummoningBook.code, SphereOfDivinity.code, 0, 0, 0)
        endmethod
    endstruct
endscope