scope MagusOrb
    struct MagusOrb extends Item
        static constant integer code = 'I09O'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static HashTable table
        private static boolean array arcana
        private static thistype array array

        private unit unit
        private effect left
        private effect right
        private integer handle
        private integer index
        private integer type
        private integer duration

        // Attributes
        real agility = 500
        real strength = 500
        real intelligence = 500
        real manaRegen = 500
        real healthRegen = 500
        real spellPowerFlat = 500

        private method remove takes integer i returns integer
            if type > 0 then
                call DestroyEffect(left)
                call DestroyEffect(right)

                if type == 1 then
                    call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -1000)
                elseif type == 2 then
                    call AddUnitBonus(unit, BONUS_MANA_REGEN, -1000)
                elseif type == 3 then
                    call UnitAddSpellPowerFlat(unit, -1000)
                elseif type == 4 then
                    call AddUnitBonus(unit, BONUS_DAMAGE, -1000)
                endif
            endif
        
            if UnitHasItemOfType(unit, code) then
                set table[handle].effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", unit, "hand left")
                set table[handle].effect[1] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", unit, "hand right")
            else
                call DestroyEffect(table[handle].effect[0])
                call DestroyEffect(table[handle].effect[1])
                set table[handle].effect[0] = null
                set table[handle].effect[1] = null
            endif

            set array[i] = array[key]
            set key = key - 1
            set arcana[index] = false
            set unit = null
            set right = null
            set left = null

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

        private static method onDamage takes nothing returns nothing
            local real damage = 2*GetEventDamage()
            local thistype this
        
            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 and Damage.isEnemy and not arcana[Damage.source.id] then
                set this = thistype.new()
                set unit = Damage.source.unit
                set handle = Damage.source.handle
                set index = Damage.source.id
                set duration = 10
                set type = 0
                set key = key + 1
                set array[key] = this
                set arcana[index] = true

                call BlzSetEventDamage(damage)
                call DestroyEffect(AddSpecialEffect("Blink Purple Caster.mdx", Damage.target.x, Damage.target.y))
                call DestroyEffect(table[handle].effect[0])
                call DestroyEffect(table[handle].effect[1])
                set table[handle].effect[0] = null
                set table[handle].effect[1] = null

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif

                if damage >= GetWidgetLife(Damage.target.unit) or Damage.target.isHero then
                    set type = GetRandomInt(1, 4)
        
                    if type == 1 then //Fire
                        set left  = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand left")
                        set right = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand right")
                        call AddUnitBonus(Damage.source.unit, BONUS_HEALTH_REGEN, 1000)
                    elseif type == 2 then //Water
                        set left  = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand left")
                        set right = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand right")
                        call AddUnitBonus(Damage.source.unit, BONUS_MANA_REGEN, 1000)
                    elseif type == 3 then //Earth
                        set left  = AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand left")
                        set right = AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand right")
                        call UnitAddSpellPowerFlat(Damage.source.unit, 1000)
                    elseif type == 4 then //Light
                        set left  = AddSpecialEffectTarget("Sweep_Holy_Small.mdx", Damage.source.unit, "hand left")
                        set right = AddSpecialEffectTarget("Sweep_Holy_Small.mdx", Damage.source.unit, "hand right")
                        call AddUnitBonus(Damage.source.unit, BONUS_DAMAGE, 1000)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterSpellDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, ElementalSpin.code, AncientSphere.code, 0, 0, 0)
        endmethod
    endstruct
endscope