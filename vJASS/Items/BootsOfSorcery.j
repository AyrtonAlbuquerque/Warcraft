scope BootsOfSorcery
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusStats takes nothing returns integer
        return 2
    endfunction

    private constant function GetBonusSpellPower takes nothing returns integer
        return 5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfSorcery extends Item
        static constant integer code = 'I00W'

        real mana = 250
        real spellPower = 25
        real movementSpeed = 75
        real cooldownReduction = 0.15

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
                call AddUnitBonus(source, BONUS_SPELL_POWER, GetBonusSpellPower())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, ManaCrystal.code, ScrollOfMastery.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope