library Zap requires Spell, Missiles, Utilities optional NewBonus
    /* -------------------------- Zap v1.3 by Chopinski ------------------------- */
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
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 150. * level + 1 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        endif
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
    private struct Lightning extends Missiles
        real mana

        private method onPeriod takes nothing returns boolean
            local boolean hasMana = mana <= GetUnitState(source, UNIT_STATE_MANA)

            if hasMana then
                call AddUnitMana(source, -mana)
            endif

            return not hasMana
        endmethod

        private method onHit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
                call DestroyEffect(AddSpecialEffectTarget(IMPACT_MODEL, hit, ATTACH))
            endif

            return false
        endmethod

        private method onRemove takes nothing returns nothing
            call SetUnitX(source, x)
            call SetUnitY(source, y)
            call BlzPauseUnitEx(source, false)
            call ShowUnit(source, true)
            call SelectUnitAddForPlayer(source, owner)
        endmethod
    endstruct

    private struct Zap extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string 
            return "|cffffcc00Storm|r transforms into a lightning, flying towards the targeted direction and dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to enemy unit in his path. |cffffcc00Zap|r drains |cff00ffff" + N2S(GetManaDrain(level), 0) + " Mana|r per second."
        endmethod

        private method onCast takes nothing returns nothing
            local Lightning zap = Lightning.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, HEIGHT)

            set zap.model = MODEL
            set zap.scale = SCALE
            set zap.speed = SPEED
            set zap.source = Spell.source.unit
            set zap.owner = Spell.source.player
            set zap.damage = GetDamage(Spell.source.unit, Spell.level)
            set zap.collision = GetCollision(Spell.level)
            set zap.mana = GetManaDrain(Spell.level)*Missiles_PERIOD

            call BlzPauseUnitEx(Spell.source.unit, true)
            call ShowUnit(Spell.source.unit, false)
            call zap.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary