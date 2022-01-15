library InfernalCharge requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities
    /* ---------------------- Infernal Charge v1.4 by Chopinski --------------------- */
    // Credits:
    //     marilynmonroe - Pit Infernal model
    //     Bribe         - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Infernal Charge ability
        private constant integer    ABILITY          = 'A003'
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
    private function GetChargeDamage takes integer level returns real
        return 200. + 0.*level
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
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Charge extends Missiles
        real distance
        real knockback

        method onPeriod takes nothing returns boolean
            call SetUnitX(source, x)
            call SetUnitY(source, y)

            return false
        endmethod

        method onHit takes unit hit returns boolean
            if ChargeFilter(owner, hit) then
                call UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                call KnockbackUnit(hit, AngleBetweenCoordinates(x, y, GetUnitX(hit), GetUnitY(hit)), distance, knockback, KNOCKBACK_MODEL, KNOCKBACK_ATTACH, true, true, false, true)
            endif

            return false
        endmethod

        method onFinish takes nothing returns boolean
            call BlzPauseUnitEx(source, false)
            call SetUnitTimeScale(source, 1)
            call SetUnitAnimation(source, "Stand")

            return true
        endmethod
    endstruct

    private struct PitInfernal
        static method onCast takes nothing returns nothing
            local Charge charge = Charge.create(Spell.source.x, Spell.source.y, 0, Spell.x, Spell.y, 0)

            set charge.damage    = GetChargeDamage(Spell.level)
            set charge.source    = Spell.source.unit
            set charge.owner     = GetOwningPlayer(Spell.source.unit)
            set charge.collision = GetChargeAoE(Spell.level)
            set charge.model     = KNOCKBACK_MODEL
            set charge.distance  = GetKnockbackDistance(Spell.level)
            set charge.knockback = GetKnockbackDuration(Spell.level)
            set charge.duration  = CHARGE_TIME

            call BlzPauseUnitEx(Spell.source.unit, true)
            call SetUnitTimeScale(Spell.source.unit, TIME_SCALE)
            call SetUnitAnimationByIndex(Spell.source.unit, ANIMATION_INDEX)
            call charge.launch()
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary