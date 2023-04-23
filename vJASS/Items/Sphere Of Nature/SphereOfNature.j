scope SphereOfNature
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I04N'
        static constant real period  = 1.
    endmodule

    private constant function GetReturnFactor takes nothing returns real
        return 25.
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 6.
    endfunction

    private constant function GetHeroDuration takes nothing returns real
        return 3.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 600.
    endfunction

    private constant function GetSpreadCount takes nothing returns integer
        return 2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfNature extends Item
        implement Configuration

        real spellPowerFlat = 50

        private static boolean array entangled
        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()

        private unit source
        private unit target
        private effect effect
        private integer index
        private real duration

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Thorned Armor|r: When receiving physical damage, returns 25% of the damage taken.\n\n|cff00ff00Passive|r: |cffffcc00Overgrowth|r: Every attack has |cffffcc0020%|r chance to entangle the target, dealing |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) + "|r |cff0080ffMagic|r damage per second for |cffffcc006|r seconds (|cffffcc003 for Heroes|r). If the entangled unit dies, the entanglement will spread to the |cffffcc002|r nearest targets.")    
        endmethod

        private method remove takes integer i returns integer
            call DestroyEffect(effect)

            if UnitAlive(target) then
                set entangled[index] = false
                call BlzPauseUnitEx(target, false)
            endif
            
            set array[i] = array[key]
            set key = key - 1
            set source = null
            set target = null
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

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration > 0 then
                        if UnitAlive(target) then
                            call UnitDamageTarget(source, target, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        else
                            set duration = period
                        endif
                    else
                        set i = remove(i)
                    endif

                    set duration = duration - period
                set i = i + 1
            endloop
        endmethod

        private static method overgrowth takes unit s, unit t, real dur returns nothing
            local integer id = GetUnitUserData(t)
            local thistype this

            if not entangled[id] then
                set this = thistype.allocate(item)
                set source = s
                set target = t
                set effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", t, "origin")
                set index = id
                set duration = dur
                set key = key + 1
                set array[key] = this
                set entangled[id] = true

                call BlzPauseUnitEx(t, true)

                if key == 0 then
                    call TimerStart(timer, period, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed = GetTriggerUnit()
            local integer index = GetUnitUserData(killed)
            local player owner = GetOwningPlayer(killer)
            local integer size
            local unit v
            local integer i
            local group g

            if entangled[index] then
                set entangled[index] = false
                set g = CreateGroup()

                call GroupEnumUnitsInRange(g, GetUnitX(killed), GetUnitY(killed), GetAoE(), null)
                set size = BlzGroupGetSize(g)
                set i = 0
                loop
                    exitwhen i == size
                        set v = BlzGroupUnitAt(g, i)
                        if IsUnitAlly(v, owner) or not UnitAlive(v) or IsUnitType(v, UNIT_TYPE_STRUCTURE) or IsUnitType(v, UNIT_TYPE_MAGIC_IMMUNE) or entangled[GetUnitUserData(v)] then
                            call GroupRemoveUnit(g, v)
                        endif
                    set i = i + 1
                endloop

                if BlzGroupGetSize(g) > 0 then
                    set i = 0
                    loop
                        exitwhen i >= GetSpreadCount() or BlzGroupGetSize(g) == 0 
                            set v = GetClosestUnitGroup(GetUnitX(killed), GetUnitY(killed), g)

                            call GroupRemoveUnit(g, v)
                            if IsUnitType(v, UNIT_TYPE_HERO) then
                                call overgrowth(killer, v, GetHeroDuration())
                            else
                                call overgrowth(killer, v, GetDuration())
                            endif 
                        set i = i + 1
                    endloop
                endif
            endif

            set g = null
            set v = null
            set owner = null
            set killer = null
            set killed = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, item) and not (Damage.source.unit == Damage.target.unit) then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, GetEventDamage()*GetReturnFactor(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and not Damage.target.isStructure and not entangled[Damage.target.id] and GetRandomReal(1, 100) <= GetChance() then
                if Damage.target.isHero then
                    call overgrowth(Damage.source.unit, Damage.target.unit, GetHeroDuration())
                else
                    call overgrowth(Damage.source.unit, Damage.target.unit, GetDuration())
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope