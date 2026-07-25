library LavaElemental requires Spell, RegisterPlayerUnitEvent, NewBonus, Utilities optional Sulfuras
    /* -------------------- Lava Elemental v1.7 by Chopinski -------------------- */
    // Credits:
    //     Henry         - Lava Elemental model (warcraft3undergorund.com)
    //     Empyreal      - fire base model (xgmguru.ru)
    //     Mythic        - Pillar of Flame model
    //     Blizzard      - icon (edited by me)
    //     Magtheridon96 - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Lava Elemental ability
        private constant integer ABILITY            = 'Rgn4'
        // The raw code of the Burning Oil ability
        private constant integer BURN               = 'Rgn7'
        // The raw code of the Lava Elemental unit
        private constant integer LAVA_ELEMENTAL     = 'rgn0'
        // The path for the effect that will be
        // added to the base of the Lava Elemental
        private constant string  FIRA_BASE          = "fire_5.mdl"
        // Effect when spawning a lava elemental
        private constant string  SPAWN_EFFECT       = "Pillar of Flame Orange.mdl"
    endglobals

    // The amount of damage the Lava Elemental has
    private function GetElementalDamage takes unit source, integer level returns integer
        static if LIBRARY_Sulfuras then
            return R2I(50 + (0.25 * level * Sulfuras.stacks[GetUnitUserData(source)]) + (0.05 * level * GetUnitBonus(source, BONUS_SPELL_POWER)))
        else
            return 25 + 25 * level
        endif
    endfunction

    // The elemental burning oil damage
    private function GetBurnDamage takes unit source, integer level returns integer
        return R2I(50. * level + (0.05 * level * GetUnitBonus(source, BONUS_SPELL_POWER)))
    endfunction

    // The Elemental cooldown
    private function GetCooldown takes unit source, unit target, integer level returns real
        if target == null then
            return 30. + 0.*level
        else
            return 180. + 0.*level
        endif
    endfunction

    // The Elemental duration
    private function GetDuration takes unit source, integer level returns real
        return 60. + 0.*level
    endfunction

    // The amount of health the Lava Elemental has
    private function GetElementalHealth takes unit source, integer level returns integer
        return R2I(500 * level + (BlzGetUnitMaxHP(source) * 0.3) + (0.4 + 0.2 * level * GetUnitBonus(source, BONUS_SPELL_POWER)))
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct LavaElemental extends Spell
        private static integer array array

        private unit unit
        private integer id
        private effect effect

        method destroy takes nothing returns nothing
            set unit = null
            set effect = null
            set array[id] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Ragnaros|r summons a |cffffcc00Lava Elemental|r. This abiliy can be targeted in the |cffffcc00ground|r or |cffffcc00allied structure|r. When summoned in the ground, the |cffffcc00Lava Elemental|r has a life time of |cffffcc00" + N2S(GetDuration(source, level), 1) + " seconds|r and this ability cooldown is set to |cffffcc00" + N2S(30. + 0.*level, 1) + " seconds|r. When targeted at an allied building, the |cffffcc00Lava Elemental|r takes that building place and lasts forever or until it dies and this ability cooldown is set to |cffffcc00" + N2S(180. + 0.*level, 1) + " seconds|r. All the damage that would be given to the structure is instead taken by the |cffffcc00Lava Elemental|r.\n\n|cffffcc00Lava Elemental|r damage is |cffff0000" + N2S(GetElementalDamage(source, level), 0) + "|r and it's attacks burn the ground around the impact for |cff00ffff" + N2S(GetBurnDamage(source, level), 0) + " Magic|r damage per second for |cffffcc002 seconds|r."
        endmethod

        private method onCast takes nothing returns nothing
            local unit lava
            local ability burn

            set this = thistype.allocate()

            if Spell.target.unit != null then
                set lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.target.x, Spell.target.y, 0)
                set id = GetUnitUserData(lava)
                set unit = Spell.target.unit
                set burn = BlzGetUnitAbility(lava, BURN)
                set effect = AddSpecialEffect(FIRA_BASE, Spell.target.x, Spell.target.y)
                set array[id] = this
                
                call UnitAddAbility(Spell.target.unit, 'Abun')
                call ShowUnit(Spell.target.unit, false)
                call SetUnitInvulnerable(Spell.target.unit, true)
                call SetUnitX(lava, Spell.target.x)
                call SetUnitY(lava, Spell.target.y)
                call BlzSetUnitMaxHP(lava, GetElementalHealth(Spell.source.unit, Spell.level))
                call SetUnitLifePercentBJ(lava, 100)
                call BlzSetUnitBaseDamage(lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                call SetUnitPropWindow(lava, 0)
                call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.target.x, Spell.target.y))
                call BlzSetAbilityRealLevelField(burn, ABILITY_RLF_FULL_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                call BlzSetAbilityRealLevelField(burn, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                call IncUnitAbilityLevel(lava, BURN)
                call DecUnitAbilityLevel(lava, BURN)
            else
                set lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.x, Spell.y, 0)
                set id = GetUnitUserData(lava)
                set unit = Spell.target.unit
                set burn = BlzGetUnitAbility(lava, BURN)
                set effect = AddSpecialEffect(FIRA_BASE, Spell.x, Spell.y)
                set array[id] = this

                call BlzSetUnitMaxHP(lava, GetElementalHealth(Spell.source.unit, Spell.level))
                call SetUnitLifePercentBJ(lava, 100)
                call BlzSetUnitBaseDamage(lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                call SetUnitPropWindow(lava, 0)
                call UnitApplyTimedLife(lava, 'BTLF', GetDuration(Spell.source.unit, Spell.level))
                call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.x, Spell.y))
                call BlzSetAbilityRealLevelField(burn, ABILITY_RLF_FULL_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                call BlzSetAbilityRealLevelField(burn, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                call IncUnitAbilityLevel(lava, BURN)
                call DecUnitAbilityLevel(lava, BURN)
            endif

            set Spell.cooldown = GetCooldown(Spell.source.unit, Spell.target.unit, Spell.level)

            set burn = null
            set lava = null
        endmethod

        private static method onDeath takes nothing returns nothing
            local thistype this = array[GetUnitUserData(GetTriggerUnit())]

            if this != 0 then
                call UnitRemoveAbility(unit, 'Abun')
                call ShowUnit(unit, true)
                call SetUnitInvulnerable(unit, false)
                call DestroyEffect(effect)
                call destroy()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary