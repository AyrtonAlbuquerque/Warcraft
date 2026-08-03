scope BootsOfDefenders
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusStats takes nothing returns integer
        return 2
    endfunction

    private constant function GetAoE takes nothing returns real
        return 800.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    private constant function GetBonusArmor takes nothing returns integer
        return 10
    endfunction

    private constant function GetBonusMagicResistance takes nothing returns integer
        return 10
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfDefenders extends Item
        static constant integer code = 'I00Y'
        static constant integer buff = 'B002'
        static constant integer ability = 'A006'

        real armor = 5
        real health = 300
        real movementSpeed = 50
        real magicResistance = 5

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onCast takes nothing returns nothing
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, GetAoE(), null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) and IsUnitEnemy(u, Spell.source.player) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        call TauntUnit(Spell.source.unit, u, GetDuration(), "Taunt.mdl", "overhead", false)
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)
            call LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, GetBonusArmor(), buff)
            call LinkBonusToBuff(Spell.source.unit, BONUS_MAGIC_RESISTANCE, GetBonusMagicResistance(), buff)

            set g = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, LifeCrystal.code, MantleOfResistance.code, Platemail.code, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
        endmethod
    endstruct
endscope