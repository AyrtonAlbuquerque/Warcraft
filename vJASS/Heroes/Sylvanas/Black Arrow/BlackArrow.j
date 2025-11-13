library BlackArrow requires Spell, DamageInterface, RegisterPlayerUnitEvent, Utilities, NewBonus, Modules optional RangerPrecision
    /* ---------------------- Black Arrow v1.5 by Chopinski --------------------- */
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
        public  constant integer ABILITY           = 'Svn1'
        // The raw code of the Black Arrow Curse debuff
        public  constant integer BLACK_ARROW_CURSE = 'Svn8'
        // The raw code of the melee unit
        public  constant integer SKELETON_WARRIOR  = 'svn0'
        // The raw code of the ranged unit
        public  constant integer SKELETON_ARCHER   = 'svn2'
        // The raw code of the Elite unit
        public  constant integer SKELETON_ELITE    = 'svn1'
        // The effect created when the skelton warrior spawns
        private constant string  RAISE_EFFECT      = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    endglobals

    // The curse duration
    public function GetCurseDuration takes integer level returns real
        return 10.
    endfunction

    // The damage bonus when Black Arrows is active
    private function GetBonusDamage takes unit u, integer level returns real
        return (5 + 5 * level) + (0.05 * level) * GetHeroAgi(u, true) + 0.1 * GetUnitBonus(u, BONUS_SPELL_POWER)
    endfunction

    // The melee sketelon health amount
    private function GetSkeletonWarriorHealth takes integer level, unit source returns integer
        return R2I(50 * (level + 6) + BlzGetUnitMaxHP(source) * 0.15)
    endfunction

    // The melee sketelon damage amount
    private function GetSkeletonWarriorDamage takes integer level, unit source returns integer
        return R2I(5 * (level + 3) + GetUnitBonus(source, BONUS_DAMAGE) * 0.15)
    endfunction

    // The ranged sketelon health amount
    private function GetSkeletonArcherHealth takes integer level, unit source returns integer
        return R2I(50 * (level + 3) + BlzGetUnitMaxHP(source) * 0.15)
    endfunction

    // The ranged sketelon damage amount
    private function GetSkeletonArcherDamage takes integer level, unit source returns integer
        return R2I(5 * (level + 6) + GetUnitBonus(source, BONUS_DAMAGE) * 0.15)
    endfunction

    // The sketelon duration
    public function GetSkeletonDuration takes integer level returns real
        return 15.
    endfunction

    // The max amount of skeleton warriors a unit can have
    private function GetMaxSkeletonCount takes integer level returns integer
        return 11
    endfunction

    // The elite sketelon health amount
    private function GetEliteHealth takes integer level, unit source returns integer
        return R2I(50 * (level + 11) + BlzGetUnitMaxHP(source) * 0.33)
    endfunction

    // The elite sketelon damage amount
    private function GetEliteDamage takes integer level, unit source returns integer
        return R2I(5 * (level + 11) + GetUnitBonus(source, BONUS_DAMAGE) * 0.33)
    endfunction

    // The elite sketelon duration
    public function GetEliteDuration takes integer level returns real
        return 60.
    endfunction

    // How long it takes to a unit to be able to spawn Elites again after it already has the max amount
    private function GetEliteCountReset takes integer level returns real
        return 20.
    endfunction

    // The Max amount of Elites a unit can have before going into cooldown
    private function GetMaxEliteCount takes integer level returns integer
        return 1 + level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct BlackArrow extends Spell
        private static integer array elite
        private static integer array counter
        private static integer array skeletons
        
        static unit array source
        static player array owner
        static boolean array active

        private integer id

        method destroy takes nothing returns nothing
            set elite[id] = 0
            call deallocate()
        endmethod

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

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Increases |cffffcc00Sylvanas|r damage by |cffff0000" + N2S(GetBonusDamage(source, level), 0) + "|r and apply a curse on attacked units. If a cursed unit dies a |cffffcc00Skeleton Warrior|r will be spawnmed in its location lasting for |cffffcc00" + N2S(GetSkeletonDuration(level), 0) + "|r seconds. Attacking an enemy Hero |cffffcc005|r times while |cffffcc00Black Arrows|r is active creates an |cffffcc00Elite Skeleton Warrior|r at the target location. Max |cffffcc00" + N2S(GetMaxEliteCount(level), 0) + " Elite Warriors|r with |cffffcc00" + N2S(GetEliteCountReset(level), 0) + "|r seconds cooldown."
        endmethod

        private static method onDamage takes nothing returns nothing
            local unit u
            local thistype this
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local integer cost = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(Damage.source.unit, ABILITY), ABILITY_ILF_MANA_COST, level - 1)

            if active[Damage.source.id] and Damage.isEnemy and not Damage.target.isStructure and Damage.amount > 0 and Damage.source.mana > cost then
                set owner[Damage.target.id] = Damage.source.player
                set source[Damage.target.id] = Damage.source.unit
                set Damage.amount = Damage.amount + GetBonusDamage(Damage.source.unit, level)

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
                                set id = Damage.source.id

                                call StartTimer(GetEliteCountReset(level), false, this, id)
                            endif
                        endif
                    endif
                endif
                call UnitAddAbilityTimed(Damage.target.unit, BLACK_ARROW_CURSE, GetCurseDuration(level), level, true)
            endif

            set u = null
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id = GetIssuedOrderId()
            local integer i = GetUnitUserData(source)

            if id == 852174 or id == 852175 then
                set active[i] = id == 852174

                static if LIBRARY_RangerPrecision then
                    if GetUnitAbilityLevel(source, RangerPrecision_ABILITY) > 0 then
                        call RangerPrecision.enable(source, active[i])
                    endif
                endif
            endif

            set source = null
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit u
            local unit killed = GetTriggerUnit()
            local integer i = GetUnitUserData(killed)
            local integer id = GetPlayerId(owner[i])
            local integer level = GetUnitAbilityLevel(killed, BLACK_ARROW_CURSE)

            if GetUnitTypeId(killed) == SKELETON_WARRIOR or GetUnitTypeId(killed) == SKELETON_ARCHER then
                set id = GetPlayerId(GetOwningPlayer(killed))
                set skeletons[id] = skeletons[id] - 1
            elseif level > 0 and skeletons[id] < GetMaxSkeletonCount(level) then
                set skeletons[id] = skeletons[id] + 1

                if IsUnitType(killed, UNIT_TYPE_RANGED_ATTACKER) then
                    set u = CreateUnit(owner[i], SKELETON_ARCHER, GetUnitX(killed), GetUnitY(killed), 0)

                    call BlzSetUnitMaxHP(u, GetSkeletonArcherHealth(level, source[i]))
                    call BlzSetUnitBaseDamage(u, GetSkeletonArcherDamage(level, source[i]), 0)
                else
                    set u = CreateUnit(owner[i], SKELETON_WARRIOR, GetUnitX(killed), GetUnitY(killed), 0)

                    call BlzSetUnitMaxHP(u, GetSkeletonWarriorHealth(level, source[i]))
                    call BlzSetUnitBaseDamage(u, GetSkeletonWarriorDamage(level, source[i]), 0)
                endif
                
                call SetUnitLifePercentBJ(u, 100)
                call SetUnitAnimation(u, "Birth")
                call UnitApplyTimedLife(u, 'BTLF', GetSkeletonDuration(level))
                call DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u), 1))
            endif

            set u = null
            set killed = null
        endmethod   

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary