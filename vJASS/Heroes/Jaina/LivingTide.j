library LivingTide requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, MouseUtils
    /* ---------------------- Living Tide v1.0 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     MyPad           - MouseUtils
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY    = 'A004'
        // The Living Tide model
        private constant string  MODEL      = "LivingTide.mdl"
        // The Living Tide scale
        private constant real    SCALE      = 1.
        // The Living Tide speed
        private constant real    SPEED      = 550.
        // The update period
        private constant real    PERIOD     = 0.03125000
    endglobals

    // The amount of damage dealt in a second
    private function GetDamagePerSecond takes unit source, integer level returns real
        return 100. * level
    endfunction

    // The living tide collision size
    private function GetCollision takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The living tide sight range
    private function GetVisionRange takes unit source, integer level returns real
        return 1000. + 0.*level
    endfunction

    // The base mana cost per second
    private function GetBaseManaCostPerSecond takes unit source, integer level returns integer
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_ILF_MANA_COST, level - 1)
    endfunction

    // The range step to change the amount of mana consumed
    private function GetManaCostRangeIncrement takes unit source, integer level returns real
        return 100.
    endfunction

    // The mana cost amount per range increment
    private function GetManaCostPerIncrement takes unit source, integer level returns real
        return 5.
    endfunction

    // The unit filter for damage
    private function UnitFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Tide extends Missiles
        method onHit takes unit u returns boolean
            if UnitFilter(owner, u) then
                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call flush(u)
                endif
            endif

            return false
        endmethod

        method onFinish takes nothing returns boolean
            call pause(true)
            return false
        endmethod
    endstruct

    private struct LivingTide
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array
        static thistype array struct

        unit unit
        player player
        integer id
        integer level
        integer mana
        real step
        real range
        Tide tide

        method remove takes integer i returns integer
            call tide.terminate()
            
            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set player = null
            set tide = 0

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local real cost
            local real x
            local real y
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if struct[id] != 0 then
                        set x = GetUnitX(unit)
                        set y = GetUnitY(unit)
                        set cost = (mana + step*(DistanceBetweenCoordinates(x, y, tide.x, tide.y)/range)) * PERIOD

                        if cost > GetUnitState(unit, UNIT_STATE_MANA) then
                            call IssueImmediateOrder(unit, "stop")
                            set struct[id] = 0
                            set i = remove(i)
                        else
                            call AddUnitMana(unit, -cost)
                            call tide.deflect(GetPlayerMouseX(player), GetPlayerMouseY(player), 0)
                            call BlzSetUnitFacingEx(unit, AngleBetweenCoordinates(x, y, tide.x, tide.y)*bj_RADTODEG)

                            if tide.paused then
                                call tide.pause(false)
                            endif
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onEnd takes nothing returns nothing
            if GetSpellAbilityId() == ABILITY then
                set struct[GetUnitUserData(GetTriggerUnit())] = 0
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if struct[Spell.source.id] == 0 then
                set this = thistype.allocate()
                set id = Spell.source.id
                set unit = Spell.source.unit
                set player = Spell.source.player
                set level = Spell.level
                set mana = GetBaseManaCostPerSecond(unit, level)
                set range = GetManaCostRangeIncrement(unit, level)
                set step = GetManaCostPerIncrement(unit, level)
                set key = key + 1
                set array[key] = this
                set struct[id] = this
                set tide = Tide.create(Spell.x, Spell.y, 0, Spell.source.x, Spell.source.y, 0)

                set tide.model = MODEL
                set tide.scale = SCALE
                set tide.speed = SPEED
                set tide.source = unit
                set tide.owner = player
                set tide.vision = GetVisionRange(unit, level)
                set tide.damage = GetDamagePerSecond(unit, level) / (1/Missiles_PERIOD)
                set tide.collision = GetCollision(unit, level)

                call tide.launch()

                if key == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function thistype.onEnd)
        endmethod
    endstruct
endlibrary
