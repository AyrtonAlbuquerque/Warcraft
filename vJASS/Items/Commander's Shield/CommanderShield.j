scope CommanderShield
    struct CommanderShield extends Item
        static constant integer code = 'I065'
        
        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()

        private unit source
        private unit target
        private effect effect
        private integer duration
        private real angle
        private real x
        private real y

        // Attributes
        real armor = 8
        real health = 12000

        private method remove takes integer i returns integer
            call DestroyEffect(effect)

            set array[i] = array[key]
            set key = key - 1
            set source = null
            set target = null
            set effect = null

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
                    else
                        set x = GetUnitX(target)
                        set y = GetUnitY(target)
                        set angle = AngleBetweenCoordinates(x, y, GetUnitX(source), GetUnitY(source))

                        call BlzSetSpecialEffectPosition(effect, x + 60*Cos(angle), y + 60*Sin(angle), BlzGetUnitZ(target))
                        call BlzSetSpecialEffectYaw(effect, angle)
                    endif

                    set duration = duration - 1
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this
        
            if UnitHasItemOfType(Damage.target.unit, code) and damage > 0 and GetRandomInt(1, 100) <= 33 then
                set this = thistype.new()
                set source = Damage.source.unit
                set target = Damage.target.unit
                set angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                set x = Damage.target.x + 60*Cos(angle)
                set y = Damage.target.y + 60*Sin(angle)
                set duration = 16
                set effect = AddSpecialEffect("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", x, y)
                set key = key + 1
                set array[key] = this
        
                call BlzSetSpecialEffectZ(effect, Damage.target.z)
                call BlzSetSpecialEffectScale(effect, 1.5)
                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetEventDamage(0)

                if key == 0 then
                    call TimerStart(timer, 0.03125, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, FusedLifeCrystals.code, WarriorShield.code, 0, 0, 0)
        endmethod
    endstruct
endscope