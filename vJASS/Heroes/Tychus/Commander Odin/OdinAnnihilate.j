library OdinAnnihilate requires Spell, Missiles, Periodic, Utilities optional NewBonus
    /* -------------------- Odin Annihilate v1.2 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Odin Annihilate ability
        public  constant integer ABILITY = 'A008'
        // The Missile model
        private constant string  MODEL   = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE   = 0.6
        // The Missile speed
        private constant real    SPEED   = 1000.
        // The Missile height offset
        private constant real    HEIGHT  = 200.
    endglobals

    // The Explosion AoE
    private function GetAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The max aoe at which rockets can strike, by default the ability aoe field
    private function GetMaxAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The explosion damage
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. * level + (0.8 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        endif
    endfunction

    // The numebr of rockets.
    private function GetRocketCount takes integer level returns integer
        return 10 + 5*level
    endfunction

    // The interval at which rockets are spawnned.
    private function GetInterval takes integer level returns real
        return 0.2 + 0.*level
    endfunction

    // The rocket missile arc.
    private function GetArc takes integer level returns real
        return GetRandomReal(30, 60)
    endfunction

    // The rocket missile curve.
    private function GetCurve takes integer level returns real
        return GetRandomReal(-20, 20)
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Rocket extends Missiles  
        real aoe
        group group

        private method onFinish takes nothing returns boolean
            local unit u

            call DestroyEffect(AddSpecialEffect(MODEL, x, y))
            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)

            set group = null

            return true
        endmethod
    endstruct

    private struct OdinAnnihilate extends Spell
        private real x
        private real y
        private real aoe
        private unit unit
        private player player
        private integer count
        private integer level

        method destroy takes nothing returns nothing
            set unit = null
            set player = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Odin|r unleashes a barrage of |cffffcc00" + N2S(GetRocketCount(level), 0) + "|r rockets towards the target area, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r Magic|r damage each rocket."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real range
            local Rocket rocket

            set count = count - 1

            if count > 0 then
                set range = GetRandomRange(aoe)
                set rocket = Rocket.create(GetUnitX(unit), GetUnitY(unit), HEIGHT, GetRandomCoordInRange(x, range, true), GetRandomCoordInRange(y, range, false), 50)
                set rocket.model = MODEL
                set rocket.scale = SCALE
                set rocket.speed = SPEED
                set rocket.source = unit
                set rocket.owner = player
                set rocket.arc = GetArc(level)
                set rocket.aoe = GetAoE(level)
                set rocket.group = CreateGroup()
                set rocket.curve = GetCurve(level)
                set rocket.damage = GetDamage(unit, level)

                call rocket.launch()
            endif

            return count > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set player = Spell.source.player
            set count = GetRocketCount(Spell.level)
            set aoe = GetMaxAoE(Spell.source.unit, Spell.level)

            call StartTimer(GetInterval(Spell.level), true, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary