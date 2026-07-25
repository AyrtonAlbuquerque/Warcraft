library BlessedField requires Spell, Modules, Utilities, optional LightInfusion
    /* --------------------- Blessed Field v1.4 by Chopinski -------------------- */
    // Credits:
    //     Darkfang - Icon
    //     AZ       - Blessings effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Blessed Field Ability
        private constant integer ABILITY       = 'Trl5'
        // The Blessed Field Aura ability
        private constant integer AURA          = 'Trl6'
        // The Blessed Field Aura Infused ability
        private constant integer INFUSED_AURA  = 'Trl7'
        // The Blessed Field Aura level 1 buff
        private constant integer BUFF_1        = 'BTr1'
        // The Blessed Field Aura level 2 buff
        private constant integer BUFF_2        = 'BTr2'
        // The Blessed Field Aura Infused buff
        private constant integer INFUSED_BUFF  = 'BTr3'
        // The Blessed Field model
        private constant string  MODEL         = "BlessedField.mdl"
        // The Blessed Field scale
        private constant real    SCALE         = 1.
        // The Blessed Field spawn model
        private constant string  SPAWN_MODEL   = "Blessings.mdl"
        // The Blessed Field spawn model scale
        private constant real    SPAWN_SCALE   = 2.5
    endglobals

    // The Blessed Field duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The regeneration bonus
    private function GetRegenBonus takes unit source, integer level returns real
        return 25 * level + ((0.25 + 0.25 * level) * GetHeroStr(source, true))
    endfunction

    // The Blessed Field damage reduction based on the buff level
    private function GetDamageReduction takes integer level returns real
        return 1. - (0.1 + 0.2*level)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BlessedField extends Spell
        private unit unit
        private effect effect

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call UnitRemoveAbility(unit, AURA)
            call UnitRemoveAbility(unit, INFUSED_AURA)
            call DummyRecycle(unit)
            call deallocate()

            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r blesses the targeted area, creating a |cffffcc00Blessed Field|r. All allied units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + "|r |cffffcc00AoE|r have their |cff00ff00Health Regeneration|r increased by |cff00ff00" + N2S(GetRegenBonus(source, level), 0) + "|r and take |cffffcc00" + N2S((1 - GetDamageReduction(level)) * 100, 0) + "%|r reduced damage from all sources.\n\n|cffffcc00Light Infused|r: Allied units within |cffffcc00Blessed Field|r area cannot be killed."
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            set effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

            call UnitAddAbility(unit, AURA)
            call SetUnitAbilityLevel(unit, AURA, Spell.level)
            call BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, AURA), ABILITY_RLF_LIFE_REGENERATION_INCREASE_PERCENT, Spell.level - 1, GetRegenBonus(Spell.source.unit, Spell.level))
            call IncUnitAbilityLevel(unit, AURA)
            call DecUnitAbilityLevel(unit, AURA)

            static if LIBRARY_LightInfusion then
                if LightInfusion.charges[Spell.source.id] > 0 then
                    call UnitAddAbility(unit, INFUSED_AURA)
                    call LightInfusion.consume(Spell.source.id)
                endif
            endif

            call StartTimer(GetDuration(Spell.source.unit, Spell.level), false, this, 0)
            call DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, Spell.x, Spell.y, 0, SPAWN_SCALE))
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                    set Damage.amount = Damage.amount * GetDamageReduction(2)
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                    set Damage.amount = Damage.amount * GetDamageReduction(1)
                endif

                if GetUnitAbilityLevel(Damage.target.unit, INFUSED_BUFF) > 0 then
                    if Damage.amount >= (Damage.target.health - 1) then
                        set Damage.amount = 0
                        call SetWidgetLife(Damage.target.unit, 1)
                    endif
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary