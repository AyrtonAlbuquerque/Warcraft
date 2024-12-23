library DoomCurse requires DamageInterface, TimerUtils, Ability, PluginSpellEffect, NewBonus
    /* ---------------------- Doom Curse v1.5 by Chopinski --------------------- */
    // Credits:
    //     marilynmonroe - Pit Infernal model
    //     Mr.Goblin     - Inferno icon
    //     Vexorian      - TimerUtils Library
    //     Mytich        - Soul Armor Spring.mdx
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Doom Curse ability
        private constant integer    ABILITY     = 'A004'
        // The raw code of the Doom Curse buff
        private constant integer    CURSE_BUFF  = 'B001'
        // The raw code of the unit created
        private constant integer    UNIT_ID     = 'n001'
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt 
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
    endglobals

    // The damage dealt per interval
    private function GetDamage takes unit source, integer level returns real
        return 125. * level + 1.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The interval at which the damage is dealt
    private function GetInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The damage amplification cursed units take from caster
    private function GetAmplification takes integer level returns real
        return 0.1 + 0.2*level
    endfunction

    // The Pit Infernal base damage
    private function GetBaseDamage takes integer level, unit source returns integer
        return R2I(50*level + GetUnitBonus(source, BONUS_DAMAGE)*0.5)
    endfunction

    // The Pit Infernal base health
    private function GetHealth takes integer level, unit source returns integer
        return R2I(1000 + 500*level + BlzGetUnitMaxHP(source)*0.5)
    endfunction

    // The Pit Infernal base armor
    private function GetArmor takes integer level, unit source returns real
        return 10.*level + GetUnitBonus(source, BONUS_ARMOR)
    endfunction

    // The Pit Infernal Spell Power
    private function GetSpellPower takes unit source, integer level returns real
        return GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Pit Infernal duration. By default is the ability summoned unit duration field. If 0 the unit will last forever.
    private function GetDuration takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_SUMMONED_UNIT_DURATION_SECONDS_NDO3, level - 1)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoomCurse extends Ability
        private static unit array source

        private integer id
        private unit caster
        private unit target
        private real damage
        private integer level

        method destroy takes nothing returns nothing
            set caster = null
            set target = null
            set source[id] = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level returns string
            return "|cffffcc00Mannoroth|r marks an enemy unit with a |cffffcc00Doom Curse|r, silencing, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage every |cffffcc00" + N2S(GetInterval(level), 1) + "|r second and increases the damage that the targeted unit takes from |cffffcc00Mannoroth|r by |cffffcc00" + N2S(GetAmplification(level) * 100, 0) + "%|r. If the cursed unit dies under the effect of |cffffcc00Doom Curse|r, a |cffffcc00Pit Infernal|r will spawn from it corpse. The |cffffcc00Pit Infernal|r can cast |cffffcc00Infernal Charge|r, charging towards the pointed direction, knocking enemy units aside and damaging them, and |cffffcc00War Stomp|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            if GetUnitAbilityLevel(target, CURSE_BUFF) > 0 then
                call UnitDamageTarget(caster, target, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)

                return true
            endif
                
            return false
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set id = Spell.target.id
            set level = Spell.level
            set caster = Spell.source.unit
            set target = Spell.target.unit
            set damage = GetDamage(Spell.source.unit, Spell.level)
            set source[id] = Spell.source.unit

            call StartTimer(GetInterval(Spell.level), true, this, -1)
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local boolean cursed = GetUnitAbilityLevel(Damage.target.unit, CURSE_BUFF) > 0
            local unit u

            if cursed and Damage.amount > 0 then
                if source[Damage.target.id] == Damage.source.unit then
                    set Damage.amount = Damage.amount * (1 + GetAmplification(level))
                endif

                if Damage.amount >= GetWidgetLife(Damage.target.unit) and source[Damage.target.id] != null then
                    set u = CreateUnit(GetOwningPlayer(source[Damage.target.id]), UNIT_ID, Damage.target.x, Damage.target.y, 0)

                    call SetUnitBonus(u, BONUS_SPELL_POWER, GetSpellPower(source[Damage.target.id], level))
                    call SetUnitAnimation(u, "Birth")
                    call BlzSetUnitBaseDamage(u, GetBaseDamage(level, source[Damage.target.id]), 0)
                    call BlzSetUnitMaxHP(u, GetHealth(level, source[Damage.target.id]))
                    call BlzSetUnitArmor(u, GetArmor(level, source[Damage.target.id]))
                    call SetUnitLifePercentBJ(u, 100)

                    if GetDuration(source[Damage.target.id], level) > 0 then
                        call UnitApplyTimedLife(u, 'BTLF', GetDuration(source[Damage.target.id], level))
                    endif
                endif
            endif

            set u = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary