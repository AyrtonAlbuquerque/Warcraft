library SpellShield requires DamageInterface, SpellEffectEvent, PluginSpellEffect, Utilities, NewBonusUtils, CrowdControl optional Metamorphosis
    /* --------------------- Spell Shield v1.3 by Chopinski --------------------- */
    // Credits:
    //     Darkfang        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Spell Shield ability
        private constant integer ABILITY      = 'A004'
        // The raw code of the Spell Shield buff
        private constant integer BUFF         = 'B003'
        // The Spell Shield model
        private constant string  MODEL        = "SpellShield.mdl"
        // Spell Shield block effect period
        private constant real    PERIOD       = 0.03125
    endglobals

    // The Adaptive Strike damage
    private function GetConversion takes integer level returns real
        return 0.2 + 0.1*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct SpellShield
        static thistype array array
        static integer key = -1
        static timer timer = CreateTimer()

        unit source
        unit target
        effect effect
        integer count
        real angle
        real x
        real y

        method remove takes integer i returns integer
            call DestroyEffect(effect)

            set array[i] = array[key]
            set key = key - 1
            set source = null
            set target = null
            set effect = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local real height
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if count <= 0 then
                        set i = remove(i)
                    else
                        set x = GetUnitX(target)
                        set y = GetUnitY(target)
                        set angle = AngleBetweenCoordinates(x, y, GetUnitX(source), GetUnitY(source))

                        static if LIBRARY_Metamorphosis then
                            if GetUnitAbilityLevel(target, Metamorphosis_BUFF) > 0 then
                                set height = GetUnitZ(target) + 400
                            else
                                set height = GetUnitZ(target) + 100
                            endif
                        else
                            set height = GetUnitZ(target) + 100
                        endif

                        call BlzSetSpecialEffectPosition(effect, x + 60*Cos(angle), y + 60*Sin(angle), height)
                        call BlzSetSpecialEffectYaw(effect, angle)
                    endif
                    set count = count - 1
                set i = i + 1
            endloop
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local real height
            local thistype this

            if damage > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                set this = thistype.allocate()
                set source = Damage.source.unit
                set target = Damage.target.unit
                set angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                set x = Damage.target.x + 60*Cos(angle)
                set y = Damage.target.y + 60*Sin(angle)
                set count = 16
                set effect = AddSpecialEffect(MODEL, x, y)
                set key = key + 1
                set array[key] = this
                set damage = damage*(1 - GetConversion(GetUnitAbilityLevel(Damage.target.unit, ABILITY)))

                static if LIBRARY_Metamorphosis then
                    if GetUnitAbilityLevel(Damage.target.unit, Metamorphosis_BUFF) > 0 then
                        set height = GetUnitZ(Damage.target.unit) + 400
                    else
                        set height = GetUnitZ(Damage.target.unit) + 100
                    endif
                else
                    set height = GetUnitZ(Damage.target.unit) + 100
                endif
        
                call BlzSetSpecialEffectZ(effect, height)
                call BlzSetSpecialEffectScale(effect, 1.5)
                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectColor(effect, 0, 0, 255)
                call BlzSetEventDamage(damage)
                call LinkBonusToBuff(Damage.target.unit, BONUS_DAMAGE, damage, BUFF)

                if key == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        static method onCast takes nothing returns nothing
            call UnitDispelAllCrowdControl(Spell.source.unit)
        endmethod

        static method onCrowdControl takes nothing returns nothing
            if GetUnitAbilityLevel(GetCrowdControlUnit(), BUFF) > 0 then
                call SetCrowdControlDuration(0)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterAnyCrowdControlEvent(function thistype.onCrowdControl)
        endmethod
    endstruct
endlibrary