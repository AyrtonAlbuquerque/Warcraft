library LavaElemental requires Ability, RegisterPlayerUnitEvent, PluginSpellEffect, NewBonus optional Sulfuras
    /* -------------------- Lava Elemental v1.6 by Chopinski -------------------- */
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
        private constant integer ABILITY            = 'A004'
        // The raw code of the Lava Elemental unit
        private constant integer LAVA_ELEMENTAL     = 'o000'
        // This ability cooldown if targeted at a 
        // structure
        private constant real    STRUCTURE_COOLDOWN = 120.
        // This ability cooldown if targeted at the 
        // ground
        private constant real    NORMAL_COOLDOWN    = 30.
        // The elemaental duration when targeted at 
        // the ground
        private constant real    ELEMENTAL_DURATION = 60.
        // The path for the effect that will be
        // added to the base of the Lava Elemental
        private constant string  FIRA_BASE          = "fire_5.mdl"
        // Effect when spawning a lava elemental
        private constant string  SPAWN_EFFECT       = "Pillar of Flame Orange.mdl"
    endglobals

    // The amount of damage the Lava Elemental has
    private function GetElementalDamage takes unit u, integer level returns integer
        static if LIBRARY_Sulfuras then
            return R2I(50 + 0.25 * level * Sulfuras.stacks[GetUnitUserData(u)])
        else
            return 25 + 25 * level
        endif
    endfunction

    // The amount of health the Lava Elemental has
    private function GetElementalHealth takes unit u, integer level returns integer
        return R2I(500 * level + BlzGetUnitMaxHP(u) * 0.3)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct LavaElemental extends Ability
        private static integer array array

        unit unit
        integer id
        effect effect

        method destroy takes nothing returns nothing
            set unit = null
            set effect = null
            set array[id] = 0

            call deallocate()
        endmethod

        private method onCast takes nothing returns nothing
            local unit lava

            set this = thistype.allocate()

            if Spell.target.unit != null then
                set lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.target.x, Spell.target.y, 0)
                set id = GetUnitUserData(lava)
                set unit = Spell.target.unit
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
                call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, STRUCTURE_COOLDOWN)
                call IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                call DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.target.x, Spell.target.y))
            else
                set lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.x, Spell.y, 0)
                set id = GetUnitUserData(lava)
                set unit = Spell.target.unit
                set effect = AddSpecialEffect(FIRA_BASE, Spell.x, Spell.y)
                set array[id] = this

                call BlzSetUnitMaxHP(lava, GetElementalHealth(Spell.source.unit, Spell.level))
                call SetUnitLifePercentBJ(lava, 100)
                call BlzSetUnitBaseDamage(lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                call SetUnitPropWindow(lava, 0)
                call UnitApplyTimedLife(lava, 'BTLF', ELEMENTAL_DURATION)
                call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, NORMAL_COOLDOWN)
                call IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                call DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.x, Spell.y))
            endif

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