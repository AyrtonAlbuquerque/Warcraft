--[[ requires RegisterPlayerUnitEvent, TimerUtils
    /* -------------------- Brilliance Aure v1.1 by Chopinski ------------------- */
    // Credits
    //      Vexorian         - TimerUtils
    //      Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY    = FourCC('A003')
    -- If true the bonus regen will stack with each cast
    local STACK      = false

    -- The bonus mana regen when an ability is cast
    local function GetBonusManaRegen(unit, level)
        return 1.5 * level
    end

    -- The duration of the bonus regen
    local function GetDuration(unit, level)
        return 2.5 * level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local BrillianceAura = setmetatable({}, {})
        local mt = getmetatable(BrillianceAura)
        mt.__index = mt

        local struct = {}

        function mt:allocate()
            local this = {}
            setmetatable(this, mt)
            return this
        end

        function mt:onExpire()
            for i = 0, self.levels - 1 do
                BlzSetAbilityRealLevelField(self.ability, self.field, i, BlzGetAbilityRealLevelField(self.ability, self.field, i) - self.bonus)
                IncUnitAbilityLevel(self.unit, ABILITY)
                DecUnitAbilityLevel(self.unit, ABILITY)
            end

            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            struct[self.unit] = nil
            self = nil
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
                local unit = GetTriggerUnit()
                local level = GetUnitAbilityLevel(unit, ABILITY)
                local this

                if level > 0 then
                    if STACK then
                        this = BrillianceAura:allocate()
                        this.timer = CreateTimer()
                        this.unit = unit
                        this.field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                        this.ability = BlzGetUnitAbility(unit, ABILITY)
                        this.levels = BlzGetAbilityIntegerField(this.ability, ABILITY_IF_LEVELS)
                        this.bonus = GetBonusManaRegen(unit, level)

                        for i = 0, this.levels - 1 do
                            BlzSetAbilityRealLevelField(this.ability, this.field, i, BlzGetAbilityRealLevelField(this.ability, this.field, i) + this.bonus)
                            IncUnitAbilityLevel(unit, ABILITY)
                            DecUnitAbilityLevel(unit, ABILITY)
                        end
                    else
                        if struct[unit] then
                            this = struct[unit]
                        else
                            this = BrillianceAura:allocate()
                            this.timer = CreateTimer()
                            this.unit = unit
                            this.field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                            this.ability = BlzGetUnitAbility(unit, ABILITY)
                            this.levels = BlzGetAbilityIntegerField(this.ability, ABILITY_IF_LEVELS)
                            this.bonus = 0
                            struct[unit] = this
                        end

                        if this.bonus == 0 then
                            this.bonus = GetBonusManaRegen(unit, level)

                            for i = 0, this.levels - 1 do
                                BlzSetAbilityRealLevelField(this.ability, this.field, i, BlzGetAbilityRealLevelField(this.ability, this.field, i) + this.bonus)
                                IncUnitAbilityLevel(unit, ABILITY)
                                DecUnitAbilityLevel(unit, ABILITY)
                            end
                        end
                    end

                    TimerStart(this.timer, GetDuration(unit, level), false, function() this:onExpire() end)
                end
            end)
        end)
    end
end