library Stampede requires Spell, Missiles, Utilities, Modules, CrowdControl, optional NewBonus
    /* ----------------------- Stampede v1.2 by Chopinski ----------------------- */
    // Credits:
    //     00110000 - RemorselessWinter effect
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY     = 'Rex8'
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
        static if LIBRARY_NewBonus then
            return 75. * level + (0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 75. * level
        endif
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
    private struct Lizard extends Missile
        real stun

        private method onUnit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call StunUnit(u, stun, STUN_MODEL, STUN_ATTACH, false)
                endif
            endif

            return false
        endmethod
    endstruct

    private struct Stampede extends Spell
        private real x
        private real y
        private real aoe
        private real stun
        private real tick
        private unit unit
        private real damage
        private real duration
        private effect effect
        private player player
        private integer level
        private real collision

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set unit = null
            set effect = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r calls forth a rampaging horde of lizards. The lizards spawn from a random direction within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r every |cffffcc00" + N2S(GetSpawnInterval(level), 1) + "|r seconds and when coming in contact with an enemy unit they will do |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and stun the target for |cffffcc00" + N2S(GetStunDuration(level), 0) + "|r seconds. Lasts for |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real fx
            local real fy
            local real angle
            local Lizard lizard

            set duration = duration - tick

            if duration > 0 then
                set fx = GetRandomCoordInRange(x, aoe, true)
                set fy = GetRandomCoordInRange(y, aoe, false)
                set angle = AngleBetweenCoordinates(fx, fy, x, y)
                set lizard = Lizard.create(fx, fy, 0, x + aoe * Cos(angle), y + aoe * Sin(angle), 0)

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
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set player = Spell.source.player
            set collision = GetCollisionSize(level)
            set duration = GetDuration(unit, level)
            set damage = GetDamage(unit, level)
            set tick = GetSpawnInterval(level)
            set stun = GetStunDuration(level)
            set aoe = GetAoE(unit, level)/2
            set effect = AddSpecialEffectEx(AOE_MODEL, x, y, 0, AOE_SCALE)

            call StartTimer(tick, true, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary
