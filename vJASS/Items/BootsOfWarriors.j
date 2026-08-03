scope BootsOfWarriors
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusPerLevel takes nothing returns integer
        return 2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfWarriors extends Item
        static constant integer code = 'I00U'

        real damage = 15
        real lifeSteal = 0.15
        real movementSpeed = 50

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusPerLevel(), GetBonusPerLevel(), GetBonusPerLevel())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, HomecomingOrb.code, RustySword.code, MaskOfDeath.code, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope