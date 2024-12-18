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
        static constant integer code = 'I05A'
        static constant integer upgrade = 'I05D'
		static constant integer potion = 'A000'
		static constant integer deliver = 'A027'

        private static HashTable table

        real mana = 250
        real health = 250
        real manaRegen = 5
        real healthRegen = 5

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00250|r Health\n+ |cffffcc00250|r Mana\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc005|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Magical Growth|r: Every time you cast an |cffffcc00active|r spell, the number of charges of Wizard Stone are increased by |cffffcc001|r and your Hero |cff0080ffSpell Power|r is increased by |cffffcc001|r. When the number of charges reach |cffffcc0050|r, the Wizard Stone transforms into |cffffcc00Ancient Stone|r, |cffffcc00doubling|r all the stats given and granting an extra |cffffcc0050|r |cff0080ffSpell Power|r.\n\nCharges: |cffffcc00" + I2S(WizardStone.table[GetHandleId(i)].integer[0]) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(WizardStone.table[GetHandleId(i)].integer[1]) + "|r")
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local integer id 
            local integer j
            local item i

            if UnitHasItemOfType(caster, code) and skill != potion and skill != deliver then
                set j = 0
                loop
                    set i = UnitItemInSlot(caster, j)
                        if i != null and GetItemTypeId(i) == code then
                            set id = GetHandleId(i)
                            set table[id].integer[0] = table[id].integer[0] + GetStackIncrease()
                            set table[id].integer[1] = table[id].integer[1] + GetBonus()
        
                            call AddUnitBonus(caster, BONUS_SPELL_POWER, GetBonus())
        
                            if table[id].integer[0] >= GetMaxStacks() then
                                call table.remove(id)
                                call RemoveItem(i)
                                call UnitAddItem(caster, CreateItem(upgrade, GetUnitX(caster), GetUnitY(caster)))
                            endif
                        endif
                    set j = j + 1
                    exitwhen j >= bj_MAX_INVENTORY
                endloop
            endif

            set i = null
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call thistype.allocate(code, ElementalShard.code, 0, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope