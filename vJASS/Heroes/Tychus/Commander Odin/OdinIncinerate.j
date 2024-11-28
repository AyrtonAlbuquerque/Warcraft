library OdinIncinerate requires SpellEffectEvent, PluginSpellEffect, Missiles, TimerUtils, MouseUtils, DamageInterface, Utilities
    /* -------------------- Odin Annihilate v1.2 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     vexorian        - TimerUtils
    //     MyPad           - MouseUtils
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Odin Incinerate ability
        public  constant integer ABILITY = 'A009'
        // The raw code of the Incinerate ability
        private constant integer FLAMES  = 'A00A'
        // The Missile model
        private constant string  MODEL   = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE   = 0.6
        // The Missile speed
        private constant real    SPEED   = 1000.
        // The Missile arc
        private constant real    ARC     = 45.
        // The Missile height offset
        private constant real    HEIGHT  = 200.
        // The time the player has to move the mouse before the spell starts
        private constant real    DRAG_AND_DROP_TIME  = 0.05
    endglobals

    // The distance between rocket explosions that create the flames. Recommended about 50% of the size of the flame strike aoe.
    private function GetOffset takes integer level returns real
        return 100. +0*level
    endfunction

    // The explosion damage
    private function GetDamage takes integer level returns real
        return 50.*level
    endfunction

    // The explosion aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The incineration damage per interval
    private function GetIncinerationDamage takes integer level returns real
        return 12.5*level
    endfunction

    // The incineration AoE
    private function GetIncinerationAoE takes unit source, integer level returns real
        return GetAoE(source, level)
    endfunction

    // The incineration damage interval
    private function GetIncinerationInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The the incineration duration
    private function GetIncinerationDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The numebr of rockets.
    private function GetRocketCount takes integer level returns integer
        return 3 + 2*level
    endfunction

    // The interval at which rockets are spawnned.
    private function GetInterval takes integer level returns real
        return 0.2 + 0.*level
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Incineration
        static integer array proxy

        timer     timer
        unit      unit
        unit      dummy
        real      damage
        integer   key

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call UnitRemoveAbility(dummy, FLAMES)
            call DummyRecycle(dummy)
            call ReleaseTimer(timer)
            call deallocate()

            set unit  = null
            set dummy = null
            set timer = null
            set proxy[key] = 0
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability  abi

            set timer      = NewTimerEx(this)
            set unit       = source
            set damage     = dmg
            set dummy      = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set key        = GetUnitUserData(dummy)
            set proxy[key] = this

            call UnitAddAbility(dummy, FLAMES)
            set abi = BlzGetUnitAbility(dummy, FLAMES)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call IncUnitAbilityLevel(dummy, FLAMES)
            call DecUnitAbilityLevel(dummy, FLAMES)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call TimerStart(timer, duration + 0.05, false, function thistype.onExpire)

            set abi = null
            return this
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if proxy[Damage.source.id] != 0 and GetEventDamage() > 0 then
                set this = proxy[Damage.source.id]
                call BlzSetEventDamage(0)
                call UnitDamageTarget(unit, Damage.target.unit, damage, false, false, Damage.attacktype, Damage.damagetype, null)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod 
    endstruct
    
    private struct Rocket extends Missiles  
        group group
        real  aoe
        real  iAoE
        real  iDamage
        real  iInterval
        real  iDuration

        method onFinish takes nothing returns boolean
            local unit u

            call Incineration.create(x, y, iDamage, iDuration, iAoE, iInterval, source)
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

    private struct OdinIncinerate
        timer   timer
        unit    unit
        player  player
        integer count
        integer level
        integer i
        real    iDamage
        real    iAoE
        real    iInterval
        real    iDuration
        real    damage
        real    angle
        real    offset
        real    aoe
        real    x
        real    y

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local Rocket   rocket

            if i < count then
                set rocket = Rocket.create(GetUnitX(unit), GetUnitY(unit), HEIGHT, x + offset*i*Cos(angle), y + offset*i*Sin(angle), 50)
                set rocket.model     = MODEL
                set rocket.scale     = SCALE
                set rocket.speed     = SPEED
                set rocket.arc       = ARC
                set rocket.source    = unit
                set rocket.owner     = player
                set rocket.damage    = damage
                set rocket.aoe       = aoe
                set rocket.iAoE      = iAoE
                set rocket.iDamage   = iDamage
                set rocket.iInterval = iInterval
                set rocket.iDuration = iDuration
                set rocket.group     = CreateGroup()

                call rocket.launch()
            else
                call ReleaseTimer(timer)
                call deallocate()
                set player = null
                set timer  = null
                set unit   = null
            endif
            set i = i + 1
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            
            call TimerStart(timer, GetInterval(level), true, function thistype.onPeriod)
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer     = NewTimerEx(this)
            set unit      = Spell.source.unit
            set level     = Spell.level
            set player    = Spell.source.player
            set x         = Spell.x
            set y         = Spell.y
            set i         = 0
            set count     = GetRocketCount(Spell.level)
            set offset    = GetOffset(Spell.level)
            set damage    = GetDamage(Spell.level)
            set aoe       = GetAoE(Spell.source.unit, Spell.level)
            set iAoE      = GetIncinerationAoE(Spell.source.unit, Spell.level)
            set iDamage   = GetIncinerationDamage(Spell.level)
            set iInterval = GetIncinerationInterval(Spell.level)
            set iDuration = GetIncinerationDuration(Spell.level)

            call TimerStart(timer, DRAG_AND_DROP_TIME, false, function thistype.onExpire)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary