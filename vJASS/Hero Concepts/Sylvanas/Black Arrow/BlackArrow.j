library BlackArrow requires DamageInterface, RegisterPlayerUnitEvent, Utilities, NewBonus optional WitheringFire
    /* ---------------------- Black Arrow v1.3 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     AZ            - Black Arrow model
    //     Darkfang      - Arcane Arrow icon
    //     YourArthas    - Skeleton Models
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Black Arrow ability
        public  constant integer ABILITY           = 'A00C'
        // The raw code of the Black Arrow Curse debuff
        public  constant integer BLACK_ARROW_CURSE = 'A00D'
        // The raw code of the melee unit
        private constant integer SKELETON_WARRIOR  = 'u000'
        // The raw code of the ranged unit
        private constant integer SKELETON_ARCHER   = 'n001'
        // The raw code of the Elite unit
        private constant integer SKELETON_ELITE    = 'n000'
        // The effect created when the skelton warrior spawns
        private constant string  RAISE_EFFECT      = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    endglobals

    // The curse duration
    public function GetCurseDuration takes integer level returns real
        return 10.
    endfunction

    // The damage bonus when Black Arrows is active
    private function GetBonusDamage takes unit u, integer level returns real
        return (5 + 5*level) + ((0.05*level)*GetHeroAgi(u, true))
    endfunction

    // The melee sketelon health amount
    private function GetSkeletonWarriorHealth takes integer level, unit source returns integer
        return R2I(50*(level + 6) + BlzGetUnitMaxHP(source)*0.15)
    endfunction

    // The melee sketelon damage amount
    private function GetSkeletonWarriorDamage takes integer level, unit source returns integer
        return R2I(5*(level + 3) + GetUnitBonus(source, BONUS_DAMAGE)*0.15)
    endfunction

    // The ranged sketelon health amount
    private function GetSkeletonArcherHealth takes integer level, unit source returns integer
        return R2I(50*(level + 3) + BlzGetUnitMaxHP(source)*0.15)
    endfunction

    // The ranged sketelon damage amount
    private function GetSkeletonArcherDamage takes integer level, unit source returns integer
        return R2I(5*(level + 6) + GetUnitBonus(source, BONUS_DAMAGE)*0.15)
    endfunction

    // The sketelon duration
    private function GetSkeletonDuration takes integer level returns real
        return 15.
    endfunction

    // The max amount of skeleton warriors a unit can have
    private function GetMaxSkeletonCount takes integer level returns integer
        return 11
    endfunction

    // The elite sketelon health amount
    private function GetEliteHealth takes integer level, unit source returns integer
        return R2I(50*(level + 11) + BlzGetUnitMaxHP(source)*0.33)
    endfunction

    // The elite sketelon damage amount
    private function GetEliteDamage takes integer level, unit source returns integer
        return R2I(5*(level + 11) + GetUnitBonus(source, BONUS_DAMAGE)*0.33)
    endfunction

    // The elite sketelon duration
    private function GetEliteDuration takes integer level returns real
        return 60.
    endfunction

    // How long it takes to a unit to be able to spawn Elites again after it already has the max amount
    private function GetEliteCountReset takes integer level returns real
        return 30.
    endfunction

    // The Max amount of Elites a unit can have before going into cooldown
    private function GetMaxEliteCount takes integer level returns integer
        return 2
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct BlackArrow
        private static integer array counter
        private static integer array elite
        private static integer array skeletons
        static player array owner
        static unit array source
        static boolean array active

        timer   t
        integer idx

        static method curse takes unit target, unit source, player owner returns nothing
            local integer id
            local integer level

            if target != null and source != null and owner != null then
                set id = GetUnitUserData(target)
                set level = GetUnitAbilityLevel(source, ABILITY)
                set .owner[id] = owner
                set .source[id] = source
                call UnitAddAbilityTimed(target, BLACK_ARROW_CURSE, GetCurseDuration(level), level, true)
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call ReleaseTimer(t)
            set elite[idx] = 0
            set t = null
            call deallocate()
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit    source = GetOrderedUnit()
            local integer id     = GetIssuedOrderId()
            local integer idx    = GetUnitUserData(source)

            if id == 852174 or id == 852175 then
                set active[idx] = id == 852174
                static if LIBRARY_WitheringFire then
                    if GetUnitAbilityLevel(source, WitheringFire_ABILITY) > 0 then
                        call WitheringFire.setMissileArt(source, active[idx])
                    endif
                endif
            endif

            set source = null
        endmethod

        static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local integer manaCost = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(Damage.source.unit, ABILITY), ABILITY_ILF_MANA_COST, level - 1)
            local boolean hasMana = GetUnitState(Damage.source.unit, UNIT_STATE_MANA) > manaCost
            local real damage = GetEventDamage()
            local unit u
            local thistype this

            if active[Damage.source.id] and Damage.isEnemy and not Damage.target.isStructure and hasMana and damage > 0 then
                set owner[Damage.target.id] = Damage.source.player
                set source[Damage.target.id] = Damage.source.unit

                call BlzSetEventDamage(damage + GetBonusDamage(Damage.source.unit, level))
                if Damage.target.isHero then
                    set counter[Damage.source.id] = counter[Damage.source.id] + 1

                    if counter[Damage.source.id] >= 5 then
                        set counter[Damage.source.id] = 0

                        if elite[Damage.source.id] < GetMaxEliteCount(level) then
                            set elite[Damage.source.id] = elite[Damage.source.id] + 1 
                            set u = CreateUnit(owner[Damage.target.id], SKELETON_ELITE, Damage.target.x, Damage.target.y, 0)

                            call BlzSetUnitMaxHP(u, GetEliteHealth(level, source[Damage.target.id]))
                            call BlzSetUnitBaseDamage(u, GetEliteDamage(level, source[Damage.target.id]), 0)
                            call SetUnitLifePercentBJ(u, 100)
                            call UnitApplyTimedLife(u, 'BTLF', GetEliteDuration(level))
                            call SetUnitAnimation(u, "Birth")
                            call DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 2))
                            
                            if elite[Damage.source.id] == GetMaxEliteCount(level) then
                                set this = thistype.allocate()
                                set .t   = NewTimerEx(this)
                                set .idx = Damage.source.id
                                call TimerStart(.t, GetEliteCountReset(level), false, function thistype.onPeriod)
                            endif
                        endif
                    endif
                endif
                call UnitAddAbilityTimed(Damage.target.unit, BLACK_ARROW_CURSE, GetCurseDuration(level), level, true)
            endif

            set u = null
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killed = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(killed, BLACK_ARROW_CURSE)
            local integer i = GetUnitUserData(killed)
            local integer idx = GetPlayerId(owner[i])
            local integer id = GetUnitTypeId(killed)
            local boolean ranged = IsUnitType(killed, UNIT_TYPE_RANGED_ATTACKER)
            local boolean skeleton = id == SKELETON_WARRIOR or id == SKELETON_ARCHER
            local unit u
            local real x
            local real y

            if skeleton then
                set idx = GetPlayerId(GetOwningPlayer(killed))
                set skeletons[idx] = skeletons[idx] - 1
            elseif level > 0 and skeletons[idx] < GetMaxSkeletonCount(level) then
                set skeletons[idx] = skeletons[idx] + 1
                set x = GetUnitX(killed)
                set y = GetUnitY(killed)
                
                if ranged then
                    set u = CreateUnit(owner[i], SKELETON_ARCHER, x, y, 0)
                    call BlzSetUnitMaxHP(u, GetSkeletonArcherHealth(level, source[i]))
                    call BlzSetUnitBaseDamage(u, GetSkeletonArcherDamage(level, source[i]), 0)
                else
                    set u = CreateUnit(owner[i], SKELETON_WARRIOR, x, y, 0)
                    call BlzSetUnitMaxHP(u, GetSkeletonWarriorHealth(level, source[i]))
                    call BlzSetUnitBaseDamage(u, GetSkeletonWarriorDamage(level, source[i]), 0)
                endif
                
                call UnitApplyTimedLife(u, 'BTLF', GetSkeletonDuration(level))
                call SetUnitLifePercentBJ(u, 100)
                call SetUnitAnimation(u, "Birth")
                call DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 1))
            endif

            set u = null
            set killed = null
        endmethod   

        static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary