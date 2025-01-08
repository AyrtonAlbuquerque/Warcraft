library BreakingSlash requires Ability, Missiles
    /* -------------------- Breaking Slash v1.3 by Chopinski -------------------- */
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
    public function GetDamage takes integer level returns real
        return 0.3 * level
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

    private struct BreakingSlash extends Ability
        private static method slash takes unit source, unit target, real damage, integer level returns nothing
            local real x = GetUnitX(target)
            local real y = GetUnitY(target)
            local real distance = GetDistance(level)
            local real angle = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local FireSlash slash = FireSlash.create(x, y, GetUnitFlyHeight(target), x + distance * Cos(angle), y + distance * Sin(angle), 0)

            set slash.source = source
            set slash.damage = damage
            set slash.model = MISSILE_MODEL
            set slash.scale = MISSILE_SCALE
            set slash.speed = MISSILE_SPEED
            set slash.owner = GetOwningPlayer(source)
            set slash.collision = GetCollision(level)

            call slash.launch()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return ""
        endmethod

        private static method onCritical takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(GetCriticalSource(), ABILITY)

            if level > 0 then
                call slash(GetCriticalSource(), GetCriticalTarget(), GetCriticalDamage() * GetDamage(level), level)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
        endmethod
    endstruct
endlibrary