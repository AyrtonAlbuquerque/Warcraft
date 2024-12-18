scope BootsOfFlames
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetLevel takes nothing returns integer
        return 15
    endfunction

    private constant function GetBonusStats takes nothing returns integer
        return 25
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfFlames extends Item
        static constant integer code = 'I010'

        real damage = 10
        real spellPower = 600
        real movementSpeed = 50

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00600|r Spell Power\n+ |cffffcc0010|r Damage\n+ |cffffcc0050|r Movement Speed\n\n|cff80ff00Active:|r |cffffcc001000|r Range Blink.\n\n|cff80ff00Passive:|r Every second all enemy units within |cffffcc00300 AoE|r take |cff00ffff" + AbilitySpellDamageEx(20, u) + " Magic|r damage.\n\nReaching level |cff80ff0015|r with this Boots in inventory grants |cffff800025 All Stats|r.")
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetHeroLevel(source) == GetLevel() and UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, BootsOfSpeed.code, HomecomingStone.code, CloakOfFlames.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope