library CrowdControl requires Utilities, Missiles, Indexer, TimerUtils, RegisterPlayerUnitEvent, optional Tenacity
    /* ------------------------------------- Crowd Control v1.0 ------------------------------------- */
    // How to Import:
    // 1 - Copy the Utilities library over to your map and follow its install instructions
    // 2 - Copy the Missiles libraries over to your map and follow their install instructions
    // 3 - Copy the Indexer library over to your map and follow its install instructions
    // 4 - Copy the TimerUtils library over to your map and follow its install instructions
    // 5 - Copy the RegisterPlayerUnitEvent library over to your map and follow its install instructions
    // 6 - Copy the Tenacity library over to your map and follow its install instructions
    // 7 - Copy this library into your map
    // 8 - Copy the 11 abilities with the CC prefix and match their raw code below.
    /* ---------------------------------------- By Chopinski ---------------------------------------- */

    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the silence ability
        private constant integer SILENCE            = 'U000'
        // The raw code of the stun ability
        private constant integer STUN               = 'U001'
        // The raw code of the attack slow ability
        private constant integer ATTACK_SLOW        = 'U002'
        // The raw code of the movement slow ability
        private constant integer MOVEMENT_SLOW      = 'U003'
        // The raw code of the banish ability
        private constant integer BANISH             = 'U004'
        // The raw code of the ensnare ability
        private constant integer ENSNARE            = 'U005'
        // The raw code of the purge ability
        private constant integer PURGE              = 'U006'
        // The raw code of the hex ability
        private constant integer HEX                = 'U007'
        // The raw code of the sleep ability
        private constant integer SLEEP              = 'U008'
        // The raw code of the cyclone ability
        private constant integer CYCLONE            = 'U009'
        // The raw code of the entangle ability
        private constant integer ENTANGLE           = 'U010'
        // The raw code of the silence buff
        private constant integer SILENCE_BUFF       = 'BNsi'
        // The raw code of the stun buff
        private constant integer STUN_BUFF          = 'BPSE'
        // The raw code of the movement slow buff
        private constant integer MOVEMENT_SLOW_BUFF = 'Bslo'
        // The raw code of the attack slow buff
        private constant integer ATTACK_SLOW_BUFF   = 'Bcri'
        // The raw code of the banish buff
        private constant integer BANISH_BUFF        = 'BHbn'
        // The raw code of the ensnare buff
        private constant integer ENSNARE_BUFF       = 'Bens'
        // The raw code of the purge buff
        private constant integer PURGE_BUFF         = 'Bprg'
        // The raw code of the hex buff
        private constant integer HEX_BUFF           = 'BOhx'
        // The raw code of the sleep buff
        private constant integer SLEEP_BUFF         = 'BUsl'
        // The raw code of the cyclone buff
        private constant integer CYCLONE_BUFF       = 'Bcyc'
        // The raw code of the entangle buff
        private constant integer ENTANGLE_BUFF      = 'BEer'
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    /* ------------------------------------------- Disarm ------------------------------------------- */
    function DisarmUnit takes unit whichUnit, boolean flag returns nothing
        call Disarm.apply(whichUnit, flag)
    endfunction
    
    function DisarmUnitTimed takes unit whichUnit, real duration, string model, string point returns nothing
        call Disarm.timed(whichUnit, duration, model, point)
    endfunction

    function IsUnitDisarmed takes unit whichUnit returns boolean
        return Disarm.isUnitDisarmed(whichUnit)
    endfunction

    /* -------------------------------------------- Fear -------------------------------------------- */
    function FearUnit takes unit whichUnit, real duration, string model, string point returns nothing
        call Fear.apply(whichUnit, duration, model, point)
    endfunction

    function IsUnitFeared takes unit whichUnit returns boolean
        return Fear.isUnitFeared(whichUnit)
    endfunction 

    /* ------------------------------------------ Knockback ----------------------------------------- */
    function KnockbackUnit takes unit whichUnit, real angle, real distance, real duration, string model, string point, boolean onCliff, boolean onDestructable, boolean onUnit, boolean stunned returns nothing
        call Knockback.apply(whichUnit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, stunned)
    endfunction
    
    function IsUnitKnockedBack takes unit whichUnit returns boolean
        return Knockback.isUnitKnocked(whichUnit)
    endfunction

    /* ------------------------------------------- Knockup ------------------------------------------ */
    function KnockupUnit takes unit whichUnit, real airTime, real maxHeight, string model, string point returns nothing
        call Knockup.apply(whichUnit, airTime, maxHeight, model, point)
    endfunction

    function IsUnitKnockedUp takes unit whichUnit returns boolean
        return Knockup.isUnitKnocked(whichUnit)
    endfunction

    /* ------------------------------------------- Silence ------------------------------------------ */
    function SilenceUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, SILENCE)
            set a = BlzGetUnitAbility(dummy, SILENCE)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, SILENCE)
            call DecUnitAbilityLevel(dummy, SILENCE)
            call IssueTargetOrder(dummy, "drunkenhaze", whichUnit)
            call UnitRemoveAbility(dummy, SILENCE)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function SilenceGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
    
            call UnitAddAbility(dummy, SILENCE)
            set a = BlzGetUnitAbility(dummy, SILENCE)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)

                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, SILENCE)
                        call DecUnitAbilityLevel(dummy, SILENCE)
                        call IssueTargetOrder(dummy, "drunkenhaze", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, SILENCE)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function SilenceArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call SilenceGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitSilenced takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, SILENCE_BUFF) > 0
    endfunction

    /* -------------------------------------------- Stun -------------------------------------------- */
    function StunUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, STUN)
            set a = BlzGetUnitAbility(dummy, STUN)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, STUN)
            call DecUnitAbilityLevel(dummy, STUN)
            call IssueTargetOrder(dummy, "thunderbolt", whichUnit)
            call UnitRemoveAbility(dummy, STUN)
        endif

        call DummyRecycle(dummy)
        
        set dummy = null
        set a = null
    endfunction

    function StunGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
    
            call UnitAddAbility(dummy, STUN)
            set a = BlzGetUnitAbility(dummy, STUN)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, STUN)
                        call DecUnitAbilityLevel(dummy, STUN)
                        call IssueTargetOrder(dummy, "thunderbolt", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, STUN)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function StunArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call StunGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitStunned takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, STUN_BUFF) > 0
    endfunction

    /* ---------------------------------------- Movement Slow --------------------------------------- */
    function SlowUnit takes unit whichUnit, real amount, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, MOVEMENT_SLOW)
            set a = BlzGetUnitAbility(dummy, MOVEMENT_SLOW)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1, 0, amount)
            call IncUnitAbilityLevel(dummy, MOVEMENT_SLOW)
            call DecUnitAbilityLevel(dummy, MOVEMENT_SLOW)
            call IssueTargetOrder(dummy, "cripple", whichUnit)
            call UnitRemoveAbility(dummy, MOVEMENT_SLOW)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function SlowGroup takes group whichGroup, real amount, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
    
            call UnitAddAbility(dummy, MOVEMENT_SLOW)
            set a = BlzGetUnitAbility(dummy, MOVEMENT_SLOW)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_MOVEMENT_SPEED_FACTOR_SLO1, 0, amount)
                        call IncUnitAbilityLevel(dummy, MOVEMENT_SLOW)
                        call DecUnitAbilityLevel(dummy, MOVEMENT_SLOW)
                        call IssueTargetOrder(dummy, "cripple", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, MOVEMENT_SLOW)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function SlowArea takes real x, real y, real aoe, real amount, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call SlowGroup(g, amount, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitSlowed takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, MOVEMENT_SLOW_BUFF) > 0
    endfunction

    /* ----------------------------------------- Attack Slow ---------------------------------------- */
    function SlowUnitAttack takes unit whichUnit, real amount, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, ATTACK_SLOW)
            set a = BlzGetUnitAbility(dummy, ATTACK_SLOW)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_ATTACK_SPEED_REDUCTION_PERCENT_CRI2, 0, amount)
            call IncUnitAbilityLevel(dummy, ATTACK_SLOW)
            call DecUnitAbilityLevel(dummy, ATTACK_SLOW)
            call IssueTargetOrder(dummy, "cripple", whichUnit)
            call UnitRemoveAbility(dummy, ATTACK_SLOW)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function SlowGroupAttack takes group whichGroup, real amount, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
            
            call UnitAddAbility(dummy, ATTACK_SLOW)
            set a = BlzGetUnitAbility(dummy, ATTACK_SLOW)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_ATTACK_SPEED_REDUCTION_PERCENT_CRI2, 0, amount)
                        call IncUnitAbilityLevel(dummy, ATTACK_SLOW)
                        call DecUnitAbilityLevel(dummy, ATTACK_SLOW)
                        call IssueTargetOrder(dummy, "cripple", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, ATTACK_SLOW)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function SlowAreaAttack takes real x, real y, real aoe, real amount, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call SlowGroupAttack(g, amount, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitAttackSlowed takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, ATTACK_SLOW_BUFF) > 0
    endfunction

    /* ------------------------------------------- Banish ------------------------------------------- */
    function BanishUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, BANISH)
            set a = BlzGetUnitAbility(dummy, BANISH)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, BANISH)
            call DecUnitAbilityLevel(dummy, BANISH)
            call IssueTargetOrder(dummy, "banish", whichUnit)
            call UnitRemoveAbility(dummy, BANISH)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function BanishGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)

            call UnitAddAbility(dummy, BANISH)
            set a = BlzGetUnitAbility(dummy, BANISH)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, BANISH)
                        call DecUnitAbilityLevel(dummy, BANISH)
                        call IssueTargetOrder(dummy, "banish", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, BANISH)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function BanishArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call BanishGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitBanished takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, BANISH_BUFF) > 0
    endfunction

    /* ------------------------------------------- Ensnare ------------------------------------------ */
    function EnsnareUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, ENSNARE)
            set a = BlzGetUnitAbility(dummy, ENSNARE)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, ENSNARE)
            call DecUnitAbilityLevel(dummy, ENSNARE)
            call IssueTargetOrder(dummy, "ensnare", whichUnit)
            call UnitRemoveAbility(dummy, ENSNARE)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function EnsnareGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)

            call UnitAddAbility(dummy, ENSNARE)
            set a = BlzGetUnitAbility(dummy, ENSNARE)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, ENSNARE)
                        call DecUnitAbilityLevel(dummy, ENSNARE)
                        call IssueTargetOrder(dummy, "ensnare", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, ENSNARE)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function EnsnareArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call EnsnareGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitEnsnared takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, ENSNARE_BUFF) > 0
    endfunction

    /* -------------------------------------------- Purge ------------------------------------------- */
    function PurgeUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, PURGE)
            set a = BlzGetUnitAbility(dummy, PURGE)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, PURGE)
            call DecUnitAbilityLevel(dummy, PURGE)
            call IssueTargetOrder(dummy, "purge", whichUnit)
            call UnitRemoveAbility(dummy, PURGE)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function PurgeGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)

            call UnitAddAbility(dummy, PURGE)
            set a = BlzGetUnitAbility(dummy, PURGE)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, PURGE)
                        call DecUnitAbilityLevel(dummy, PURGE)
                        call IssueTargetOrder(dummy, "purge", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, PURGE)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function PurgeArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call PurgeGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitPurged takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, PURGE_BUFF) > 0
    endfunction

    /* --------------------------------------------- Hex -------------------------------------------- */
    function HexUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, HEX)
            set a = BlzGetUnitAbility(dummy, HEX)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, HEX)
            call DecUnitAbilityLevel(dummy, HEX)
            call IssueTargetOrder(dummy, "hex", whichUnit)
            call UnitRemoveAbility(dummy, HEX)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function HexGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
            
            call UnitAddAbility(dummy, HEX)
            set a = BlzGetUnitAbility(dummy, HEX)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, HEX)
                        call DecUnitAbilityLevel(dummy, HEX)
                        call IssueTargetOrder(dummy, "hex", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, HEX)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function HexArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call HexGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitHexed takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, HEX_BUFF) > 0
    endfunction

    /* -------------------------------------------- Sleep ------------------------------------------- */
    function SleepUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, SLEEP)
            set a = BlzGetUnitAbility(dummy, SLEEP)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, SLEEP)
            call DecUnitAbilityLevel(dummy, SLEEP)
            call IssueTargetOrder(dummy, "sleep", whichUnit)
            call UnitRemoveAbility(dummy, SLEEP)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function SleepGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
            
            call UnitAddAbility(dummy, SLEEP)
            set a = BlzGetUnitAbility(dummy, SLEEP)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, SLEEP)
                        call DecUnitAbilityLevel(dummy, SLEEP)
                        call IssueTargetOrder(dummy, "sleep", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, SLEEP)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function SleepArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call SleepGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitSleeping takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, SLEEP_BUFF) > 0
    endfunction

    /* ------------------------------------------- Cyclone ------------------------------------------ */
    function CycloneUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, CYCLONE)
            set a = BlzGetUnitAbility(dummy, CYCLONE)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, CYCLONE)
            call DecUnitAbilityLevel(dummy, CYCLONE)
            call IssueTargetOrder(dummy, "cyclone", whichUnit)
            call UnitRemoveAbility(dummy, CYCLONE)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function CycloneGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
            
            call UnitAddAbility(dummy, CYCLONE)
            set a = BlzGetUnitAbility(dummy, CYCLONE)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, CYCLONE)
                        call DecUnitAbilityLevel(dummy, CYCLONE)
                        call IssueTargetOrder(dummy, "cyclone", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, CYCLONE)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function CycloneArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call CycloneGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitCycloned takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, CYCLONE_BUFF) > 0
    endfunction

    /* ------------------------------------------ Entangle ------------------------------------------ */
    function EntangleUnit takes unit whichUnit, real duration returns nothing
        local unit dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFlyHeight(whichUnit), 0)
        local ability a

        static if LIBRARY_Tenacity then
            set duration = GetTenacityDuration(whichUnit, duration)
        endif

        if duration > 0 then
            call UnitAddAbility(dummy, ENTANGLE)
            set a = BlzGetUnitAbility(dummy, ENTANGLE)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, duration)
            call IncUnitAbilityLevel(dummy, ENTANGLE)
            call DecUnitAbilityLevel(dummy, ENTANGLE)
            call IssueTargetOrder(dummy, "entanglingroots", whichUnit)
            call UnitRemoveAbility(dummy, ENTANGLE)
        endif

        call DummyRecycle(dummy)

        set dummy = null
        set a = null
    endfunction

    function EntangleGroup takes group whichGroup, real duration returns nothing
        local integer i = 0
        local integer size = BlzGroupGetSize(whichGroup)
        local unit u
        local unit dummy
        local ability a
        local real newDuration = duration

        if size > 0 then
            set u = BlzGroupUnitAt(whichGroup, i)
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 0)
            
            call UnitAddAbility(dummy, ENTANGLE)
            set a = BlzGetUnitAbility(dummy, ENTANGLE)

            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(whichGroup, i)
                    
                    static if LIBRARY_Tenacity then
                        set newDuration = GetTenacityDuration(u, duration)
                    endif

                    if UnitAlive(u) and newDuration > 0 then
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_NORMAL, 0, newDuration)
                        call BlzSetAbilityRealLevelField(a, ABILITY_RLF_DURATION_HERO, 0, newDuration)
                        call IncUnitAbilityLevel(dummy, ENTANGLE)
                        call DecUnitAbilityLevel(dummy, ENTANGLE)
                        call IssueTargetOrder(dummy, "entanglingroots", u)
                    endif
                set i = i + 1
            endloop

            call UnitRemoveAbility(dummy, ENTANGLE)
            call DummyRecycle(dummy)
        endif

        set u = null
        set a = null
        set dummy = null
    endfunction

    function EntangleArea takes real x, real y, real aoe, real duration returns nothing
        local group g = CreateGroup()

        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        call EntangleGroup(g, duration)
        call DestroyGroup(g)

        set g = null
    endfunction

    function IsUnitEntangled takes unit whichUnit returns boolean
        return GetUnitAbilityLevel(whichUnit, ENTANGLE_BUFF) > 0
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Systems                                            */
    /* ---------------------------------------------------------------------------------------------- */
    /* ------------------------------------------ Knockback ----------------------------------------- */
    struct Knockback extends Missiles
        private static integer array knocked
    
        boolean cliff
        boolean destructable
        boolean unit
        boolean isPaused
        integer key
        effect attachment
    
        method onPeriod takes nothing returns boolean
            if UnitAlive(source) then
                call SetUnitX(source, prevX)
                call SetUnitY(source, prevY)
                
                return false
            else
                return true
            endif
        endmethod
        
        method onHit takes unit u returns boolean
            if unit and u != source then
                if UnitAlive(u) then
                    return true
                else
                    return false
                endif
            else
                return false
            endif
        endmethod
        
        method onDestructable takes destructable d returns boolean
            if destructable then
                if GetDestructableLife(d) > 0 then
                    return true
                else
                    return false
                endif
            else
                return false
            endif
        endmethod
        
        method onCliff takes nothing returns boolean
            return cliff
        endmethod
        
        method onPause takes nothing returns boolean
            call pause(false)
            return false
        endmethod
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(attachment)
            set knocked[key] = knocked[key] - 1
            
            set attachment = null
        endmethod
        
        static method isUnitKnocked takes unit u returns boolean
            return knocked[GetUnitUserData(u)] > 0
        endmethod
        
        static method apply takes unit whichUnit, real angle, real distance, real duration, string model, string point, boolean onCliff, boolean onDestructable, boolean onUnit, boolean stunned returns nothing
            local real x = GetUnitX(whichUnit)
            local real y = GetUnitY(whichUnit)
            local real newDuration = duration
            local thistype this

            static if LIBRARY_Tenacity then
                set newDuration = GetTenacityDuration(whichUnit, duration)
            endif

            if newDuration > 0 then
                set this = thistype.create(x, y, 0, x + distance*Cos(angle), y + distance*Sin(angle), 0)
                set .source = whichUnit
                set .duration = newDuration
                set .collision = 2*BlzGetUnitCollisionSize(whichUnit)
                set .cliff = onCliff
                set .destructable = onDestructable
                set .unit = onUnit
                set .isPaused = isPaused
                set .key = GetUnitUserData(whichUnit)
                set knocked[key] = knocked[key] + 1
                
                if model != null and point != null then
                    set .attachment = AddSpecialEffectTarget(model, whichUnit, point)
                endif
                
                if stunned then
                    call StunUnit(whichUnit, newDuration)
                endif
                
                call launch()
            endif
        endmethod
    endstruct

    /* ------------------------------------------- Knockup ------------------------------------------ */
    struct Knockup
        private static integer array knocked

        timer timer 
        unit unit
        effect effect
        integer key
        boolean up
        real rate
        real airTime

        static method isUnitKnocked takes unit u returns boolean
            return knocked[GetUnitUserData(u)] > 0
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if up then
                set up = false
                call SetUnitFlyHeight(unit, GetUnitDefaultFlyHeight(unit), rate)
                call TimerStart(timer, airTime/2, false, function thistype.onPeriod)
            else
                call DestroyEffect(effect)
                call ReleaseTimer(timer)
                call deallocate()

                set knocked[key] = knocked[key] - 1
                set timer = null
                set unit = null
                set effect = null
            endif
        endmethod

        static method apply takes unit whichUnit, real airTime, real maxHeight, string model, string point returns nothing
            local thistype this
            local real duration = airTime

            static if LIBRARY_Tenacity then
                set duration = GetTenacityDuration(whichUnit, airTime)
            endif

            if duration > 0 then
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set unit = whichUnit
                set rate = maxHeight/duration
                set .airTime = duration
                set up = true
                set key = GetUnitUserData(unit)
                set knocked[key] = knocked[key] + 1

                if model != null and point != null then
                    set effect = AddSpecialEffectTarget(model, unit, point)
                endif

                call StunUnit(whichUnit, duration)
                call UnitAddAbility(unit, 'Amrf')
                call UnitRemoveAbility(unit, 'Amrf')
                call SetUnitFlyHeight(unit, (GetUnitDefaultFlyHeight(unit) + maxHeight), rate)
                call TimerStart(timer, duration/2, false, function thistype.onPeriod)
            endif
        endmethod
    endstruct

    /* -------------------------------------------- Fear -------------------------------------------- */
    struct Fear
        static constant real PERIOD = 1./5.
        static constant integer DIRECTION_CHANGE = 5 
        static constant real MAX_CHANGE = 200.
        static integer key = -1
        static thistype array array
        static integer array struct
        static boolean array flag
        static real array x
        static real array y
        static timer timer = CreateTimer()

        unit unit
        effect effect
        integer id
        real duration
        integer change
        boolean selected

        static method isUnitFeared takes unit target returns boolean
            return struct[GetUnitUserData(target)] != 0
        endmethod

        method remove takes integer i returns integer
            set flag[id] = true
            call IssueImmediateOrder(unit, "stop")
            call DestroyEffect(effect)
            call UnitRemoveAbility(unit, 'Abun')

            if selected then
                call SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
            endif

            set struct[id] = 0
            set unit = null
            set effect = null
            set array[i] = array[key]
            set key = key - 1

            call deallocate()

            if key == -1 then
                call PauseTimer(timer)
            endif

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration > 0 and UnitAlive(unit) then
                        set duration = duration - PERIOD
                        set change = change + 1

                        if change >= DIRECTION_CHANGE then
                            set change = 0
                            set flag[id] = true
                            set x[id] = GetRandomReal(GetUnitX(unit) - MAX_CHANGE, GetUnitX(unit) + MAX_CHANGE)
                            set y[id] = GetRandomReal(GetUnitY(unit) - MAX_CHANGE, GetUnitY(unit) + MAX_CHANGE)
                            call IssuePointOrder(unit, "move", x[id], y[id])
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        static method apply takes unit whichUnit, real duration, string model, string point returns nothing
            local integer id = GetUnitUserData(whichUnit)
            local thistype this
            local real newDuration = duration

            static if LIBRARY_Tenacity then
                set newDuration = GetTenacityDuration(whichUnit, duration)
            endif

            if newDuration > 0 then
                if struct[id] != 0 then
                    set this = struct[id]
                else
                    set this = thistype.allocate()
                    set .id = id
                    set unit = whichUnit
                    set change = 0
                    set selected = IsUnitSelected(whichUnit, GetOwningPlayer(whichUnit))
                    set key = key + 1
                    set array[key] = this
                    set struct[id] = this

                    call UnitAddAbility(whichUnit, 'Abun')

                    if selected then
                        call SelectUnit(whichUnit, false)
                    endif

                    if model != null and point != null then
                        set effect = AddSpecialEffectTarget(model, whichUnit, point)
                    endif

                    if key == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif

                set .duration = newDuration
                set flag[id] = true
                set x[id] = GetRandomReal(GetUnitX(whichUnit) - MAX_CHANGE, GetUnitX(whichUnit) + MAX_CHANGE)
                set y[id] = GetRandomReal(GetUnitY(whichUnit) - MAX_CHANGE, GetUnitY(whichUnit) + MAX_CHANGE)
                call IssuePointOrder(whichUnit, "move", x[id], y[id])
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id

            if isUnitFeared(source) then
                set id = GetUnitUserData(source)

                if not flag[id] then
                    set flag[id] = true
                    call IssuePointOrder(source, "move", x[id], y[id])
                else
                    set flag[id] = false
                endif
            endif

            set source = null
        endmethod

        private static method onSelect takes nothing returns nothing
            local unit source = GetTriggerUnit()
        
            if isUnitFeared(source) then
                if IsUnitSelected(source, GetOwningPlayer(source)) then
                    call SelectUnit(source, false)
                endif
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
        endmethod
    endstruct

    /* ------------------------------------------- Disarm ------------------------------------------- */
    struct Disarm
        static constant integer ability = 'Abun'
        static constant real period  = 0.03125000
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array
        static thistype array struct
        readonly static integer array count

        unit unit
        effect effect
        integer id
        integer ticks

        static method isUnitDisarmed takes unit target returns boolean
            return GetUnitAbilityLevel(target, ability) > 0
        endmethod

        private method remove takes integer i returns integer
            call disarm(unit, false)
            call DestroyEffect(effect)

            set struct[id] = 0
            set unit = null
            set effect = null
            set array[i] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if ticks <= 0 then
                        set i = remove(i)
                    endif
                    set ticks = ticks - 1
                set i = i + 1
            endloop
        endmethod

        static method apply takes unit whichUnit, real duration, string model, string point returns nothing
            local integer  i = GetUnitUserData(whichUnit)
            local thistype this
            local real newDuration = duration

            static if LIBRARY_Tenacity then
                set newDuration = GetTenacityDuration(whichUnit, duration)
            endif

            if newDuration > 0 then
                if struct[i] != 0 then
                    set this = struct[i]
                else
                    set this = thistype.allocate()
                    set unit = whichUnit
                    set id = i
                    set key = key + 1
                    set array[key] = this
                    set struct[i] = this

                    if model != null and point != null then
                        set effect = AddSpecialEffectTarget(model, unit, point)
                    endif

                    call disarm(whichUnit, true)

                    if key == 0 then
                        call TimerStart(timer, period, true, function thistype.onPeriod)
                    endif
                endif

                set ticks = R2I(newDuration/period)
            endif
        endmethod

        static method disarm takes unit whichUnit, boolean flag returns nothing
            local integer i = GetUnitUserData(whichUnit)
            
            if flag then
                set count[i] = count[i] + 1
                if count[i] > 0 then
                    call UnitAddAbility(whichUnit, ability)
                endif
            else
                set count[i] = count[i] - 1
                if count[i] <= 0 then
                    call UnitRemoveAbility(whichUnit, ability)
                endif
            endif
        endmethod
    endstruct
endlibrary
