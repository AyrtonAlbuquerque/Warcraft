scope GreedAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetFactor takes nothing returns real
        return 0.025
    endfunction

    private constant function GetHeroFactor takes nothing returns real
        return 0.25
    endfunction

    private constant function GetAvarice takes nothing returns real
        return 0.03
    endfunction

    private constant function GetAvariceGold takes nothing returns integer
        return 500
    endfunction

    private constant function GetAttackSpeedBonus takes nothing returns real
        return 0.5
    endfunction

    private constant function GetDuration takes nothing returns real
        return 3.
    endfunction

    private constant function GetHighLevelThreshold takes nothing returns integer
        return 6
    endfunction

    private function GetBonusCriticalDamage takes unit source, integer level, player owner returns real
        return R2I(GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) / GetAvariceGold()) * GetAvarice()
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GreedAxe extends Item
        static constant integer code = 'I01Z'
        private static integer array gained
        private static thistype array array
        private static thistype array struct

        // Attributes
        real damage = 45
        real criticalDamage = 0.2
        real criticalChance = 0.25
        real armorPenetration = 0.2

        private unit unit
        private real bonus
        private timer timer
        private integer type
        private integer index
        private player player

        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)

            if bonus > 0 then
                call AddUnitBonus(unit, type, -bonus)
            endif

            if type == BONUS_ATTACK_SPEED then
                set array[index] = 0
            else
                set struct[index] = 0
            endif

            set unit = null
            set timer = null
            set player = null

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0045|r Damage\n+ |cffffcc0025%|r Critical Chance\n+ |cffffcc0020%|r Critical Damage\n+ |cffffcc0020%|r Armor Penetration\n\n|cff00ff00Passive|r: |cffffcc00Pillage|r: After hitting a |cffffcc00Critical Strike|r gain |cffffcc00" + N2S(GetAttackSpeedBonus() * 100, 0) + "%|r |cffffcc00Attack Speed|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds and every attack grants |cffffcc00Gold|r equal to |cffffcc00" + N2S(GetFactor() * 100, 1) + "%|r (|cffffcc00" + N2S(GetHeroFactor() * 100, 0) + "%|r against |cffffcc00Heroes|r and |cffffcc00High-Level|r units) of the damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Avarice|r: Gain |cffffcc00" + N2S(GetAvarice() * 100, 0) + "%|r Critical Damage|r for every |cffffcc00" + I2S(GetAvariceGold()) + " Gold.|r\n\nGold Granted: |cffffcc00" + I2S(gained[id]) + "|r\nBonus |cffffcc00Critical Damage|r: " + "|cffffcc00" + N2S(GetBonusCriticalDamage(u, GetWidgetLevel(u), GetOwningPlayer(u)) * 100, 0) + "%|r"
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if UnitHasItemOfType(unit, code) then
                call AddUnitBonus(unit, type, -bonus)
                set bonus = GetBonusCriticalDamage(unit, GetWidgetLevel(unit), player)
                call AddUnitBonus(unit, type, bonus)
            else
                call destroy()
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private method onPickup takes unit u, item i returns nothing
            if UnitCountItemOfType(u, code) == 1 then
                set this = thistype.allocate(0)
                set unit = u
                set index = GetUnitUserData(u)
                set player = GetOwningPlayer(u)
                set type = BONUS_CRITICAL_DAMAGE
                set timer = NewTimerEx(this)
                set bonus = GetBonusCriticalDamage(unit, GetWidgetLevel(unit), player)
                set struct[index] = this

                call AddUnitBonus(unit, type, bonus)
                call TimerStart(timer, 0.5, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source) 
            local thistype this = array[id]

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = source
                    set index = id
                    set type = BONUS_ATTACK_SPEED
                    set timer = NewTimerEx(this)
                    set bonus = GetAttackSpeedBonus()
                    set array[id] = this

                    call AddUnitBonus(unit, type, bonus)
                endif

                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif

            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer pillage

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and array[Damage.source.id] != 0 then
                call DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", Damage.target.unit, "origin"))

                if Damage.target.isHero or Damage.target.level > GetHighLevelThreshold() then
                    set pillage = R2I(Damage.amount * GetHeroFactor())
                    set gained[Damage.source.id] = gained[Damage.source.id] + pillage

                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                else
                    set pillage = R2I(Damage.amount * GetFactor())
                    set gained[Damage.source.id] = gained[Damage.source.id] + pillage
                    
                    call AddPlayerGold(Damage.source.player, pillage)
                    call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(pillage)), 0.75, 255, 215, 0, 255)
                endif
            endif
        endmethod

        private static  method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), GlovesOfSteel.code, WarriorBlade.code, GreatAxe.code, 0, 0) 
        endmethod
    endstruct
endscope