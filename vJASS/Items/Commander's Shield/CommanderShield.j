scope CommanderShield
    struct CommanderShield extends Item
        static constant integer code = 'I065'
        
        // Attributes
        real armor = 8
        real block = 100
        real health = 12000

        private real x
        private real y
        private real angle
        private unit source
        private unit target
        private effect effect
        private integer duration

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set source = null
            set target = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1
            
            if duration > 0 then
                set x = GetUnitX(target)
                set y = GetUnitY(target)
                set angle = AngleBetweenCoordinates(x, y, GetUnitX(source), GetUnitY(source))

                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectPosition(effect, x + 60*Cos(angle), y + 60*Sin(angle), BlzGetUnitZ(target))
            endif

            return duration > 0
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) and Damage.amount > 0 and GetRandomInt(1, 100) <= 33 then
                set this = thistype.allocate(0)
                set duration = 16
                set source = Damage.source.unit
                set target = Damage.target.unit
                set angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                set x = Damage.target.x + 60*Cos(angle)
                set y = Damage.target.y + 60*Sin(angle)
                set effect = AddSpecialEffect("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", x, y)
                set Damage.amount = 0
        
                call StartTimer(0.03125, true, this, -1)
                call BlzSetSpecialEffectScale(effect, 1.5)
                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectZ(effect, Damage.target.z)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), FusedLifeCrystals.code, WarriorShield.code, 0, 0, 0)
        endmethod
    endstruct
endscope