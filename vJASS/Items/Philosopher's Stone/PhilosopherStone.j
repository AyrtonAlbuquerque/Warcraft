scope PhilosopherStone
    struct PhilosopherStone extends Item
        static constant integer code = 'I07U'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static integer array bonus
        private static boolean array check
        private static thistype array array

        private unit unit
        private player player
        private integer index
        private integer cooldown

        // Attributes
        real mana = 10000
        real health = 10000
        real healthRegen = 300
        
        private method remove takes integer i returns integer
            set array[i] = array[key]
            set key = key - 1
            set check[index] = false
            set unit = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0010000|r Mana\n+ |cffffcc0010000|r Health\n+ |cffffcc00300|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Philosopher's Stone|r, every second grants |cffffcc00250 Gold|r.\n\n|cff00ff00Passive|r: |cffffcc00Eternal Life|r: Every |cffffcc00120|r seconds |cff00ff00Health Regeneration|r is increased by |cffffcc00500|r  for |cffffcc0030|r seconds.\n\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItemOfType(unit, code) then
                        set bonus[index] = bonus[index] + 250
                        
                        call AddPlayerGold(player, 250)

                        if cooldown <= 0 then
                            set cooldown = 120

                            call AddUnitBonusTimed(unit, BONUS_HEALTH_REGEN, 500, 30)
                            call DestroyEffectTimed(AddSpecialEffectTarget("GreenHeal.mdx", unit, "origin"), 30)
                        endif

                        set cooldown = cooldown - 1
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)
            local thistype self

            if not check[id] then
                set self = thistype.new()
                set self.unit = u
                set self.player = GetOwningPlayer(u)
                set self.index = id
                set self.cooldown = 120
                set key = key + 1
                set array[key] = self
                set check[id] = true

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, ElementalShard.code, AncientStone.code, 0, 0, 0)
        endmethod
    endstruct
endscope