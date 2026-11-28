scope CrowsMantle
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetShieldAmount takes unit source returns real
        return (0.3 * BlzGetUnitMaxHP(source)) + (0.8 * GetUnitBonus(source, BONUS_SPELL_POWER)) + (20 * GetUnitBonus(source, BONUS_MAGIC_RESISTANCE))
    endfunction

    private constant function GetDuration takes nothing returns real
        return 20.
    endfunction

    private constant function GetCooldown takes nothing returns real
        return 90.
    endfunction

    private constant function GetHealthFactor takes nothing returns real
        return 0.5
    endfunction
    
    private constant function GetMaxStacks takes nothing returns real
        return 2.
    endfunction

    private constant function GetBaseMultiplier takes nothing returns real
        return 0.5
    endfunction

    private constant function GetMultiplierIncrement takes nothing returns real
        return 0.25
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct CrowsMantle extends Item
        static constant integer code = 'I022'
        private static thistype array array
        private static timer array cooldown
        private static real array stacks
        
        // Attributes
        real mana = 500
        real healing = 0.2
        real tenacity = 0.2
        real magicResistance = 10

        private unit unit
        private real bonus
        private timer timer
        private Shield shield
        private integer index

        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)

            if shield != 0 then
                call DestroyShield(shield)

                set shield = 0
                set array[index] = 0
            endif
            
            if not UnitHasItemOfType(unit, code) then
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -bonus)

                set bonus = 0
                set stacks[index] = 0
            endif

            set unit = null
            set timer = null

            call deallocate()
        endmethod

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00500|r Mana\n+ |cffffcc0020%|r Healing\n+ |cffffcc0020%|r Resolve\n+ |cffffcc0010|r Magic Resistance\n\n|cff00ff00Passive|r: |cffffcc00Dark Embrace:|r Gain |cff00ff00" + N2S(stacks[id] * GetUnitBonus(u, BONUS_MAGIC_RESISTANCE), 0) + " Health Regeneration|r. Whenever taking |cff00ffffMagic|r damage, the multiplier is incresed by |cffffcc00" + N2S(GetMultiplierIncrement(), 2) + "x|r stacking up to max of |cffffcc00" + N2S(GetMaxStacks(), 0) + "x|r. Stacks lasts until leaving combat. \n\n|cff00ff00Passive|r: |cffffcc00Crow's Oath:|r When |cffff0000Health|r drops below |cffffcc00" + N2S(GetHealthFactor() * 100, 0) + "%|r, gain a |cff00ffff" + N2S(GetShieldAmount(u), 0) + "|r shield against |cff00ffffMagic|r damage for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds.\n\n|cffffcc00" + N2S(GetCooldown(), 0) + "|r seconds cooldown."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if cooldown[id] == null then
                set cooldown[id] = CreateTimer()
            endif

            if UnitCountItemOfType(u, code) == 1 then
                set this = thistype.allocate(0)
                set unit = u
                set index = id
                set timer = NewTimerEx(this)
                set stacks[index] = GetBaseMultiplier()
                set bonus = stacks[index] * GetUnitBonus(u, BONUS_MAGIC_RESISTANCE)

                call AddUnitBonus(u, BONUS_HEALTH_REGEN, bonus)
                call TimerStart(timer, 0.5, true, function thistype.onPeriod)
            endif

            call UnitStartItemCooldown(u, i, TimerGetRemaining(cooldown[id]))
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real value
            
            if UnitHasItemOfType(unit, code) then
                set value = stacks[index] * GetUnitBonus(unit, BONUS_MAGIC_RESISTANCE)

                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, value - bonus)

                set bonus = value
            else
                call destroy()
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.target.id]
        
            if UnitHasItemOfType(Damage.target.unit, code) then
                if Damage.amount > 0 and Damage.isSpell and stacks[Damage.target.id] < GetMaxStacks() then
                    set stacks[Damage.target.id] = stacks[Damage.target.id] + GetMultiplierIncrement()
                endif

                if Damage.target.health < (BlzGetUnitMaxHP(Damage.target.unit) * GetHealthFactor()) and TimerGetRemaining(cooldown[Damage.target.id]) <= 0 then
                    if this == 0 then
                        set this = thistype.allocate(0)
                        set index = Damage.target.id
                        set timer = NewTimerEx(this)
                        set shield = CreateShield(Damage.target.unit, Damage.target.unit, GetShieldAmount(Damage.target.unit), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_ANY, 0, "Crows.mdl", "origin", true, 2, true)
                        set array[Damage.target.id] = this
                    else
                        call ShieldAddAmount(shield, GetShieldAmount(Damage.target.unit))
                    endif
                    
                    call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
                    call TimerStart(cooldown[Damage.target.id], GetCooldown(), false, null)
                    call UnitStartItemTypeCooldown(Damage.target.unit, code, GetCooldown())
                endif
            endif
        endmethod

        private static method onBreak takes nothing returns nothing
            local thistype this = array[GetUnitUserData(GetShieldingTarget())]

            if this != 0 then
                if shield == GetTriggerShield() then
                    call destroy()
                endif
            endif
        endmethod

        private static method onLeave takes nothing returns nothing
            local unit source = GetCombatSourceUnit()

            if UnitHasItemOfType(source, code) then
                set stacks[GetUnitUserData(source)] = GetBaseMultiplier()
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ManaCrystal.code, WarriorHelmet.code, NoviceCloak.code, 0, 0)
            call RegisterUnitLeaveCombatEvent(function thistype.onLeave)
            call RegisterShieldBreakEvent(function thistype.onBreak)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope