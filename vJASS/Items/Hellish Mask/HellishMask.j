scope HellishMask
    struct HellishMask extends Item
        static constant integer code = 'I06R'
        
        private static integer key = -1
        private static timer timer = CreateTimer()
        private static HashTable table
        private static thistype array array
        private static integer array bonus

        private unit unit
        private integer index
        private integer target
        private integer source
        private integer duration
        
        // Attributes
        real damage = 750
        real lifeSteal = 0.3

        private method remove takes integer i returns integer
            set bonus[index] = bonus[index] - 1
            set table[target].integer[source] = table[target].integer[source] - 1

            call AddUnitBonus(unit, BONUS_ARMOR, 1)

            if bonus[index] <= 0 then
                call DestroyEffect(table[target].effect[0])
                set table[target].effect[0] = null
            endif

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
                    elseif not UnitAlive(unit) then
                        set duration = 1
                    endif

                    set duration = duration - 1
				set i = i + 1
			endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                if table[Damage.target.handle].integer[Damage.source.handle] < 25 then
                    set this = thistype.new()
                    set unit = Damage.target.unit
                    set index = Damage.target.id
                    set target = Damage.target.handle
                    set source = Damage.source.handle
                    set duration = 10
                    set key = key + 1
                    set array[key] = this
                    set bonus[index] = bonus[index] + 1
                    set table[target].integer[source] = table[target].integer[source] + 1

                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, -1)

                    if table[target].effect[0] == null then
                        set table[target].effect[0] = AddSpecialEffectTarget("Sweep_Blood_Small.mdx", Damage.target.unit, "chest")
                    endif

                    if key == 0 then
                        call TimerStart(timer, 1, true, function thistype.onPeriod)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, DemonicMask.code, SphereOfDarkness.code, 0, 0, 0)
        endmethod
    endstruct
endscope