library DrunkenStyle requires SpellEffectEvent, PluginSpellEffect, Utilities, Missiles, TimerUtils, MouseUtils, NewBonus
    /* --------------------- Drunken Style v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     Vexorian           - MouseUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Drunken Style Ability
        private constant integer ABILITY = 'A005'
        // The Drunken Style knockback model
        private constant string  MODEL   = "WindBlow.mdl"
        // The Drunken Style knockback attach point
        private constant string  ATTACH  = "origin"
    endglobals

    // The Drunken Style dash duration
    private function GetDuration takes integer level returns real
        return 0.25
    endfunction

    // The Drunken Style dash distance
    private function GetDistance takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Drunken Style dash type reset time
    private function GetResetTime takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Drunken Style knockback distance
    private function GetKnockbackDistance takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Drunken Style knockback duration
    private function GetKnockbackDuration takes integer level returns real
        return 0.25 + 0.*level
    endfunction

    // The Drunken Style collison per dash type
    private function GetCollision takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The Drunken Style dash cone at which damage can be applyed in degrees
    private function GetDamageCone takes integer dashType returns real
        if dashType == 1 then
            return 180.
        elseif dashType == 2 then
            return 360.
        elseif dashType == 3 then
            return 30.
        else
            return 180.
        endif
    endfunction

    // The Drunken Style dash damage
    private function GetDamage takes integer level, unit source returns real
        return 25.*level + GetUnitBonus(source, BONUS_DAMAGE)*(0.25 + 0.25*level)
    endfunction

    // The Drunken Style Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Dash extends Missiles
        real    fov
        real    face
        real    distance
        real    knockback
        real    centerX
        real    centerY

        method onPeriod takes nothing returns boolean
            if UnitAlive(source) then
                call SetUnitX(source, x)
                call SetUnitY(source, y)
                call BlzSetUnitFacingEx(source, face)

                return false
            else
                return true
            endif
        endmethod

        method onHit takes unit hit returns boolean
            if IsUnitInCone(hit, centerX, centerY, collision, face, fov) then
                if DamageFilter(owner, hit) then
                    if UnitDamageTarget(source, hit, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH) then
                        call KnockbackUnit(hit, AngleBetweenCoordinates(x, y, GetUnitX(hit), GetUnitY(hit)), distance, knockback, MODEL, ATTACH, true, true, false, true)
                    endif
                endif
            endif

            return false
        endmethod

        method onRemove takes nothing returns nothing
            call BlzUnitInterruptAttack(source)
            call SetUnitTimeScale(source, 1)
            call IssueImmediateOrder(source, "stop")
            call QueueUnitAnimation(source, "Stand Ready")
        endmethod
    endstruct
    
    private struct DrunkenStyle
        static thistype array n
        static integer  array type

        timer   timer
        integer i

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call ReleaseTimer(timer)
            call deallocate()

            set n[i]    = 0
            set type[i] = 0
            set timer   = null
        endmethod

        private static method getAngle takes player owner, unit caster, real x, real y, real mx, real my, real aoe returns real
            local group   g = CreateGroup() 
            local integer j = 0
            local real    a = 0.
            local unit    u
            local integer size

            call GroupEnumUnitsInRange(g, mx, my, aoe, null)
            set size = BlzGroupGetSize(g)
            if size > 0 then
                loop
                    exitwhen j == size
                        set u = BlzGroupUnitAt(g, j)
                        if IsUnitEnemy(u, owner) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            set j = size
                            set a = AngleBetweenCoordinates(x, y, mx, my)
                        else
                            set j = j + 1
                        endif
                endloop

                if a == 0. then
                    set a = GetUnitFacing(caster)*bj_DEGTORAD
                endif
            else
                set a = GetUnitFacing(caster)*bj_DEGTORAD
            endif
            call DestroyGroup(g)

            set g = null
            set u = null
            return a
        endmethod

        private static method onCast takes nothing returns nothing
            local real d = GetDistance(Spell.level)
            local real a = getAngle(Spell.source.player, Spell.source.unit, Spell.source.x, Spell.source.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player), 100)
            local Dash dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)
            local thistype this
            
            if n[Spell.source.id] != 0 then
                set this = n[Spell.source.id]
            else
                set this  = thistype.allocate()
                set timer = NewTimerEx(this)
                set i     = Spell.source.id
                set n[i]  = this
            endif

            set type[i] = type[i] + 1

            if type[i] > 3 then
                set type[i] = 0
                call SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif type[i] == 1 then
                call StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                call SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif type[i] == 2 then
                call StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                call SetUnitAnimationByIndex(Spell.source.unit, 23)
            else
                call SetUnitAnimationByIndex(Spell.source.unit, 17)
            endif

            set dash.model     = MODEL
            set dash.source    = Spell.source.unit
            set dash.owner     = Spell.source.player
            set dash.centerX   = Spell.source.x
            set dash.centerY   = Spell.source.y
            set dash.type      = type[i]
            set dash.face      = a*bj_RADTODEG
            set dash.damage    = GetDamage(Spell.level, Spell.source.unit)
            set dash.duration  = GetDuration(Spell.level)
            set dash.collision = GetCollision(type[i])
            set dash.fov       = GetDamageCone(type[i])
            set dash.distance  = GetKnockbackDistance(Spell.level)
            set dash.knockback = GetKnockbackDuration(Spell.level)

            call dash.launch()
            call BlzUnitInterruptAttack(Spell.source.unit)
            call SetUnitTimeScale(Spell.source.unit, 1.75)
            call TimerStart(timer, GetResetTime(Spell.level), false, function thistype.onExpire)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary