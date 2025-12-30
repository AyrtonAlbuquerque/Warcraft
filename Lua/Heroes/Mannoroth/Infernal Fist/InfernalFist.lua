OnInit("InfernalFist", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"

    -- ---------------------------- Infernal Fist v1.0 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Infernal Fist ability
    local ABILITY    = S2A('MnrA')
    -- The bonus damage model
    local MODEL      = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"

    -- The attack speed bonus
    local function GetBonusAttackSpeed(source, level)
        return 1. + 0.*level
    end

    -- The Attack speed bonus duration
    local function GetDuration(source, level)
        return 5. + 0.*level
    end

    -- The bonus cooldown per target
    local function GetCooldown(source, level)
        return 20. - 0.*level
    end

    -- The Max Health bonus damage
    local function GetDamage(target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.05 + 0.*level
        else
            return 0.10 + 0.*level
        end
    end

    -- The number of attacks to apply max health damage
    local function GetAttackCount(source, level)
        return 3 - 0*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        InfernalFist = Class(Spell)

        local array = {}
        local timer = {}

        function InfernalFist:destroy()
            DestroyTimer(self.timer)
            timer[self.unit] = nil

            self.unit = nil
            self.timer = nil
        end

        function InfernalFist.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            
            if level > 0 and Damage.isEnemy then
                if not array[Damage.source.unit] then
                    array[Damage.source.unit] = {}
                end

                array[Damage.source.unit][Damage.target.unit] = (array[Damage.source.unit][Damage.target.unit] or 0) + 1

                if array[Damage.source.unit][Damage.target.unit] >= GetAttackCount(Damage.source.unit, level) then
                    array[Damage.source.unit][Damage.target.unit] = 0
                    Damage.amount = Damage.amount + (GetDamage(Damage.target.unit, level) * BlzGetUnitMaxHP(Damage.target.unit))

                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, "origin"))
                end

                if not timer[Damage.source.unit] then
                    local self = { destroy = InfernalFist.destroy }

                    self.unit = Damage.source.unit
                    self.timer = CreateTimer()
                    timer[self.unit] = self

                    AddUnitBonusTimed(Damage.source.unit, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(Damage.source.unit, level), GetDuration(Damage.source.unit, level))
                    TimerStart(self.timer, GetCooldown(Damage.source.unit, level), false, function()
                        self:destroy()
                    end)
                end
            end
        end

        function InfernalFist.onInit()
            RegisterSpell(InfernalFist.allocate(), ABILITY)
            RegisterAttackDamageEvent(InfernalFist.onDamage)
        end
    end
end)