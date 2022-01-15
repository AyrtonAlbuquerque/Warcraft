library BreakingSlash requires CriticalStrike, Missiles
    /* -------------------- Breaking Slash v1.2 by Chopinski -------------------- */
    // Credits:
    //     PeeKay         - Icon
    //     AZ             - Slash model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Breaking Slash ability
        public  constant integer    ABILITY         = 'A000'
        // The missile model
        private constant string     MISSILE_MODEL   = "Fire_Slash.mdl"
        // The missile size
        private constant real       MISSILE_SCALE   = 1.
        // The missile speed
        private constant real       MISSILE_SPEED   = 1200.
        // The attack type of the damage dealt
        private constant attacktype ATTACK_TYPE     = ATTACK_TYPE_HERO  
        // The damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE     = DAMAGE_TYPE_UNIVERSAL
    endglobals

    // The Fire Slash damage deatl based on a base damage amount and the ability level
    public function GetDamage takes real damage, integer level returns real
        return damage*level*0.3
    endfunction

    // The Fire Slash travel distance
    private function GetDistance takes integer level returns real
        return 500. + 100.*level
    endfunction

    // The Fire Slash collision size
    private function GetCollision takes integer level returns real
        return 75. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and /*
            */ UnitAlive(target) and /*
            */ not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct FireSlash extends Missiles
        method onHit takes unit hit returns boolean
            if Filtered(owner, hit) then
                call UnitDamageTarget(source, hit, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null)
            endif

            return false
        endmethod
    endstruct

    struct BreakingSlash extends array
        static method slash takes unit source, unit target, real damage, integer level returns nothing
            local real x  = GetUnitX(target)
            local real y  = GetUnitY(target)
            local real z  = GetUnitFlyHeight(target)
            local real a  = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local real d  = GetDistance(level)
            local real tx = x + d*Cos(a)
            local real ty = y + d*Sin(a)
            local FireSlash missile = FireSlash.create(x, y, z, tx, ty, 0)

            set missile.source    = source
            set missile.owner     = GetOwningPlayer(source)
            set missile.damage    = damage
            set missile.model     = MISSILE_MODEL
            set missile.scale     = MISSILE_SCALE
            set missile.speed     = MISSILE_SPEED
            set missile.collision = GetCollision(level)

            call missile.launch()
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit    source = GetCriticalSource()
            local unit    target = GetCriticalTarget()
            local real    damage = GetCriticalDamage()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                call slash(source, target, GetDamage(damage, level), level)
            endif

            set source = null
            set target = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
        endmethod
    endstruct
endlibrary