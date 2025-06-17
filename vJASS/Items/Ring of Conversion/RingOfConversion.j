scope RingOfConversion
    struct RingOfConversion extends Item
        static constant integer code = 'I06X'
        static constant integer spell = 'A00K'
        static constant integer ability = 'A00L'

        // Attributes
        real mana = 10000
        real manaRegen = 250

        private unit unit

        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            local real amount

            if GetUnitAbilityLevel(unit, ability) > 0 then
                set amount = GetUnitState(unit, UNIT_STATE_MANA)
                call SetUnitState(unit, UNIT_STATE_MANA, amount - (BlzGetUnitMaxMana(unit) * 0.02))
                set amount = amount - GetUnitState(unit, UNIT_STATE_MANA)
                call SetWidgetLife(unit, (GetWidgetLife(unit) + (amount/2)))
            
                return true
            endif

            return false
        endmethod
        
        private method onDrop takes unit u, item i returns nothing
            if not UnitHasItemOfType(u, code) then
                call UnitRemoveAbility(u, ability)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if GetUnitAbilityLevel(Spell.source.unit, ability) > 0 then
                call UnitRemoveAbility(Spell.source.unit, ability)
            else
                call UnitAddAbility(Spell.source.unit, ability)
                call BlzUnitHideAbility(Spell.source.unit, ability, true)

                set this = thistype.allocate(0)
                set unit = Spell.source.unit
                
                call StartTimer(1, true, this, -1)
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

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(spell, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), DesertRing.code, SphereOfPower.code, SphereOfPower.code, 0, 0)
        endmethod
    endstruct
endscope