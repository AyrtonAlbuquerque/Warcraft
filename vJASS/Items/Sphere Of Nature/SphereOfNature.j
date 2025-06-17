scope SphereOfNature
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
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
        static constant integer code = 'I04N'

        // Attributes
        real spellPower = 50

        private static boolean array entangled

        private unit source
        private unit target
        private effect effect
        private integer index
        private real duration

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)

            if UnitAlive(target) then
                set entangled[index] = false
                call BlzPauseUnitEx(target, false)
            endif
            
            set source = null
            set target = null
            set effect = null

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Thorned Armor|r: When receiving physical damage, returns 25%% of the damage taken.\n\n|cff00ff00Passive|r: |cffffcc00Overgrowth|r: Every attack has |cffffcc0020%%|r chance to entangle the target, dealing |cff0080ff" + N2S(GetDamage(), 0) + "|r |cff0080ffMagic|r damage per second for |cffffcc006|r seconds (|cffffcc003 for Heroes|r). If the entangled unit dies, the entanglement will spread to the |cffffcc002|r nearest targets."    
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1

            if duration > 0 then
                if UnitAlive(target) then
                    call UnitDamageTarget(source, target, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                else
                    return false
                endif
            endif

            return duration > 0
        endmethod

        private static method overgrowth takes unit s, unit t, real dur returns nothing
            local integer id = GetUnitUserData(t)
            local thistype this

            if not entangled[id] then
                set this = thistype.allocate(0)
                set source = s
                set target = t
                set effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", t, "origin")
                set index = id
                set duration = dur
                set entangled[id] = true

                call BlzPauseUnitEx(t, true)
                call StartTimer(1, true, this, id)
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
            if UnitHasItemOfType(Damage.target.unit, code) and not (Damage.source.unit == Damage.target.unit) then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, Damage.amount*GetReturnFactor(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and not entangled[Damage.target.id] and GetRandomReal(1, 100) <= GetChance() then
                if Damage.target.isHero then
                    call overgrowth(Damage.source.unit, Damage.target.unit, GetHeroDuration())
                else
                    call overgrowth(Damage.source.unit, Damage.target.unit, GetDuration())
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), OrbOfThorns.code, SphereOfPower.code, 0, 0, 0)
        endmethod
    endstruct
endscope