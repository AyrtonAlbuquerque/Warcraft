library Avatar requires Spell, NewBonus, Utilities
    /* ------------------------ Avatar v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard - Icon
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
    private struct Avatar extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "When activated, |cffffcc00Muradin|r gains |cffff0000" + N2S(GetBonusDamage(level), 0) + " Damage|r, |cff00ff00" + N2S(GetBonusHealth(level), 0) + " Health|r, |cff808080" + N2S(GetBonusArmor(level), 0) + " Armor|r and becomes immune to |cff00ffffMagic|r. While in |cffffcc00Avatar|r form, |cffffcc00Double Thunder|r has |cffffcc00100%|r of occuring, and |cffffcc00Storm Bolt|r and |cffffcc00Thunder Clap|r got enhanced. If |cffffcc00Storm Bolt|r kills the target unit its cooldown is reset. The second |cffffcc00Thunder Clap|r stuns enemy units instead."
        endmethod   

        private method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH, GetBonusHealth(Spell.level), BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_DAMAGE, GetBonusDamage(Spell.level), BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, GetBonusArmor(Spell.level), BUFF)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary