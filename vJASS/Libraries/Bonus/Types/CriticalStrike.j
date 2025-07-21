library CriticalStrike requires ArcingFloatingText, NewBonus, optional DamageInterface
    globals
        // The critical chance bonus
        integer BONUS_CRITICAL_CHANCE
        // The critical damage bonus
        integer BONUS_CRITICAL_DAMAGE
        // The text size
        private constant real TEXT_SIZE = 0.02
        // When true the damage interface library is used
        private constant boolean USE_DAMAGE_INTERFACE = true
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterCriticalStrikeEvent takes code c returns nothing
        call Critical.register(c)
    endfunction

    function GetCriticalSource takes nothing returns unit
        return Critical.source.unit
    endfunction

    function GetCriticalTarget takes nothing returns unit
        return Critical.target.unit
    endfunction

    function GetCriticalDamage takes nothing returns real
        return Critical.damage
    endfunction

    function GetUnitCriticalChance takes unit u returns real
        return Critical.getChance(u)
    endfunction

    function GetUnitCriticalMultiplier takes unit u returns real
        return Critical.getMultiplier(u)
    endfunction

    function SetUnitCriticalChance takes unit u, real value returns real
        return Critical.setChance(u, value)
    endfunction

    function SetUnitCriticalMultiplier takes unit u, real value returns real
        return Critical.setMultiplier(u, value)
    endfunction

    function SetCriticalEventDamage takes real newValue returns nothing
        set Critical.damage = newValue
    endfunction

    function UnitAddCriticalStrike takes unit u, real chance, real multiplier returns nothing
        call Critical.add(u, chance, multiplier)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct CriticalChance extends Bonus
        private static constant integer ability = 'Z00C'
        private static constant abilityreallevelfield field = ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE
    
        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return GetUnitCriticalChance(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return SetUnitCriticalChance(u, value)
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
    
        private static method onInit takes nothing returns nothing
            set BONUS_CRITICAL_CHANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    private struct CriticalDamage extends Bonus
        private static constant integer ability = 'Z00C'
        private static constant abilityreallevelfield field = ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2
    
        method get takes unit u returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return GetUnitCriticalMultiplier(u)
            else
                return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ability), field, 0)
            endif
        endmethod

        method Set takes unit u, real value returns real
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                return SetUnitCriticalMultiplier(u, value)
            else
                if value == 0 then
                    set value = 1
                endif

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
    
        private static method onInit takes nothing returns nothing
            set BONUS_CRITICAL_DAMAGE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    struct Critical
        readonly static Unit source
        readonly static Unit target
        readonly static real array chance
        readonly static real array multiplier
        readonly static trigger trigger = CreateTrigger()

        static real damage

        static method getChance takes unit u returns real
            return chance[GetUnitUserData(u)]
        endmethod

        static method getMultiplier takes unit u returns real
            return multiplier[GetUnitUserData(u)]
        endmethod

        static method setChance takes unit u, real value returns real
            set chance[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setMultiplier takes unit u, real value returns real
            set multiplier[GetUnitUserData(u)] = value

            return value
        endmethod

        static method add takes unit u, real chance, real multuplier returns nothing
            call setChance(u, getChance(u) + chance)
            call setMultiplier(u, getMultiplier(u) + multuplier)
        endmethod

        static method register takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        private static method onDamage takes nothing returns nothing
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                if Damage.amount > 0 and GetRandomReal(0, 1) <= chance[Damage.source.id] and Damage.isEnemy and not Damage.target.isStructure and multiplier[Damage.source.id] > 0 then                
                    set source = Damage.source
                    set target = Damage.target
                    set damage = Damage.amount * (1 + multiplier[Damage.source.id])
                    set Damage.amount = damage

                    call TriggerEvaluate(trigger)

                    if damage > 0 then
                        call ArcingTextTag.create("|cffff0000" + (I2S(R2I(damage)) + "!") + "|r", target.unit, TEXT_SIZE)
                    endif

                    set damage = 0
                    set source = 0
                    set target = 0
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            static if LIBRARY_DamageInterface and USE_DAMAGE_INTERFACE then
                call RegisterAttackDamagingEvent(function thistype.onDamage)
            endif
        endmethod
    endstruct
endlibrary