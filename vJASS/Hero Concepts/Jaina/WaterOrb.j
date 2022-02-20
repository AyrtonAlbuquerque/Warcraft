library WaterOrb requires RegisterPlayerUnitEvent, Utilities, NewBonus, DamageInterface
    /* ----------------------- Water Orb v1.0 by Chopinski ---------------------- */
    // Credits:
    //     Darkfang             - Icon
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     General Frank        - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the level 1 buff
        private constant integer BUFF_1         = 'B002'
        // The raw code of the level 2 buff
        private constant integer BUFF_2         = 'B003'
        // The raw code of the level 3 buff
        private constant integer BUFF_3         = 'B004'
        // The raw code of the level 4 buff
        private constant integer BUFF_4         = 'B005'
        // The orb model
        private constant string  MODEL          = "OrbWaterX.mdl"
        // The orb model scale
        private constant real    SCALE          = 1.
        // The pickup effect model
        private constant string  EFFECT         = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        // The pickup effect model attach point
        private constant string  ATTACH         = "origin"
        // The update period
        private constant real    PERIOD         = 0.25
    endglobals

    // The orb duration
    private function GetDuratoin takes integer buffid returns real
        if buffid == BUFF_1 then
            return 20.
        elseif buffid == BUFF_2 then
            return 20.
        elseif buffid == BUFF_3 then
            return 20.
        else
            return 20.
        endif
    endfunction

    // The max mana bonus
    private function GetManaBonus takes integer buffid returns real
        if buffid == BUFF_1 then
            return 20.
        elseif buffid == BUFF_2 then
            return 30.
        elseif buffid == BUFF_3 then
            return 40.
        else
            return 50.
        endif
    endfunction

    // The chance to drop an orb
    private function GetDropChance takes unit target, integer buffid returns integer
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 100
        else
            if buffid == BUFF_1 then
                return 20
            elseif buffid == BUFF_2 then
                return 20
            elseif buffid == BUFF_3 then
                return 20
            else
                return 20
            endif
        endif
    endfunction

    // The orb pickup range
    private function GetPickupRange takes integer buffid returns real
        if buffid == BUFF_1 then
            return 100.
        elseif buffid == BUFF_2 then
            return 100.
        elseif buffid == BUFF_3 then
            return 100.
        else
            return 100.
        endif
    endfunction

    // The unit drop filter
    private function UnitDropFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    // The unit pickup filter
    private function UnitPickupFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitType(target, UNIT_TYPE_HERO) and IsUnitEnemy(target, owner)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WaterOrb
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array
        static integer array flag

        group group
        player player
        effect effect
        real duration
        real bonus
        real range
        real x
        real y

        private method remove takes integer i returns integer
            call DestroyGroup(group)
            call DestroyEffect(effect)
            
            set array[i] = array[key]
            set key = key - 1
            set group = null
            set player = null
            set effect = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this
            local unit u

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration > 0 then
                        set duration = duration - PERIOD

                        call GroupEnumUnitsInRange(group, x, y, range, null)
                        loop
                            set u = FirstOfGroup(group)
                            exitwhen u == null
                                if UnitPickupFilter(player, u) then
                                    call AddUnitBonus(u, BONUS_MANA, bonus)
                                    call DestroyEffect(AddSpecialEffectTarget(EFFECT, u, ATTACH))
                                    set i = remove(i)
                                    exitwhen true
                                endif
                            call GroupRemoveUnit(group, u)
                        endloop
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop

            set u = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 then
                set flag[Damage.target.id] = 0
                
                if damage >= GetWidgetLife(Damage.target.unit) and UnitDropFilter(Damage.target.unit) then
                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_4) then
                            set flag[Damage.target.id] = BUFF_4
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_3) then
                            set flag[Damage.target.id] = BUFF_3
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_2) then
                            set flag[Damage.target.id] = BUFF_2
                        endif
                    elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                        if GetRandomInt(0, 100) <= GetDropChance(Damage.target.unit, BUFF_1) then
                            set flag[Damage.target.id] = BUFF_1
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer id = GetUnitUserData(source)
            local thistype this
            
            if flag[id] != 0 then
                set this = thistype.allocate()
                set key = key + 1
                set array[key] = this
                set x = GetUnitX(source)
                set y = GetUnitY(source)
                set group = CreateGroup()
                set player = GetOwningPlayer(source)
                set effect = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
                set duration = GetDuratoin(flag[id])
                set range = GetPickupRange(flag[id])
                set bonus = GetManaBonus(flag[id])
                
                if key == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                endif
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary
