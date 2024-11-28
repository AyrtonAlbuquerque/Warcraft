library DoomCurse requires DamageInterface, TimerUtils, SpellEffectEvent, PluginSpellEffect, NewBonus
    /* ---------------------- Doom Curse v1.4 by Chopinski --------------------- */
    // Credits:
    //     marilynmonroe - Pit Infernal model
    //     Mr.Goblin     - Inferno icon
    //     Vexorian      - TimerUtils Library
    //     Mytich        - Soul Armor Spring.mdx
    //     Bribe         - SpellEffectEvent Library
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
    private function GetDamage takes integer level returns real
        return 125.*level
    endfunction

    // The interval at which the damage is dealt
    private function GetInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The damage amplification cursed units take from caster
    private function GetAmplification takes integer level returns real
        return 1.1 + 0.2*level
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

    // The Pit Infernal duration. By default is the ability summoned unit duration field. If 0 the unit will last forever.
    private function GetDuration takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_SUMMONED_UNIT_DURATION_SECONDS_NDO3, level - 1)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoomCurse
        static unit array source

        timer   timer
        unit    caster
        unit    target
        integer index
        integer level
        real    damage

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if GetUnitAbilityLevel(target, CURSE_BUFF) > 0 then
                call UnitDamageTarget(caster, target, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
            else
                call ReleaseTimer(timer)
                set source[index] = null
                set caster        = null
                set target        = null
                set timer         = null
                call deallocate()
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer         = NewTimerEx(this)
            set caster        = Spell.source.unit
            set level         = Spell.level
            set target        = Spell.target.unit
            set index         = GetUnitUserData(Spell.target.unit)
            set damage        = GetDamage(Spell.level)
            set source[index] = Spell.source.unit

            call TimerStart(timer, GetInterval(Spell.level), true, function thistype.onPeriod)
        endmethod

        private static method onDamage takes nothing returns nothing
            local real    damage = GetEventDamage()
            local boolean cursed = GetUnitAbilityLevel(Damage.target.unit, CURSE_BUFF) > 0
            local integer level  = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local unit    u

            if cursed and damage > 0 then
                if source[Damage.target.id] == Damage.source.unit then
                    set damage = damage*GetAmplification(level)
                    call BlzSetEventDamage(damage)
                endif

                if damage >= GetWidgetLife(Damage.target.unit) and source[Damage.target.id] != null then
                    set u = CreateUnit(GetOwningPlayer(source[Damage.target.id]), UNIT_ID, Damage.target.x, Damage.target.y, 0.)
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

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary