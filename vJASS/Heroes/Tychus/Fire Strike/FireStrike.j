library FireStrike requires Missiles, Spell, Utilities, Modules, RegisterPlayerUnitEvent optional NewBonus
    /* --------------------- Fire Strike v1.0 by Chopinski ---------------------- */
    // Credits:
    //     Panda - icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fire Strike ability
        public  constant integer ABILITY              = 'Tyc5'
        // The raw code of the Flames ability
        private constant integer FLAMES               = 'Flam'
        // The starting height of the missile
        private constant integer START_HEIGHT         = 1500
        // The starting offset of the missile
        private constant integer START_OFFSET         = 3000
        // The Missile model
        private constant string  MODEL                = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE                = 0.8
        // The Missile speed
        private constant real    SPEED                = 1500.
        // The time the player has to move the mouse before the spell starts
        private constant real    DRAG_AND_DROP_TIME   = 3.
        // Skill indicator model
        private constant string  INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
        // Indicator scaling
        private constant real    INDICATOR_SCALE      = 7
        // Indicator time scaling
        private constant real    INDICATOR_TIME_SCALE = 1.5
    endglobals

    // The amount of damage dealt when the missile lands
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 300 * level + (0.5 + 0.25*level) * GetUnitBonus(source, BONUS_DAMAGE) + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 300. * level
        endif
    endfunction

    // The amount of damage Fire deals per second
    private function GetFireDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 150. * level + (0.15*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        endif
    endfunction

    // The max range that a missile can spawn
    // By default it is the ability Area of Effect Field value
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The amount of missiles spawned per line
    private function GetCount takes unit source, integer level returns integer
        return 5 + 0*level
    endfunction

    // The amount of missiles lines
    private function GetLineCount takes unit source, integer level returns integer
        return 7 + 0*level
    endfunction

    // The missile line spawn interval
    private function GetInterval takes unit source, integer level returns real
        return 0.2 - 0.*level
    endfunction

    // The Fire damage interval
    private function GetFireInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The fire duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The damage filter
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Incineration
        private static integer array proxy

        private unit unit
        private unit dummy
        private real damage
        private integer key

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(dummy, FLAMES)
            call DummyRecycle(dummy)
            call deallocate()

            set unit = null
            set dummy = null
            set proxy[key] = 0
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability spell

            set unit = source
            set damage = dmg
            set dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set key = GetUnitUserData(dummy)
            set proxy[key] = this

            call UnitAddAbility(dummy, FLAMES)
            set spell = BlzGetUnitAbility(dummy, FLAMES)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call BlzSetAbilityStringLevelField(spell, ABILITY_SLF_SPECIAL, 0, "")
            call IncUnitAbilityLevel(dummy, FLAMES)
            call DecUnitAbilityLevel(dummy, FLAMES)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call StartTimer(duration + 0.05, false, this, 0)

            set spell = null

            return this
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = proxy[Damage.source.id]

            if this != 0 and Damage.amount > 0 then
                set Damage.source = unit
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod 
    endstruct
    
    private struct Rocket extends Missile
        real burn
        real time
        real interval
        integer level

        private method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsInRange(g, x, y, collision, null)
            call Incineration.create(x, y, burn, time, collision, interval, source)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct FireStrike extends Spell
        private static thistype array struct

        private real x
        private real y
        private unit unit
        private integer id
        private real angle
        private real range
        private real burn
        private real time
        private integer count
        private integer index
        private integer lines
        private boolean firing
        private boolean cancelled
        private real interval
        private real lineInterval
        private boolean done
        private real timeout
        private effect effect
        private player player
        private integer level
        private boolean casting

        method destroy takes nothing returns nothing
            if casting then
                call DestroyEffectTimed(effect, 2)
            else
                call DestroyEffect(effect)
            endif

            set unit = null
            set effect = null
            set player = null
            
            if struct[id] == this then
                set struct[id] = 0
            endif

            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r calls for a |cffffcc00Fire Strike|r in the targeted direction. Each missile deals |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage to all enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r of its impact location and leaves a trail of fire that burns enemy units for |cff00ffff" + N2S(GetFireDamage(source, level), 0) + " Magic|r damage per second for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction."
        endmethod
        
        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real tx
            local real ty
            local real side
            local Rocket rocket
            local integer i = 0
            local boolean down = IsPlayerMouseButtonDown(player, MOUSE_BUTTON_TYPE_LEFT)

            if cancelled then
                return false
            endif

            if down and not firing and (casting or not done) then
                set angle = AngleBetweenCoordinates(this.x, this.y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            endif

            if not casting then
                if not UnitAlive(unit) then
                    return false
                endif

                if down and not done then
                    call BlzSetSpecialEffectYaw(effect, angle)
                elseif not down then
                    set done = true
                endif

                return true
            endif

            set timeout = timeout - 0.03
            set lineInterval = lineInterval - 0.03

            if (not down or timeout <= 0) and lineInterval <= 0 then
                set lineInterval = GetInterval(unit, level)
                set x = this.x + index * range * Cos(angle)
                set y = this.y + index * range * Sin(angle)
                set index = index + 1
                set lines = lines - 1
                set firing = true

                loop
                    exitwhen i >= count
                        set side = (i - (count - 1) / 2.) * range
                        set tx = x + side * Cos(angle + bj_PI/2)
                        set ty = y + side * Sin(angle + bj_PI/2)
                        set rocket = Rocket.create(tx - START_OFFSET*Cos(angle), ty - START_OFFSET*Sin(angle), START_HEIGHT, tx, ty, 0)
                        set rocket.source = unit
                        set rocket.level = level
                        set rocket.model = MODEL
                        set rocket.scale = SCALE
                        set rocket.speed = SPEED
                        set rocket.burn = burn
                        set rocket.time = time
                        set rocket.interval = interval
                        set rocket.arc = GetRandomReal(0, 30) * bj_DEGTORAD
                        set rocket.owner = player
                        set rocket.damage = GetDamage(unit, level)
                        set rocket.collision = GetAoE(unit, level)

                        call rocket.launch()
                    set i = i + 1
                endloop
            endif

            if not firing then
                call BlzSetSpecialEffectYaw(effect, angle)
            endif

            return lines > 0
        endmethod

        private method onCast takes nothing returns nothing
            if struct[Spell.source.id] != 0 then
                set this = struct[Spell.source.id]

                if x != Spell.x or y != Spell.y then
                    call BlzSetSpecialEffectX(effect, Spell.x)
                    call BlzSetSpecialEffectY(effect, Spell.y)
                    call BlzSetSpecialEffectYaw(effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(player), GetPlayerMouseY(player)))
                endif

                set x = Spell.x
                set y = Spell.y
                set index = 0
                set firing = false
                set casting = true
                set level = Spell.level
                set timeout = DRAG_AND_DROP_TIME
                set range = GetAoE(Spell.source.unit, Spell.level)
                set count = GetCount(Spell.source.unit, Spell.level)
                set lines = GetLineCount(Spell.source.unit, Spell.level)
                set burn = GetFireDamage(Spell.source.unit, Spell.level)
                set time = GetDuration(Spell.source.unit, Spell.level)
                set interval = GetFireInterval(Spell.level)
                set lineInterval = 0
            else
                set this = thistype.allocate()
                set x = Spell.x
                set y = Spell.y
                set index = 0
                set firing = false
                set casting = true
                set cancelled = false
                set level = Spell.level
                set id = Spell.source.id
                set unit = Spell.source.unit
                set player = Spell.source.player
                set timeout = DRAG_AND_DROP_TIME
                set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                set range = GetAoE(Spell.source.unit, Spell.level)
                set count = GetCount(Spell.source.unit, Spell.level)
                set lines = GetLineCount(Spell.source.unit, Spell.level)
                set burn = GetFireDamage(Spell.source.unit, Spell.level)
                set time = GetDuration(Spell.source.unit, Spell.level)
                set interval = GetFireInterval(Spell.level)
                set lineInterval = 0

                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)

                call StartTimer(0.03, true, this, 0)
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id = GetUnitUserData(source)
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local thistype this = struct[id]
            local real range
            local string base
            local string order
            local real distance
            local ability skill
            
            if level > 0 then
                set skill = BlzGetUnitAbility(source, ABILITY)
                set order = OrderId2String(GetIssuedOrderId())
                set base = BlzGetAbilityStringLevelField(skill, ABILITY_SLF_BASE_ORDER_ID_NCL6, level - 1)
                set range = BlzGetAbilityRealLevelField(skill, ABILITY_RLF_CAST_RANGE, level - 1)
                set distance = DistanceBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetUnitX(source), GetUnitY(source))

                if order != base and this != 0 then
                    if not casting then
                        set cancelled = true
                        set struct[id] = 0
                    endif
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if this != 0 then
                        set cancelled = true
                        set struct[id] = 0
                    endif

                    set this = thistype.allocate()
                    set done = false
                    set index = 0
                    set firing = false
                    set cancelled = false
                    set x = GetOrderPointX()
                    set y = GetOrderPointY()
                    set this.id = id
                    set casting = false
                    set this.level = level
                    set unit = source
                    set player = GetOwningPlayer(source)
                    set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                    set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                    set struct[id] = this

                    call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)
                    call BlzSetSpecialEffectYaw(effect, angle)

                    call StartTimer(0.03, true, this, 0)
                endif
            endif

            set skill = null
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary
