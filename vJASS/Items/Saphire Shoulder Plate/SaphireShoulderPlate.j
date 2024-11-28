scope SaphireShoulderPlate
    struct SaphireShoulderPlate extends Item
        static constant integer code = 'I05Q'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        readonly static integer array agi
        readonly static integer array str

        private unit unit
        private integer index
        private integer duration
        
        // Attributes
        real strength = 150
        real health = 15000

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0015000|r Health\n+ |cffffcc00150|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Will|r: Every attack taken has |cffffcc0010%|r chance to increase Hero |cffff0000Strength|r and |cff00ff00Agility|r by |cffffcc0010|r for 30 seconds.\n\nCurrent Strength Bonus: |cffff0000" + I2S(str[id]) + "|r\nCurrent Agility Bonus: |cff00ff00" + I2S(agi[id]) + "|r")
        endmethod

        private method remove takes integer i returns integer
            call AddUnitBonus(unit, BONUS_STRENGTH, -10)
            call AddUnitBonus(unit, BONUS_AGILITY, -10)
            call ArcingTextTag.create(("|cffff0000" + "-10"), unit)
            call ArcingTextTag.create(("|cff32cd32" + "-10"), unit)

            set str[index] = str[index] - 10
            set agi[index]  = agi[index] - 10
            set array[i] = array[key]
            set key = key - 1
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif

                    set duration = duration - 1
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.target.unit, code) and GetRandomInt(1, 100) <= 10 then
                set this = thistype.new()
                set unit = Damage.target.unit
                set index = Damage.target.id
                set duration = 30
                set key = key + 1
                set array[key] = this
                set str[index] = str[index] + 10
                set agi[index] = agi[index] + 10

                call DestroyEffect(AddSpecialEffectTarget("Blue.mdx", Damage.target.unit, "chest"))
                call AddUnitBonus(Damage.target.unit, BONUS_STRENGTH, 10)
                call AddUnitBonus(Damage.target.unit, BONUS_AGILITY, 10)
                call ArcingTextTag.create(("|cffff0000" + "+10"), Damage.target.unit)
                call ArcingTextTag.create(("|cff32cd32" + "+10"), Damage.target.unit)

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, FusedLifeCrystals.code, EmeraldShoulderPlate.code, 0, 0, 0)
        endmethod
    endstruct
endscope