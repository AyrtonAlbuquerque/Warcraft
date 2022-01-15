library OdinAnnihilate requires SpellEffectEvent, PluginSpellEffect, Missiles, TimerUtils, Utilities
    /* -------------------- Odin Annihilate v1.2 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     vexorian        - TimerUtils
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
    private function GetDamage takes integer level returns real
        return 50.*level
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
        group group
        real  aoe

        method onFinish takes nothing returns boolean
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

    private struct OdinAnnihilate
        timer   timer
        unit    unit
        player  player
        integer count
        integer level
        real    aoe
        real    x
        real    y

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real     range
            local Rocket   rocket

            if count > 0 then
                set range  = GetRandomRange(aoe)
                set rocket = Rocket.create(GetUnitX(unit), GetUnitY(unit), HEIGHT, GetRandomCoordInRange(x, range, true), GetRandomCoordInRange(y, range, false), 50)
                set rocket.model  = MODEL
                set rocket.scale  = SCALE
                set rocket.speed  = SPEED
                set rocket.source = unit
                set rocket.owner  = player
                set rocket.arc    = GetArc(level)
                set rocket.curve  = GetCurve(level)
                set rocket.damage = GetDamage(level)
                set rocket.aoe    = GetAoE(level)
                set rocket.group  = CreateGroup()

                call rocket.launch()
            else
                call ReleaseTimer(timer)
                call deallocate()
                set player = null
                set timer  = null
                set unit   = null
            endif
            set count = count - 1
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer  = NewTimerEx(this)
            set unit   = Spell.source.unit
            set level  = Spell.level
            set player = Spell.source.player
            set x      = Spell.x
            set y      = Spell.y
            set aoe    = GetMaxAoE(Spell.source.unit, Spell.level)
            set count  = GetRocketCount(Spell.level)

            call TimerStart(timer, GetInterval(Spell.level), true, function thistype.onPeriod)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary