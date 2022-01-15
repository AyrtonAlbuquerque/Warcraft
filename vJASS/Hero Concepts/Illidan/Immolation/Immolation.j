library Immolation requires RegisterPlayerUnitEvent, NewBonusUtils, TimerUtils
    /* ---------------------- Immolation v1.1 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Vexorian        - TimerUtils
    //     Mythic          - Immolation Effect (Edited by me)
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Immolation ability
        private constant integer ABILITY      = 'A002'
        // The raw code of the Immolation buff
        private constant integer BUFF         = 'B002'
        // The immolation damage period
        private constant real    PERIOD       = 1.
        // The immolation Damage model
        private constant string  MODEL        = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
        // The immolation Damage model
        private constant string  ATTACH_POINT = "head"
    endglobals

    // The immolation AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Immolation damage
    private function GetDamage takes integer level returns real
        return 20.*level
    endfunction

    // The Immolation armor debuff duration
    private function GetDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Immolation
        static thistype array n

        timer   timer
        unit    unit
        group   group
        player  player
        integer i

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer  level
            local unit     u

            if GetUnitAbilityLevel(unit, BUFF) > 0 then
                set level = GetUnitAbilityLevel(unit, ABILITY)
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if DamageFilter(player, u) then
                            if UnitDamageTarget(unit, u, GetDamage(level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                                call DestroyEffect(AddSpecialEffectTarget(MODEL, u, ATTACH_POINT))
                                call AddUnitBonusTimed(u, BONUS_ARMOR, -1, GetDuration(level))
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            else
                call ReleaseTimer(timer)
                call DestroyGroup(group)
                call deallocate()

                set n[i]   = 0
                set timer  = null
                set unit   = null
                set player = null
                set group  = null
            endif

            set u = null
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit     source = GetOrderedUnit()
            local integer  index  = GetUnitUserData(source)
            local thistype this

            if n[index] == 0 and GetIssuedOrderId() == 852177 then
                set this   = thistype.allocate()
                set i      = index
                set timer  = NewTimerEx(this)
                set group  = CreateGroup()
                set player = GetOwningPlayer(source)
                set unit   = source
                set n[i]   = this

                call LinkEffectToBuff(source, BUFF, "Ember Green.mdl", "chest")
                call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
            endif
        
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary