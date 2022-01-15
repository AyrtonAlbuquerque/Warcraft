--[[ requires RegisterPlayerUnitEvent, TimerUtils, Indexer, NewBonus
    /* ----------------------- Wild Bond v1.0 by Chopinski ---------------------- */
    -- Credits:
    --     Nyx-Studio      - Icon
    --     Magtheridon96  - RegisterPlayerUnitEvent
    --     Vexorian       - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Wild Bond Ability
    local ABILITY = FourCC('A006')
    -- The raw code of the Rexxar unit in the editor
    local REXXAR_ID = FourCC('O000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Rexxar will gain Wild Bond at this level
    local GAIN_AT_LEVEL = 20
    -- The updating period
    local PERIOD = 1.

    -- The bonus damage per unit alive
    local function GetBonusDamage(level)
        return 20. * level
    end
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    WildBond = setmetatable({}, {})
    local mt = getmetatable(WildBond)
    mt.__index = mt

    local struct = {}

    function mt:update()
        self.bonus = 0
        GroupEnumUnitsOfPlayer(self.group, self.player, nil)
        for i = 0, BlzGroupGetSize(self.group) - 1 do
            local unit = BlzGroupUnitAt(self.group, i)
            if UnitAlive(unit) and GetUnitAbilityLevel(unit, FourCC('Aloc')) == 0 and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_HERO) then
                self.bonus = self.bonus + GetBonusDamage(GetUnitAbilityLevel(self.unit, ABILITY))
            end
        end
        AddUnitBonus(self.unit, BONUS_DAMAGE, self.bonus)
    end

    function mt:create(unit, ability)
        local this = nil

        if ability == ABILITY and not struct[unit] then
            this = {}
            setmetatable(this, mt)

            this.timer = CreateTimer()
            this.group = CreateGroup()
            this.player = GetOwningPlayer(unit)
            this.unit = unit
            this.bonus = 0
            struct[unit] = this

            this:update()
            TimerStart(this.timer, PERIOD, true, function()
                if GetUnitAbilityLevel(this.unit, ABILITY) then
                    AddUnitBonus(this.unit, BONUS_DAMAGE, -this.bonus)
                    this:update()
                else
                    PauseTimer(this.timer)
                    DestroyTimer(this.timer)
                    DestroyGroup(this.group)
                    struct[this.unit] = nil
                end
            end)
        end

        return this
    end

    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()

            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == REXXAR_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                    WildBond:create(unit, ABILITY)
                end
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            WildBond:create(GetLearningUnit(), GetLearnedSkill())
        end)
    end)
end