library Zap requires SpellEffectEvent, PluginSpellEffect, Missiles
    /* -------------------------- Zap v1.2 by Chopinski ------------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Zap ability
        public  constant integer ABILITY      = 'A008'
        // The Zap model
        private constant string  MODEL        = "ZapMissile.mdl"
        // The Zap scale
        private constant real    SCALE        = 1.
        // The Zap Missile speed
        private constant real    SPEED        = 2000.
        // The Zap Missile heigth
        private constant real    HEIGHT       = 150.
        // The Zap Missile damage model
        private constant string  IMPACT_MODEL = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        // The Zap Missile damage model attach point
        private constant string  ATTACH       = "origin"
    endglobals

    // The Zap missile collision
    private function GetCollision takes integer level returns real
        return 150. + 0.*level
    endfunction

    // The Zap damage
    private function GetDamage takes integer level returns real
        return 150.*level
    endfunction

    // The Zap mana drain per second
    private function GetManaDrain takes integer level returns real
        return 100.*level
    endfunction

    // The Zap Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Zap extends Missiles
        real mana

        method onPeriod takes nothing returns boolean
            local boolean hasMana = mana <= GetUnitState(source, UNIT_STATE_MANA)

            if hasMana then
                call AddUnitMana(source, -mana)
            endif

            return not hasMana
        endmethod

        method onHit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
                call DestroyEffect(AddSpecialEffectTarget(IMPACT_MODEL, hit, ATTACH))
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            call SetUnitX(source, x)
            call SetUnitY(source, y)
            call BlzPauseUnitEx(source, false)
            call ShowUnit(source, true)
            call SelectUnitAddForPlayer(source, owner)
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, HEIGHT)

            set model     = MODEL
            set scale     = SCALE
            set speed     = SPEED
            set source    = Spell.source.unit
            set owner     = Spell.source.player
            set damage    = GetDamage(Spell.level)
            set collision = GetCollision(Spell.level)
            set mana      = GetManaDrain(Spell.level)*Missiles_PERIOD

            call BlzPauseUnitEx(Spell.source.unit, true)
            call ShowUnit(Spell.source.unit, false)
            call launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary