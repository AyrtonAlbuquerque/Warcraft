library Stampede requires Ability, Missiles, Utilities, Periodic, CrowdControl, optional NewBonus
    /* ----------------------- Stampede v1.2 by Chopinski ----------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY     = 'A009'
        // The missile model
        private constant string  MODEL       = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
        // The missile scale
        private constant real    SCALE       = 0.8
        // The missile speed
        private constant real    SPEED       = 800
        // The stun model
        private constant string  STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attach point
        private constant string  STUN_ATTACH = "overhead"
    endglobals

    // The amount of damage dealt when a boar hits an enemy
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. * level + 0.2 * level * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25. * level
        endif
    endfunction

    // The stun duration
    private function GetStunDuration takes integer level returns real
        return 0.25 * level
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
        return 0.125 - 0.025*level
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
    private struct Lizard extends Missiles
        real stun

        private method onHit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call StunUnit(u, stun, STUN_MODEL, STUN_ATTACH, false)
                endif
            endif

            return false
        endmethod
    endstruct

    private struct Stampede extends Ability
        private real aoe
        private real stun
        private unit unit
        private real offset
        private real period
        private real damage
        private real duration
        private player player
        private real collision

        method destroy takes nothing returns nothing
            call deallocate()

            set unit = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r calls forth a rampaging horde of lizards that follows him. The lizards spawns every |cffffcc00" + N2S(GetSpawnInterval(level), 3) + "|r seconds and when coming in contact with an enemy unit they will do |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and stun the target for |cffffcc00" + N2S(GetStunDuration(level), 2) + "|r seconds. Lasts for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real angle
            local Lizard lizard

            set duration = duration - period

            if duration > 0 then
                set offset = -offset
                set angle = GetUnitFacing(unit) * bj_DEGTORAD
                set x = GetUnitX(unit) + aoe * Cos(angle + bj_PI) + GetRandomReal(0, aoe) * Cos(angle + offset*bj_PI/2)
                set y = GetUnitY(unit) + aoe * Sin(angle + bj_PI) + GetRandomReal(0, aoe) * Sin(angle + offset*bj_PI/2)
                set lizard = Lizard.create(x, y, 0, x + 2*aoe*Cos(angle), y + 2*aoe*Sin(angle), 0)

                set lizard.model = MODEL
                set lizard.scale = SCALE
                set lizard.speed = SPEED
                set lizard.stun = stun
                set lizard.source = unit
                set lizard.owner = player
                set lizard.damage = damage
                set lizard.collision = collision

                call lizard.launch()
            endif

            return duration > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.create()
            set offset = 1
            set unit = Spell.source.unit
            set player = Spell.source.player
            set collision = GetCollisionSize(Spell.level)
            set duration = GetDuration(unit, Spell.level)
            set damage = GetDamage(unit, Spell.level)
            set period = GetSpawnInterval(Spell.level)
            set stun = GetStunDuration(Spell.level)
            set aoe = GetAoE(unit, Spell.level)/2

            call StartTimer(period, true, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary
