scope BookOfNature
    struct BookOfNature extends Item
        static constant integer code = 'I06H'
        static constant integer unit = 'n00L'
        static constant integer ability = 'B00Q'
        
        real healthRegen = 200
        real intelligence = 250
        real spellPowerFlat = 600

        private static method onDamage takes nothing returns nothing
            local integer i = 0
            
            if GetEventDamage() >= GetWidgetLife(Damage.target.unit) and GetUnitAbilityLevel(Damage.target.unit, ability) > 0 then
                loop
                    exitwhen i == 3
                        call UnitApplyTimedLife(CreateUnit(Damage.source.player, unit, Damage.target.x, Damage.target.y, 0), 'BTLF', 60)
                    set i = i + 1
                endloop
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SummoningBook.code, SphereOfNature.code, 0, 0, 0)
        endmethod
    endstruct
endscope