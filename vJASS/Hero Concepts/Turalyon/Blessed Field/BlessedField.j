library BlessedField requires SpellEffectEvent, PluginSpellEffect, TimerUtils, Utilities, optional LightInfusion
    /* --------------------- Blessed Field v1.2 by Chopinski -------------------- */
    // Credits:
    //     Darkfang           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     AZ                 - Blessings effect
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
    private struct BlessedField
        static integer array revive

        timer   timer
        real    x
        real    y
        unit    unit
        real    face
        effect  effect
        player  player
        integer level
        integer index
        boolean infused = false

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call ReleaseTimer(timer)
            call DestroyEffect(effect)
            call UnitRemoveAbility(unit, AURA)
            call UnitRemoveAbility(unit, INFUSED_AURA)
            call DummyRecycle(unit)
            call deallocate()

            set timer  = null
            set unit   = null
            set effect = null
            set player = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer    = NewTimerEx(this)
            set x        = Spell.x
            set y        = Spell.y
            set face     = 0.
            set player   = Spell.source.player
            set unit     = DummyRetrieve(player, x, y, 0, face)
            set effect   = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
            set level    = Spell.level

            call UnitAddAbility(unit, AURA)
            call SetUnitAbilityLevel(unit, AURA, level)

            static if LIBRARY_LightInfusion then
                if LightInfusion.charges[Spell.source.id] > 0 then
                    call UnitAddAbility(unit, INFUSED_AURA)
                    call SetUnitAbilityLevel(unit, INFUSED_AURA, level)
                    call LightInfusion.consume(Spell.source.id)
                endif
            endif

            call DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, x, y, 0, SPAWN_SCALE))
            call TimerStart(timer, GetDuration(Spell.source.unit, level), true, function thistype.onExpire)
        endmethod

        private static method onReset takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set revive[index] = revive[index] - 1

            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this

            if damage > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then // Level 2 of the Blessed Field ability (50% reductions)
                    set damage = damage*GetDamageReduction(2)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then // Level 2 of the Blessed Field Infused ability (50% hp restore)
                        if damage >= GetWidgetLife(Damage.target.unit) then
                            if not Damage.target.isHero then
                                set damage = 0
                                call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if revive[Damage.target.id] == 0 then
                                    set this   = thistype.allocate()
                                    set timer  = NewTimerEx(this)
                                    set index  = Damage.target.id
                                    set damage = 0
                                    set revive[Damage.target.id] = revive[Damage.target.id] + 1

                                    call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                    call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                    call TimerStart(timer, GetHeroResetTime(), false, function thistype.onReset)
                                endif
                            endif
                        endif
                    endif
                    call BlzSetEventDamage(damage)
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then // Level 1 of the Blessed Field ability (30% reductions)
                    set damage = damage*GetDamageReduction(1)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then // Level 1 of the Blessed Field Infused ability (30% hp restore)
                        if damage >= GetWidgetLife(Damage.target.unit) then
                            if not Damage.target.isHero then
                                set damage = 0
                                call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if revive[Damage.target.id] == 0 then
                                    set this   = thistype.allocate()
                                    set timer  = NewTimerEx(this)
                                    set index  = Damage.target.id
                                    set damage = 0
                                    set revive[Damage.target.id] = revive[Damage.target.id] + 1

                                    call SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                    call DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                    call TimerStart(timer, GetHeroResetTime(), false, function thistype.onReset)
                                endif
                            endif
                        endif
                    endif
                    call BlzSetEventDamage(damage)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary