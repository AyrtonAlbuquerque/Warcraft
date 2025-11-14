library HolyStrike requires DamageInterface, Ability
    /* ---------------------- Holy Strike v1.3 by Chopinski --------------------- */
    // Credits:
    //     AbstractCreativity - Icon
    //     Bribe              - SpellEffectEvent
    //     Blizzard           - Healing Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Holy Strike ablity
        private constant integer ABILITY      = 'Trl4'
        // The Holy Strike level 1 buff
        private constant integer BUFF_1       = 'BTr0'
        // The Holy Strike level 2 buff
        private constant integer BUFF_2       = 'BTr1'
        // The Holy Strike level 3 buff
        private constant integer BUFF_3       = 'BTr2'
        // The Holy Strike level 4 buff
        private constant integer BUFF_4       = 'BTr3'
        // The Holy Strike heal model
        private constant string  MODEL        = "HolyStrike.mdl"
        // The Holy Strike heal attchment point
        private constant string  ATTACH_POINT = "origin"
    endglobals

    // The Holy Strike Heal
    private function GetHeal takes integer level, boolean isRanged returns real
        local real heal = 10.*level

        if isRanged then
            set heal = heal/2
        endif

        return heal
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HolyStrike extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r provides to all nearby allied units within |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) + " AoE|r the ability to |cffffcc00Holy Strike|r, healing |cffffcc00" + N2S(GetHeal(level, false), 0) + "|r health with every auto attack. Healing halved for range attacks."
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.isEnemy then
                if GetUnitAbilityLevel(Damage.source.unit, BUFF_4) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(4, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_3) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(3, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_2) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(2, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_1) > 0 then
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(1, Damage.source.isRanged))
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary