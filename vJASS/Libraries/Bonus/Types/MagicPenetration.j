library MagicPenetration requires NewBonus, DamageInterface, MagicResistance
    globals
        // The bonus for magic penetration
        integer BONUS_MAGIC_PENETRATION
        // The bonus for flat magic penetration
        integer BONUS_MAGIC_PENETRATION_FLAT
        // Magic resistance effectiveness. overwrites the default when USE_PENETRATION is true
        private constant real MAGIC_MULTIPLIER = 0.06
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function GetUnitMagicPenetration takes unit u, boolean flat returns real
        if flat then
            return MagicPenetrationFlat[u]
        else
            return MagicPenetration[u]
        endif
    endfunction

    function SetUnitMagicPenetration takes unit u, real value, boolean flat returns real
        if flat then
            set MagicPenetrationFlat[u] = value
        else
            set MagicPenetration[u] = value
        endif

        return value
    endfunction

    function UnitAddMagicPenetration takes unit u, real value, boolean flat returns real
        if flat then
            set MagicPenetrationFlat[u] = MagicPenetrationFlat[u] + value
            return MagicPenetrationFlat[u]
        else
            set MagicPenetration[u] = MagicPenetration[u] + value
            return MagicPenetration[u]
        endif
    endfunction

    function GetMagicReduction takes unit source, unit target returns real
        local real magic = GetUnitMagicResistance(target) - GetUnitMagicPenetration(source, true)

        if magic > 0 then
            set magic = magic * (1 - GetUnitMagicPenetration(source, false))
        endif

        return (magic * MAGIC_MULTIPLIER) / (1 + (magic * MAGIC_MULTIPLIER))
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct MagicPenetrationFlat extends Bonus
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
            set BONUS_MAGIC_PENETRATION_FLAT = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    struct MagicPenetration extends Bonus
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
            if Damage.isSpell and Damage.premitigation > 0 then
                set Damage.amount = Damage.premitigation * (1 - GetMagicReduction(Damage.source.unit, Damage.target.unit))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_MAGIC_PENETRATION = RegisterBonus(thistype.allocate())

            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary