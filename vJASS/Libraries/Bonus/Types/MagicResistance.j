library MagicResistance requires NewBonus, DamageInterface
    globals
        // The bonus for magic resistance
        integer BONUS_MAGIC_RESISTANCE
        // Heroes base magic resistance, which with the current formula equates to aproximately 24% magic resistance
        private constant real BASE_HERO_MAGIC_RESISTANCE = 5
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function GetUnitMagicResistance takes unit u returns real
        return MagicResistance[u]
    endfunction

    function SetUnitMagicResistance takes unit u, real value returns real
        set MagicResistance[u] = value

        return value
    endfunction

    function UnitAddMagicResistance takes unit u, real value returns real
        set MagicResistance[u] = MagicResistance[u] + value

        return MagicResistance[u]
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct MagicResistance extends Bonus
        private static constant integer ability = 'Z00B'
        private static constant abilityreallevelfield field = ABILITY_RLF_DAMAGE_REDUCTION_ISR2
    
        private static boolean array check
        private static real array resistance

        static method operator [] takes unit u returns real
            local integer id = GetUnitUserData(u)

            if IsUnitType(u, UNIT_TYPE_HERO) and not check[id] then
                set check[id] = true
                set resistance[id] = resistance[id] + BASE_HERO_MAGIC_RESISTANCE
            endif

            return resistance[id]
        endmethod

        static method operator []= takes unit u, real value returns nothing
            set resistance[GetUnitUserData(u)] = value
        endmethod

        method get takes unit u returns real
            static if USE_DAMAGE_INTERFACE then
                return GetUnitMagicResistance(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real bonus returns real
            static if USE_DAMAGE_INTERFACE then
                return SetUnitMagicResistance(u, bonus)
            else
                if GetUnitAbilityLevel(u, ability) == 0 then
                    call UnitAddAbility(u, ability)
                    call UnitMakeAbilityPermanent(u, true, ability)
                endif
                
                if BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0, bonus) then
                    call IncUnitAbilityLevel(u, ability)
                    call DecUnitAbilityLevel(u, ability)
                endif
            
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method add takes unit u, real bonus returns real
            call Set(u, get(u) + bonus)

            return bonus
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_MAGIC_RESISTANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endlibrary