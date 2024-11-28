scope BookOfFlames
    struct BookOfFlames extends Item
        static constant integer code = 'I06B'
        static constant integer unit = 'o004'
        static constant integer ability = 'A04E'

        real damage = 500
        real intelligence = 250
        real spellPowerFlat = 600

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local real size

            if GetUnitTypeId(killer) == unit then
                set size = BlzGetUnitRealField(killer, UNIT_RF_SCALING_VALUE)

                call BlzSetUnitMaxHP(killer, BlzGetUnitMaxHP(killer) + 250)
                call SetUnitLifePercentBJ(killer, GetUnitLifePercent(killer))
                call BlzSetUnitBaseDamage(killer, BlzGetUnitBaseDamage(killer, 0) + 25, 0)

                if size < 2 then
                    call BlzSetUnitRealField(killer, UNIT_RF_SCALING_VALUE, size + 0.01)
                    call SetUnitScale(killer, size + 0.01, size + 0.01, size + 0.01)
                endif
            endif

            set killer = null
        endmethod

        private static method onCast takes nothing returns nothing
            call CreateUnit(Spell.source.player, unit, Spell.source.x, Spell.source.y, 0)
            call CreateUnit(Spell.source.player, unit, Spell.source.x, Spell.source.y, 0)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, SummoningBook.code, SphereOfFire.code, 0, 0, 0)
        endmethod
    endstruct
endscope