scope WizardStone
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetStackIncrease takes nothing returns integer
        return 1
    endfunction

    private constant function GetBonus takes nothing returns integer
        return 1
    endfunction

    private constant function GetMaxStacks takes nothing returns integer
        return 50
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WizardStone extends Item
        static constant integer code = 'I01H'

        real mana = 300
        real health = 300
        real manaRegen = 5
        real healthRegen = 5

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00300|r Health\n+ |cffffcc00300|r Mana\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc005|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Magical Growth|r: Casting an |cffffcc00active|r spell increases the number of charges of |cffffcc00Wizard Stone|r by |cffffcc00" + N2S(GetStackIncrease(), 0) + "|r and gain |cff00ffff" + N2S(GetBonus(), 0) + " Spell Power|r permanently. When the number of charges reach |cffffcc00" + N2S(GetMaxStacks(), 0) + "|r, |cffffcc00Wizard Stone|r transforms into |cffffcc00Ancient Stone|r, |cffffcc00doubling|r all the stats given and granting extra |cff00ffff" + N2S(GetMaxStacks() * GetBonus(), 0) + " Spell Power|r."
        endmethod

        private static method onCast takes nothing returns nothing
            local integer j = 0
            local item i

            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 then
                loop
                    exitwhen j >= bj_MAX_INVENTORY
                        set i = UnitItemInSlot(Spell.source.unit, j)

                        if i != null and GetItemTypeId(i) == code then
                            call SetItemCharges(i, GetItemCharges(i) + GetStackIncrease())
                            call AddUnitBonus(Spell.source.unit, BONUS_SPELL_POWER, GetBonus())

                            if GetItemCharges(i) >= GetMaxStacks() then
                                call RemoveItem(i)
                                call UnitAddItem(Spell.source.unit, CreateItem(AncientStone.code, GetUnitX(Spell.source.unit), GetUnitY(Spell.source.unit)))
                            endif
                        endif
                    set j = j + 1
                endloop
            endif

            set i = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ElementalShard.code, SphereOfPower.code, 0, 0, 0)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope