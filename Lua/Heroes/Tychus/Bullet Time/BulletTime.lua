OnInit("BulletTime", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Bullet Time v1.4 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Bullet Time ability
    local ABILITY = S2A('Tyc0')

    -- The Bullet Time duration after no attacks.
    local function GetDuration(level)
        return 5. + 0.*level
    end

    -- The Bullet Time Attack Speed bonus per attack per level
    local function GetBonus(level)
        return 0.1 + 0.*level
    end

    -- The Bullet Time Max bonus per level. Real(1. => 100%)
    local function GetMaxBonus(level)
        return 1. * level
    end

    -- The Bullet Time level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BulletTime = Class(Spell)

        local array = {}

        function BulletTime:destroy()
            DestroyTimer(self.timer)
            AddUnitBonus(self.unit, BONUS_ATTACK_SPEED, -self.bonus)
            
            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
        end

        function BulletTime:onTooltip(source, level, ability)
            return "Every attack increases the fire rate of |cffffcc00Tychus|r mini-gun by |cffffcc00" .. N2S(GetBonus(level) * 100, 0) .. "%%|r, stacking up to |cffffcc00" .. N2S(GetMaxBonus(level) * 100, 0) .. "%%|r bonus |cffffcc00Attack Speed|r. The bonus lasts for |cffffcc00" .. N2S(GetDuration(level), 1) .. "|r seconds after |cffffcc00Tychus|r stops attacking."
        end

        function BulletTime.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.isEnemy then
                local amount = GetBonus(level)
                local self = array[Damage.source.unit]

                if not self then
                    self = { destroy = BulletTime.destroy }

                    self.unit = Damage.source.unit
                    self.bonus = 0
                    self.timer = CreateTimer()
                    array[Damage.source.unit] = self
                end

                if self.bonus + amount <= GetMaxBonus(level) then
                    self.bonus = self.bonus + amount
                    AddUnitBonus(self.unit, BONUS_ATTACK_SPEED, amount)
                end

                TimerStart(self.timer, GetDuration(level), false, function ()
                    self:destroy()
                end)
            end
        end

        function BulletTime.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, ABILITY)
            end
        end

        function BulletTime.onInit()
            RegisterSpell(BulletTime.allocate(), ABILITY)
            RegisterAttackDamageEvent(BulletTime.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, BulletTime.onLevel)
        end
    end
end)