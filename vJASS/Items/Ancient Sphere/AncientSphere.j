scope AncientSphere 
    struct AncientSphere extends Item 
        static constant integer code = 'I070' 

        // Attributes
        real mana = 500 
        real health = 500 
        real manaRegen = 10
        real spellPower = 100
        real healthRegen = 10

        private static real array hr
        private static real array mr
        private static integer array hp
        private static integer array mp
        private static integer array sp
        private static boolean array check

        private unit unit
        private integer index
        
        method destroy takes nothing returns nothing
            set unit = null

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00500|r Health\n+ |cffffcc00500|r Mana\n+ |cffffcc00100|r Spell Power\n+ |cffffcc0010|r Health Regeneration\n+ |cffffcc0010|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Infused Enlightenment|r: Every |cffffcc0045|r seconds gains |cffff000050 Health|r, |cff8080ff50 Mana|r, |cff00ffff5 Spell Power|r, |cff00ff000.25 Health Regeneration|r and |cff8080ff0.25 Mana Regeneration|r permanently.\n\nHealth Bonus: |cffff0000" + I2S(hp[id]) + "|r\nMana Bonus: |cff0000ff" + I2S(mp[id]) + "|r\nHealth Regen Bonus: |cff00ff00" + N2S(hr[id], 2) + "|r\nMana Regen Bonus: |cff00ffff"  + N2S(mr[id], 2) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(sp[id]) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            if UnitHasItemOfType(unit, code) then
                set hp[index] = hp[index] + 50
                set mp[index] = mp[index] + 50
                set hr[index] = hr[index] + 0.25
                set mr[index] = mr[index] + 0.25
                set sp[index] = sp[index] + 5

                call AddUnitBonus(unit, BONUS_HEALTH, 50)
                call AddUnitBonus(unit, BONUS_MANA, 50)
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, 0.25)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, 0.25)
                call AddUnitBonus(unit, BONUS_SPELL_POWER, 5)
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl", unit, "origin"))
            
                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local thistype self
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set self = thistype.allocate(0)
                set self.unit = u
                set self.index = id

                call StartTimer(45, true, self, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing 
            call RegisterItem(allocate(code), SphereOfPower.code, AncientStone.code, 0, 0, 0) 
        endmethod 
    endstruct 
endscope 