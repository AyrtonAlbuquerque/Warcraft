library Immolation requires Spell, RegisterPlayerUnitEvent, NewBonus, Modules, Utilities
    /* ---------------------- Immolation v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Immolation Effect (Edited by me)
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Immolation ability
        private constant integer ABILITY      = 'Idn2'
        // The immolation damage period
        private constant real    PERIOD       = 1.
        // The immolation model
        private constant string  MODEL        = "Ember Green.mdl"
        // The immolation Damage model point
        private constant string  MODEL_POINT  = "chest"
        // The immolation Damage model
        private constant string  DAMAGE_MODEL = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
        // The immolation Damage model
        private constant string  ATTACH_POINT = "head"
    endglobals

    // The immolation AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Immolation damage
    private function GetDamage takes unit source, integer level returns real
        return 20. * level + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Immolation damage increase
    private function GetDamageIncrease takes unit source, integer level returns real
        return 0.025 * level
    endfunction

    // The Immolation max damage increase
    private function GetMaxDamageIncrease takes unit source, integer level returns real
        return 0.25 * level
    endfunction

    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Immolation extends Spell
        private unit unit
        private group group
        private player player
        private effect effect
        private real multiplier

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string 
            return "When entering combat, |cffffcc00Illidan|r is engulfed in fel flames, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r. |cffffcc00Immolation|r damage is increased by |cffffcc00" + N2S(GetDamageIncrease(source, level) * 100, 1) + "%|r per second up to a maximum increase of |cffffcc00" + N2S(GetMaxDamageIncrease(source, level) * 100, 1) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer level
            local real increase
            local real maximum
            local real damage
            local unit u

            if IsUnitInCombat(unit) then
                set level = GetUnitAbilityLevel(unit, ABILITY)
                set damage = GetDamage(unit, level) * (1 + multiplier)
                set maximum = GetMaxDamageIncrease(unit, level)
                set increase = GetDamageIncrease(unit, level)

                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if DamageFilter(player, u) then
                            if UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                call DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, u, ATTACH_POINT))
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                if (multiplier + increase) <= maximum then
                    set multiplier = multiplier + increase
                else
                    set multiplier = maximum
                endif

                return true
            endif

            return false
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)

            if IsUnitInCombat(source) and not HasStartedTimer(id) and level == 1 then
                set this = thistype.allocate()
                set multiplier = 0
                set group = CreateGroup()
                set unit = source
                set player = GetOwningPlayer(source)
                set effect = AddSpecialEffectTarget(MODEL, source, MODEL_POINT)

                call StartTimer(PERIOD, true, this, id)
            endif
        endmethod

        private static method onEnter takes nothing returns nothing
            local integer id = GetUnitUserData(GetCombatSourceUnit())
            local thistype this

            if GetUnitAbilityLevel(GetCombatSourceUnit(), ABILITY) > 0 and not HasStartedTimer(id) then
                set this = thistype.allocate()
                set multiplier = 0
                set group = CreateGroup()
                set unit = GetCombatSourceUnit()
                set player = GetOwningPlayer(GetCombatSourceUnit())
                set effect = AddSpecialEffectTarget(MODEL, unit, MODEL_POINT)

                call StartTimer(PERIOD, true, this, id)
            endif

        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterUnitEnterCombatEvent(function thistype.onEnter)
        endmethod
    endstruct
endlibrary