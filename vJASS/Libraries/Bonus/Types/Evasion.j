library Evasion requires ArcingFloatingText, NewBonus, optional DamageInterface
    globals
        // The bonus for miss chance
        integer BONUS_MISS_CHANCE
        // The bonus for pierce chance
        integer BONUS_PIERCE_CHANCE
        // The bonus for evasion chance
        integer BONUS_EVASION_CHANCE
        // The text size
        private constant real TEXT_SIZE = 0.016
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterEvasionEvent takes code c returns nothing
        call Evasion.registers(c)
    endfunction

    function GetMissingUnit takes nothing returns unit
        return Evasion.source.unit
    endfunction

    function GetEvadingUnit takes nothing returns unit
        return Evasion.target.unit
    endfunction

    function GetEvadedDamage takes nothing returns real
        return Evasion.damage
    endfunction

    function GetUnitEvasionChance takes unit u returns real
        return Evasion.getEvasion(u)
    endfunction

    function GetUnitMissChance takes unit u returns real
        return Evasion.getMiss(u)
    endfunction

    function GetUnitPierceChance takes unit u returns real
        return Evasion.getPierce(u)
    endfunction

    function SetUnitEvasionChance takes unit u, real chance returns real
        return Evasion.setEvasion(u, chance)
    endfunction

    function SetUnitMissChance takes unit u, real chance returns real
        return Evasion.setMiss(u, chance)
    endfunction

    function SetUnitPierceChance takes unit u, real chance returns real
        return Evasion.setPierce(u, chance)
    endfunction

    function UnitAddEvasionChance takes unit u, real chance returns real
        return Evasion.setEvasion(u, Evasion.getEvasion(u) + chance)
    endfunction

    function UnitAddMissChance takes unit u, real chance returns real
        return Evasion.setMiss(u, Evasion.getMiss(u) + chance)
    endfunction

    function UnitAddPierceChance takes unit u, real chance returns real
        return Evasion.setPierce(u, Evasion.getPierce(u) + chance)
    endfunction
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Miss extends Bonus
        method get takes unit u returns real
            return GetUnitMissChance(u)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitMissChance(u, value)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_MISS_CHANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    private struct Pierce extends Bonus
        method get takes unit u returns real
            return GetUnitPierceChance(u)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitPierceChance(u, value)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_PIERCE_CHANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
    
    struct Evasion extends Bonus
        private static constant integer ability = 'Z00D'
        private static constant abilityreallevelfield field = ABILITY_RLF_CHANCE_TO_EVADE_EEV1

        readonly static Unit source
        readonly static Unit target
        readonly static real damage
        readonly static real array miss
        readonly static real array evasion
        readonly static real array pierce
        readonly static trigger trigger = CreateTrigger()
    
        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return GetUnitEvasionChance(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return SetUnitEvasionChance(u, value)
            else
                if GetUnitAbilityLevel(u, ability) == 0 then
                    call UnitAddAbility(u, ability)
                    call UnitMakeAbilityPermanent(u, true, ability)
                endif
                
                if BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0, value) then
                    call IncUnitAbilityLevel(u, ability)
                    call DecUnitAbilityLevel(u, ability)
                endif
            
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        static method getEvasion takes unit u returns real
            return evasion[GetUnitUserData(u)]
        endmethod

        static method getPierce takes unit u returns real
            return pierce[GetUnitUserData(u)]
        endmethod

        static method getMiss takes unit u returns real
            return miss[GetUnitUserData(u)]
        endmethod

        static method setEvasion takes unit u, real value returns real
            set evasion[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setMiss takes unit u, real value returns real
            set miss[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setPierce takes unit u, real value returns real
            set pierce[GetUnitUserData(u)] = value

            return value
        endmethod

        static method registers takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        private static method onDamage takes nothing returns nothing
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                if Damage.isAttack and Damage.amount > 0 then
                    if (GetRandomReal(0, 1) <= evasion[Damage.target.id] or GetRandomReal(0, 1) <= miss[Damage.source.id]) and GetRandomReal(0, 1) > pierce[Damage.source.id] then
                        set source = Damage.source
                        set target = Damage.target
                        set damage = Damage.amount
                        set Damage.amount = 0
                        set Damage.process = false
                        set Damage.weapontype = WEAPON_TYPE_WHOKNOWS

                        call TriggerEvaluate(trigger)
                        call ArcingTextTag.create("|cffff0000miss|r", source.unit, TEXT_SIZE)

                        set damage = 0
                        set source = 0
                        set target = 0
                    endif
                endif
            endif
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_EVASION_CHANCE = RegisterBonus(thistype.allocate())

            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                call RegisterDamageConfigurationEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endlibrary