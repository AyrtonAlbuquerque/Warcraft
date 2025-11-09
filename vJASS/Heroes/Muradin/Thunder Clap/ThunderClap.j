library ThunderClap requires Spell, TimedHandles, CrowdControl, Utilities optional Avatar optional StormBolt optional NewBonus
    /* -------------------------------------- Thunder Clap v1.6 ------------------------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    //     TriggerHappy   - TimedHandles
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Thunder Clap ability
        public  constant integer ABILITY             = 'Mrd2'
        // The raw code of the Thunder Clap Recast ability
        public  constant integer THUNDER_CLAP_RECAST = 'Mrd6'
        // The model used when storm bolt refunds mana on kill
        private constant string  HEAL_EFFECT         = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
        // The attachment point
        private constant string  ATTACH_POINT        = "origin"
        // The slow model
        private constant string  SLOW_MODEL          = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
        // The slow model attachment point
        private constant string  SLOW_POINT          = "overhead"
        // The stun model
        private constant string  STUN_MODEL          = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attachment point
        private constant string  STUN_POINT          = "overhead"
        // Use Storm Bolt v3
        private constant boolean STORM_BOLT_V3       = true
    endglobals

    // The damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 75.*level + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 75.*level
        endif
    endfunction

    // The movement speed slow amount
    private function GetMovementSlowAmount takes unit source, integer level returns real
        return 0.5 + 0*level
    endfunction

    // The attack speed slow amount
    private function GetAttackSlowAmount takes unit source, integer level returns real
        return 0.5 + 0*level
    endfunction

    // The duration
    private function GetDuration takes unit source, unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        endif
    endfunction

    // The AoE
    private function GetAoE takes unit source, integer level returns real
        local real aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)

        static if LIBRARY_Avatar then
            if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                set aoe = aoe * 1.5
            endif
        endif

        return aoe
    endfunction

    // The healing amount
    private function GetHealAmount takes unit source, unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.1
        else
            return 0.025
        endif
    endfunction

    // Filter for units
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct ThunderClap extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Muradin|r slams the ground, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and slowing the movement speed and attack rate of nearby enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r by |cffffcc00" + N2S(GetAttackSlowAmount(source, level) * 100, 0) + "%|r. In addition, |cffffcc00Muradin|r gets healed by |cffffcc002.5%|r (|cffffcc0010%|r for |cffffcc00Heroes|r) of his maximum health for every unit hit by |cffffcc00Thunder Clap|r. If |cffffcc00Avatar|r is active, |cffffcc00Thunder Clap|r AoE is increased by |cffffcc0050%|r and the second |cffffcc00Thunder Clap|r stuns enemy units instead."
        endmethod
        
        private method onCast takes nothing returns nothing
            local unit source = Spell.source.unit
            local player owner = Spell.source.player
            local integer id = Spell.id
            local integer level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)
            local real damage = GetDamage(Spell.source.unit, level)
            local real movement = GetMovementSlowAmount(Spell.source.unit, level)
            local real attack = GetAttackSlowAmount(Spell.source.unit, level)
            local real aoe = GetAoE(Spell.source.unit, level)
            local group g = CreateGroup()
            local real heal = 0
            local unit u
    
            call GroupEnumUnitsInRange(g, Spell.source.x, Spell.source.y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitFilter(owner, u) then
                        static if LIBRARY_Avatar then
                            if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                                if id ==  THUNDER_CLAP_RECAST then
                                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                        set heal = heal + GetHealAmount(source, u, level)

                                        call StunUnit(u, GetDuration(source, u, level), STUN_MODEL, STUN_POINT, false)
                                    endif
                                else
                                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                        set heal = heal + GetHealAmount(source, u, level)

                                        call SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                                        call SlowUnitAttack(u, attack, GetDuration(source, u, level), null, null, false)
                                    endif
                                endif
                            else
                                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                    set heal = heal + GetHealAmount(source, u, level)

                                    call SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                                    call SlowUnitAttack(u, attack, GetDuration(source, u, level), null, null, false)
                                endif
                            endif
                        else
                            if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                set heal = heal + GetHealAmount(source, u, level)

                                call SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                                call SlowUnitAttack(u, attack, GetDuration(source, u, level), null, null, false)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            if heal > 0 then
                call SetWidgetLife(source, GetWidgetLife(source) + (BlzGetUnitMaxHP(source)*heal))
                call DestroyEffectTimed(AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT), 1.0)
            endif
            
            static if LIBRARY_StormBolt and STORM_BOLT_V3 then
                call StormBolt.lightning(source, damage, aoe)
            endif

            set g = null
            set owner = null
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpell(thistype.allocate(), THUNDER_CLAP_RECAST)
        endmethod
    endstruct
endlibrary