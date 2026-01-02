OnInit("BlackArrow", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "RangerPrecision"

    -- ----------------------------- Black Arrow v1.5 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Black Arrow ability
    BlackArrow_ABILITY           = S2A('Svn1')
    -- The raw code of the Black Arrow Curse debuff
    BlackArrow_BLACK_ARROW_CURSE = S2A('Svn8')
    -- The raw code of the melee unit
    BlackArrow_SKELETON_WARRIOR  = S2A('svn0')
    -- The raw code of the ranged unit
    BlackArrow_SKELETON_ARCHER   = S2A('svn2')
    -- The raw code of the Elite unit
    BlackArrow_SKELETON_ELITE    = S2A('svn1')
    -- The effect created when the skelton warrior spawns
    local RAISE_EFFECT           = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    
    -- The curse duration
    function BlackArrow_GetCurseDuration(level)
        return 10
    end

    -- The damage bonus when Black Arrows is active
    local function GetBonusDamage(unit, level)
        return (5 + 5 * level) + (0.05 * level) * GetHeroAgi(unit, true) + 0.1 * GetUnitBonus(unit, BONUS_SPELL_POWER)
    end

    -- The melee sketelon health amount
    local function GetSkeletonWarriorHealth(level, source, target)
        return R2I((50 * (level + 6)) + (BlzGetUnitMaxHP(source) * 0.15) + (0.15 * level * BlzGetUnitMaxHP(target)))
    end

    -- The melee sketelon damage amount
    local function GetSkeletonWarriorDamage(level, source, target)
        return R2I((5 * (level + 3)) + (GetUnitBonus(source, BONUS_DAMAGE) * 0.15) + (0.15 * level * BlzGetUnitBaseDamage(target, 0)) + (0.15 * level * GetUnitBonus(target, BONUS_DAMAGE)))
    end

    -- The ranged sketelon health amount
    local function GetSkeletonArcherHealth(level, source, target)
        return R2I((50 * (level + 3)) + (BlzGetUnitMaxHP(source) * 0.15) + (0.15 * level * BlzGetUnitMaxHP(target)))
    end

    -- The ranged sketelon damage amount
    local function GetSkeletonArcherDamage(level, source, target)
        return R2I((5 * (level + 6)) + (GetUnitBonus(source, BONUS_DAMAGE) * 0.15) + (0.15 * level * BlzGetUnitBaseDamage(target, 0)) + (0.15 * level * GetUnitBonus(target, BONUS_DAMAGE)))
    end

    -- The sketelon duration
    function BlackArrow_GetSkeletonDuration(level)
        return 15.
    end

    -- The max amount of skeleton warriors a unit can have
    local function GetMaxSkeletonCount(level)
        return 11
    end

    -- The elite sketelon health amount
    local function GetEliteHealth(level, source, target)
        return R2I((50 * (level + 11)) + (BlzGetUnitMaxHP(source) * 0.33) + (0.2 * level * BlzGetUnitMaxHP(target)))
    end

    -- The elite sketelon damage amount
    local function GetEliteDamage(level, source, target)
        return R2I((5 * (level + 11)) + (GetUnitBonus(source, BONUS_DAMAGE) * 0.33) + (0.2 * level * BlzGetUnitBaseDamage(target, 0)) + (0.2 * level * GetUnitBonus(target, BONUS_DAMAGE)))
    end

    -- The elite sketelon duration
    function BlackArrow_GetEliteDuration(level)
        return 60.
    end

    -- How long it takes to a unit to be able to spawn Elites again after it already has the max amount
    local function GetEliteCountReset(level)
        return 20.
    end

    -- The Max amount of Elites a unit can have before going into cooldown
    local function GetMaxEliteCount(level)
        return 1 + level
    end

    -- The minimum level for normal units to spawn elites
    local function GetMinLevel()
        return 6
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BlackArrow = Class(Spell)

        local elite = {}
        local counter = {}
        local skeletons = {}

        BlackArrow.owner = {}
        BlackArrow.source = {}
        BlackArrow.active = {}

        function BlackArrow:destroy()
            elite[self.unit] = 0

            self.unit = nil
        end

        function BlackArrow.curse(target, source, owner)
            if target and source and owner then
                local level = GetUnitAbilityLevel(source, BlackArrow_ABILITY)

                BlackArrow.owner[target] = owner
                BlackArrow.source[target] = source

                UnitAddAbilityTimed(target, BlackArrow_BLACK_ARROW_CURSE, BlackArrow_GetCurseDuration(level), level, true)
            end
        end

        function BlackArrow:onTooltip(source, level, ability)
            return "Increases |cffffcc00Sylvanas|r damage by |cffff0000" .. N2S(GetBonusDamage(source, level), 0) .. "|r and apply a curse on attacked units. If a cursed unit dies a |cffffcc00Skeleton Warrior|r will be spawnmed in its location lasting for |cffffcc00" .. N2S(BlackArrow_GetSkeletonDuration(level), 0) .. "|r seconds. Attacking an enemy Hero or High Level Unit |cffffcc005|r times while |cffffcc00Black Arrows|r is active creates an |cffffcc00Elite Skeleton Warrior|r at the target location. Max |cffffcc00" .. N2S(GetMaxEliteCount(level), 0) .. " Elite Warriors|r with |cffffcc00" .. N2S(GetEliteCountReset(level), 0) .. "|r seconds cooldown."
        end

        function BlackArrow.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, BlackArrow_ABILITY)
            local cost = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(Damage.source.unit, BlackArrow_ABILITY), ABILITY_ILF_MANA_COST, level - 1)

            if BlackArrow.active[Damage.source.unit] and Damage.isEnemy and not Damage.target.isStructure and Damage.amount > 0 and Damage.source.mana > cost then
                BlackArrow.owner[Damage.target.unit] = Damage.source.player
                BlackArrow.source[Damage.target.unit] = Damage.source.unit
                Damage.amount = Damage.amount + GetBonusDamage(Damage.source.unit, level)

                if Damage.target.isHero or Damage.target.level >= GetMinLevel() then
                    counter[Damage.source.unit] = (counter[Damage.source.unit] or 0) + 1

                    if counter[Damage.source.unit] >= 5 then
                        counter[Damage.source.unit] = 0

                        if (elite[Damage.source.unit] or 0) < GetMaxEliteCount(level) then
                            elite[Damage.source.unit] = (elite[Damage.source.unit] or 0) + 1 

                            local unit = CreateUnit(BlackArrow.owner[Damage.target.unit], BlackArrow_SKELETON_ELITE, Damage.target.x, Damage.target.y, 0)

                            BlzSetUnitMaxHP(unit, GetEliteHealth(level, BlackArrow.source[Damage.target.unit], Damage.target.unit))
                            BlzSetUnitBaseDamage(unit, GetEliteDamage(level, BlackArrow.source[Damage.target.unit], Damage.target.unit), 0)
                            SetUnitLifePercentBJ(unit, 100)
                            UnitApplyTimedLife(unit, S2A('BTLF'), BlackArrow_GetEliteDuration(level))
                            SetUnitAnimation(unit, "Birth")
                            DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 2))
                            
                            if (elite[Damage.source.unit] or 0) == GetMaxEliteCount(level) then
                                local self = { destroy = BlackArrow.destroy }
                                
                                self.unit = Damage.source.unit

                                TimerStart(CreateTimer(), GetEliteCountReset(level), false, function ()
                                    DestroyTimer(GetExpiredTimer())
                                    self:destroy()
                                end)
                            end
                        end
                    end
                end

                UnitAddAbilityTimed(Damage.target.unit, BlackArrow_BLACK_ARROW_CURSE, BlackArrow_GetCurseDuration(level), level, true)
            end
        end

        function BlackArrow.onOrder()
            local source = GetOrderedUnit()
            local id = GetIssuedOrderId()

            if id == 852174 or id == 852175 then
                BlackArrow.active[source] = id == 852174

                if RangerPrecision then
                    if GetUnitAbilityLevel(source, RangerPrecision_ABILITY) > 0 then
                        RangerPrecision.enable(source, BlackArrow.active[source])
                    end
                end
            end
        end

        function BlackArrow.onDeath()
            local killed = GetTriggerUnit()
            local id = GetPlayerId(BlackArrow.owner[killed])
            local level = GetUnitAbilityLevel(killed, BlackArrow_BLACK_ARROW_CURSE)
            local unit

            if GetUnitTypeId(killed) == BlackArrow_SKELETON_WARRIOR or GetUnitTypeId(killed) == BlackArrow_SKELETON_ARCHER then
                id = GetPlayerId(GetOwningPlayer(killed))
                skeletons[id] = (skeletons[id] or 0) - 1
            elseif level > 0 and (skeletons[id] or 0) < GetMaxSkeletonCount(level) then
                skeletons[id] = (skeletons[id] or 0) + 1

                if IsUnitType(killed, UNIT_TYPE_RANGED_ATTACKER) then
                    unit = CreateUnit(BlackArrow.owner[killed], BlackArrow_SKELETON_ARCHER, GetUnitX(killed), GetUnitY(killed), 0)

                    BlzSetUnitMaxHP(unit, GetSkeletonArcherHealth(level, BlackArrow.source[killed], killed))
                    BlzSetUnitBaseDamage(unit, GetSkeletonArcherDamage(level, BlackArrow.source[killed], killed), 0)
                else
                    unit = CreateUnit(BlackArrow.owner[killed], BlackArrow_SKELETON_WARRIOR, GetUnitX(killed), GetUnitY(killed), 0)

                    BlzSetUnitMaxHP(unit, GetSkeletonWarriorHealth(level, BlackArrow.source[killed], killed))
                    BlzSetUnitBaseDamage(unit, GetSkeletonWarriorDamage(level, BlackArrow.source[killed], killed), 0)
                end
                
                SetUnitLifePercentBJ(unit, 100)
                SetUnitAnimation(unit, "Birth")
                UnitApplyTimedLife(unit, S2A('BTLF'), BlackArrow_GetSkeletonDuration(level))
                DestroyEffect(AddSpecialEffectEx(RAISE_EFFECT, GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 1))
            end
        end

        function BlackArrow.onInit()
            RegisterSpell(BlackArrow.allocate(), BlackArrow_ABILITY)
            RegisterAttackDamageEvent(BlackArrow.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, BlackArrow.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, BlackArrow.onOrder)
        end
    end
end)