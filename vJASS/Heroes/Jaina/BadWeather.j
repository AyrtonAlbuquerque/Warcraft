library BadWeather requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, TimerUtils, Utilities, DamageInterface
    /* ---------------------- Bad Weather v1.0 by Chopinski --------------------- */
    // Credits:
    //     Bribe                - SpellEffectEvent
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     Vexorian             - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ability
        private constant integer ABILITY       = 'A005'
        // The raw code of the debuff Ability
        private constant integer DEBUFF        = 'A007'
        // The raw code of the debuff buff
        private constant integer BUFF          = 'B001'
        // The rain model
        private constant string  MODEL         = "Rain.mdl"
        // The rain model scale
        private constant real    SCALE         = 2.5
        // The raw code of the Jaina unit in the editor
        private constant integer JAINA_ID      = 'H000'
        // The GAIN_AT_LEVEL is greater than 0
        // Jaina will gain Bad Weather at this level 
        private constant integer GAIN_AT_LEVEL = 20
    endglobals

    // The rain duration
    private function GetDuratoin takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The bonus damage dealt (use different buffs per level in the debuff ability)
    private function GetDamageBonus takes integer buffid returns real
        if buffid == BUFF then
            return 0.2
        else
            return 0.2
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BadWeather
        timer timer
        unit unit
        effect effect

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call UnitRemoveAbility(unit, DEBUFF)
            call DestroyEffect(effect)
            call DummyRecycle(unit)
            call ReleaseTimer(timer)
            call deallocate()
            
            set timer = null
            set unit = null
            set effect = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 and Damage.isEnemy then
                call BlzSetEventDamage(GetEventDamage()*(1 + GetDamageBonus(BUFF)))
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer = NewTimerEx(this)
            set unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            set effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

            call UnitAddAbility(unit, DEBUFF)
            call TimerStart(timer, GetDuratoin(Spell.source.unit, Spell.level), false, function thistype.onExpire)
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == JAINA_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary
