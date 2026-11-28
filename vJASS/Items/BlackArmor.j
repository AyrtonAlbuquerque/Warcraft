scope BlackArmor
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source, integer level returns real
        return (10 * level) + (0.1 * level * BlzGetUnitArmor(source)) + (0.1 * level * GetUnitBonus(source, BONUS_MAGIC_RESISTANCE))
    endfunction

    private constant function GetDamageTreshold takes nothing returns real
        return 5000.
    endfunction

    private constant function GetBonusArmor takes nothing returns integer
        return 1
    endfunction

    private constant function GetBonusMagicResistance takes nothing returns integer
        return 1
    endfunction
    
    private constant function GetDamageReduction takes nothing returns real
        return 0.2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BlackArmor extends Item
        static constant integer code = 'I023'
        private static real array stored  
        private static integer array ar
        private static integer array mr

        // Attributes
        real armor = 8
        real health = 600
        real magicResistance = 8

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc008|r Armor\n+ |cffffcc008|r Magic Resistance\n+ |cffffcc00600|r Health\n\n|cff00ff00Passive|r: |cffffcc00Impenetrable|r: All damage taken is reduced by |cffffcc00" + N2S(GetDamageReduction() * 100, 0) + "%|r and is stored. When all damage stored reaches |cffffcc00" + N2S(GetDamageTreshold(), 0) + "|r, |cff808080Armor|r and |cff00ffffMagic Resistance|r are increased by |cffffcc00" + N2S(GetBonusArmor(), 0) + "|r permanently.\n\n|cff00ff00Passive|r: |cffffcc00Spiked Plate|r: When being attacked, returns |cffffcc00" + N2S(GetDamage(u, GetWidgetLevel(u)), 0) + " Pure|r damage.\n\nBonus |cff808080Armor|r: |cffffcc00" + I2S(ar[id]) + "|r\nBonus |cff00ffffMagic Resistance|r: |cffffcc00" + I2S(mr[id]) + "|r\nDamage Reduced: |cffffcc00" + N2S(stored[id], 0) + "|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            local real reduced

            if UnitHasItemOfType(Damage.target.unit, code) and Damage.amount > 0 and Damage.isEnemy and Damage.damagetype != DAMAGE_TYPE_UNIVERSAL then
                set reduced = Damage.amount * GetDamageReduction()
                set Damage.amount = Damage.amount - reduced

                if (stored[Damage.target.id] + reduced) >= GetDamageTreshold() then
                    set ar[Damage.target.id] = ar[Damage.target.id] + GetBonusArmor()
                    set mr[Damage.target.id] = mr[Damage.target.id] + GetBonusMagicResistance()

                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, GetBonusArmor())
                    call AddUnitBonus(Damage.target.unit, BONUS_MAGIC_RESISTANCE, GetBonusMagicResistance())
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", Damage.target.unit, "origin"))

                    if (stored[Damage.target.id] + reduced) > 5000 then
                        set stored[Damage.target.id] = ((stored[Damage.target.id] + reduced) - GetDamageTreshold())
                    else
                        set stored[Damage.target.id] = 0
                    endif
                else
                    set stored[Damage.target.id] = stored[Damage.target.id] + reduced
                endif

                if Damage.isAttack then
                    call UnitDamageTarget(Damage.target.unit, Damage.source.unit, GetDamage(Damage.target.unit, Damage.target.level), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), NoviceCloak.code, SoldierChestPlate.code, 0, 0, 0)
        endmethod
    endstruct
endscope