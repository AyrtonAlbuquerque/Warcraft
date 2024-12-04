scope HellishMask
    struct HellishMask extends Item
        static constant integer code = 'I06R'
        
        // Attributes
        real damage = 750
        real lifeSteal = 0.3

        private static HashTable table
        private static integer array bonus

        private unit unit
        private integer index
        private integer target
        private integer source

        method destroy takes nothing returns nothing
            set unit = null
            set bonus[index] = bonus[index] - 1
            set table[target].integer[source] = table[target].integer[source] - 1

            if bonus[index] <= 0 then
                call DestroyEffect(table[target].effect[0])
                set table[target].effect[0] = null
            endif

            call super.destroy()
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
                    set bonus[index] = bonus[index] + 1
                    set table[target].integer[source] = table[target].integer[source] + 1

                    call StartTimer(10, false, this, -1)
                    call AddUnitBonusTimed(Damage.target.unit, BONUS_ARMOR, -1, 10)

                    if table[target].effect[0] == null then
                        set table[target].effect[0] = AddSpecialEffectTarget("Sweep_Blood_Small.mdx", Damage.target.unit, "chest")
                    endif
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, DemonicMask.code, SphereOfDarkness.code, 0, 0, 0)
        endmethod
    endstruct
endscope