OnInit("DoubleThunder", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Avatar"
    requires.optional "StormBolt"
    requires.optional "ThunderClap"

    -- ---------------------------------- Double Thunder v1.6 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Double Thunder ability
    local ABILITY           = S2A('Mrd0')
    -- Enable or disable double storm bolt (use to control behavior in versions v1, v2 ans v3)
    local DOUBLE_STORM_BOLT = false
    -- Auto level up
    local AUTO_LEVEL_UP     = true

    -- This updates the double thunder level at levels 10, 15 and 20
    local function GetLevel(level)
        return 5
    end

    -- The chance to proc double thunder
    local function GetDoubleChance(unit, level)
        if Avatar then
            if GetUnitAbilityLevel(unit, Avatar_BUFF) > 0 then
                return 100
            else
                return 25 * level
            end
        else
            return 25 * level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DoubleThunder = Class()

        local storm = {}
        local thunder = {}

        function DoubleThunder.onCast()
            local source = GetTriggerUnit()
            local skill = GetSpellAbilityId()
        
            if StormBolt and DOUBLE_STORM_BOLT then
                if skill == StormBolt_ABILITY then
                    if storm[source] then
                        storm[source] = false
                    elseif GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        local self = {
                            unit = source,
                            abiltiy = skill,
                            x = GetSpellTargetX(),
                            y = GetSpellTargetY(),
                            target = GetSpellTargetUnit(),
                            mana = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, skill), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(source, skill) - 1),
                            order = BlzGetAbilityStringLevelField(BlzGetUnitAbility(source, skill), ABILITY_SLF_BASE_ORDER_ID_NCL6, GetUnitAbilityLevel(source, skill) - 1)
                        }

                        storm[source] = true

                        TimerStart(CreateTimer(), 0.1, false, function()
                            BlzEndUnitAbilityCooldown(self.unit, self.abiltiy)
                            SetUnitState(self.unit, UNIT_STATE_MANA, (GetUnitState(self.unit, UNIT_STATE_MANA) + self.mana))

                            if not self.target then
                                if not IssuePointOrder(self.unit, self.order, self.x, self.y) then
                                    storm[self.unit] = false
                                end
                            else
                                if not IssueTargetOrder(self.unit, self.order, self.target) then
                                    storm[self.unit] = false
                                end
                            end

                            self = nil
                            DestroyTimer(GetExpiredTimer())
                        end)
                    end
                end
            end

            if ThunderClap then
                if skill == ThunderClap_ABILITY then
                    if thunder[source] then
                        thunder[source] = false
                    elseif GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        local self = {
                            unit = source,
                            abiltiy = skill,
                            mana = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, skill), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(source, skill) - 1),
                            order = BlzGetAbilityStringLevelField(BlzGetUnitAbility(source, skill), ABILITY_SLF_BASE_ORDER_ID_NCL6, GetUnitAbilityLevel(source, skill) - 1)
                        }

                        thunder[source] = true

                        TimerStart(CreateTimer(), 0.1, false, function()
                            BlzEndUnitAbilityCooldown(self.unit, self.abiltiy)
                            SetUnitState(self.unit, UNIT_STATE_MANA, (GetUnitState(self.unit, UNIT_STATE_MANA) + self.mana))

                            if not IssueImmediateOrder(self.unit, self.order) then
                                thunder[self.unit] = false
                            end

                            self = nil
                            DestroyTimer(GetExpiredTimer())
                        end)
                    end
                end
            end
        end

        function DoubleThunder.onLevel()
            local source = GetTriggerUnit()
            local level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 and level < BlzGetAbilityIntegerField(BlzGetUnitAbility(source, ABILITY), ABILITY_IF_LEVELS) then
                if ModuloInteger(GetHeroLevel(source), GetLevel()) == 0 and GetHeroLevel(source) >= 10 then
                   IncUnitAbilityLevel(source, ABILITY)
                end
            end
        end
        
        function DoubleThunder.onInit()
            if AUTO_LEVEL_UP then
                RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, DoubleThunder.onLevel)
            end

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, DoubleThunder.onCast)
        end
    end
end)