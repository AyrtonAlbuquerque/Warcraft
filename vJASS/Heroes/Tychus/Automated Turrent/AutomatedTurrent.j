library AutomatedTurrent requires Spell, DamageInterface, Missiles, Utilities, NewBonus optional ArsenalUpgrade
    /* ------------------- Automated Turrent v1.3 by Chipinski ------------------ */
    // Credits:
    //     NFWar        - Gun Fire Icon
    //     4eNNightmare - Rocket Flare Icon
    //     Mythic       - Missile model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Automated Turrent ability
        public  constant integer ABILITY = 'A002'
        // The raw code of the Automated Turrent Missile ability
        private constant integer MISSILE = 'A003'
        // The raw code of the Automated Turrent unit
        private constant integer UNIT    = 'o000'
        // The Missile model
        private constant string  MODEL   = "Airstrike Rocket.mdl"
        // The Missile scale
        private constant real    SCALE   = 0.5
        // The Missile speed
        private constant real    SPEED   = 1000.
    endglobals

    // The Automated Turrent duration
    private function GetDuration takes unit caster, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Automated Turrent max hp
    private function GetMaxHealth takes integer level, unit source returns integer
        return R2I(100 + 100*level + 0.2 * BlzGetUnitMaxHP(source))
    endfunction

    // The Automated Turrent base damage.
    private function GetUnitDamage takes integer level, unit source returns integer
        return R2I(5 * level + (0.1 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE))
    endfunction

    // The number of Automated Turrents created
    private function GetAmount takes integer level returns integer
        return 1 + 0*level
    endfunction

    // The number of attacks necessary for a missile to be released
    private function GetAttackCount takes unit source, integer level returns integer
        static if LIBRARY_ArsenalUpgrade then
            if GetUnitAbilityLevel(source, ArsenalUpgrade_ABILITY) > 0 then
                return 18 - 2*level
            else
                return 22 - 2*level
            endif
        else
            return 22 - 2*level
        endif
    endfunction

    // The Missile max aoe for random location
    private function GetMaxAoE takes integer level returns real
        return 150. + 0.*level
    endfunction

    // The Missile damage aoe
    private function GetAoE takes integer level returns real
        return 150. + 0.*level
    endfunction

    // The Automated Turrent missile damage.
    private function GetDamage takes unit source, integer level returns real
        return 25.*level + (0.25 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Automated Turrent missile arc.
    private function GetArc takes integer level returns real
        return GetRandomReal(0, 20)
    endfunction

    // The Automated Turrent missile curve.
    private function GetCurve takes integer level returns real
        return GetRandomReal(-15, 15)
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Missile extends Missiles
        real aoe
        group group

        private method onFinish takes nothing returns boolean
            local unit u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)

            set group = null
            
            return true
        endmethod
    endstruct

    private struct AutomatedTurrent extends Spell
        private static unit array owner
        private static integer array array

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r summons an immobile |cffffcc00Automated Turrent|r at the target location The turrent has |cffff0000" + I2S(GetUnitDamage(level, source)) + " Attack Damage|r and |cffff0000" + I2S(GetMaxHealth(level, source)) + " Health|r. Every |cffffcc00" + I2S(GetAttackCount(source, level)) + "|r attacks, |cffffcc00Automated Turrent|r releases a |cffffcc00Missile|r to a random spot within |cffffcc00" + N2S(GetMaxAoE(level), 0) + " AoE|r of it's primary target. The |cffffcc00Missile|r damages enemy units within |cffffcc00" + N2S(GetAoE(level), 0) + " AoE|r, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage."
        endmethod

        private method onCast takes nothing returns nothing
            local integer i = GetAmount(Spell.level)
            local unit u
            
            loop
                exitwhen i <= 0
                    set u = CreateUnit(Spell.source.player, UNIT, Spell.x, Spell.y, 0)
                    set owner[GetUnitUserData(u)] = Spell.source.unit
                    set array[GetUnitUserData(u)] = 0

                    call SetUnitAbilityLevel(u, MISSILE, Spell.level)
                    call BlzSetUnitBaseDamage(u, GetUnitDamage(Spell.level, Spell.source.unit), 0)
                    call BlzSetUnitMaxHP(u, GetMaxHealth(Spell.level, Spell.source.unit))
                    call SetUnitLifePercentBJ(u, 100)
                    call UnitApplyTimedLife(u, 'BTLF', GetDuration(Spell.source.unit, Spell.level))
                set i = i - 1
            endloop

            set u = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local real range
            local Missile missile
            local integer level = GetUnitAbilityLevel(Damage.source.unit, MISSILE)

            if level > 0 and Damage.isEnemy then
                set array[Damage.source.id] = array[Damage.source.id] + 1

                if array[Damage.source.id] >= GetAttackCount(Damage.source.unit, level) then
                    set array[Damage.source.id] = 0
                    set range = GetRandomRange(GetMaxAoE(level))
                    set missile = Missile.create(Damage.source.x, Damage.source.y, Damage.source.z + 80, GetRandomCoordInRange(Damage.target.x, range, true), GetRandomCoordInRange(Damage.target.y, range, false), 0)
                    set missile.model = MODEL
                    set missile.scale = SCALE
                    set missile.speed = SPEED
                    set missile.source = Damage.source.unit
                    set missile.owner = Damage.source.player
                    set missile.arc = GetArc(level)
                    set missile.curve = GetCurve(level)
                    set missile.damage = GetDamage(owner[Damage.source.id], level)
                    set missile.group = CreateGroup()
                    set missile.aoe = GetAoE(level)

                    call missile.launch()
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary