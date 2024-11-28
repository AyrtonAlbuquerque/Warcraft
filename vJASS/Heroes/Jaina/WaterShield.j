library WaterShield requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, DamageInterface, Missiles, Utilities, TimerUtils
    /* --------------------- Water Shield v1.1 by Chopinski --------------------- */
    // Credits:
    //     Darkfang        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY                = 'A002'
        // The shield model
        private constant string  MODEL                  = "WaterShield.mdl"
        // The shield attachement point
        private constant string  ATTACH                 = "origin"
        // The explosion model
        private constant string  EXPLOSION_MODEL        = "LivingTide.mdl"
        // The scale of the explosion model
        private constant real    EXPLOSION_SCALE        = 0.6
        // The water bolt model
        private constant string  BOLT_MODEL             = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
        // The water bolt scal
        private constant real    BOLT_SCALE             = 1.
        // The water bolt speed
        private constant real    BOLT_SPEED             = 1000.
    endglobals

    // The shield amount
    private function GetAmount takes unit source, integer level returns real
        return 100.*level + (0.5 + 0.5*level)*GetHeroInt(source, true)
    endfunction

    // The water bolt damage
    private function GetBoltDamage takes unit source, integer level returns real
        return 25. + 25.*level
    endfunction

    // The range at which units can be selected by water bolt
    private function GetAoE takes unit source, integer level returns real
        return 400. + 0.*level
    endfunction

    // The aoe of the explosion when there is a remaining shield amount
    private function GetExplosionAoE takes unit source, integer level returns real
        return 400. + 0.*level
    endfunction

    // The angle in degrees at which units can be selected
    private function GetAngle takes unit source, integer level returns real
        return 90. + 0.*level
    endfunction

    // The Shield duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The unit filter
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WaterBolt extends Missiles
        method onFinish takes nothing returns boolean
            if UnitAlive(target) then
                call UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif

            return true
        endmethod
    endstruct
    
    private struct WaterShield
        static thistype array defense
        static thistype array offense
        static effect array effect

        timer timer
        unit source
        unit target
        player player
        group group
        integer id
        integer level
        real amount
        real angle
        real aoe
        boolean defensive

        method destroy takes nothing returns nothing
            if defensive then
                set defense[id] = 0

                if offense[id] == 0 then
                    call DestroyEffect(effect[id])
                    set effect[id] = null
                endif
            else
                set offense[id] = 0

                if defense[id] == 0  then   
                    call DestroyEffect(effect[id])
                    set effect[id] = null
                endif
            endif

            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
            set group = null
            set source = null
            set target = null
            set player = null
        endmethod

        static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u

            if defensive and amount > 0 then
                call GroupEnumUnitsInRange(group, GetUnitX(target), GetUnitY(target), aoe, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) then
                            call UnitDamageTarget(source, u, amount, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
                call DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, GetUnitX(target), GetUnitY(target), 0, EXPLOSION_SCALE))
            endif

            call destroy()
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local thistype this

            if damage > 0 and defense[Damage.target.id] != 0 then
                set this = defense[Damage.target.id]

                if damage <= amount then
                    set amount = amount - damage
                    call BlzSetEventDamage(0)
                else
                    set damage = damage - amount
                    set amount = 0

                    call BlzSetEventDamage(damage)
                    call destroy()
                endif
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local thistype this
            local WaterBolt bolt
            local unit u

            if Damage.isEnemy and offense[Damage.target.id] != 0 then
                set this = offense[Damage.target.id]

                call GroupEnumUnitsInRange(group, Damage.target.x, Damage.target.y, aoe, null)
                call GroupRemoveUnit(group, Damage.target.unit)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitFilter(player, u) and IsUnitInCone(u, Damage.target.x, Damage.target.y, aoe, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y)*bj_RADTODEG, angle) then
                            set bolt = WaterBolt.create(Damage.target.x, Damage.target.y, 50, GetUnitX(u), GetUnitY(u), 50)
                            
                            set bolt.model = BOLT_MODEL
                            set bolt.speed = BOLT_SPEED
                            set bolt.scale = BOLT_SCALE
                            set bolt.source = source
                            set bolt.target = u
                            set bolt.damage = amount

                            call bolt.launch()
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local integer id = GetUnitUserData(GetTriggerUnit())
            local thistype this

            if defense[id] != 0 then
                set this = defense[id]
                call destroy()
            endif

            if offense[id] != 0 then
                set this = offense[id]
                call destroy()
            endif
        endmethod

        static method onCast takes nothing returns nothing
            local thistype this
            
            if effect[Spell.target.id] == null then
                set effect[Spell.target.id] = AddSpecialEffectTarget(MODEL, Spell.target.unit, ATTACH)
            endif

            if IsUnitEnemy(Spell.target.unit, Spell.source.player) then
                if offense[Spell.target.id] != 0 then
                    set this = offense[Spell.target.id]
                else
                    set this = thistype.allocate()
                    set timer = NewTimerEx(this)
                    set id = Spell.target.id
                    set target = Spell.target.unit
                    set group = CreateGroup()
                    set defensive = false
                    set offense[id] = this
                endif

                set source = Spell.source.unit
                set player = Spell.source.player
                set level = Spell.level
                set amount = GetBoltDamage(source, level)
                set angle = GetAngle(source, level)
                set aoe = GetAoE(source, level)
            else
                if defense[Spell.target.id] != 0 then
                    set this = defense[Spell.target.id]
                else
                    set this = thistype.allocate()
                    set timer = NewTimerEx(this)
                    set id = Spell.target.id
                    set target = Spell.target.unit
                    set group = CreateGroup()
                    set defensive = true
                    set amount = 0
                    set defense[id] = this
                endif

                set source = Spell.source.unit
                set player = Spell.source.player
                set level = Spell.level
                set amount = amount + GetAmount(source, level)
                set aoe = GetExplosionAoE(source, level)
            endif

            call TimerStart(timer, GetDuration(source, level), false, function thistype.onExpire)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttack)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary