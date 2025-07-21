library HammerTime requires Spell, DamageInterface, Utilities optional StormBolt, optional ThunderClap, optional Avatar
    /* ---------------------- HammerTime v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Hammer Time ability
        private constant integer ABILITY       = 'A009'
        // The raw code of the Muradin unit in the editor
        private constant integer MURADIN_ID    = 'H000'
        // The GAIN_AT_LEVEL is greater than 0
        // Muradin will gain Hammer Time at this level 
        private constant integer GAIN_AT_LEVEL = 20
    endglobals

    // The cooldown reduced for the storm bolt ability
    private function GetStormBoltCooldown takes integer level returns real
        return 0.5 + 0.*level
    endfunction

    // The cooldown reduced for the thunder clap ability
    private function GetThunderClapCooldown takes integer level returns real
        return 0.5 + 0.*level
    endfunction

    // The cooldown reduced for the Avatar ability
    private function GetAvatarCooldown takes integer level returns real
        return 1. + 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HammerTime extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Muradin|r basic attacks against enemy units reduce the cooldown of |cffffcc00Storm Bolt|r by |cffffcc00" + N2S(GetStormBoltCooldown(level), 1) + "|r seconds and |cffffcc00Thunder Clap|r by |cffffcc00" + N2S(GetThunderClapCooldown(level), 1) + "|r seconds and |cffffcc00Avatar|r cooldown by |cffffcc00" + N2S(GetAvatarCooldown(level), 1) +"|r second."
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == MURADIN_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local real cooldown
            local real reduction

            if level > 0 and Damage.isEnemy then
                static if LIBRARY_StormBolt then
                    set cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, StormBolt_ABILITY)
                    set reduction = GetStormBoltCooldown(level)

                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            call ResetUnitAbilityCooldown(Damage.source.unit, StormBolt_ABILITY)
                        else
                            call BlzStartUnitAbilityCooldown(Damage.source.unit, StormBolt_ABILITY, cooldown - reduction)
                        endif
                    endif
                endif

                static if LIBRARY_ThunderClap then
                    set cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, ThunderClap_ABILITY)
                    set reduction = GetThunderClapCooldown(level)

                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            call ResetUnitAbilityCooldown(Damage.source.unit, ThunderClap_ABILITY)
                        else
                            call BlzStartUnitAbilityCooldown(Damage.source.unit, ThunderClap_ABILITY, cooldown - reduction)
                        endif
                    endif
                endif

                static if LIBRARY_Avatar then
                    set cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, Avatar_ABILITY)
                    set reduction = GetAvatarCooldown(level)

                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            call ResetUnitAbilityCooldown(Damage.source.unit, Avatar_ABILITY)
                        else
                            call BlzStartUnitAbilityCooldown(Damage.source.unit, Avatar_ABILITY, cooldown - reduction)
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary