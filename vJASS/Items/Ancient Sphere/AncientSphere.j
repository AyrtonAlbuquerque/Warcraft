scope AncientSphere 
    struct AncientSphere extends Item 
        static constant integer code = 'I070' 

        // Attributes
        real mana = 10000 
        real health = 10000 
        real manaRegen = 100 
        real spellPower = 100 
        real healthRegen = 100 

        private static integer array hp
        private static integer array mp
        private static integer array hr
        private static integer array mr
        private static integer array sp
        private static boolean array check

        private unit unit
        private integer index
        
        method destroy takes nothing returns nothing
            set unit = null

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Health\n+ |cffffcc0010000|r Mana\n+ |cffffcc00100|r Spell Power\n+ |cffffcc00100|r Health Regeneration\n+ |cffffcc00100|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Infused Enlightenment|r: Every |cffffcc0045|r seconds your Hero gains permanently |cffffcc00500|r Health, |cffffcc00500|r Mana, |cffffcc0010|r Spell Power, |cffffcc0010|r Health Regeneration and |cffffcc0010|r Mana Regeneration.\n\nHealth Bonus: |cffff0000" + I2S(hp[id]) + "|r\nMana Bonus: |cff0000ff" + I2S(mp[id]) + "|r\nHealth Regen Bonus: |cff00ff00" + I2S(hr[id]) + "|r\nMana Regen Bonus: |cff00ffff"  + I2S(mr[id]) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(sp[id]) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            if UnitHasItemOfType(unit, code) then
                set hp[index] = hp[index] + 500
                set mp[index] = mp[index] + 500
                set hr[index] = hr[index] + 10
                set mr[index] = mr[index] + 10
                set sp[index] = sp[index] + 10

                call AddUnitBonus(unit, BONUS_HEALTH, 500)
                call AddUnitBonus(unit, BONUS_MANA, 500)
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, 10)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, 10)
                call AddUnitBonus(unit, BONUS_SPELL_POWER, 10)
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