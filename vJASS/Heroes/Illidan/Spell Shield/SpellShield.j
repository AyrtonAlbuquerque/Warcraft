library SpellShield requires DamageInterface, Ability, Utilities, NewBonus, CrowdControl, Periodic optional Metamorphosis
    /* --------------------- Spell Shield v1.4 by Chopinski --------------------- */
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
    private struct SpellShield extends Ability
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

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Illidan|r becomes immune to all crowd control for |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, level - 1), 1) + "|r seconds. In addition, |cffffcc00" + N2S(GetConversion(level) * 100, 0) + "%|r of all |cff00ffffMagic|r damage |cffffcc00Illidan|r takes while under the effect of |cffffcc00Spell Shield|r is converted into bonus damage, lasting until the effect expires."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real height

            set duration = duration - 1

            if duration > 0 then
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

            return duration > 0
        endmethod

        private method onCast takes nothing returns nothing
            call UnitDispelAllCrowdControl(Spell.source.unit)
        endmethod

        private static method onCrowdControl takes nothing returns nothing
            if GetUnitAbilityLevel(GetCrowdControlUnit(), BUFF) > 0 then
                call SetCrowdControlDuration(0)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local real bonus
            local real height
            local thistype this

            if Damage.amount > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                set this = thistype.allocate()
                set duration = 16
                set source = Damage.source.unit
                set target = Damage.target.unit
                set angle = AngleBetweenCoordinates(Damage.target.x, Damage.target.y, Damage.source.x, Damage.source.y)
                set x = Damage.target.x + 60*Cos(angle)
                set y = Damage.target.y + 60*Sin(angle)
                set effect = AddSpecialEffect(MODEL, x, y)
                set bonus = Damage.amount * GetConversion(GetUnitAbilityLevel(Damage.target.unit, ABILITY))
                set Damage.amount = Damage.amount - bonus

                static if LIBRARY_Metamorphosis then
                    if GetUnitAbilityLevel(Damage.target.unit, Metamorphosis_BUFF) > 0 then
                        set height = GetUnitZ(Damage.target.unit) + 400
                    else
                        set height = GetUnitZ(Damage.target.unit) + 100
                    endif
                else
                    set height = GetUnitZ(Damage.target.unit) + 100
                endif
        
                call StartTimer(PERIOD, true, this, -1)
                call BlzSetSpecialEffectZ(effect, height)
                call BlzSetSpecialEffectScale(effect, 1.5)
                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectColor(effect, 0, 0, 255)
                call LinkBonusToBuff(Damage.target.unit, BONUS_DAMAGE, bonus, BUFF)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterAnyCrowdControlEvent(function thistype.onCrowdControl)
        endmethod
    endstruct
endlibrary