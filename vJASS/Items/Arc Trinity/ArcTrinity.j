scope ArcTrinity
    struct ArcTrinity extends Item
        static constant integer code = 'I0A0'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static thistype array array
        private static integer array struct
        
        private unit unit
        private integer index
        private integer duration
        private Table table

        // Attributes
        real damage = 2000
        real criticalDamage = 3
        real criticalChance = -30

        private method remove takes integer i returns integer
            call DestroyEffect(table.effect[0])
            call DestroyEffect(table.effect[1])
            call AddUnitBonus(unit, BONUS_SPELL_VAMP, -1)
            call AddUnitBonus(unit, BONUS_LIFE_STEAL, -1)
            call AddUnitBonus(unit, BONUS_DAMAGE, -3000)
            call table.destroy()

            set array[i] = array[key]
            set key = key - 1
            set struct[index] = 0
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
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

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source)
            local thistype this

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                if struct[id] != 0 then
                    set this = struct[id]
                else
                    set this = thistype.new()
                    set table = Table.create()
                    set unit = source
                    set index = id
                    set key = key + 1
                    set array[key] = this
                    set struct[id] = this
                    set table.effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", source, "hand left")
                    set table.effect[1] = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", source, "hand right")

                    call AddUnitBonus(source, BONUS_SPELL_VAMP, 1)
                    call AddUnitBonus(source, BONUS_LIFE_STEAL, 1)
                    call AddUnitBonus(source, BONUS_DAMAGE, 3000)

                    if key == 0 then
                        call TimerStart(timer, 1, true, function thistype.onPeriod)
                    endif
                endif

                set duration = 10
            endif

            set target = null
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, TriedgeSword.code, TriedgeSword.code, TriedgeSword.code, 0, 0)
        endmethod
    endstruct
endscope