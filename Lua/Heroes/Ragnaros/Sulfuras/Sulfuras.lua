OnInit("Sulfuras", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------------- Sulfuras v1.7 ------------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Sufuras Ability
    local ABILITY        = S2A('Rgn0')
    -- The missile model
    local MISSILE_MODEL  = "Fireball Minor.mdl"
    -- The missile speed
    local MISSILE_SPEED  = 1250
    -- The missile scale
    local MISSILE_SCALE  = 0.5
    
    -- Modify this function to change the amount of damage Ragnaros gains per kill
    local function GetBonus(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 5*level
        else
            return level
        end
    end

    -- Every GetStackCount number of kills the damage will be increased by GetBonus
    local function GetStackCount(unit, level)
        return 3 + 0*level
    end

    -- The minimum range for the missile to be created
    local function GetMinimumRange()
        return 400.
    end

    -- Modify this function to change when Ragnaros gains bonus damage based on the Death Event.
    local function UnitFilter(player, target)
        return IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Fireball = Class(Missile)

        function Fireball:onFinish()
            AddUnitBonus(self.source, BONUS_DAMAGE, self.bonus)

            return false
        end
    end

    do
        Sulfuras = Class(Spell)

        local count = {}
        Sulfuras.stacks = {}

        function Sulfuras:onTooltip(source, level, ability)
            return "|cffffcc00Ragnaros|r gains |cffffcc001|r damage for every |cffffcc00" .. N2S(GetStackCount(source, level), 0) .. "|r enemy unit killed by him. Hero kills grants |cffffcc005|r bonus damage.\n\nDamage Bonus: |cffffcc00" .. I2S(Sulfuras.stacks[source]) .. "|r"
        end

        function Sulfuras.onDeath()
            local source = GetKillingUnit()

            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                local target = GetDyingUnit()

                if UnitFilter(GetOwningPlayer(source), target) then
                    local level = GetUnitAbilityLevel(source, ABILITY)

                    if IsUnitType(target, UNIT_TYPE_HERO) then
                        local amount = GetBonus(target, level)

                        Sulfuras.stacks[source] = (Sulfuras.stacks[source] or 0) + amount

                        if DistanceBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target)) >= GetMinimumRange() then
                            local fireball = Fireball.create(GetUnitX(target), GetUnitY(target), 50, GetUnitX(source), GetUnitY(source), 50)
                            
                            fireball.model = MISSILE_MODEL
                            fireball.speed = MISSILE_SPEED
                            fireball.scale = MISSILE_SCALE
                            fireball.source = source
                            fireball.target = source
                            fireball.bonus = amount

                            fireball:launch()
                        else
                            AddUnitBonus(source, BONUS_DAMAGE, amount)
                        end
                    else
                        count[source] = (count[source] or 0) + 1

                        if count[source] >= GetStackCount(source, level) then
                            local amount = GetBonus(target, level)

                            count[source] = 0
                            Sulfuras.stacks[source] = (Sulfuras.stacks[source] or 0) + amount

                            if DistanceBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target)) >= GetMinimumRange() then
                                local fireball = Fireball.create(GetUnitX(target), GetUnitY(target), 50, GetUnitX(source), GetUnitY(source), 50)
                                
                                fireball.model = MISSILE_MODEL
                                fireball.speed = MISSILE_SPEED
                                fireball.scale = MISSILE_SCALE
                                fireball.source = source
                                fireball.target = source
                                fireball.bonus = amount

                                fireball:launch()
                            else
                                AddUnitBonus(source, BONUS_DAMAGE, amount)
                            end
                        end
                    end
                end
            end
        end

        function Sulfuras.onInit()
            RegisterSpell(Sulfuras.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, Sulfuras.onDeath)
        end
    end
end)