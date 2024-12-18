scope NecklaceOfVigor
    struct NecklaceOfVigor extends Item
        static constant integer code = 'I07L'

        private static HashTable table
        private static integer array strikes

        // Attributes
        real mana = 10000
        real health = 10000
        real spellPower = 750
        
        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Health\n+ |cffffcc0010000|r Mana\n+ |cffffcc00750|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Vigorous Strike|r: After casting an ability your next basic attack will deal |cffffcc00" + R2I2S(3 * GetUnitSpellPowerFlat(u)) + "|r as bonus |cffd45e19Pure|r damage to the target.\n\nStrikes Left: |cffffcc00" + I2S(strikes[id]) + "|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.isEnemy and strikes[Damage.source.id] > 0 then
                set strikes[Damage.source.id] = strikes[Damage.source.id] - 1
                call UnitDamageTarget(Damage.source.unit, Damage.target.unit, 3*GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER), false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)

                if strikes[Damage.source.id] == 0 then
                    call DestroyEffect(table[Damage.source.id].effect[0])
                    call DestroyEffect(table[Damage.source.id].effect[1])
                    call table.remove(Damage.source.id)
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local integer index = GetUnitUserData(caster)

            if UnitHasItemOfType(caster, code) and skill != 'AIre' then
                set strikes[index] = strikes[index] + 1

                if strikes[index] == 1 then
                    set table[index].effect[0] = AddSpecialEffectTarget("Sweep_Soul_Small.mdx", caster, "hand left")
                    set table[index].effect[1] = AddSpecialEffectTarget("Sweep_Soul_Small.mdx", caster, "hand right")
                endif
            endif

            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call thistype.allocate(code, AncientStone.code, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope