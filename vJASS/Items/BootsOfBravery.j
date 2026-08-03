scope BootsOfBravery
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusStats takes nothing returns integer
        return 2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfBravery extends Item
        static constant integer code = 'I00X'

        real health = 250
        real movementSpeed = 50
        real attackSpeed = 0.15
        real cooldownReduction = 0.15

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, HomecomingOrb.code, GlovesOfHaste.code, LifeCrystal.code, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope