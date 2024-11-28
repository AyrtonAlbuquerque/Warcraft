scope GoldenBoots
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
    struct GoldenBoots extends Item
        static constant integer code = 'I014'

        real damage = 15
        real lifeSteal = 0.15
        real movementSpeed = 50

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetHeroLevel(source) == GetLevel() and UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, BootsOfSpeed.code, HomecomingStone.code, RustySword.code, MaskOfDeath.code, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope