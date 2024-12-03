scope PhilosopherStone
    struct PhilosopherStone extends Item
        static constant integer code = 'I07U'

        // Attributes
        real mana = 10000
        real health = 10000
        real healthRegen = 300

        private static integer array bonus

        private unit unit
        private player player
        private integer index
        private integer cooldown
        
        method destroy takes nothing returns nothing
            set unit = null
            set player = null

            call super.destroy()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0010000|r Mana\n+ |cffffcc0010000|r Health\n+ |cffffcc00300|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Philosopher's Stone|r, every second grants |cffffcc00250 Gold|r.\n\n|cff00ff00Passive|r: |cffffcc00Eternal Life|r: Every |cffffcc00120|r seconds |cff00ff00Health Regeneration|r is increased by |cffffcc00500|r  for |cffffcc0030|r seconds.\n\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

        private method onPeriod takes nothing returns boolean
            if UnitHasItemOfType(unit, code) then
                set bonus[index] = bonus[index] + 250
                
                call AddPlayerGold(player, 250)

                if cooldown <= 0 then
                    set cooldown = 120

                    call AddUnitBonusTimed(unit, BONUS_HEALTH_REGEN, 500, 30)
                    call DestroyEffectTimed(AddSpecialEffectTarget("GreenHeal.mdx", unit, "origin"), 30)
                endif

                set cooldown = cooldown - 1
            
                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self

            if not HasStartedTimer(id) then
                set self = thistype.new()
                set self.unit = u
                set self.player = GetOwningPlayer(u)
                set self.index = id
                set self.cooldown = 120

                call StartTimer(1, true, self, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, ElementalShard.code, AncientStone.code, 0, 0, 0)
        endmethod
    endstruct
endscope