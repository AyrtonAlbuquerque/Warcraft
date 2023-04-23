scope SphereOfDivinity
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I04Q'
		static constant integer ability = 'A03P'
		static constant integer buff    = 'B00L'
	endmodule

    private constant function GetAoE takes nothing returns real
        return 400.
    endfunction

    private constant function GetHealthPercentage takes nothing returns real
        return 0.1
    endfunction

    private constant function GetHealFactor takes nothing returns real
        return 0.33
    endfunction

    private constant function GetChance takes nothing returns real
        return 30.
    endfunction

    private constant function GetAmplification takes nothing returns real
        return 1.2
    endfunction

    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfDivinity extends Item
        implement Configuration

        real spellPowerFlat = 50

        private static integer array touch

        private timer timer
        private integer index

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call ReleaseTimer(timer)
            set touch[index] = touch[index] - 1
            set timer = null

            call deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage     
            local thistype this

            if UnitHasItemOfType(Damage.source.unit, item) then
                call BlzSetEventDamage(GetEventDamage()*GetAmplification())

                if Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                    set this = thistype.allocate(item)
                    set timer = NewTimerEx(this)
                    set index = Damage.target.id
                    set touch[index] = touch[index] + 1

                    call CastAbilityTarget(Damage.target.unit, ability, "faeriefire", 1)
                    call TimerStart(timer, GetDuration(), true, function thistype.onExpire)
                endif
            endif

            if GetUnitAbilityLevel(Damage.target.unit, buff) > 0 and Damage.isEnemy then
                set damage = GetEventDamage()*GetHealFactor()
                call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + damage))
                call ArcingTextTag.create(("|cff32cd32" + "+" + I2S(R2I(damage))), Damage.source.unit)
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killed = GetTriggerUnit()

            if touch[GetUnitUserData(killed)] > 0 then
                call DestroyEffect(AddSpecialEffectTarget("HolyBlast.mdx", killed, "chest"))
                call HealArea(GetOwningPlayer(GetKillingUnit()), GetUnitX(killed), GetUnitY(killed), GetAoE(), BlzGetUnitMaxHP(killed)*GetHealthPercentage(), "", "")
            endif

            set killed = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope