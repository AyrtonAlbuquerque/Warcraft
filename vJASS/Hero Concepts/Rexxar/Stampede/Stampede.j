library Stampede requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, TimerUtils, CrowdControl
    /* ----------------------- Stampede v1.1 by Chopinski ----------------------- */
    // Credits:
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    //     00110000        - RemorselessWinter effect
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY     = 'A005'
        // The missile model
        private constant string  MODEL       = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
        // The missile scale
        private constant real    SCALE       = 0.8
        // The model used to indicate the aoe effect
        private constant string  AOE_MODEL   = "RemorselessWinter.mdl"
        // The blind model attachment point
        private constant real    AOE_SCALE   = 1.7
        // The missile speed
        private constant real    SPEED       = 1000
        // The stun model
        private constant string  STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attach point
        private constant string  STUN_ATTACH = "overhead"
    endglobals

    // The amount of damage dealt when a boar hits an enemy
    private function GetDamage takes unit source, integer level returns real
        return 75.*level
    endfunction

    // The stun duration
    private function GetStunDuration takes integer level returns real
        return 0.25*level
    endfunction

    // The ability duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The ability aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The missile spawn interval
    private function GetSpawnInterval takes integer level returns real
        return 0.5 - 0.1*level
    endfunction

    // The missile collision size
    private function GetCollisionSize takes integer level returns real
        return 64. + 0.*level
    endfunction

    // The unit filter
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Missile extends Missiles
        real stun

        method onHit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call StunUnit(u, stun, STUN_MODEL, STUN_ATTACH, false)
                endif
            endif

            return false
        endmethod
    endstruct

    private struct Stampede
        timer timer
        effect effect
        unit unit
        player player
        integer level
        real collision
        real duration
        real damage
        real tick
        real stun
        real aoe
        real x
        real y

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local Missile missile
            local real angle
            local real fx
            local real fy

            if duration > 0 then
                set duration = duration - tick
                set fx = GetRandomCoordInRange(x, aoe, true)
                set fy = GetRandomCoordInRange(y, aoe, false)
                set angle = AngleBetweenCoordinates(fx, fy, x, y)
                set missile = Missile.create(fx, fy, 0, x + aoe*Cos(angle), y + aoe*Sin(angle), 0)
                set missile.model = MODEL
                set missile.scale = SCALE
                set missile.speed = SPEED
                set missile.source = unit
                set missile.owner = player
                set missile.collision = collision
                set missile.damage = damage
                set missile.stun = stun

                call missile.launch()
            else
                call ReleaseTimer(timer)
                call DestroyEffect(effect)
                call deallocate()

                set timer = null
                set effect = null
            endif
        endmethod

        static method onCast takes nothing returns nothing
            local thistype this = thistype.create()

            set timer = NewTimerEx(this)
            set x = Spell.x
            set y = Spell.y
            set unit = Spell.source.unit
            set player = Spell.source.player
            set level = Spell.level
            set collision = GetCollisionSize(level)
            set duration = GetDuration(unit, level)
            set damage = GetDamage(unit, level)
            set tick = GetSpawnInterval(level)
            set stun = GetStunDuration(level)
            set aoe = GetAoE(unit, level)/2
            set effect = AddSpecialEffectEx(AOE_MODEL, x, y, 0, AOE_SCALE)

            call TimerStart(timer, tick, true, function thistype.onPeriod)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary
