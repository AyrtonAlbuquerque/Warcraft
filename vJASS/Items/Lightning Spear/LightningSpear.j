scope LightningSpear
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private function GetDamage takes unit source returns real
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 50. + (0.025 * GetHeroLevel(source) * GetUnitBonus(source, BONUS_SPELL_POWER))
        else
            return 50. + (0.3 * GetUnitBonus(source, BONUS_SPELL_POWER))
        endif 
    endfunction

    private constant function GetAoE takes nothing returns real
        return 500.
    endfunction

    private constant function GetBounces takes nothing returns integer
        return 4
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct LightningSpear extends Item
        static constant integer code = 'I03V'
    
        real damage = 15
        real attackSpeed = 0.55

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0055%%|r Attack Speed\n+ |cffffcc0015|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc0020%%|r chance to release chain lightning, dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage up to |cffffcc004|r nearby enemies."        
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and GetRandomReal(1, 100) <= GetChance() then
                call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit), GetAoE(), 0.2, 0.1, GetBounces(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "BLNL", "Shock2HD.mdx", "origin", false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfLightning.code, GlovesOfSilver.code, 0, 0, 0)
        endmethod
    endstruct
endscope