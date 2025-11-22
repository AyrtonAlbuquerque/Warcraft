scope SaphireShoulderPlate
    struct SaphireShoulderPlate extends Item
        static constant integer code = 'I05Q'

        // Attributes
        real strength = 15
        real health = 800

        private static integer array agi
        private static integer array str

        private unit unit
        private integer index

        method destroy takes nothing returns nothing
            call ArcingTextTag.create(("|cffff0000" + "-3"), unit, 0.015)
            call ArcingTextTag.create(("|cff32cd32" + "-3"), unit, 0.015)
            call deallocate()

            set str[index] = str[index] - 3
            set agi[index]  = agi[index] - 3
            set unit = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
        return "|cffffcc00Gives|r:\n+ |cffffcc00800|r Health\n+ |cffffcc0015|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Will|r: Every attack taken has |cffffcc0010%%|r chance to increase Hero |cffff0000Strength|r and |cff00ff00Agility|r by |cffffcc003|r for |cffffcc0030|r seconds.\n\nCurrent Strength Bonus: |cffff0000" + I2S(str[id]) + "|r\nCurrent Agility Bonus: |cff00ff00" + I2S(agi[id]) + "|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.target.unit, code) and GetRandomInt(1, 100) <= 10 then
                set this = thistype.allocate(0)
                set unit = Damage.target.unit
                set index = Damage.target.id
                set str[index] = str[index] + 3
                set agi[index] = agi[index] + 3

                call DestroyEffectTimed(AddSpecialEffectTarget("Blue.mdx", Damage.target.unit, "chest"), 30)
                call AddUnitBonusTimed(Damage.target.unit, BONUS_STRENGTH, 3, 30)
                call AddUnitBonusTimed(Damage.target.unit, BONUS_AGILITY, 3, 30)
                call ArcingTextTag.create(("|cffff0000" + "+3"), Damage.target.unit, 0.015)
                call ArcingTextTag.create(("|cff32cd32" + "+3"), Damage.target.unit, 0.015)
                call StartTimer(30, false, this, -1)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), FusedLifeCrystals.code, EmeraldShoulderPlate.code, 0, 0, 0)
        endmethod
    endstruct
endscope