library BlessedField requires Ability, Periodic, Utilities, optional LightInfusion
    /* --------------------- Blessed Field v1.3 by Chopinski -------------------- */
    // Credits:
    //     Darkfang - Icon
    //     AZ       - Blessings effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Blessed Field Ability
        private constant integer ABILITY       = 'A005'
        // The Blessed Field Aura ability
        private constant integer AURA          = 'A006'
        // The Blessed Field Aura Infused ability
        private constant integer INFUSED_AURA  = 'A007'
        // The Blessed Field Aura level 1 buff
        private constant integer BUFF_1        = 'B005'
        // The Blessed Field Aura level 2 buff
        private constant integer BUFF_2        = 'B006'
        // The Blessed Field Aura Infused level 1 buff
        private constant integer BUFF_3        = 'B007'
        // The Blessed Field Aura Infused level 2 buff
        private constant integer BUFF_4        = 'B008'
        // The Blessed Field model
        private constant string  MODEL         = "BlessedField.mdl"
        // The Blessed Field scale
        private constant real    SCALE         = 1.
        // The Blessed Field spawn model
        private constant string  SPAWN_MODEL   = "Blessings.mdl"
        // The Blessed Field spawn model scale
        private constant real    SPAWN_SCALE   = 2.5
        // The Blessed Field Infused Restore model
        private constant string  RESTORE_MODEL = "Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl"
    endglobals

    // The Blessed Field duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Blessed Field damage reduction based on the buff level
    private function GetDamageReduction takes integer level returns real
        return 1. - (0.1 + 0.2*level)
    endfunction

    // The Blessed Field health restored when receiving a killing blow
    private function GetHealthRegained takes unit source, integer level returns real
        return BlzGetUnitMaxHP(source)*(0.1 + 0.2*level)
    endfunction

    // The Blessed Field Infused hero revive cooldown 
    private function GetHeroResetTime takes nothing returns real
        return 60.
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BlessedField extends Ability
        private static integer array revive

        private real x
        private real y
        private unit unit
        private real face
        private integer id
        private effect effect
        private player player
        private integer level
        private boolean infused = false

        method destroy takes nothing returns nothing
            if unit == null then
                set revive[id] = revive[id] - 1
            else
                call DestroyEffect(effect)
                call UnitRemoveAbility(unit, AURA)
                call UnitRemoveAbility(unit, INFUSED_AURA)
                call DummyRecycle(unit)
            endif

            set unit = null
            set effect = null
            set player = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r blesses the targeted area, creating a |cffffcc00Blessed Field|r. All allied units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + "|r |cffffcc00AoE|r have their |cff00ff00Health Regeneration|r increased by |cff00ff00" + N2S(25 * level, 0) + "|r and take |cffffcc00" + N2S((1 - GetDamageReduction(level)) * 100, 0) + "%|r reduced damage from all sources.\n\n|cffffcc00Light Infused|r: When allied units within |cffffcc00Blessed Field|r area receives a killing blow, their death is denied and they regain |cffffcc00" + N2S((0.1 + 0.2*level) * 100, 0) + "%|r of their |cffff0000Maximum Health|r. This effect can only happen once for |cffffcc00Hero|r units with |cffffcc00" + N2S(GetHeroResetTime(), 1) + "|r seconds cooldown."
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set face = 0
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set player = Spell.source.player
            set unit = DummyRetrieve(player, x, y, 0, face)
            set effect = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)

            call UnitAddAbility(unit, AURA)
            call SetUnitAbilityLevel(unit, AURA, level)

            static if LIBRARY_LightInfusion then
                if LightInfusion.charges[Spell.source.id] > 0 then
                    call UnitAddAbility(unit, INFUSED_AURA)
                    call SetUnitAbilityLevel(unit, INFUSED_AURA, level)
                    call LightInfusion.consume(Spell.source.id)
                endif
            endif

            call StartTimer(GetDuration(Spell.source.unit, level), false, this, 0)
            call DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, x, y, 0, SPAWN_SCALE))
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if Damage.amount > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                    set Damage.amount = Damage.amount * GetDamageReduction(2)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if Damage.amount >= Damage.target.health then
                            set Damage.amount = 0
                            
                            if not Damage.target.isHero then
                                call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if revive[Damage.target.id] == 0 then
                                    set this = thistype.allocate()
                                    set id = Damage.target.id
                                    set revive[Damage.target.id] = revive[Damage.target.id] + 1

                                    call StartTimer(GetHeroResetTime(), false, this, id)
                                    call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                    call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                endif
                            endif
                        endif
                    endif
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                    set Damage.amount = Damage.amount * GetDamageReduction(1)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if Damage.amount >= Damage.target.health then
                            set Damage.amount = 0

                            if not Damage.target.isHero then
                                call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if revive[Damage.target.id] == 0 then
                                    set this = thistype.allocate()
                                    set id = Damage.target.id
                                    set revive[Damage.target.id] = revive[Damage.target.id] + 1

                                    call StartTimer(GetHeroResetTime(), false, this, id)
                                    call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                    call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                endif
                            endif
                        endif
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