--[[ requires DamageInterface, RegisterPlayerUnitEvent, Utilities, NewBonus optional WitheringFire
    /* ---------------------- Black Arrow v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     AZ            - Black Arrow model
    //     Darkfang      - Arcane Arrow icon
    //     YourArthas    - Skeleton Models
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Black Arrow ability
    BlackArrow_ABILITY           = FourCC('A00C')
    -- The raw code of the Black Arrow Curse debuff
    BlackArrow_BLACK_ARROW_CURSE = FourCC('A00D')
    -- The raw code of the melee unit
    local SKELETON_WARRIOR       = FourCC('u000')
    -- The raw code of the ranged unit
    local SKELETON_ARCHER        = FourCC('n001')
    -- The raw code of the Elite unit
    local SKELETON_ELITE         = FourCC('n000')
    -- The effect created when the skelton warrior spawns
    local RAISE_EFFECT           = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"

    -- The curse duration
    function BlackArrow_GetCurseDuration(level)
        return 10.
    end

    -- The damage bonus when Black Arrows is active
    local function GetBonusDamage(unit, level)
        return (5 + 5*level) + ((0.05*level)*GetHeroAgi(unit, true))
    end

    -- The melee sketelon health amount
    local function GetSkeletonWarriorHealth(unit, level)
        return R2I(50*(level + 6) + BlzGetUnitMaxHP(unit)*0.15)
    end

    -- The melee sketelon damage amount
    local function GetSkeletonWarriorDamage(unit, level)
        return R2I(5*(level + 3) + GetUnitBonus(unit, BONUS_DAMAGE)*0.15)
    end

    -- The ranged sketelon health amount
    local function GetSkeletonArcherHealth(unit, level)
        return R2I(50*(level + 3) + BlzGetUnitMaxHP(unit)*0.15)
    end

    -- The ranged sketelon damage amount
    local function GetSkeletonArcherDamage(unit, level)
        return R2I(5*(level + 6) + GetUnitBonus(unit, BONUS_DAMAGE)*0.15)
    end

    -- The sketelon duration
    local function GetSkeletonDuration(level)
        return 15.
    end

    -- The max amount of skeleton warriors a unit can have
    local function GetMaxSkeletonCount(level)
        return 11
    end

    -- The elite sketelon health amount
    local function GetEliteHealth(level)
        return R2I(50*(level + 11) + BlzGetUnitMaxHP(unit)*0.33)
    end

    -- The elite sketelon damage amount
    local function GetEliteDamage(unit, level)
        return R2I(5*(level + 11) + GetUnitBonus(unit, BONUS_DAMAGE)*0.33)
    end

    -- The elite sketelon duration
    local function GetEliteDuration(level)
        return 60.
    end

    -- How long it takes to a unit to be able to spawn Elites again after it already has the max amount
    local function GetEliteCountReset(level)
        return 30.
    end

    -- The Max amount of Elites a unit can have before going into cooldown
    local function GetMaxEliteCount(level)
        return 2
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    BlackArrow = setmetatable({}, {})
    local mt = getmetatable(BlackArrow)
    mt.__index = mt
    
    BlackArrow.active = {}
    local counter = {}
    local elite = {}
    local skeletons = {}
    local source = {}
    local player = {}
    
    onInit(function()
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, BlackArrow_ABILITY)
            local manaCost = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(Damage.source.unit, BlackArrow_ABILITY), ABILITY_ILF_MANA_COST, level - 1)
            local hasMana = GetUnitState(Damage.source.unit, UNIT_STATE_MANA) > manaCost
            local damage = GetEventDamage()

            if BlackArrow.active[Damage.source.unit] and Damage.isEnemy and not Damage.target.isStructure and hasMana and damage > 0 then
                player[Damage.target.unit] = Damage.source.player
                source[Damage.target.unit] = Damage.source.unit

                BlzSetEventDamage(damage + GetBonusDamage(Damage.source.unit, level))
                if Damage.target.isHero then
                    counter[Damage.source.unit] = (counter[Damage.source.unit] or 0) + 1

                    if counter[Damage.source.unit] >= 5 then
                        counter[Damage.source.unit] = 0

                        if (elite[Damage.source.unit] or 0) < GetMaxEliteCount(level) then
                            local u = CreateUnit(player[Damage.target.unit], SKELETON_ELITE, Damage.target.x, Damage.target.y, 0)
                            
                            elite[Damage.source.unit] = (elite[Damage.source.unit] or 0) + 1
                            BlzSetUnitMaxHP(u, GetEliteHealth(source[Damage.target.unit], level))
                            BlzSetUnitBaseDamage(u, GetEliteDamage(source[Damage.target.unit], level), 0)
                            SetUnitLifePercentBJ(u, 100)
                            UnitApplyTimedLife(u, FourCC('BTLF'), GetEliteDuration(level))
                            SetUnitAnimation(u, "Birth")
                            DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(u), GetUnitY(u), GetUnitZ(u), 2))
                            
                            if (elite[Damage.source.unit] or 0) == GetMaxEliteCount(level) then
                                local timer = CreateTimer()
                                local unit = Damage.source.unit
                                
                                TimerStart(timer, GetEliteCountReset(level), false, function()
                                    elite[unit] = 0
                                    PauseTimer(timer)
                                    DestroyTimer(timer)
                                end)
                            end
                        end
                    end
                end
                UnitAddAbilityTimed(Damage.target.unit, BlackArrow_BLACK_ARROW_CURSE, BlackArrow_GetCurseDuration(level), level, true)
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()
            local level = GetUnitAbilityLevel(unit, BlackArrow_BLACK_ARROW_CURSE)
            local id = GetUnitTypeId(unit)

            if id == SKELETON_WARRIOR or id == SKELETON_ARCHER then
                local i = GetOwningPlayer(unit)
                skeletons[i] = skeletons[i] - 1
            elseif level > 0 and (skeletons[player[unit]] or 0) < GetMaxSkeletonCount(level) then
                local x = GetUnitX(unit)
                local y = GetUnitY(unit)
                local u
                
                skeletons[player[unit]] = (skeletons[player[unit]] or 0) + 1
                if IsUnitType(unit, UNIT_TYPE_RANGED_ATTACKER) then
                    u = CreateUnit(player[unit], SKELETON_ARCHER, x, y, 0)
                    BlzSetUnitMaxHP(u, GetSkeletonArcherHealth(source[unit], level))
                    BlzSetUnitBaseDamage(u, GetSkeletonArcherDamage(source[unit], level), 0)
                else
                    u = CreateUnit(player[unit], SKELETON_WARRIOR, x, y, 0)
                    BlzSetUnitMaxHP(u, GetSkeletonWarriorHealth(source[unit], level))
                    BlzSetUnitBaseDamage(u, GetSkeletonWarriorDamage(source[unit], level), 0)
                end
                
                UnitApplyTimedLife(u, FourCC('BTLF'), GetSkeletonDuration(level))
                SetUnitLifePercentBJ(u, 100)
                SetUnitAnimation(u, "Birth")
                DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(u), GetUnitY(u), GetUnitZ(u), 1))
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
            local unit = GetOrderedUnit()
            local id = GetIssuedOrderId()

            if id == 852174 or id == 852175 then
                BlackArrow.active[unit] = id == 852174
                if WitheringFire then
                    if GetUnitAbilityLevel(unit, WitheringFire_ABILITY) > 0 then
                        WitheringFire:setMissileArt(unit, BlackArrow.active[unit])
                    end
                end
            end
        end) 
    end)
end