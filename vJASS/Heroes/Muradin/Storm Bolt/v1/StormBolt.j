library StormBolt requires Ability, Missiles, Utilities, TimedHandles, CrowdControl, NewBonus optional Avatar
    /* --------------------------------------- Storm Bolt v1.4 -------------------------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     TriggerHappy   - TimedHandles
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
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
        // The model used when storm bolt stuns a unit
        private constant string     STUN_MODEL         = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The attachment point of the stun model
        private constant string     STUN_POINT         = "overhead"
    endglobals

    // The storm bolt damage
    public function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 150. + 50.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. + 50.*level
        endif
    endfunction

    // The storm bolt damage when the target is already stunned
    public function GetBonusDamage takes integer level returns real
        return 0.25 * level
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

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Hammer extends Missiles
        real time
        real mana
        integer level
        boolean bonus = false

        private method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                if IsUnitStunned(target) then
                    set damage = damage * (1 + GetBonusDamage(level))
                    set bonus  = true
                endif

                if UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
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
                        call StunUnit(target, time, STUN_MODEL, STUN_POINT, false)
                    endif
                endif
            endif

            return true
        endmethod
    endstruct

    struct StormBolt extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Muradin|r throw his hammer at an enemy unit, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage and stunning the target for |cffffcc003|r seconds (|cffffcc001|r on |cffffcc00Heroes|r). If the target is already stunned, |cffffcc00Storm Bolt|r will do |cffffcc00" + N2S(GetBonusDamage(level), 0) + "%|r bonus damage. In addintion, if |cffffcc00Storm Bolt|r kills the target, |cffffcc0050%|r of its mana cost is refunded."
        endmethod

        private method onCast takes nothing returns nothing
            local Hammer hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.target.x, Spell.target.y, 60)

            set hammer.source = Spell.source.unit
            set hammer.target = Spell.target.unit
            set hammer.model = MISSILE_MODEL
            set hammer.speed = MISSILE_SPEED
            set hammer.scale = MISSILE_SCALE
            set hammer.level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)
            set hammer.damage = GetDamage(Spell.source.unit, hammer.level)
            set hammer.time = GetDuration(Spell.source.unit, Spell.target.unit, hammer.level)
            set hammer.mana = GetMana(Spell.source.unit, hammer.level)

            call hammer.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterSpell(thistype.allocate(), STORM_BOLT_RECAST)
        endmethod
    endstruct
endlibrary