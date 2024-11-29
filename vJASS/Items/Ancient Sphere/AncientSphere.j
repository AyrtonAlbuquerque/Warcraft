scope AncientSphere 
    struct AncientSphere extends Item 
        static constant integer code = 'I070' 

        private static integer array hp
        private static integer array mp
        private static integer array hr
        private static integer array mr
        private static integer array sp
        private static boolean array check

        private unit unit
        private timer timer
        private integer index

        // Attributes
        real mana = 10000 
        real health = 10000 
        real manaRegen = 100 
        real healthRegen = 100 
        real spellPowerFlat = 100 
        
        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)

            set timer = null
            set unit = null
            set check[index] = false

            call super.destroy()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0010000|r Health\n+ |cffffcc0010000|r Mana\n+ |cffffcc00100|r Spell Power\n+ |cffffcc00100|r Health Regeneration\n+ |cffffcc00100|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Infused Enlightenment|r: Every |cffffcc0045|r seconds your Hero gains permanently |cffffcc001000|r Health, |cffffcc001000|r Mana, |cffffcc0010|r Spell Power, |cffffcc0010|r Health Regeneration and |cffffcc0010|r Mana Regeneration.\n\nHealth Bonus: |cffff0000" + I2S(hp[id]) + "|r\nMana Bonus: |cff0000ff" + I2S(mp[id]) + "|r\nHealth Regen Bonus: |cff00ff00" + I2S(hr[id]) + "|r\nMana Regen Bonus: |cff00ffff"  + I2S(mr[id]) + "|r\nSpell Power Bonus: |cff0080ff" + I2S(sp[id]) + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

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
                call UnitAddSpellPowerFlat(unit, 10)
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl", unit, "origin"))
            else
                call destroy()
            endif
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self

            if not check[id] then
                set self = thistype.new()
                set self.timer = NewTimerEx(self)
                set self.unit = u
                set self.index = id
                set check[id] = true

                call TimerStart(self.timer, 45, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onInit takes nothing returns nothing 
            call thistype.allocate(code, SphereOfPower.code, AncientStone.code, 0, 0, 0) 
        endmethod 
    endstruct 
endscope 