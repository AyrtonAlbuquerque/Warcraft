library ExplosiveRune requires Ability, Utilities optional Afterburner, CooldownReduction, NewBonus
    /* -------------------- Explosive Rune v1.6 by Chopinski -------------------- */
    // Credits:
    //     Mythic           - Conflagrate model
    //     JetFangInferno   - FireRune model
    //     Blizzard         - icon (Edited by me)
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     Bribe            - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Explosive Rune Ability
        private constant integer    ABILITY             = 'A001'
        // The number of charges of the ability
        private constant integer    CHARGES_COUNT       = 4
        // The number of charges of the ability
        private constant real       CHARGES_COOLDOWN    = 10.0
        // The Explosion delay
        private constant real       EXPLOSION_DELAY     = 1.5
        // The Explosion effect path
        private constant string     EXPLOSION_EFFECT    = "Conflagrate.mdl"
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
        // If true will damage structures
        private constant boolean    DAMAGE_STRUCTURES   = false
        // If true will damage allies
        private constant boolean    DAMAGE_ALLIES       = false
        // If true will damage magic immune unit if the
        // ATTACK_TYPE is not spell damage
        private constant boolean    DAMAGE_MAGIC_IMMUNE = false
    endglobals

    //The damage amount of the explosion
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return (50. + 50.*level) + 0.75*GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return (50. + 50.*level)
        endif
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ExplosiveRune extends Ability
        private static integer array charges

        private real x
        private real y
        private real aoe
        private unit unit
        private integer id
        private real damage

        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Ragnaros creates an |cffffcc00Explosive Rune|r in the target location that explodes after |cffffcc00" + N2S(EXPLOSION_DELAY, 1) + "|r seconds, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage to enemy units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r. Holds up to |cffffcc00" + I2S(CHARGES_COUNT) + "|r charges. Gains |cffffcc001|r charge every |cffffcc00" + N2S(CHARGES_COOLDOWN, 1) + "|r seconds.\n\nCharges: |cffffcc00" + I2S(charges[GetUnitUserData(source)]) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer level = GetUnitAbilityLevel(unit, ABILITY)

            if level > 0 then
                if charges[id] < CHARGES_COUNT and charges[id] >= 0 then
                    set charges[id] = charges[id] + 1

                    call BlzEndUnitAbilityCooldown(unit, ABILITY)
                endif
            else
                set charges[id] = 0
            endif

            return level > 0
        endmethod

        private method onExpire takes nothing returns nothing
            static if LIBRARY_Afterburner then
                call Afterburn(x, y, unit)
            endif

            call UnitDamageArea(unit, x, y, aoe, damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_MAGIC_IMMUNE, DAMAGE_ALLIES)
            call DestroyEffect(AddSpecialEffect(EXPLOSION_EFFECT, x, y))
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            
            set x = Spell.x
            set y = Spell.y
            set id = Spell.source.id
            set unit = Spell.source.unit
            set damage = GetDamage(Spell.source.unit, Spell.level)
            set aoe = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_AREA_OF_EFFECT, Spell.level - 1)

            if charges[id] > 0 then
                set charges[id] = charges[id] - 1

                if charges[id] >= 1 then
                    call ResetUnitAbilityCooldown(unit, ABILITY)
                else
                    static if LIBRARY_CooldownReduction then
                        call CalculateAbilityCooldown(unit, ABILITY, Spell.level, GetRemainingTime(GetTimerInstance(id)))
                    else
                        call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, GetRemainingTime(GetTimerInstance(id)))
                        call IncUnitAbilityLevel(unit, ABILITY)
                        call DecUnitAbilityLevel(unit, ABILITY)
                    endif
                endif
            endif

            call StartTimer(EXPLOSION_DELAY, false, this, -1)
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            local integer id = GetUnitUserData(source)

            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set this.id = id
                set this.unit = source
                set charges[id] = CHARGES_COUNT

                call StartTimer(CHARGES_COOLDOWN, true, this, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary