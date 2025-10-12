library BadWeather requires RegisterPlayerUnitEvent, Spell, Modules, Utilities, DamageInterface
    /* ---------------------- Bad Weather v1.1 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     Vexorian             - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ability
        private constant integer ABILITY       = 'Jna6'
        // The raw code of the debuff Ability
        private constant integer DEBUFF        = 'Jna7'
        // The raw code of the debuff buff
        private constant integer BUFF          = 'BJn4'
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
    private struct BadWeather extends Spell
        private unit unit
        private effect effect

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(unit, DEBUFF)
            call DestroyEffect(effect)
            call DummyRecycle(unit)
            call deallocate()
            
            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Jaina|r conjures a heavy rain at the target region causing all enemy units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r to take |cffffcc00" + N2S(20, 0) + "%|r increased |cff00ffffMagic|r damage.\n\nLasts for |cffffcc00" + N2S(GetDuratoin(source, level), 0) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            set effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

            call UnitAddAbility(unit, DEBUFF)
            call StartTimer(GetDuratoin(Spell.source.unit, Spell.level), false, this, -1)
        endmethod

        private static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 and Damage.isEnemy then
                set Damage.amount = Damage.amount * (1 + GetDamageBonus(BUFF))
            endif
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

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary
