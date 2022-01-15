library FragGranade requires SpellEffectEvent, PluginSpellEffect, Missiles, NewBonusUtils, TimerUtils, Utilities, optional ArsenalUpgrade
    /* ---------------------- Bullet Time v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard          - Icon
    //     Vexorian          - TimerUtils
    //     Bribe             - SpellEffectEvent
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
    private function GetDamage takes integer level returns real
        return 50. + 50.*level
    endfunction

    // The Frag Granade lasting duraton
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
        static timer          timer = CreateTimer()
        static integer        id    = -1
        static thistype array array

        unit    unit
        group   group
        player  player
        effect  effect
        real    damage
        real    proximity
        real    duration
        real    stun
        real    armor
        real    armor_dur
        real    aoe
        real    x
        real    y

        private method remove takes integer i returns integer
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call DestroyEffect(AddSpecialEffectEx(EXPLOSION, x, y, 0, EXP_SCALE))

            set unit     = null
            set group    = null
            set effect   = null
            set player   = null
            set array[i] = array[id]
            set id       = id - 1

            if id == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private method explode takes nothing returns nothing
            local unit u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(player, u) then
                        if UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call AddUnitBonusTimed(u, BONUS_ARMOR, -armor, armor_dur)
                            if stun > 0 then
                                call StunUnit(u, stun)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local unit     u
            local thistype this

            loop
                exitwhen i > id
                    set this = array[i]

                    if duration > 0 then
                        call GroupEnumUnitsInRange(group, x, y, proximity, null)
                        loop
                            set u = FirstOfGroup(group)
                            exitwhen u == null
                                if DamageFilter(player, u) then
                                    set duration = 0
                                    call explode()
                                    exitwhen true
                                endif
                            call GroupRemoveUnit(group, u)
                        endloop

                        if duration == 0 then
                            set i = remove(i)
                        endif
                    else
                        call explode()
                        set i = remove(i)
                    endif
                    set duration = duration - PERIOD
                set i = i + 1
            endloop

            set u = null
        endmethod

        static method create takes unit source, player owner, integer level, real tx, real ty, real amount, real area, real reduction, real armor_time, real stun_time, real timeout returns thistype
            local thistype this = thistype.allocate()

            set unit      = source
            set player    = owner
            set damage    = amount
            set duration  = timeout
            set armor     = reduction
            set armor_dur = armor_time
            set aoe       = area
            set x         = tx
            set y         = ty
            set stun      = stun_time
            set proximity = GetProximityAoE(level)
            set effect    = AddSpecialEffectEx(MODEL, x, y, 20, SCALE)
            set group     = CreateGroup()
            set id        = id + 1
            set array[id] = this

            call BlzSetSpecialEffectTimeScale(effect, 0)

            if id == 0 then
                call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
            endif

            return this
        endmethod
    endstruct

    private struct FragGranade extends Missiles
        real    aoe
        integer armor
        real    armor_dur
        real    stun
        integer level
        group   group

        method onFinish takes nothing returns boolean
            local integer i = 0
            local unit    u

            call GroupEnumUnitsInRange(group, x, y, aoe, null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        set i = i + 1
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call AddUnitBonusTimed(u, BONUS_ARMOR, -armor, armor_dur)
                            if stun > 0 then
                                call StunUnit(u, stun)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call DestroyGroup(group)

            if i > 0 then
                call DestroyEffect(AddSpecialEffectEx(EXPLOSION, x, y, 0, EXP_SCALE))
            else
                call Mine.create(source, owner, level, x, y, damage, aoe, armor, armor_dur, stun, GetDuration(source, level))
            endif

            set group = null
            return true
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 75, Spell.x, Spell.y, 0)

            set source    = Spell.source.unit
            set owner     = Spell.source.player
            set level     = Spell.level
            set speed     = SPEED
            set model     = MODEL
            set scale     = SCALE
            set arc       = ARC
            set stun      = 0.
            set damage    = GetDamage(level)
            set aoe       = GetAoE(level)
            set armor     = GetArmor(level)
            set armor_dur = GetArmorDuration(level)
            set group     = CreateGroup()

            static if LIBRARY_ArsenalUpgrade then
                if GetUnitAbilityLevel(Spell.source.unit, ArsenalUpgrade_ABILITY) > 0 then
                    set stun = GetStunDuration(Spell.level)
                endif
            endif

            call launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary