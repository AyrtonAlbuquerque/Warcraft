library FragGranade requires Spell, Missiles, NewBonus, Periodic, Utilities, CrowdControl, optional ArsenalUpgrade,
    /* ---------------------- Bullet Time v1.4 by Chopinski --------------------- */
    // Credits:
    //     Blizzard          - Icon
    //     Magtheridon96     - RegisterPlayerUnitEvent
    //     WILL THE ALMIGHTY - Explosion model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Frag Granade ability
        public  constant integer ABILITY   = 'A001'
        // The Frag Granade model
        private constant string  MODEL     = "Abilities\\Weapons\\MakuraMissile\\MakuraMissile.mdl"
        // The Frag Granade scale
        private constant real    SCALE     = 2.
        // The Frag Granade speed
        private constant real    SPEED     = 1000.
        // The Frag Granade arc
        private constant real    ARC       = 45.
        // The Frag Granade Explosion model
        private constant string  EXPLOSION = "Explosion.mdl"
        // The Frag Granade Explosion model scale
        private constant real    EXP_SCALE = 1.
        // The Frag Granade proximity Period
        private constant real    PERIOD    = 0.25
        // The Frag Granade stun model
        private constant string  STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The Frag Granade stun model attach point
        private constant string  STUN_ATTACH = "overhead"
    endglobals

    // The Frag Granade armor reduction duraton
    private function GetArmorDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Frag Granade armor reduction
    private function GetArmor takes integer level returns integer
        return 2 + 2*level
    endfunction

    // The Frag Granade Explosion AOE
    private function GetAoE takes integer level returns real
        return 150. + 50.*level
    endfunction

    // The Frag Granade Proximity AOE
    private function GetProximityAoE takes integer level returns real
        return 100. + 0.*level
    endfunction

    // The Frag Granade damage
    private function GetDamage takes unit source, integer level returns real
        return 50. + 50.*level + (0.1 * level) * GetUnitBonus(source, BONUS_SPELL_POWER) + (0.2 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction

    // The Frag Granade lasting duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Frag Granade stun duration
    private function GetStunDuration takes integer level returns real
        return 1.5 + 0.*level
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Mine
        private real x
        private real y
        private real aoe
        private unit unit
        private real stun
        private real armor
        private group group
        private real damage
        private player player
        private effect effect
        private real duration
        private real proximity
        private real armor_duration
        

        method destroy takes nothing returns nothing
            call explode()
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call DestroyEffect(AddSpecialEffectEx(EXPLOSION, x, y, 0, EXP_SCALE))
            call deallocate()

            set unit = null
            set group = null
            set effect = null
            set player = null
        endmethod

        private method explode takes nothing returns nothing
            local unit u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(player, u) then
                        if UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call AddUnitBonusTimed(u, BONUS_ARMOR, -armor, armor_duration)
                            
                            if stun > 0 then
                                call StunUnit(u, stun, STUN_MODEL, STUN_ATTACH, false)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - PERIOD

            if duration > 0 then
                call GroupEnumUnitsInRange(group, x, y, proximity, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if DamageFilter(player, u) then
                            set u = null
                            return false
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif

            return duration > 0
        endmethod

        static method create takes unit source, player owner, integer level, real tx, real ty, real amount, real area, real reduction, real armor_time, real stun_time, real timeout returns thistype
            local thistype this = thistype.allocate()

            set x = tx
            set y = ty
            set aoe = area
            set unit = source
            set player = owner
            set damage = amount
            set stun = stun_time
            set armor = reduction
            set duration = timeout
            set armor_duration = armor_time
            set group = CreateGroup()
            set proximity = GetProximityAoE(level)
            set effect = AddSpecialEffectEx(MODEL, x, y, 20, SCALE)

            call StartTimer(PERIOD, true, this, 0)
            call BlzSetSpecialEffectTimeScale(effect, 0)

            return this
        endmethod

        implement Periodic
    endstruct

    private struct Granade extends Missiles
        real aoe
        real time
        real stun
        group group
        integer armor
        integer level

        private method onFinish takes nothing returns boolean
            local integer i = 0
            local unit u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        set i = i + 1

                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call AddUnitBonusTimed(u, BONUS_ARMOR, -armor, time)

                            if stun > 0 then
                                call StunUnit(u, stun, STUN_MODEL, STUN_ATTACH, false)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)

            if i > 0 then
                call DestroyEffect(AddSpecialEffectEx(EXPLOSION, x, y, 0, EXP_SCALE))
            else
                call Mine.create(source, owner, level, x, y, damage, aoe, armor, time, stun, GetDuration(source, level))
            endif

            set group = null

            return true
        endmethod
    endstruct

    private struct FragGranade extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r throws a |cffffcc00Frag Granade|r at the target location. Upon arrival, if there are enemy units nearby, the granade explodes dealing |cff00ffff" + N2S(GetDamage(source, level),0) + " Magic|r damage and shredding |cff808080" + I2S(GetArmor(level)) + " Armor|r for |cffffcc00" + N2S(GetArmorDuration(level), 1) + "|r seconds. If there are no enemies nearby, the granade will stay in the location and explode when an enemy unit comes nearby or its duration expires after |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."

        endmethod

        private method onCast takes nothing returns nothing
            local Granade granade = Granade.create(Spell.source.x, Spell.source.y, 75, Spell.x, Spell.y, 0)

            set granade.speed = SPEED
            set granade.model = MODEL
            set granade.scale = SCALE
            set granade.arc = ARC
            set granade.stun = 0
            set granade.source = Spell.source.unit
            set granade.owner = Spell.source.player
            set granade.level = Spell.level
            set granade.damage = GetDamage(Spell.source.unit, Spell.level)
            set granade.aoe = GetAoE(Spell.level)
            set granade.armor = GetArmor(Spell.level)
            set granade.time = GetArmorDuration(Spell.level)
            set granade.group = CreateGroup()

            static if LIBRARY_ArsenalUpgrade then
                if GetUnitAbilityLevel(Spell.source.unit, ArsenalUpgrade_ABILITY) > 0 then
                    set granade.stun = GetStunDuration(Spell.level)
                endif
            endif

            call granade.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary