scope SphereOfLightning
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 500.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 100.
    endfunction

    private constant function GetCount takes nothing returns integer
        return 4
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
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
    struct SphereOfLightning extends Item
        static constant integer code = 'I04T'
        static constant real period = 0.25

        private timer timer
        private unit unit
        private group group
        private integer procs

        // Attributes
        real spellPowerFlat = 50

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call super.destroy()

            set unit = null
            set timer = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Thunder Bolt|r: Every attack has |cffffcc0020%|r to call down thunder bolts on the target and up to |cffffcc004|r nearby enemy units within |cffffcc00500|r AoE, dealing |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) + "|r |cff0080ffMagic|r damage.")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u

            if procs > 0 then
                if BlzGroupGetSize(group) > 0 then
                    set u = GroupPickRandomUnitEx(group)
                    call UnitDamageTarget(unit, u, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    call DestroyEffect(AddSpecialEffect("Lightnings.mdx", GetUnitX(u), GetUnitY(u)))
                    call GroupRemoveUnit(group, u)
                    set u = null
                else
                    call destroy()
                endif
            else
                call destroy()
            endif

            set procs = procs - 1
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                set this = thistype.new()
                set timer = NewTimerEx(this)
                set unit = Damage.source.unit
                set group = GetEnemyUnitsInRange(Damage.source.player, Damage.target.x, Damage.target.y, GetAoE(), false, false)
                set procs = GetCount()

                call GroupRemoveUnit(group, Damage.target.unit)
                call UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                call DestroyEffect(AddSpecialEffect("Lightnings.mdx", Damage.target.x, Damage.target.y))
                call TimerStart(timer, period, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, OrbOfLightning.code, SphereOfPower.code, 0, 0, 0)
        endmethod
    endstruct
endscope