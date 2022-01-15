library StormBolt requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, TimedHandles, SpellPower, optional Avatar
    /* ---------------------- Storm Bolt v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    //     TriggerHappy   - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Storm Bolt ability
        public  constant integer    ABILITY            = 'A001'
        // The raw code of the Storm Bolt Double Thunder ability
        public  constant integer    STORM_BOLT_RECAST  = 'A002'
        // The missile model
        private constant string     MISSILE_MODEL      = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
        // The missile size
        private constant real       MISSILE_SCALE      = 1.
        // The missile speed
        private constant real       MISSILE_SPEED      = 1250.
        // The model used when storm bolt deal bonus damage
        private constant string     BONUS_DAMAGE_MODEL = "ShockHD.mdl"
        // The model used when storm bolt refunds mana on kill
        private constant string     REFUND_MANA        = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        // The attachment point of the bonus dmaage model
        private constant string     ATTACH_POINT       = "origin"
        // The attack type of the damage dealt
        private constant attacktype ATTACK_TYPE        = ATTACK_TYPE_NORMAL  
        // The damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE        = DAMAGE_TYPE_MAGIC
    endglobals

    // The storm bolt damage
    public function GetDamage takes integer level returns real
        return 150. + 50.*level
    endfunction

    // The storm bolt damage when the target is already stunned
    public function GetBonusDamage takes real damage, integer level returns real
        return damage * (1. + 0.25*level)
    endfunction

    // The storm bolt stun duration
    private function GetDuration takes unit source, unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        endif
    endfunction

    // The storm bolt mana refunded
    public function GetMana takes unit source, integer level returns real
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_ILF_MANA_COST, level - 1)*0.5
    endfunction

    // Returns true if the target unit is already stunned
    private function Stunned takes unit target returns boolean
        return GetUnitAbilityLevel(target, 'BPSE') > 0
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Hammer extends Missiles
        integer level
        real    dur
        real    mana
        boolean bonus = false

        method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                if Stunned(target) then
                    set damage = GetSpellDamage(GetBonusDamage(damage, level), source)
                    set bonus  = true
                endif

                if UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                    if bonus then
                        call DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, target, ATTACH_POINT))
                    endif

                    if not UnitAlive(target) then
                        call AddUnitMana(source, mana)
                        call DestroyEffectTimed(AddSpecialEffectTarget(REFUND_MANA, source, ATTACH_POINT), 1.0)
                        static if LIBRARY_Avatar then
                            if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                                call ResetUnitAbilityCooldown(source, ABILITY)
                            endif
                        endif
                    else
                        call StunUnit(target, dur)
                    endif
                endif
            endif

            return true
        endmethod
    endstruct

    struct StormBolt extends array
        private static method onCast takes nothing returns nothing
            local Hammer hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.target.x, Spell.target.y, 60)

            set hammer.source   = Spell.source.unit
            set hammer.target   = Spell.target.unit
            set hammer.model    = MISSILE_MODEL
            set hammer.speed    = MISSILE_SPEED
            set hammer.scale    = MISSILE_SCALE
            set hammer.level    = GetUnitAbilityLevel(Spell.source.unit, ABILITY)
            set hammer.damage   = GetDamage(hammer.level)
            set hammer.dur      = GetDuration(Spell.source.unit, Spell.target.unit, hammer.level)
            set hammer.mana     = GetMana(Spell.source.unit, hammer.level)

            call hammer.launch()
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterSpellEffectEvent(STORM_BOLT_RECAST, function thistype.onCast)
        endmethod
    endstruct
endlibrary