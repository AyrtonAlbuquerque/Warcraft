library Critical requires RegisterPlayerUnitEvent, NewBonusUtils, CriticalStrike, Missiles
    /* ----------------------- Critical v1.2 by Chopinski ----------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Critical Strike ability
        private constant integer    ABILITY         = 'A003'
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

    // The the critical strike chance increament
    private function GetBonusChance takes integer level returns real
        if level == 1 then
            return 10.
        else
            return 5.
        endif
    endfunction

    // The the critical strike multiplier increament
    private function GetBonusMultiplier takes integer level returns real
        if level == 1 then
            return 1.
        else
            return 0.5
        endif
    endfunction

    // The Fire Slash damage deatl based on a base damage amount and the ability level
    public function GetDamage takes real damage, integer level returns real
        return damage*(0.2 + 0.05*level)
    endfunction

    // The Fire Slash travel distance
    private function GetDistance takes integer level returns real
        return 600. + 0.*level
    endfunction

    // The Fire Slash collision size
    private function GetCollision takes integer level returns real
        return 75. + 0.*level
    endfunction

    // Filter
    private function Filtered takes player op, unit target returns boolean
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
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
    
    private struct CriticalStrike
        static method slash takes unit source, unit target, real damage, integer level returns nothing
            local real x  = GetUnitX(target)
            local real y  = GetUnitY(target)
            local real z  = GetUnitFlyHeight(target)
            local real a  = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local real d  = GetDistance(level)
            local real tx = x + d*Cos(a)
            local real ty = y + d*Sin(a)
            local FireSlash missile = FireSlash.create(x, y, z, tx, ty, 0)

            set missile.source = source
            set missile.owner = GetOwningPlayer(source)
            set missile.damage = damage
            set missile.model = MISSILE_MODEL
            set missile.scale = MISSILE_SCALE
            set missile.speed = MISSILE_SPEED
            set missile.collision = GetCollision(level)

            call missile.launch()
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local real damage = GetCriticalDamage()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                call slash(source, target, GetDamage(damage, level), level)
            endif

            set source = null
            set target = null
        endmethod

        static method onLevelUp takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer skill = GetLearnedSkill()
        
            if skill == ABILITY then
                call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, GetBonusChance(level))
                call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, GetBonusMultiplier(level))
            endif
        
            set source = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary