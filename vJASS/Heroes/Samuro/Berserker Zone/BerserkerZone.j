library BerserkerZone requires Spell, Modules, Utilities, NewBonus
    /* --------------------- BerserkerZone v1.1 by Chopinski -------------------- */
    // Credits:
    //     Az - BladeZone model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Berserker Zone ability
        public  constant integer ABILITY    = 'SmrB'
        // The raw code of the Berserker Zone aura
        public  constant integer AURA       = 'SmrC'
        // The raw code of the Berserker Zone buff
        public  constant integer BUFF       = 'BSm1'
        // The model path used in Berserker Zone
        private constant string  MODEL      = "BladeZone.mdl"
        // The model scale
        private constant real    SCALE      = 1
    endglobals

    // The Berserker Zone damage bonus per interval
    private function GetBonusDamage takes integer level returns real
        return 5. * level
    endfunction

    // The Berserker Zone crit chance bonus per interval
    private function GetBonusCriticalChance takes integer level returns real
        return 0.01 * level
    endfunction

    // The Berserker Zone crit damage bonus per interval
    private function GetBonusCriticalDamage takes integer level returns real
        return 0.025 * level
    endfunction

    // The Berserker Zone bonus interval
    private function GetInterval takes integer level returns real
        return 1 + 0. * level
    endfunction

    // The Berserker Zone duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Berserker Zone AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BerserkerZone extends Spell
        private real x
        private real y
        private real aoe
        private unit unit
        private group group
        private real period
        private effect effect
        private integer level
        private real duration

        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call UnitRemoveAbility(unit, AURA)
            call DummyRecycle(unit)
            call deallocate()

            set unit = null
            set group = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Samuro|r places his blade in the ground creating a |cffffcc00Berserker Zone|r. Allied units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r of the blade gains |cffff0000" + N2S(GetBonusDamage(level), 0) + "|r |cffff0000Damage|r, |cffffcc00" + N2S(GetBonusCriticalChance(level) * 100, 1) + "%%|r |cffff0000Critical Chance|r and |cffffcc00" + N2S(GetBonusCriticalDamage(level) * 100, 1) + "%%|r |cffff0000Critical Damage|r every second.\n\nLasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - period

            if duration > 0 then
                call GroupEnumUnitsInRange(group, x, y, aoe, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if GetUnitAbilityLevel(u, BUFF) > 0 then
                            call LinkBonusToBuff(u, BONUS_DAMAGE, GetBonusDamage(level), BUFF)
                            call LinkBonusToBuff(u, BONUS_CRITICAL_CHANCE, GetBonusCriticalChance(level), BUFF)
                            call LinkBonusToBuff(u, BONUS_CRITICAL_DAMAGE, GetBonusCriticalDamage(level), BUFF)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
            
            return duration > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set group = CreateGroup()
            set period = GetInterval(Spell.level)
            set aoe = GetAoE(Spell.source.unit, Spell.level)
            set unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            set effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)
            set duration = GetDuration(Spell.source.unit, Spell.level)

            call UnitAddAbility(unit, AURA)
            call SetUnitAbilityLevel(unit, AURA, Spell.level)
            call StartTimer(period, true, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary