scope RunicBoots
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetLevel takes nothing returns integer
        return 15
    endfunction

    private constant function GetBonusStats takes nothing returns integer
        return 25
    endfunction

    private constant function GetHealth takes nothing returns real
        return 50.
    endfunction

    private constant function GetMana takes nothing returns real
        return 50.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct RunicBoots extends Item
        static constant integer code = 'I022'
        static constant integer ability = 'A02C'

        real mana = 150
        real health = 150
        real spellPower = 20
        real movementSpeed = 75

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r \n+ |cffffcc00150|r Health \n+ |cffffcc00150|r Mana \n+ |cffffcc0020|r Spell Power \n+ |cffffcc0075|r Movement Speed \n\n|cff80ff00Active:|r|cffffcc00 Restoration: |rHeals Health and Mana for |cffffcc00" + R2I2S(GetHealth() * GetHeroLevel(u)) + "|r. \n\nReaching level |cff80ff0015 |rgrants |cffff800025 All Stats|r. \n\n10 seconds cooldown."
        endmethod

        private static method onCast takes nothing returns nothing
            call SetWidgetLife(Spell.source.unit, (GetWidgetLife(Spell.source.unit) + (GetHealth() * GetHeroLevel(Spell.source.unit))))
            call SetUnitState(Spell.source.unit, UNIT_STATE_MANA, (GetUnitState(Spell.source.unit, UNIT_STATE_MANA) + (GetMana() * GetHeroLevel(Spell.source.unit))))
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetHeroLevel(source) == GetLevel() and UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, LifeCrystal.code, ManaCrystal.code, 0, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope