library ArmorPenetration requires NewBonus, DamageInterface
    globals
        // The bonus for armor penetration
        integer BONUS_ARMOR_PENETRATION
        // The bonus for flat armor penetration
        integer BONUS_ARMOR_PENETRATION_FLAT
        // Armor effectiveness. overwrites the default
        private constant real ARMOR_MULTIPLIER = 0.06
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function GetUnitArmorPenetration takes unit u, boolean flat returns real
        if flat then
            return ArmorPenetrationFlat[u]
        else
            return ArmorPenetration[u]
        endif
    endfunction

    function SetUnitArmorPenetration takes unit u, real value, boolean flat returns real
        if flat then
            set ArmorPenetrationFlat[u] = value
        else
            set ArmorPenetration[u] = value
        endif

        return value
    endfunction

    function UnitAddArmorPenetration takes unit u, real value, boolean flat returns real
        if flat then
            set ArmorPenetrationFlat[u] = ArmorPenetrationFlat[u] + value
            return ArmorPenetrationFlat[u]
        else
            set ArmorPenetration[u] = ArmorPenetration[u] + value
            return ArmorPenetration[u]
        endif
    endfunction
    
    function GetArmorReduction takes unit source, unit target returns real
        local real armor = BlzGetUnitArmor(target) - GetUnitArmorPenetration(source, true)

        if armor > 0 then
            set armor = armor * (1 - GetUnitArmorPenetration(source, false))
        endif

        return (armor * ARMOR_MULTIPLIER) / (1 + (armor * ARMOR_MULTIPLIER))
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct ArmorPenetrationFlat extends Bonus
        private static real array bonus

        static method operator [] takes unit u returns real
            return bonus[GetUnitUserData(u)]
        endmethod

        static method operator []= takes unit u, real value returns nothing
            set bonus[GetUnitUserData(u)] = value
        endmethod

        method get takes unit u returns real
            return bonus[GetUnitUserData(u)]
        endmethod

        method Set takes unit u, real value returns real
            set bonus[GetUnitUserData(u)] = value

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_ARMOR_PENETRATION_FLAT = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
    
    struct ArmorPenetration extends Bonus
        private static real array bonus

        static method operator [] takes unit u returns real
            return bonus[GetUnitUserData(u)]
        endmethod

        static method operator []= takes unit u, real value returns nothing
            set bonus[GetUnitUserData(u)] = value
        endmethod

        method get takes unit u returns real
            return bonus[GetUnitUserData(u)]
        endmethod

        method Set takes unit u, real value returns real
            set bonus[GetUnitUserData(u)] = value

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.isAttack and Damage.premitigation > 0 then
                set Damage.amount = Damage.premitigation * (1 - GetArmorReduction(Damage.source.unit, Damage.target.unit))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_ARMOR_PENETRATION = RegisterBonus(thistype.allocate())

            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary