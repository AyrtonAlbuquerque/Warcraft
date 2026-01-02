library LightBurst requires Spell, NewBonus, Utilities, CrowdControl optional LightInfusion
    /* -------------------------------------- Light Burst v1.5 -------------------------------------- */
    // Credits:
    //     Redeemer59         - Icon
    //     AZ                 - Stomp and Misisle effect
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The Light Burst Ability
        private constant integer ABILITY      = 'Trl3'
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
    private function GetDamage takes unit source, integer level returns real
        return (100 + 100. * level) + ((0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.4 * level * GetHeroStr(source, true))
    endfunction

    // The Light Burst Damage Filter for enemy units
    private function DamageFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Burst extends Missile
        real aoe
        real time
        real slow
        real bonus
        boolean infused = false

        private method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local unit u

            call DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
            call GroupEnumUnitsInRange(g, x, y, aoe, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) then
                        if IsUnitEnemy(u, owner) then
                            if DamageFilter(u) then
                                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                    call SlowUnit(u, slow, time, null, null, false)

                                    if infused then
                                        call DisarmUnit(u, time, DISARM, ATTACH, false)
                                    endif
                                endif
                            endif
                        else
                            if infused then
                                call AddUnitBonusTimed(u, BONUS_MOVEMENT_SPEED, bonus, time)
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

    private struct LightBurst extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Turalyon|r thrusts his light sword releasing a |cffffcc00Light Burst|r towards the targeted direction. Upon arrival it explodes, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage and slowing all enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r by |cffffcc00" + N2S(GetSlow(level) * 100, 0) + "%|r.\n\n|cffffcc00Light Infused|r: |cffffcc00Light Burst|r increases the |cffffff00Movement Speed|r of any allied unit within its explosion range by |cffffcc00" + I2S(GetBonus(level)) + "|r and |cffff0000Disarms|r enemy units for |cffffcc00" + N2S(GetDuration(level), 1) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local Burst burst = Burst.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, 0)

            set burst.model = MODEL
            set burst.scale = SCALE
            set burst.speed = SPEED
            set burst.source = Spell.source.unit 
            set burst.owner = Spell.source.player
            set burst.slow = GetSlow(Spell.level)
            set burst.time = GetDuration(Spell.level)
            set burst.aoe = GetAoE(Spell.source.unit, Spell.level)
            set burst.damage = GetDamage(Spell.source.unit, Spell.level)

            static if LIBRARY_LightInfusion then
                if LightInfusion.charges[Spell.source.id] > 0 then
                    set burst.infused = true
                    set burst.bonus = GetBonus(Spell.level)

                    call LightInfusion.consume(Spell.source.id)
                endif
            endif

            call burst.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary