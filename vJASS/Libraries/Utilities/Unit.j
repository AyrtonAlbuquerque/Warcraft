library Unit
    struct Unit
        private static location location = Location(0, 0)

        unit unit
        
        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod

        method operator x takes nothing returns real
            return GetUnitX(unit)
        endmethod

        method operator y takes nothing returns real
            return GetUnitY(unit)
        endmethod

        method operator z takes nothing returns real
            call MoveLocation(location, GetUnitX(unit), GetUnitY(unit))
            return GetUnitFlyHeight(unit) + GetLocationZ(location)
        endmethod

        method operator id takes nothing returns integer
            return GetUnitUserData(unit)
        endmethod

        method operator type takes nothing returns integer
            return GetUnitTypeId(unit)
        endmethod

        method operator handle takes nothing returns integer
            return GetHandleId(unit)
        endmethod

        method operator player takes nothing returns player
            return GetOwningPlayer(unit)
        endmethod

        method operator armor takes nothing returns real
            return BlzGetUnitArmor(unit)
        endmethod

        method operator mana takes nothing returns real
            return GetUnitState(unit, UNIT_STATE_MANA)
        endmethod

        method operator health takes nothing returns real
            return GetWidgetLife(unit)
        endmethod

        method operator agility takes nothing returns integer
            return GetHeroAgi(unit, true)
        endmethod

        method operator strength takes nothing returns integer
            return GetHeroStr(unit, true)
        endmethod

        method operator intelligence takes nothing returns integer
            return GetHeroInt(unit, true)
        endmethod

        method operator armortype takes nothing returns armortype
            return ConvertArmorType(BlzGetUnitIntegerField(unit, UNIT_IF_ARMOR_TYPE))
        endmethod

        method operator defensetype takes nothing returns defensetype
            return ConvertDefenseType(BlzGetUnitIntegerField(unit, UNIT_IF_DEFENSE_TYPE))
        endmethod

        method operator isHero takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_HERO)
        endmethod

        method operator isMelee takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MELEE_ATTACKER)
        endmethod

        method operator isRanged takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_RANGED_ATTACKER)
        endmethod

        method operator isSummoned takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_SUMMONED)
        endmethod

        method operator isStructure takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_STRUCTURE)
        endmethod

        method operator isMagicImmune takes nothing returns boolean
            return IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
        endmethod

        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()

            set unit = u

            return this
        endmethod
    endstruct
endlibrary