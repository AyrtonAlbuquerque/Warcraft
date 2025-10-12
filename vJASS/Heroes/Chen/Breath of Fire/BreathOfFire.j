library BreathOfFire requires Spell, NewBonus, Dummy, Utilities, Missiles, Modules optional KegSmash
    /* -------------------- Breath of Fire v1.5 by Chopinski -------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     AZ                 - Breth of Fire model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Breath of Fire Ability
        public  constant integer ABILITY      = 'Chn3'
        // The Breath of Fire model
        private constant string  MODEL        = "BreathOfFire.mdl"
        // The Breath of Fire scale
        private constant real    SCALE        = 0.75
        // The Breath of Fire Missile speed
        private constant real    SPEED        = 500.
        // The Breath of Fire DoT period
        private constant real    PERIOD       = 1.
        // The Breath of Fire DoT model
        private constant string  DOT_MODEL    = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
        // The Breath of Fire DoT model attach point
        private constant string  ATTACH       = "origin"
    endglobals

    // The Breath of Fire final AoE
    private function GetFinalArea takes integer level returns real
        return 400. + 0.*level
    endfunction

    // The Breath of Fire cone width
    private function GetCone takes integer level returns real
        return 60. + 0.*level
    endfunction

    // The Breath of Fire DoT/Brew Cloud ignite duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Breath of Fire travel distance, by default the ability cast range
    private function GetDistance takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction

    // The Breath of Fire DoT damage
    private function GetDoTDamage takes unit source, integer level returns real
        return 10. * level + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Breath of Fire Brew Cloud ignite damage
    private function GetIgniteDamage takes unit source, integer level returns real
        return 25. * level + 0.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Breath of Fire Brew Cloud ignite damage interval
    private function GetIgniteInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The Breath of Fire Damage
    private function GetDamage takes unit source, integer level returns real
        return 50. + 50.*level + 0.75 * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Breath of Fire armor reduction
    private function GetArmorReduction takes integer level returns integer
        return 5 + 0*level
    endfunction

    // The Breath of Fire Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoT
        private unit source
        private unit target
        private real damage
        private effect effect
        private real duration

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set source = null
            set target = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - PERIOD

            if duration > 0 then
                if UnitAlive(target) then
                    static if LIBRARY_KegSmash then
                        if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                            call UnitDamageTarget(source, target, 2*damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        else
                            call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    else
                        call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                else
                    return false
                endif
            endif

            return duration > 0
        endmethod

        static method create takes unit source, unit target, integer level returns thistype
            local integer id = GetUnitUserData(target)
            local thistype this = GetTimerInstance(id)

            if this == 0 then
                set this = thistype.allocate()
                set this.source = source
                set this.target = target
                set this.damage = GetDoTDamage(source, level)
                set this.effect = AddSpecialEffectTarget(DOT_MODEL, target, ATTACH)

                static if LIBRARY_KegSmash then
                    if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                        call LinkBonusToBuff(target, BONUS_ARMOR, -GetArmorReduction(level), KegSmash_BUFF)
                    endif
                endif

                call StartTimer(PERIOD, true, this, id)
            endif

            set duration = GetDuration(source, level)

            return this
        endmethod

        implement Periodic
    endstruct

    private struct Wave extends Missile
        group group
        integer level
        real fov
        real face
        real centerX
        real centerY
        real distance
        real ignite_damage
        real ignite_duration
        real ignite_interval

        private method onUnit takes unit hit returns boolean
            if IsUnitInCone(hit, centerX, centerY, distance, face, fov) then
                if DamageFilter(owner, hit) then
                    if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call DoT.create(source, hit, level)
                    endif
                endif
            endif

            return false
        endmethod

        private method onPeriod takes nothing returns boolean
            static if LIBRARY_KegSmash then
                local unit u
                local real d

                call GroupEnumUnitsOfPlayer(group, owner, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if GetUnitTypeId(u) == Dummy.type and BrewCloud.active(u) then
                            set d = DistanceBetweenCoordinates(x, y, GetUnitX(u), GetUnitY(u))

                            if d <= collision + KegSmash_GetAoE(source, level)/2 and IsUnitInCone(u, centerX, centerY, 2*distance, face, 180) then
                                call BrewCloud.ignite(u, ignite_damage, ignite_duration, ignite_interval)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif

            return false
        endmethod

        private method onRemove takes nothing returns nothing
            call DestroyGroup(group)
            set group = null
        endmethod
    endstruct

    private struct BreathOfFire extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Chen|r breathes fire in a cone, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to enemy units and setting them on fire, dealing |cff00ffff" + N2S(GetDoTDamage(source, level), 0) + "|r |cff00ffffMagic|r damage every |cffffcc00" + N2S(GetIgniteInterval(level), 1) + "|r second. If the unit is under the effect of |cffffcc00Drunken Haze|r, the |cffffcc00DoT|r damage is doubled and reduces the unit armor by |cffffcc00" + N2S(GetArmorReduction(level), 0) + "|r. In addition, if the fire wave comes in contact with a |cffffcc00Brew Cloud|r it will ignite it, setting the terrain on fire, dealing |cff00ffff" + N2S(GetIgniteDamage(source, level), 0) + "|r |cff00ffffMagic|r damage per second to enemy units within range.\n\nLasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local real distance = GetDistance(Spell.source.unit, Spell.level)
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local effect e = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE)
            local Wave wave = Wave.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * Cos(angle), Spell.source.y + distance * Sin(angle), 0)

            set wave.speed = SPEED
            set wave.level = Spell.level
            set wave.distance = distance
            set wave.face = angle * bj_RADTODEG
            set wave.source = Spell.source.unit 
            set wave.owner = Spell.source.player
            set wave.centerX = Spell.source.x
            set wave.centerY = Spell.source.y
            set wave.group = CreateGroup()
            set wave.fov = GetCone(Spell.level)
            set wave.damage = GetDamage(Spell.source.unit, Spell.level)
            set wave.collision = GetFinalArea(Spell.level)
            set wave.ignite_damage = GetIgniteDamage(Spell.source.unit, Spell.level)
            set wave.ignite_duration = GetDuration(Spell.source.unit, Spell.level)
            set wave.ignite_interval = GetIgniteInterval(Spell.level)

            call BlzSetSpecialEffectYaw(e, angle)
            call DestroyEffect(e)
            call wave.launch()

            set e = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary