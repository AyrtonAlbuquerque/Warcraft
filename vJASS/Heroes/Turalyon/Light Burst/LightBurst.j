library LightBurst requires SpellEffectEvent, PluginSpellEffect, NewBonusUtils, Utilities, CrowdControl optional LightInfusion
    /* -------------------------------------- Light Burst v1.3 -------------------------------------- */
    // Credits:
    //     Redeemer59         - Icon
    //     Bribe              - SpellEffectEvent
    //     AZ                 - Stomp and Misisle effect
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The Light Burst Ability
        private constant integer ABILITY      = 'A004'
        // The Light Burst Missile Model
        private constant string  MODEL        = "Light Burst.mdl"
        // The Light Burst Missile Model scale
        private constant real    SCALE        = 1.5
        // The Light Burst Missile Speed
        private constant real    SPEED        = 2000.
        // The Light Burst Missile Height offset
        private constant real    HEIGHT       = 100.
        // The Light Burst Stomp Model
        private constant string  STOMP        = "LightStomp.mdl"
        // The Light Burst Stomp scale
        private constant real    STOMP_SCALE  = 0.55
        // The Light Burst disarm Model
        private constant string  DISARM       = "Disarm.mdl"
        // The Light Burst disarm attach point
        private constant string  ATTACH       = "overhead"
    endglobals

    // The Light Burst AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Light Burst Buff/Debuff duration
    private function GetDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Light Burst Slow amount
    private function GetSlow takes integer level returns real
        return 0.1 + 0.1*level
    endfunction

    // The Light Burst Movement Speed bonus
    private function GetBonus takes integer level returns integer
        return 20 + 20*level
    endfunction

    // The Light Burst Damage
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction

    // The Light Burst Damage Filter for enemy units
    private function DamageFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Missile extends Missiles
        real    aoe
        real    dur
        real    slow
        real    bonus
        boolean infused = false

        method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local unit  u

            call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
            call GroupEnumUnitsInRange(g, x, y, aoe, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) then
                        if IsUnitEnemy(u, owner) then
                            if DamageFilter(u) then
                                call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                call SlowUnit(u, slow, dur, null, null, false)

                                if infused then
                                    call DisarmUnit(u, dur, DISARM, ATTACH, false)
                                endif
                            endif
                        else
                            if infused then
                                call AddUnitBonusTimed(u, BONUS_MOVEMENT_SPEED, bonus, dur)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop
            call DestroyGroup(g)

            set g = null
            return true
        endmethod
    endstruct

    private struct LightBurst extends array
        private static method onCast takes nothing returns nothing
            local Missile missile = Missile.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, 0)

            set missile.model  = MODEL
            set missile.scale  = SCALE
            set missile.speed  = SPEED
            set missile.source = Spell.source.unit 
            set missile.owner  = Spell.source.player
            set missile.damage = GetDamage(Spell.level)
            set missile.aoe    = GetAoE(Spell.source.unit, Spell.level)
            set missile.dur    = GetDuration(Spell.level)
            set missile.slow   = GetSlow(Spell.level)

            static if LIBRARY_LightInfusion then
                if LightInfusion.charges[Spell.source.id] > 0 then
                    set missile.infused = true
                    set missile.bonus   = GetBonus(Spell.level)
                    call LightInfusion.consume(Spell.source.id)
                endif
            endif

            call missile.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary