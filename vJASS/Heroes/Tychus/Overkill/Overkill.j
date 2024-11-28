library Overkill requires RegisterPlayerUnitEvent, Missiles, Utilities, MouseUtils, NewBonus optional ArsenalUpgrade
    /* ----------------------- Overkill v1.3 by Chopinski ----------------------- */
    // Credits:
    //     Blizzard         - Icon
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     MyPad            - MouseUtils
    //     Gray Knight      - Bullet model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Overkill ability
        public  constant integer ABILITY = 'A004'
        // The raw code of the Overkill buff
        private constant integer BUFF    = 'B001'
        // The Bullet model
        private constant string  MODEL   = "Bullet.mdl"
        // The Bullet scale
        private constant real    SCALE   = 1.
        // The Bullet speed
        private constant real    SPEED   = 2000.
        // The firing period
        private constant real    PERIOD  = 0.03125
    endglobals

    // The X coordinate starting point for the bullets. This exists so the bullets
    // will come out of the tychus model weapon barrel.
    private function GetX takes real x, real face returns real
        return x + 120*Cos(face + 13*bj_DEGTORAD)
    endfunction

    // The Y coordinate starting point for the bullets. This exists so the bullets
    // will come out of the tychus model weapon barrel.
    private function GetY takes real y, real face returns real
        return y + 120*Sin(face + 13*bj_DEGTORAD)
    endfunction

    // The Bullet damage.
    private function GetDamage takes integer level, unit source returns real
        return (5. + 5.*level) + GetUnitBonus(source, BONUS_DAMAGE)*0.25*level
    endfunction

    // The Bullet collision.
    private function GetCollision takes integer level returns real
        return 15. + 0.*level
    endfunction

    // The Bullets max aoe spread.
    private function GetMaxAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Bullet max travel distance
    private function GetTravelDistance takes integer level returns real
        return 600. + 0.*level
    endfunction

    // The Bullet mana cost
    private function GetManaCost takes unit source, integer level returns real
        static if LIBRARY_ArsenalUpgrade then
            if GetUnitAbilityLevel(source, ArsenalUpgrade_ABILITY) > 0 then
                return 0.5 + 0.*level
            else
                return 1. + 0.*level
            endif
        else
            return 1. + 0.*level
        endif
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Bullet extends Missiles
        method onHit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                call UnitDamageTarget(source, hit, damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null)
            endif

            return false
        endmethod
    endstruct

    private struct Overkill
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array
        static thistype array n

        unit unit
        player  player
        real prevX
        real prevY
        integer id

        private method remove takes integer i returns integer
            call AddUnitAnimationProperties(unit, "spin", false)
            call QueueUnitAnimation(unit, "Stand Ready")
            call IssueImmediateOrderById(unit, 852590)
            call UnitRemoveAbility(unit, 'Abun')

            set array[i] = array[key]
            set key = key - 1
            set n[id] = 0
            set unit = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local integer level
            local real cost
            local real offset
            local real face
            local real range
            local real x
            local real y
            local boolean  morphed = false
            local thistype this
            local Bullet bullet

            loop
                exitwhen i > key
                    set this = array[i]
                    set level = GetUnitAbilityLevel(unit, ABILITY)
                    set cost = GetManaCost(unit, level)

                    static if LIBRARY_CommanderOdin then
                        set morphed = CommanderOdin.morphed[id]
                    endif

                    if GetUnitAbilityLevel(unit, BUFF) > 0 and GetUnitState(unit, UNIT_STATE_MANA) >= cost and not morphed then
                        set offset = GetTravelDistance(level)
                        set range = GetRandomRange(GetMaxAoE(level))
                        set face = GetUnitFacing(unit)*bj_DEGTORAD
                        set x = GetUnitX(unit)
                        set y = GetUnitY(unit)
                        set bullet = Bullet.create(GetX(x, face), GetY(y, face), 70, GetRandomCoordInRange(x + offset*Cos(face), range, true), GetRandomCoordInRange(y + offset*Sin(face), range, false), GetRandomReal(0, 80))
                        set bullet.model = MODEL
                        set bullet.speed = SPEED
                        set bullet.scale = SCALE
                        set bullet.source = unit
                        set bullet.owner = player
                        set bullet.damage = GetDamage(level, unit)
                        set bullet.collision = GetCollision(level)

                        if x != prevX and y != prevY then
                            set prevX = x
                            set prevY = y
                            call AddUnitAnimationProperties(unit, "spin", true)
                        else
                            call AddUnitAnimationProperties(unit, "spin", false)
                            call SetUnitAnimation(unit, "Attack")
                        endif

                        call AddUnitMana(unit, -cost)
                        call BlzSetUnitFacingEx(unit, AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))*bj_RADTODEG)
                        call bullet.launch()
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onOrder takes nothing returns nothing
            local integer order = GetIssuedOrderId()
            local unit caster = GetOrderedUnit()
            local integer i = GetUnitUserData(caster)
            local thistype this

            if order == 852589 then // On
                if n[i] != 0 then
                    set this = n[i]
                else
                    set this = thistype.allocate()
                    set unit = caster
                    set id = i
                    set prevX = GetUnitX(caster)
                    set prevY = GetUnitY(caster)
                    set player = GetOwningPlayer(caster)
                    set key = key + 1
                    set array[key] = this
                    set n[i] = this

                    if key == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif

                call UnitAddAbility(unit, 'Abun')
            endif

            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary