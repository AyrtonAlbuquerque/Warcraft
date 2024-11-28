library ExplosiveRune requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Utilities, DamageInterfaceUtils optional Afterburner, CooldownReduction
    /* -------------------- Explosive Rune v1.5 by Chopinski -------------------- */
    // Credits:
    //     Mythic           - Conflagrate model
    //     JetFangInferno   - FireRune model
    //     Blizzard         - icon (Edited by me)
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     Bribe            - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Explosive Rune Ability
        private constant integer    ABILITY             = 'A001'
        // The number of charges of the ability
        private constant integer    CHARGES_COUNT       = 4
        // The number of charges of the ability
        private constant real       CHARGES_COOLDOWN    = 15.0
        // The Explosion delay
        private constant real       EXPLOSION_DELAY     = 1.5
        // The Explosion effect path
        private constant string     EXPLOSION_EFFECT    = "Conflagrate.mdl"
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
        // If true will damage structures
        private constant boolean    DAMAGE_STRUCTURES   = false
        // If true will damage allies
        private constant boolean    DAMAGE_ALLIES       = false
        // If true will damage magic immune unit if the
        // ATTACK_TYPE is not spell damage
        private constant boolean    DAMAGE_MAGIC_IMMUNE = false
        // If true, the ability tooltip will change accordingly
        private constant boolean    CHANGE_TOOLTIP      = true
    endglobals

    //The damage amount of the explosion
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ExplosiveRune
        static integer array charges
        static integer array n

        timer   timer
        unit 	unit
        real    damage
        real    aoe
        integer id
        real    x
        real    y

        private static method toolTip takes unit u returns nothing
            local integer id = GetUnitUserData(u) 
            local integer lvl = GetUnitAbilityLevel(u, ABILITY)
            local string array s
            
            set s[1] = R2SW(BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, lvl - 1), 0, 0)
            set s[0] = ("Ragnaros creates an |cffffcc00Explosive Rune|r in the target location that explodes after" + /* 
                        */" |cffffcc00" + R2SW(EXPLOSION_DELAY, 1, 1) + "|r seconds, dealing |cff00ffff" + /*
                        */AbilitySpellDamageEx(GetDamage(lvl), u) + " Magic|r damage to enemy units within |cffffcc00" + /*
                        */s[1] + " AoE|r. Holds up to |cffffcc00" + I2S(CHARGES_COUNT) + "|r charges. " + /*
                        */"Gains |cffffcc001|r charge every |cffffcc00" + R2SW(CHARGES_COOLDOWN, 1, 1) + "|r seconds.\n\n" + /*

                        */"Charges: |cffffcc00" + I2S(charges[id]) + "|r")
            call BlzSetAbilityExtendedTooltip(ABILITY, s[0], lvl - 1)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                if charges[id] < CHARGES_COUNT and charges[id] >= 0 then
                    set charges[id] = charges[id] + 1
                    call BlzEndUnitAbilityCooldown(unit, ABILITY)
                    static if CHANGE_TOOLTIP then
                        call toolTip(unit)
                    endif
                endif
            else
                call ReleaseTimer(timer)
                
                set charges[id] = 0
                set n[id] = 0
                set timer = null
                set unit  = null

                call deallocate()
            endif
        endmethod

        private static method onExplodeRune takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            static if LIBRARY_Afterburner then
                call Afterburn(x, y, unit)
            endif
            call UnitDamageArea(unit, x, y, aoe, damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_MAGIC_IMMUNE, DAMAGE_ALLIES)
            call DestroyEffect(AddSpecialEffect(EXPLOSION_EFFECT, x, y))
            call ReleaseTimer(timer)

            set timer = null
            set unit  = null

            call deallocate()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this
            local thistype rune

            if n[Spell.source.id] == 0 then
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set unit = Spell.source.unit
                set id = Spell.source.id
                set charges[id] = CHARGES_COUNT
                set n[id] = this

                call TimerStart(timer, CHARGES_COOLDOWN, true, function thistype.onPeriod)
            else
                set this = n[Spell.source.id]
            endif
            
            set rune = thistype.allocate()
            set rune.timer = NewTimerEx(rune)
            set rune.unit = Spell.source.unit
            set rune.damage = GetDamage(Spell.level)
            set rune.aoe = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_AREA_OF_EFFECT, Spell.level - 1)
            set rune.x = Spell.x
            set rune.y = Spell.y

            if charges[id] > 0 then
                set charges[id] = charges[id] - 1
                if charges[id] >= 1 then
                    call ResetUnitAbilityCooldown(unit, ABILITY)
                else
                    static if LIBRARY_CooldownReduction then
                        call CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, TimerGetRemaining(timer))
                    else
                        call BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, TimerGetRemaining(timer))
                        call IncUnitAbilityLevel(unit, ABILITY)
                        call DecUnitAbilityLevel(unit, ABILITY)
                    endif
                endif
            endif

            call TimerStart(rune.timer, EXPLOSION_DELAY, false, function thistype.onExplodeRune)

            static if CHANGE_TOOLTIP then
                call toolTip(unit)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary