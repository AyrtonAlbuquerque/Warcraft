scope AngelicShield
    struct AngelicShield extends Item
        static constant integer code = 'I0AF'
        static constant integer buff = 'B00Z'
        static constant integer ability = 'A01I'

        real armor = 20
        real health = 50000

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050000|r Health\n+ |cffffcc00500|r Damage Block\n+ |cffffcc0020|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Guardian Angel|r: |cffffcc00Damage Block|r increases by |cffffcc00100|r  for every |cffffcc0010%%|r of missing health. In addition, overblocked damage heals your Hero.\n\n|cff00ff00Active|r: |cffffcc00Sanctified Zone|r: When activated, all allied units within |cffffcc00800 AoE|r becomes immune to all damage, and all the damage your Hero takes during this time is evenly distributed amongst allied units within range. Lasts |cffffcc0015|r seconds.\n\nDamage Block: |cffffcc00" + R2I2S(500 + (10* R2I(100 - GetUnitLifePercent(u)))) + "|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local real heal          
            local group g1
            local group g2
            local unit  v

            if damage > 0 then
                if UnitHasItemOfType(Damage.target.unit, code) and Damage.isAttack then
                    call BlzSetEventDamage(damage - (500 + (10 * R2I(100 - GetUnitLifePercent(Damage.target.unit)))))
                endif

                if GetUnitAbilityLevel(Damage.target.unit, buff) > 0 then
                    call BlzSetEventDamage(0)
                endif

                if GetUnitAbilityLevel(Damage.target.unit, ability) > 0 then
                    set g1 = CreateGroup()
                    set g2 = CreateGroup()

                    call GroupEnumUnitsInRange(g1, Damage.target.x, Damage.target.y, 900, null)

                    loop
                        set v = FirstOfGroup(g1)
                        exitwhen v == null
                            if IsUnitAlly(v, Damage.target.player) and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                                call GroupAddUnit(g2, v)
                            endif
                        call GroupRemoveUnit(g1, v)
                    endloop

                    call DestroyGroup(g1)

                    if BlzGroupGetSize(g2) > 0 then
                        set heal = (damage / BlzGroupGetSize(g2))

                        loop
                            set v = FirstOfGroup(g2)
                            exitwhen v == null
                                if GetUnitAbilityLevel(v, buff) > 0 then
                                    call SetWidgetLife(v, GetWidgetLife(v) + heal)
                                endif
                            call GroupRemoveUnit(g2, v)
                        endloop
                    endif
                    
                    call DestroyGroup(g2)
                endif
            endif

            set g1 = null
            set g2 = null
        endmethod

        private static method onCast takes nothing returns nothing
            call UnitAddAbilityTimed(Spell.source.unit, ability, 15, 1, true)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellEffectEvent('A01T', function thistype.onCast)
            call thistype.allocate(code, SphereOfDivinity.code, BloodbourneShield.code, 0, 0, 0)
        endmethod
    endstruct
endscope