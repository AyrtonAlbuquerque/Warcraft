scope LightningSpear
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private function GetDamage takes unit source returns real
        return (5. * GetWidgetLevel(source)) + ((0.05 * GetWidgetLevel(source) * (BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE)))) + (0.025 * GetWidgetLevel(source) * GetUnitBonus(source, BONUS_SPELL_POWER))
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
        static constant integer code = 'I014'
    
        real damage = 15
        real spellPower = 15
        real attackSpeed = 0.25

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0015|r Damage\n+ |cffffcc0015|r Spell Power\n+ |cffffcc0025%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Chain Lightning|r: Every attack has |cffffcc00" + N2S(GetChance(), 0) + "%|r chance to release a chain lightning, dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage up to |cffffcc00" + N2S(GetBounces(), 0) + "|r nearby enemies."   
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and GetRandomReal(0, 100) <= GetChance() then
                call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit), GetAoE(), 0.2, 0.1, GetBounces(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, "BLNL", "Shock2HD.mdx", "origin", false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), GlovesOfHaste.code, MageStick.code, RustySword.code, OrbOfLightning.code, 0)
        endmethod
    endstruct
endscope