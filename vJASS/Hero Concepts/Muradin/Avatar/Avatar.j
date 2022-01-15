library Avatar requires SpellEffectEvent, NewBonusUtils
    /* ------------------------ Avatar v1.2 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Avatar ability
        public  constant integer ABILITY = 'A008'
        // The raw code of the Avatar buff
        public  constant integer BUFF    = 'BHav'
    endglobals

    // The Health Bonus
    private function GetBonusHealth takes integer level returns integer
        return 500 + 500*level
    endfunction

    // The Damage Bonus
    private function GetBonusDamage takes integer level returns integer
        return 50*level
    endfunction

    // The Armor Bonus
    private function GetBonusArmor takes integer level returns integer
        return 10*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Avatar extends array
        private static method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH, GetBonusHealth(Spell.level), BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_DAMAGE, GetBonusDamage(Spell.level), BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, GetBonusArmor(Spell.level), BUFF)
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary