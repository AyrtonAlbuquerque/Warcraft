library Immolation requires Spell, RegisterPlayerUnitEvent, NewBonus, Periodic, Utilities
    /* ---------------------- Immolation v1.2 by Chopinski ---------------------- */
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
        private constant integer ABILITY      = 'A002'
        // The raw code of the Immolation buff
        private constant integer BUFF         = 'B002'
        // The immolation damage period
        private constant real    PERIOD       = 1.
        // The immolation Damage model
        private constant string  MODEL        = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
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

    // The Immolation ardor reduction
    private function GetArmorReduction takes integer level returns real
        return 1 + 0.*level
    endfunction

    // The Immolation armor debuff duration
    private function GetDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Immolation extends Spell
        private unit unit
        private group group
        private player player

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string 
            return "Engulfs |cffffcc00Illidan|r in fel flames, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r and shreding their armor by |cffffcc00" + N2S(GetArmorReduction(level), 0) + "|r every time they are affected by |cffffcc00Immolation|r for |cffffcc00" + N2S(GetDuration(level), 0) + "|r seconds.\n\nDrains mana until deactivated. "
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(unit, ABILITY)
            local unit u

            if GetUnitAbilityLevel(unit, BUFF) > 0 then 
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if DamageFilter(player, u) then
                            if UnitDamageTarget(unit, u, GetDamage(unit, level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                call DestroyEffect(AddSpecialEffectTarget(MODEL, u, ATTACH_POINT))
                                call AddUnitBonusTimed(u, BONUS_ARMOR, -GetArmorReduction(level), GetDuration(level))
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                set u = null

                return true
            endif

            return false
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id = GetUnitUserData(source)
            local thistype this

            if GetIssuedOrderId() == 852177 and not HasStartedTimer(id) then
                set this = thistype.allocate()
                set unit = source
                set group = CreateGroup()
                set player = GetOwningPlayer(source)

                call StartTimer(PERIOD, true, this, id)
                call LinkEffectToBuff(source, BUFF, "Ember Green.mdl", "chest")
            endif
        
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary