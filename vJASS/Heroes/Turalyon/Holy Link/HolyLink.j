library HolyLink requires Spell, Utilities, DamageInterface, NewBonus, Periodic optional LightInfusion
    /* ----------------------- Holy Link v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Metal_Sonic     - Rejuvenation Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Holy Link ability
        private constant integer ABILITY       = 'A002'
        // The Holy Link Normal buff model
        private constant string  MODEL         = "Rejuvenation.mdl"
        // The Holy Link infused buff model
        private constant string  INFUSED_MODEL = "Rejuvenation.mdl"
        // The Holy Link lightning effect
        private constant string  LIGHTNING     = "HWSB"
        // The Holy Link model attachment point
        private constant string  ATTACH_POINT  = "chest"
        // The Holy Link update period
        private constant real    PERIOD        = 0.031250000
    endglobals

    // The Holy Link Health Regen bonus
    private function GetBonus takes unit source, integer level returns real
        local real base = 5. + 5.*level

        return (base + base*(1 - (GetUnitLifePercent(source)*0.01)))*PERIOD
    endfunction

    // The Holy Link Movement Speed bonus
    private function GetMovementBonus takes integer level, boolean infused returns integer
        if infused then
            return 50 + 0*level
        else
            return 0
        endif
    endfunction

    // The Holy Link break distance
    private function GetAoE takes integer level, boolean infused returns real
        if infused then
            return 1200. + 0.*level
        else
            return 800. + 0.*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HolyLink extends Spell
        private static integer array reduce

        private unit unit
        private integer id
        private unit target
        private effect self
        private integer bonus
        private effect effect
        private real distance
        private integer count
        private boolean infused
        private lightning lightning

        method destroy takes nothing returns nothing
            call DestroyLightning(lightning)
            call DestroyEffect(effect)

            if infused then
                set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] - 1

                call DestroyEffect(self)
                call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -bonus)
                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, -bonus)
            endif

            set self = null
            set unit = null
            set target = null
            set effect = null
            set lightning = null

			call deallocate()
        endmethod

        private static method link takes unit source, unit target, integer id, integer level, boolean infused returns nothing
            local thistype this = thistype.allocate()

            set this.id = id
            set this.count = 0
            set this.unit = source
            set this.target = target
            set this.infused = infused
            set this.distance = GetAoE(level, infused)
            set this.bonus = GetMovementBonus(level, infused)
            set this.effect = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
            set this.lightning = AddLightningEx(LIGHTNING, false, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 30, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 30)

            if infused then
                set self = AddSpecialEffectTarget(MODEL, source, ATTACH_POINT)
                set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] + 1

                call AddUnitBonus(source, BONUS_MOVEMENT_SPEED, bonus)
                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
            endif

            call StartTimer(PERIOD, true, this, id)
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r creates a |cffffcc00Holy Link|r between himself and the targeted allied unit, increasing its |cff00ff00Health Regeneration|r while linked to |cffffcc00Turalyon|r by |cff00ff00" + N2S(5. + 5.*level, 1) + "|r increased by |cffffcc001%|r for every |cffffcc001%|r of the linked unit missing health. The link is broken if the distance between |cffffcc00Turalyon|r and the linked unit is greater than |cffffcc00" + N2S(GetAoE(level, false), 0) + " AoE|r.\n\n|cffffcc00Light Infused|r: Both |cffffcc00Turalyon|r and the linked unit get their |cff00ff00Health Regeneration|r increased. In addition their |cffffff00Movement Speed|r is increased by |cffffcc00" + I2S(GetMovementBonus(level, true)) + "|r and all the damage the linked unit takes is reduced by |cffffcc0025%|r. The distance at which the link is broken is also increased to |cffffcc00" + N2S(GetAoE(level, true), 0) + " AoE|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x = GetUnitX(unit)
            local real y = GetUnitY(unit)
            local real tx = GetUnitX(target)
            local real ty = GetUnitY(target)
            local integer level = GetUnitAbilityLevel(unit, ABILITY)

            if DistanceBetweenCoordinates(x, y, tx, ty) <= distance and UnitAlive(target) and UnitAlive(unit) then
                if infused then
                    call SetWidgetLife(unit, GetWidgetLife(unit) + GetBonus(unit, level))
                    call SetWidgetLife(target, GetWidgetLife(target) + GetBonus(target, level))
                else
                    call SetWidgetLife(target, GetWidgetLife(target) + GetBonus(target, level))
                endif

                if count <= 28 then // This is here because reforged lightnings don't persist visually...
                    set count = count + 1
                    call MoveLightningEx(lightning, false, x, y, GetUnitZ(unit) + 30, tx, ty, GetUnitZ(target) + 30)
                else
                    set count = 0
                    call DestroyLightning(lightning)
                    set lightning = AddLightningEx(LIGHTNING, false, x, y, GetUnitZ(unit) + 30, tx, ty, GetUnitZ(target) + 30)
                endif
            
                return true
            endif

            return false
        endmethod

        private method onCast takes nothing returns nothing
            set this = GetTimerInstance(Spell.source.id)

            if this != 0 then
                if Spell.target.unit == target then
                    static if LIBRARY_LightInfusion then
                        if infused then
                            call ResetUnitAbilityCooldown(unit, Spell.id)
                        else
                            set infused = LightInfusion.charges[id] > 0
                            set distance = GetAoE(Spell.level, infused)
                            set bonus = GetMovementBonus(Spell.level, infused)

                            if infused then
                                set reduce[Spell.target.id] = reduce[Spell.target.id] + 1 
                                set self = AddSpecialEffectTarget(MODEL, unit, ATTACH_POINT)

                                call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, bonus)
                                call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
                            endif

                            call LightInfusion.consume(id)
                        endif
                    else
                        call ResetUnitAbilityCooldown(unit, Spell.id)
                    endif
                else
                    call DestroyLightning(lightning)
                    call DestroyEffect(effect)

                    static if LIBRARY_LightInfusion then
                        if infused then
                            set reduce[GetUnitUserData(target)] = reduce[GetUnitUserData(target)] - 1

                            call DestroyEffect(self)
                            call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -bonus)
                            call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, -bonus)
                        endif

                        set count = 0
                        set unit = Spell.source.unit
                        set target = Spell.target.unit
                        set infused = LightInfusion.charges[id] > 0
                        set distance = GetAoE(Spell.level, infused)
                        set bonus = GetMovementBonus(Spell.level, infused)
                        set effect = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
                        set lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)

                        if infused then
                            set reduce[Spell.target.id] = reduce[Spell.target.id] + 1 
                            set self = AddSpecialEffectTarget(MODEL, unit, ATTACH_POINT)

                            call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, bonus)
                            call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, bonus)
                        endif

                        call LightInfusion.consume(id)
                    else
                        set count = 0
                        set infused = false
                        set unit = Spell.source.unit
                        set target = Spell.target.unit
                        set distance = GetAoE(Spell.level, infused)
                        set bonus = GetMovementBonus(Spell.level, infused)
                        set effect = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
                        set lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                    endif
                endif
            else
                static if LIBRARY_LightInfusion then
                    call link(Spell.source.unit, Spell.target.unit, Spell.source.id, Spell.level, LightInfusion.charges[Spell.source.id] > 0)
                    call LightInfusion.consume(Spell.source.id)
                else
                    call link(Spell.source.unit, Spell.target.unit, Spell.source.id, Spell.level, false)
                endif
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            static if LIBRARY_LightInfusion then
                if Damage.amount > 0 and reduce[Damage.target.id] > 0 then
                    set Damage.amount = Damage.amount * 0.75
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)

            static if LIBRARY_LightInfusion then
                call RegisterAnyDamageEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endlibrary