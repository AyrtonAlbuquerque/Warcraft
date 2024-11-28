scope RingOfConversion
    struct RingOfConversion extends Item
        static constant integer code = 'I06X'
        static constant integer spell = 'A00K'
        static constant integer ability = 'A00L'

        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()

        private unit unit

        // Attributes
        real mana = 10000
        real manaRegen = 250

        private method remove takes integer i returns integer
            set unit = null
            set array[i] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local real heal
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if GetUnitAbilityLevel(unit, ability) > 0 then
                        set heal = GetUnitState(unit, UNIT_STATE_MANA)
                        call SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) - (BlzGetUnitMaxMana(unit) * 0.002))
                        set heal = heal - GetUnitState(unit, UNIT_STATE_MANA)
                        call SetWidgetLife(unit, (GetWidgetLife(unit) + (heal/2)))
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(Spell.source.unit, ability) > 0 then
                call UnitRemoveAbility(Spell.source.unit, ability)
            else
                call UnitAddAbility(Spell.source.unit, ability)
                call BlzUnitHideAbility(Spell.source.unit, ability, true)

                set this = thistype.new()
                set unit = Spell.source.unit
                set key = key + 1
                set array[key] = this
                
                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif
        endmethod
        
        private method onDrop takes unit u, item i returns nothing
            if not UnitHasItemOfType(u, code) then
                call UnitRemoveAbility(u, ability)
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed = GetTriggerUnit()

            if UnitHasItemOfType(killer, code) then
                if IsUnitType(killed, UNIT_TYPE_HERO) then
                    call SetUnitState(killer, UNIT_STATE_MANA, GetUnitState(killer, UNIT_STATE_MANA) + 5000)
                else 
                    call SetUnitState(killer, UNIT_STATE_MANA, GetUnitState(killer, UNIT_STATE_MANA) + 500)
                endif
            endif

            set killed = null
            set killer = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(spell, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, DesertRing.code, SphereOfPower.code, SphereOfPower.code, 0, 0)
        endmethod
    endstruct
endscope