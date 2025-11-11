library Misha requires Table, RegisterPlayerUnitEvent, Spell, NewBonus, Modules, Utilities
    /* ------------------------- Misha v1.2 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard - Icon
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY   = 'Rex0'
        // The raw code of the Misha unit
        public  constant integer MISHA     = 'rex0'
    endglobals
    
    // The Misha Max Health
    private function GetMishaHealth takes unit source, integer level returns real
        return 1500 + 500 * level + (0.125 * level) * BlzGetUnitMaxHP(source)
    endfunction
    
    // The Misha Damage
    private function GetMishaDamage takes unit source, integer level returns real
        return 25 + 25 * level + 0.5 * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction
    
    // The Misha Armor
    private function GetMishaArmor takes unit source, integer level returns real
        return 1. + 1. * level + (0.1 * level) * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Misha extends Spell
        private static HashTable table
        private static boolean creating = false
        readonly static group array group
        readonly static integer array owner
        
        private unit unit
        private integer id
        private integer level
        private player player
        
        method destroy takes nothing returns nothing
            set unit = null
            set player = null

            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Rexxar|r summons his companion |cffffcc00Misha|r to aid him in the battlefield. |cffffcc00Misha|r has |cffff0000" + N2S(GetMishaHealth(source, level), 0) + "|r |cffff0000Health|r, |cffff0000" + N2S(GetMishaDamage(source, level), 0) + "|r |cffff0000Damage|r and |cff808080" + N2S(GetMishaArmor(source, level), 0) + "|r |cff808080Armor|r."
        endmethod

        private method onExpire takes nothing returns nothing
            local unit u
            local integer i = 0
            local group g = CreateGroup()
            
            if group[id] == null then
                set group[id] = CreateGroup()
            endif
            
            call GroupClear(group[id])
            call GroupEnumUnitsOfPlayer(g, player, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if UnitAlive(u) and GetUnitTypeId(u) == MISHA then
                        set creating = true
                        set owner[GetUnitUserData(u)] = id

                        call GroupAddUnit(group[id], u)
                        call BlzSetUnitMaxHP(u, R2I(GetMishaHealth(unit, level)))
                        call SetUnitLifePercentBJ(u, 100)
                        call BlzSetUnitBaseDamage(u, R2I(GetMishaDamage(unit, level)), 0)
                        call BlzSetUnitArmor(u, GetMishaArmor(unit, level))

                        loop
                            exitwhen i == 6
                                if table[GetPlayerId(player)].has(i) then
                                    call UnitAddItemToSlotById(u, table[GetPlayerId(player)][i], i)
                                endif
                            set i = i + 1
                        endloop

                        set creating = false
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null
        endmethod
        
        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set id = Spell.source.id
            set unit = Spell.source.unit
            set level = Spell.level
            set player = Spell.source.player
            
            call StartTimer(0, false, this, -1)
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer i = GetUnitUserData(source)
            local integer id = owner[i]
            local integer j = 0
            
            if id != 0 then
                set owner[i] = 0

                call GroupRemoveUnit(group[id], source)

                loop
                    exitwhen j == 6
                        call RemoveItem(UnitItemInSlot(source, j))
                    set j = j + 1
                endloop
            endif
            
            set source = null
        endmethod
    
        private static method onPickup takes nothing returns nothing
            local integer i = 0
            local unit u = GetManipulatingUnit()
            local integer id = GetPlayerId(GetOwningPlayer(u))

            if GetUnitTypeId(u) == MISHA and not creating then
                loop
                    exitwhen i == 6
                        set table[id][i] = GetItemTypeId(UnitItemInSlot(u, i))
                    set i = i + 1
                endloop
            endif

            set u = null
        endmethod

        private static method onDrop takes nothing returns nothing
            local integer i = 0
            local boolean removed = false
            local unit u = GetManipulatingUnit()
            local integer id = GetPlayerId(GetOwningPlayer(u))

            if GetUnitTypeId(u) == MISHA and UnitAlive(u) and not creating then
                loop
                    exitwhen i == 6
                        if not removed and GetItemTypeId(UnitItemInSlot(u, i)) == GetItemTypeId(GetManipulatedItem()) then
                            set removed = true
                            call table[id].remove(i)
                        else
                            set table[id][i] = GetItemTypeId(UnitItemInSlot(u, i))
                        endif
                    set i = i + 1
                endloop
            endif

            set u = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct
endlibrary