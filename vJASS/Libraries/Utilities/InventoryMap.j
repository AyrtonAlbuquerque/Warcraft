library InventoryMap requires RegisterPlayerUnitEvent, GetMainSelectedUnit
    /* --------------------- Inventory Map v1.0 by Chopinki --------------------- */
    // Credits
    //  -
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // Key mapped to the item 1
        private constant oskeytype ITEM_1 = OSKEY_1
        // Key mapped to the item 2
        private constant oskeytype ITEM_2 = OSKEY_2
        // Key mapped to the item 3
        private constant oskeytype ITEM_3 = OSKEY_3
        // Key mapped to the item 4
        private constant oskeytype ITEM_4 = OSKEY_4
        // Key mapped to the item 5
        private constant oskeytype ITEM_5 = OSKEY_5
        // Key mapped to the item 6
        private constant oskeytype ITEM_6 = OSKEY_6
    endglobals
    
    // Returns the inventory frame handle linked to the mapped key
    private function GetMappedKey takes oskeytype key returns framehandle
        if key == ITEM_1 then
            return BlzGetFrameByName("InventoryButton_0", 0)
        elseif key == ITEM_2 then
            return BlzGetFrameByName("InventoryButton_1", 0)
        elseif key == ITEM_3 then
            return BlzGetFrameByName("InventoryButton_2", 0)
        elseif key == ITEM_4 then
            return BlzGetFrameByName("InventoryButton_3", 0)
        elseif key == ITEM_5 then
            return BlzGetFrameByName("InventoryButton_4", 0)
        elseif key == ITEM_6 then
            return BlzGetFrameByName("InventoryButton_5", 0)
        else
            return null
        endif
    endfunction

    private function GetMappedItem takes oskeytype key, unit u returns item
        if key == OSKEY_1 then
            return UnitItemInSlot(u, 0)
        elseif key == OSKEY_2 then
            return UnitItemInSlot(u, 1)
        elseif key == OSKEY_3 then
            return UnitItemInSlot(u, 2)
        elseif key == OSKEY_4 then
            return UnitItemInSlot(u, 3)
        elseif key == OSKEY_5 then
            return UnitItemInSlot(u, 4)
        elseif key == OSKEY_6 then
            return UnitItemInSlot(u, 5)
        endif

        return null
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct InventoryMap extends array
        static trigger trigger = CreateTrigger()

        static method onKey takes nothing returns nothing
            local unit source

            if GetLocalPlayer() == GetTriggerPlayer() then
                set source = GetMainSelectedUnitEx()
                //call BlzFrameClick(GetMappedKey(BlzGetTriggerPlayerKey()))
            endif

            call UnitUseItem(source, GetMappedItem(BlzGetTriggerPlayerKey(), source))

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i > bj_MAX_PLAYERS
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_1, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_2, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_3, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_4, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_5, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), ITEM_6, 0, true)
                set i = i + 1
            endloop

            call TriggerAddCondition(trigger, Condition(function thistype.onKey))
        endmethod
    endstruct
endlibrary