scope BootsOfMastery
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonus takes nothing returns integer
        return 10
    endfunction

    private constant function GetBonusPerLevel takes nothing returns integer
        return 2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfMastery extends Item
        static constant integer code = 'I00T'
        static constant integer ability = 'A004'
        private static integer array attribute

        real movementSpeed = 65

        private method onDrop takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if attribute[id] == 0 then
                call AddUnitBonus(u, BONUS_AGILITY, -GetBonus())
            elseif attribute[id] == 1 then
                call AddUnitBonus(u, BONUS_STRENGTH, -GetBonus())
            else
                call AddUnitBonus(u, BONUS_INTELLIGENCE, -GetBonus())
            endif

            call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNBootsOfAgility.dds")
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if UnitCountItemOfType(u, code) > 1 then
                if attribute[id] == 0 then
                    call AddUnitBonus(u, BONUS_AGILITY, GetBonus())
                    call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNBootsOfAgility.dds")
                elseif attribute[id] == 1 then
                    call AddUnitBonus(u, BONUS_STRENGTH, GetBonus())
                    call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNBootsOfStrength.dds")
                else
                    call AddUnitBonus(u, BONUS_INTELLIGENCE, GetBonus())
                    call BlzSetItemIconPath(i, "ReplaceableTextures\\CommandButtons\\BTNBootsOfIntelligence.dds")
                endif
            else
                set attribute[id] = 0
                call AddUnitBonus(u, BONUS_AGILITY, GetBonus())
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusPerLevel(), GetBonusPerLevel(), GetBonusPerLevel())
            endif
            
            set source = null
        endmethod

        private static method onCast takes nothing returns nothing
            local integer count = UnitCountItemOfType(Spell.source.unit, code)
            local integer bonus = GetBonus()
            local integer i = 0
            local string icon

            if count > 0 then
                if attribute[Spell.source.id] == 0 then
                    set attribute[Spell.source.id] = 1
                    set icon = "ReplaceableTextures\\CommandButtons\\BTNBootsOfStrength.dds"

                    call AddUnitBonus(Spell.source.unit, BONUS_AGILITY, -bonus * count)
                    call AddUnitBonus(Spell.source.unit, BONUS_STRENGTH, bonus * count)
                elseif attribute[Spell.source.id] == 1 then
                    set attribute[Spell.source.id] = 2
                    set icon = "ReplaceableTextures\\CommandButtons\\BTNBootsOfIntelligence.dds"

                    call AddUnitBonus(Spell.source.unit, BONUS_STRENGTH, -bonus * count)
                    call AddUnitBonus(Spell.source.unit, BONUS_INTELLIGENCE, bonus * count)
                else
                    set attribute[Spell.source.id] = 0
                    set icon = "ReplaceableTextures\\CommandButtons\\BTNBootsOfAgility.dds"

                    call AddUnitBonus(Spell.source.unit, BONUS_INTELLIGENCE, -bonus * count)
                    call AddUnitBonus(Spell.source.unit, BONUS_AGILITY, bonus * count)
                endif

                loop
                    exitwhen i == UnitInventorySize(Spell.source.unit)
                        if GetItemTypeId(UnitItemInSlot(Spell.source.unit, i)) == code then
                            call BlzSetItemIconPath(UnitItemInSlot(Spell.source.unit, i), icon)
                        endif
                    set i = i + 1
                endloop
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, ClawsOfAgility.code, GauntletOfStrength.code, BraceletOfIntelligence.code, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope