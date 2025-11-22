scope GlovesOfGold
    struct GlovesOfGold extends Item
        static constant integer code = 'I062'
        static integer array bonus

        real attackSpeed = 1.25

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:\n+ |cffffcc00125%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Hand of Midas|r: Every attack has |cffffcc001%|r chance to turn |cffff0000non-Hero|r targets into a pile of |cffffcc00gold|r equivalent to |cffffcc0020%|r |cffff0000Max Health|r.|r\n\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer bounty

            if UnitHasItemOfType(Damage.source.unit, code) and not Damage.target.isStructure and not IsUnitType(Damage.target.unit, UNIT_TYPE_HERO) and Damage.isEnemy and GetRandomInt(1,100) <= 1 then
                set bounty = R2I(BlzGetUnitMaxHP(Damage.target.unit) * 0.2)
                set bonus[Damage.source.id] = bonus[Damage.source.id] + bounty

                call UnitDamageTarget(Damage.source.unit, Damage.target.unit, 500000.0, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
                call AddPlayerGold(Damage.source.player, bounty)
                call CreateTextOnUnit(Damage.target.unit, ("+" + I2S(bounty)), 1.0, 255, 215, 0, 255)
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", Damage.target.unit, "origin"))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), GlovesOfSilver.code, GlovesOfSilver.code, 0, 0, 0)
        endmethod
    endstruct
endscope