scope SoulScyther
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetKillCount takes nothing returns integer
        return 10
    endfunction

    private constant function GetBonus takes nothing returns integer
        return 1
    endfunction

    private constant function GetHeroBonus takes nothing returns integer
        return 2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SoulScyther extends Item
        static constant integer code = 'I037'
        private static integer array counter
        private static integer array stats

        real damage = 10
        real agility = 10
        real strength = 10
        real intelligence = 10

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010|r All Stats\n+ |cffffcc0010|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Soul Eater:|r Every |cffffcc0010|r enemy units killed, |cffff0000Strength|r, |cff00ff00Agility|r and |cff00ffffIntelligence|r are increased by |cffffcc001|r permanently. Killing a enemy Hero increases all stats by |cffffcc002|r.\n\nStats Bonus: |cffffcc00" + I2S(SoulScyther.stats[id]) + "|r")
        endmethod

        static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local integer amount
            local integer i

            if UnitHasItemOfType(killer, code) then
                set i = GetUnitUserData(killer)

                if IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
                    set amount = GetHeroBonus()
                    set stats[i] = stats[i] + amount
                    call UnitAddStat(killer, amount, amount, amount)
                else
                    set counter[i] = counter[i] + 1

                    if counter[i] == GetKillCount() then
                        set counter[i] = 0
                        set amount = GetBonus()
                        set stats[i] = stats[i] + amount
                        call UnitAddStat(killer, amount, amount, amount)
                    endif
                endif
            endif

            set killer = null
        endmethod
        
        static method onInit takes nothing returns nothing
            call thistype.allocate(code, RustySword.code, GlaiveScythe.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope