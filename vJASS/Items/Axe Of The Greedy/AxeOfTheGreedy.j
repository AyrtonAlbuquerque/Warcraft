scope GreedyAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I05H'
        static constant real period  = 0.25
    endmodule

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
        implement Configuration

        real criticalChance = 25
        real criticalDamage = 1
        real damage = 45

        private static integer array gold
        private static thistype array struct
        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()

        private unit unit
        private integer index
        private real duration

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0045|r Damage\n+ |cffffcc0025%|r Critical Strike Chance\n+ |cffffcc00100%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Pillage|r: After hitting a critical strike, for the next |cffffcc003 |rseconds, the Hero gains |cffffcc0050% |rAttack Speed bonus and every attack grants |cffffcc00Gold |requal to |cffffcc002.5% (25% against Heroes)|r of the damage dealt.\n\nGold Granted: |cffffcc00" + I2S(GreedyAxe.gold[id]) + "|r")
        endmethod

        private method remove takes integer i returns integer
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -GetAttackSpeedBonus())

            set array[i] = array[key]
            set key = key - 1
            set struct[index] = 0
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif

                    set duration = duration - period
                set i = i + 1
            endloop
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id    
            local thistype this

            if UnitHasItemOfType(source, item) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                set id = GetUnitUserData(source)

                if struct[id] != 0 then
                    set this = struct[id]
                else
                    set this = thistype.allocate(item)
                    set unit = source
                    set index = id
                    set key = key + 1
                    set array[key] = this
                    set struct[id] = this

                    call AddUnitBonus(source, BONUS_ATTACK_SPEED, GetAttackSpeedBonus())

                    if key == 0 then
                        call TimerStart(timer, period, true, function thistype.onPeriod)
                    endif
                endif

                set duration = GetDuration()
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer pillage 

            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and struct[Damage.source.id] != 0 then
                call DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", Damage.target.unit, "origin"))

                if IsUnitType(Damage.target.unit, UNIT_TYPE_HERO) then
                    set pillage = R2I(GetEventDamage()*GetHeroFactor())
                    set gold[Damage.source.id] = gold[Damage.source.id] + pillage
                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                else
                    set pillage = R2I(GetEventDamage()*GetFactor())
                    set gold[Damage.source.id] = gold[Damage.source.id] + pillage
                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                endif
            endif
        endmethod

        private static  method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
        endmethod
    endstruct
endscope