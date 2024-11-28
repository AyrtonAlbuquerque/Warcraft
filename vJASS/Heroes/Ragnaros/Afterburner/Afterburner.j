library Afterburner requires DamageInterface, RegisterPlayerUnitEvent, Utilities
    /* ---------------------- Afterburner v1.5 by Chopinski --------------------- */
    // Credits:
    //     PrinceYaser      - icon.
    //     Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        //The raw code of the Afternurner Ability
        private constant integer    ABILITY         = 'A003'
        //The raw code of the Afternurner Prox Ability
        private constant integer    AFTERBURN_PROXY = 'A007'
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE     = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC
    endglobals

    //function responsible to determine the duration of the Afterburn
    //By default, it uses the Cooldown value in the Object Editor
    private function GetDuration takes unit u returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_DURATION_NORMAL, GetUnitAbilityLevel(u, ABILITY) - 1)
    endfunction

    //function responsible to determine the AoE of the Afterburn
    //By default, it uses the AoE value in the Object Editor
    private function GetAoE takes unit u returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, GetUnitAbilityLevel(u, ABILITY) - 1)
    endfunction

    //The damage per interval of the Afterburn
    private function GetDamage takes unit u returns real
        return 25.*GetUnitAbilityLevel(u, ABILITY)
    endfunction

    //The damage interval of the Afterburn
    private function GetDamageInterval takes unit u returns real
        return 1.0
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Afterburner
        static integer array proxy

        timer   timer
        unit    unit
        unit    dummy
        real    damage
        integer index

        private static method onDamage takes nothing returns nothing
            local thistype this

            if proxy[Damage.source.id] != 0 and GetEventDamage() > 0 then
                set this = proxy[Damage.source.id]
                call BlzSetEventDamage(0)
                call UnitDamageTarget(unit, Damage.target.unit, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call DummyRecycle(dummy)
            call ReleaseTimer(timer)
            set unit = null
            set timer = null
            set proxy[index] = 0
            call deallocate()
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this  = thistype.allocate()
            local unit     dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            local integer  id    = GetUnitUserData(dummy)
            local ability  skill
    
            set timer     = NewTimerEx(this)
            set unit      = source
            set .dummy    = dummy
            set damage    = dmg
            set index     = id
            set proxy[id] = this

            call UnitAddAbility(dummy, AFTERBURN_PROXY)
            set skill = BlzGetUnitAbility(dummy, AFTERBURN_PROXY)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call IncUnitAbilityLevel(dummy, AFTERBURN_PROXY)
            call DecUnitAbilityLevel(dummy, AFTERBURN_PROXY)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call TimerStart(timer, duration + 0.05, false, function thistype.onExpire)
            
            set dummy = null
            set skill = null

            return this
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod
    endstruct

    function Afterburn takes real x, real y, unit source returns nothing
        if GetUnitAbilityLevel(source, ABILITY) > 0 then
            call Afterburner.create(x, y, GetDamage(source), GetDuration(source), GetAoE(source), GetDamageInterval(source), source)
        endif
    endfunction
endlibrary