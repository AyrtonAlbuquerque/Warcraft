library StormBolt requires Spell, Missiles, Utilities, CrowdControl optional NewBonus
    /* --------------------------------------- Storm Bolt v1.5 -------------------------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Storm Bolt ability
        public  constant integer    ABILITY            = 'Mrd9'
        // The raw code of the Storm Bolt Double Thunder ability
        public  constant integer    STORM_BOLT_RECAST  = 'MrdB'
        // The missile model
        private constant string     MISSILE_MODEL      = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
        // The missile size
        private constant real       MISSILE_SCALE      = 1.15
        // The missile speed
        private constant real       MISSILE_SPEED      = 1250.
        // The model used when storm bolt deal bonus damage
        private constant string     BONUS_DAMAGE_MODEL = "ShockHD.mdl"
        // The attachment point of the bonus damage model
        private constant string     ATTACH_POINT       = "origin"
        // The extra eye candy model
        private constant string     EXTRA_MODEL        = "StormShock.mdl"
        // The model used when storm bolt slows a unit
        private constant string     SLOW_MODEL         = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
        // The attachment point of the slow model
        private constant string     SLOW_POINT         = "origin"
    endglobals

    // The storm bolt damage
    public function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. + 50.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50.*level
        endif
    endfunction

    // The storm bolt damage when the target is already stunned
    public function GetBonusDamage takes integer level returns real
        return 0.25 * level
    endfunction

    // The storm bolt AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The storm bolt minimum travel distance
    private function GetMinimumDistance takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The storm bolt slow amount
    private function GetSlow takes integer level returns real
        return 0.1 + 0.1*level
    endfunction

    // The storm bolt slow duration
    private function GetSlowDuration takes integer level returns real
        return 2. + 0.*level
    endfunction

    // The Damage Filter units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Hammer extends Missile
        real slow
        integer level
        boolean bonus
        real newDamage
        real slowDuration
        boolean deflected

        private method onUnit takes unit u returns boolean
            if UnitAlive(u) then
                if DamageFilter(owner, u) then
                    set newDamage = damage

                    if IsUnitStunned(u) or IsUnitSlowed(u) then
                        set newDamage = damage * (1 + GetBonusDamage(level))
                        set bonus  = true
                    endif
    
                    if UnitDamageTarget(source, u, newDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call SlowUnit(u, slow, slowDuration, SLOW_MODEL, SLOW_POINT, false)

                        if bonus then
                            call DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, u, ATTACH_POINT))
                        endif
                    endif
                endif
            endif
            
            return false
        endmethod

        private method onFinish takes nothing returns boolean
            if not deflected then
                set deflected = true
                
                call deflectTarget(source)
                call flushAll()
            else
                static if LIBRARY_ThunderClap then
                    call ResetUnitAbilityCooldown(source, ThunderClap_ABILITY)
                endif
            endif

            return false
        endmethod
    endstruct

    struct StormBolt extends Spell
        readonly static real array x
        readonly static real array y

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Muradin|r throw his hammer towards a target location. On its way the hammer deals |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and slows enemy units by |cffffcc00" + N2S(GetSlow(level) * 100, 0) + "%|r for |cffffcc00" + N2S(GetSlowDuration(level), 1) + "|r seconds. Units already under the effect of a |cffd45e19Stun|r or |cffd45e19Slow|r takes |cffffcc00" + N2S(GetBonusDamage(level) * 100, 0) + "%|r bonus damage. Upon reaching the destination the hammer comes back to |cffffcc00Muradin|r. When the hammer finally reaches |cffffcc00Muradin|r the cooldown of |cff00ff00Thunder Clap|r is reseted."
        endmethod

        private method onCast takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetMinimumDistance(level)
            local Hammer hammer

            if DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) < distance then
                set x[Spell.source.id] = Spell.source.x + distance * Cos(angle)
                set y[Spell.source.id] = Spell.source.y + distance * Sin(angle)
                set hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, x[Spell.source.id], y[Spell.source.id], 60)
            else
                set x[Spell.source.id] = Spell.x
                set y[Spell.source.id] = Spell.y
                set hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)
            endif

            set hammer.source = Spell.source.unit
            set hammer.owner = Spell.source.player
            set hammer.model = MISSILE_MODEL
            set hammer.speed = MISSILE_SPEED
            set hammer.scale = MISSILE_SCALE
            set hammer.level = level
            set hammer.bonus = false
            set hammer.deflected = false
            set hammer.damage = GetDamage(hammer.source, hammer.level)
            set hammer.collision = GetAoE(Spell.source.unit, level)
            set hammer.slow = GetSlow(level)
            set hammer.slowDuration = GetSlowDuration(level)

            call hammer.attach(EXTRA_MODEL, 0, 0, 0, MISSILE_SCALE)
            call hammer.launch()
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpell(thistype.allocate(), STORM_BOLT_RECAST)
        endmethod
    endstruct
endlibrary