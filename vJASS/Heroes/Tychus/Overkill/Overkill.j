library Overkill requires Spell, RegisterPlayerUnitEvent, Missiles, Utilities, MouseUtils, NewBonus, Modules optional ArsenalUpgrade
    /* ----------------------- Overkill v1.5 by Chopinski ----------------------- */
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
        public  constant integer ABILITY = 'Tyc3'
        // The raw code of the Overkill buff
        private constant integer BUFF    = 'BTy0'
        // The Bullet model
        private constant string  MODEL   = "Bullet.mdl"
        // The Bullet scale
        private constant real    SCALE   = 1.
        // The Bullet speed
        private constant real    SPEED   = 2000.
        // The firing period
        private constant real    PERIOD  = 0.03125
        // The key to move without following cursor
        private constant oskeytype KEY   = OSKEY_TAB
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
        return (5. + 5.*level) + (0.1 * level) * GetUnitBonus(source, BONUS_DAMAGE)
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
        return 700. + 0.*level
    endfunction

    // The Bullet mana cost
    private function GetManaCost takes unit source, integer level returns real
        static if LIBRARY_ArsenalUpgrade then
            if GetUnitAbilityLevel(source, ArsenalUpgrade_ABILITY) > 0 then
                return 0.5 * level
            else
                return 1. * level
            endif
        else
            return 1. * level
        endif
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Bullet extends Missile
        private method onUnit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                call UnitDamageTarget(source, hit, damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null)
            endif

            return false
        endmethod
    endstruct

    private struct Overkill extends Spell
        private static boolean array holding
        private static boolean array registered
        private static trigger trigger = CreateTrigger()

        private unit unit
        private integer id
        private real prevX
        private real prevY
        private real window
        private real facing
        private player player

        method destroy takes nothing returns nothing
            call AddUnitAnimationProperties(unit, "spin", false)
            call QueueUnitAnimation(unit, "Stand Ready")
            call IssueImmediateOrderById(unit, 852590)
            call SetUnitPropWindowBJ(unit, window)
            call UnitRemoveAbility(unit, 'Abun')
            call deallocate()

            set unit = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r fire his mini-gun at full power, unleashing a barrage of bullets towards his facing direction. Each bullet consumes |cff00ffff" + N2S(GetManaCost(source, level), 0) + " Mana|r and deals |cffff0000" + N2S(GetDamage(level, source), 0) + " Physical|r damage to any enemy unit in its trajectory. |cffffcc00Tychus|r will only stop firing if he has no mana left or deactivates |cffffcc00Overkill|r. In addition |cffffcc00Tychus|r can move while on |cffffcc00Overkill|r and will always be facing the |cffffcc00Cursor|r during its active period. Hold the |cffffcc00TAB|r key to move wihtout changing direction."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real face
            local real range
            local real offset
            local Bullet bullet
            local boolean morphed = false
            local integer level = GetUnitAbilityLevel(unit, ABILITY)
            local real cost = GetManaCost(unit, level)

            static if LIBRARY_CommanderOdin then
                set morphed = CommanderOdin.morphed[id]
            endif

            if GetUnitAbilityLevel(unit, BUFF) > 0 and GetUnitState(unit, UNIT_STATE_MANA) >= cost and not morphed then
                set x = GetUnitX(unit)
                set y = GetUnitY(unit)
                set offset = GetTravelDistance(level)
                set range = GetRandomRange(GetMaxAoE(level))
                set face = GetUnitFacing(unit)*bj_DEGTORAD
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

                if not holding[GetPlayerId(player)] then
                    set facing = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))*bj_RADTODEG
                endif

                call BlzSetUnitFacingEx(unit, facing)
                call AddUnitMana(unit, -cost)
                call bullet.launch()

                return true
            endif

            return false
        endmethod

        private method onCast takes nothing returns nothing
            if not HasStartedTimer(Spell.source.id) then
                set this = thistype.allocate()
                set unit = Spell.source.unit
                set id = Spell.source.id
                set prevX = Spell.source.x
                set prevY = Spell.source.y
                set window = GetUnitPropWindow(unit) * bj_RADTODEG
                set facing = GetUnitFacing(unit) * bj_DEGTORAD
                set player = Spell.source.player

                if not registered[GetPlayerId(player)] then
                    set registered[GetPlayerId(player)] = true
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, player, KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, player, KEY, 0, false)
                endif

                call UnitAddAbility(unit, 'Abun')
                call SetUnitPropWindowBJ(unit, 360)
                call StartTimer(PERIOD, true, this, id)
            endif
        endmethod

        private static method onKey takes nothing returns nothing
            if BlzGetTriggerPlayerIsKeyDown() then
                set holding[GetPlayerId(GetTriggerPlayer())] = true
            else
                set holding[GetPlayerId(GetTriggerPlayer())] = false
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call TriggerAddCondition(trigger, Condition(function thistype.onKey))
        endmethod
    endstruct
endlibrary