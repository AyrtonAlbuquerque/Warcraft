library InfernalCharge requires Spell, Missiles, Utilities, CrowdControl, optional NewBonus
    /* ------------------------------------ Infernal Charge v1.6 ------------------------------------ */
    // Credits:
    //     marilynmonroe - Pit Infernal model
    //     Bribe         - SpellEffectEvent
    /* ---------------------------------------- By Chopinksi ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Infernal Charge ability
        private constant integer    ABILITY          = 'Mnr8'
        // The time scale of the pit infernal when charging
        private constant integer    TIME_SCALE       = 2
        // The index of the animation played when charging
        private constant integer    ANIMATION_INDEX  = 16
        // How long the Pit Infernal charges
        private constant real       CHARGE_TIME      = 1.0
        // The blast model
        private constant string     KNOCKBACK_MODEL  = "WindBlow.mdx"
        // The blast model
        private constant string     KNOCKBACK_ATTACH = "origin"
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE      = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt 
        private constant damagetype DAMAGE_TYPE      = DAMAGE_TYPE_MAGIC
    endglobals

    // The damage dealt by the Pit Infernal when charging
    private function GetChargeDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 200. + 0.*level + 1. * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 200. + 0.*level
        endif
    endfunction

    // The Area of Effect at which units will be knocked back
    private function GetChargeAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The distance units are knocked back by the charging pit infernal
    private function GetKnockbackDistance takes integer level returns real
        return 300. + 0.*level
    endfunction

    // How long units are knocked back
    private function GetKnockbackDuration takes integer level returns real
        return 0.5 + 0.*level
    endfunction

    // The Area of Effect at which units will be knocked back
    private function ChargeFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Charge extends Missile
        real distance
        real knockback

        private method onUnit takes unit hit returns boolean
            if ChargeFilter(owner, hit) then
                if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                    call KnockbackUnit(hit, AngleBetweenCoordinates(x, y, GetUnitX(hit), GetUnitY(hit)), distance, knockback, KNOCKBACK_MODEL, KNOCKBACK_ATTACH, true, true, false, false)
                endif
            endif

            return false
        endmethod

        private method onFinish takes nothing returns boolean
            call BlzPauseUnitEx(source, false)
            call SetUnitTimeScale(source, 1)
            call SetUnitAnimation(source, "Stand")

            return true
        endmethod
    endstruct

    private struct InfernalCharge extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Pit Infernal|r charges in the pointed direction, knocking back and damaging enemy units, dealing |cff00ffff" + N2S(GetChargeDamage(source, level), 0) + "|r |cff00ffffMagic|r damage."
        endmethod

        private method onCast takes nothing returns nothing
            local Charge charge = Charge.create(Spell.source.x, Spell.source.y, 0, Spell.x, Spell.y, 0)

            set charge.unit = Spell.source.unit
            set charge.source = Spell.source.unit
            set charge.duration = CHARGE_TIME
            set charge.model = KNOCKBACK_MODEL
            set charge.damage = GetChargeDamage(Spell.source.unit, Spell.level)
            set charge.owner = GetOwningPlayer(Spell.source.unit)
            set charge.collision = GetChargeAoE(Spell.level)
            set charge.distance = GetKnockbackDistance(Spell.level)
            set charge.knockback = GetKnockbackDuration(Spell.level)

            call BlzPauseUnitEx(Spell.source.unit, true)
            call SetUnitTimeScale(Spell.source.unit, TIME_SCALE)
            call SetUnitAnimationByIndex(Spell.source.unit, ANIMATION_INDEX)
            call charge.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary