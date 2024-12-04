scope GreedyAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetFactor takes nothing returns real
        return 0.025
    endfunction

    private constant function GetHeroFactor takes nothing returns real
        return 0.25
    endfunction

    private constant function GetAttackSpeedBonus takes nothing returns real
        return 0.5
    endfunction

    private constant function GetDuration takes nothing returns real
        return 3.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GreedyAxe extends Item
        static constant integer code = 'I05H'

        // Attributes
        real damage = 45
        real criticalDamage = 1
        real criticalChance = 25

        private static integer array bonus

        private unit unit
        private real duration

        method destroy takes nothing returns nothing
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -GetAttackSpeedBonus())
            call super.destroy()

            set unit = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0045|r Damage\n+ |cffffcc0025%%|r Critical Strike Chance\n+ |cffffcc00100%%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Pillage|r: After hitting a critical strike, for the next |cffffcc003 |rseconds, the Hero gains |cffffcc0050%% |rAttack Speed bonus and every attack grants |cffffcc00Gold|r equal to |cffffcc002.5%% (25%% against Heroes)|r of the damage dealt.\n\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 0.25

            return duration > 0
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source) 
            local thistype this = GetTimerInstance(id)

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                if this == 0 then
                    set this = thistype.new()
                    set unit = source

                    call StartTimer(0.25, true, this, id)
                    call AddUnitBonus(source, BONUS_ATTACK_SPEED, GetAttackSpeedBonus())
                endif

                set duration = GetDuration()
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer pillage

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and HasStartedTimer(Damage.source.id) then
                call DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", Damage.target.unit, "origin"))

                if IsUnitType(Damage.target.unit, UNIT_TYPE_HERO) then
                    set pillage = R2I(GetEventDamage()*GetHeroFactor())
                    set bonus[Damage.source.id] = bonus[Damage.source.id] + pillage
                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                else
                    set pillage = R2I(GetEventDamage()*GetFactor())
                    set bonus[Damage.source.id] = bonus[Damage.source.id] + pillage
                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                endif
            endif
        endmethod

        implement Periodic

        private static  method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, OrcishAxe.code, OrcishAxe.code, 0, 0, 0) 
        endmethod
    endstruct
endscope