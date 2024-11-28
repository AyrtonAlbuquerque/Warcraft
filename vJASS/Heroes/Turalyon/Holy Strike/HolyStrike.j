library HolyStrike requires DamageInterface
    /* ---------------------- Holy Strike v1.2 by Chopinski --------------------- */
    // Credits:
    //     AbstractCreativity - Icon
    //     Bribe              - SpellEffectEvent
    //     Blizzard           - Healing Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Holy Strike level 1 buff
        private constant integer BUFF_1       = 'B001'
        // The Holy Strike level 2 buff
        private constant integer BUFF_2       = 'B002'
        // The Holy Strike level 3 buff
        private constant integer BUFF_3       = 'B003'
        // The Holy Strike level 4 buff
        private constant integer BUFF_4       = 'B004'
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
    private struct HolyStrike extends array
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
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary