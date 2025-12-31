OnInit("WildBond", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------ Wild Bond v1.2 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Wild Bond Ability
    local ABILITY       = S2A('Rex9')
    -- The raw code of the Rexxar unit in the editor
    local REXXAR_ID     = S2A('Rexr')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Rexxar will gain Wild Bond at this level
    local GAIN_AT_LEVEL = 20
    -- The updating period
    local PERIOD        = 1.

    -- The bonus damage per unit alive
    local function GetBonusDamage(level)
        return 20. * level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        WildBond = Class(Spell)

        local array = {}

        function WildBond:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)

            array[self.unit] = nil

            self.unit = nil
            self.group = nil
            self.timer = nil
            self.player = nil
        end

        function WildBond:update()
            self.bonus = 0

            GroupEnumUnitsOfPlayer(self.group, self.player, nil)
            
            local u = FirstOfGroup(self.group)

            while u do
                if UnitAlive(u) and GetUnitAbilityLevel(u, S2A('Aloc')) == 0 and not IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    self.bonus = self.bonus + GetBonusDamage(GetUnitAbilityLevel(u, ABILITY))
                end
            end

            AddUnitBonus(self.unit, BONUS_DAMAGE, self.bonus)
        end

        function WildBond.create(source)
            local self = array[source]

            if not self then
                self = { destroy = WildBond.destroy }

                self.unit = source
                self.group = CreateGroup()
                self.timer = CreateTimer()
                self.player = GetOwningPlayer(source)

                array[source] = self

                self:update()
                TimerStart(self.timer, PERIOD, true, function ()
                    if GetUnitAbilityLevel(self.unit, ABILITY) > 0 then
                        AddUnitBonus(self.unit, BONUS_DAMAGE, -(self.bonus or 0))
                        self:update()
                    else
                        self:destroy()
                    end
                end)
            end

            return self
        end

        function WildBond:onLearn(source, skill, level)
            WildBond.create(source)
        end

        function WildBond.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == REXXAR_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                    WildBond.create(unit)
                end
            end
        end

        function WildBond.onInit()
            RegisterSpell(WildBond.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, WildBond.onLevelUp)
        end
    end
end)