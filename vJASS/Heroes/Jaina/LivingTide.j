library LivingTide requires Spell, Missiles, Utilities, MouseUtils, Modules optional NewBonus optional WaterElemental
    /* ---------------------- Living Tide v1.1 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     MyPad           - MouseUtils
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY    = 'Jna5'
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
        static if LIBRARY_NewBonus then
            return 150. * level + (0.2 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        endif
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
    private struct Tide extends Missile
        private method onUnit takes unit u returns boolean
            static if LIBRARY_WaterElemental then
                if UnitFilter(owner, u) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call flush(u)
                    endif
                elseif GetUnitTypeId(u) == WaterElemental_ELEMENTAL and GetOwningPlayer(u) == owner then
                    call SetWidgetLife(u, GetWidgetLife(u) + damage)
                    call flush(u)
                endif

            else
                if UnitFilter(owner, u) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call flush(u)
                    endif
                endif

            endif

            return false
        endmethod

        private method onFinish takes nothing returns boolean
            call pause(true)
            return false
        endmethod
    endstruct

    private struct LivingTide extends Spell
        private static thistype array struct

        private Tide tide
        private real step
        private real range
        private unit unit
        private integer id
        private integer mana
        private integer level
        private player player

        method destroy takes nothing returns nothing
            call tide.terminate()
            call deallocate()

            set tide = 0
            set unit = null
            set player = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Jaina|r conjures a |cffffcc00Living Tide|r at the target location that follows the cursor at constant speed and deals |cff00ffff" + N2S(GetDamagePerSecond(source, level), 0) + " Magic|r damage to enemy units within |cffffcc00" + N2S(GetCollision(source, level), 0) + " AoE|r and heals her |cffffcc00Water Elementals|r for the same amount. |cffffcc00Jaina|r can keep the |cffffcc00Living Tide|r alive for as long as she has mana or until being interrupted. Drains |cffffcc00" + N2S(GetBaseManaCostPerSecond(source, level), 0) + "|r mana per second. Mana drain is increased by |cffffcc00" + N2S(GetManaCostPerIncrement(source, level), 0) + "|r for every |cffffcc00" + N2S(GetManaCostRangeIncrement(source, level), 0) + "|r range between |cffffcc00Jaina|r and the |cffffcc00Living Tide|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real cost

            if struct[id] != 0 then
                set x = GetUnitX(unit)
                set y = GetUnitY(unit)
                set cost = (mana + step*(DistanceBetweenCoordinates(x, y, tide.x, tide.y)/range)) * PERIOD

                if cost > GetUnitState(unit, UNIT_STATE_MANA) then
                    call IssueImmediateOrder(unit, "stop")
                    set struct[id] = 0
                else
                    call AddUnitMana(unit, -cost)
                    call tide.deflect(GetPlayerMouseX(player), GetPlayerMouseY(player), 0)
                    call BlzSetUnitFacingEx(unit, AngleBetweenCoordinates(x, y, tide.x, tide.y)*bj_RADTODEG)

                    if tide.paused then
                        call tide.pause(false)
                    endif
                endif
            endif

            return struct[id] != 0
        endmethod

        private method onCast takes nothing returns nothing
            if struct[Spell.source.id] == 0 then
                set this = thistype.allocate()
                set id = Spell.source.id
                set unit = Spell.source.unit
                set level = Spell.level
                set player = Spell.source.player
                set mana = GetBaseManaCostPerSecond(unit, level)
                set range = GetManaCostRangeIncrement(unit, level)
                set step = GetManaCostPerIncrement(unit, level)
                set tide = Tide.create(Spell.x, Spell.y, 0, Spell.source.x, Spell.source.y, 0)
                set struct[id] = this

                set tide.model = MODEL
                set tide.scale = SCALE
                set tide.speed = SPEED
                set tide.source = unit
                set tide.owner = player
                set tide.vision = GetVisionRange(unit, level)
                set tide.damage = GetDamagePerSecond(unit, level) * Missile.period
                set tide.collision = GetCollision(unit, level)

                call tide.launch()
                call StartTimer(PERIOD, true, this, id)
            endif
        endmethod

        private method onEnd takes nothing returns nothing
            set struct[GetUnitUserData(GetTriggerUnit())] = 0
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary
