--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, MouseUtils
    /* ---------------------- Living Tide v1.0 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     MyPad           - MouseUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY    = FourCC('A004')
    -- The Living Tide model
    local MODEL      = "LivingTide.mdl"
    -- The Living Tide scale
    local SCALE      = 1.
    -- The Living Tide speed
    local SPEED      = 550.
    -- The update period
    local PERIOD     = 0.03125000

    -- The amount of damage dealt in a second
    local function GetDamagePerSecond(unit, level)
        return 100. * level
    end

    -- The living tide collision size
    local function GetCollision(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The living tide sight range
    local function GetVisionRange(unit, level)
        return 1000. + 0.*level
    end

    -- The base mana cost per second
    local function GetBaseManaCostPerSecond(unit, level)
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_ILF_MANA_COST, level - 1)
    end

    -- The range step to change the amount of mana consumed
    local function GetManaCostRangeIncrement(unit, level)
        return 100.
    end

    -- The mana cost amount per range increment
    local function GetManaCostPerIncrement(unit, level)
        return 5.
    end

    -- The unit filter for damage
    local function UnitFilter(player, target)
        return UnitAlive(target) and IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local LivingTide = setmetatable({}, {})
        local mt = getmetatable(LivingTide)
        mt.__index = mt

        local timer = CreateTimer()
        local key = 0
        local array = {}
        local struct = {}

        function mt:allocate()
            local this = {}
            setmetatable(this, mt)
            return this
        end

        function mt:remove(i)
            self.tide:terminate()

            array[i] = array[key]
            key = key - 1

            if key == 0 then
                PauseTimer(timer)
            end

            self = nil

            return i - 1
        end

        onInit(function()
            RegisterSpellEffectEvent(ABILITY, function()
                if struct[Spell.source.unit] == nil then
                    local this = LivingTide:allocate()

                    this.unit = Spell.source.unit
                    this.player = Spell.source.player
                    this.level = Spell.level
                    this.mana = GetBaseManaCostPerSecond(this.unit, this.level)
                    this.range = GetManaCostRangeIncrement(this.unit, this.level)
                    this.step = GetManaCostPerIncrement(this.unit, this.level)
                    key = key + 1
                    array[key] = this
                    struct[this.unit] = this
                    this.tide = Missiles:create(Spell.x, Spell.y, 0, Spell.source.x, Spell.source.y, 0)

                    this.tide:model(MODEL)
                    this.tide:scale(SCALE)
                    this.tide:speed(SPEED)
                    this.tide.source = this.unit
                    this.tide.owner = this.player
                    this.tide:vision(GetVisionRange(this.unit, this.level))
                    this.tide.damage = GetDamagePerSecond(this.unit, this.level) / (1/0.025)
                    this.tide.collision = GetCollision(this.unit, this.level)

                    this.tide.onHit = function(unit)
                        if UnitFilter(this.tide.owner, unit) then
                            if UnitDamageTarget(this.tide.source, unit, this.tide.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                this.tide:flush(unit)
                            end
                        end

                        return false
                    end

                    this.tide.onFinish = function()
                        this.tide:pause(true)
                        return false
                    end

                    this.tide:launch()

                    if key == 1 then
                        TimerStart(timer, PERIOD, true, function()
                            local i = 1
                            local this

                            while i <= key do
                                this = array[i]

                                if struct[this.unit] then
                                    local x = GetUnitX(this.unit)
                                    local y = GetUnitY(this.unit)
                                    local cost = (this.mana + this.step*(DistanceBetweenCoordinates(x, y, this.tide.x, this.tide.y)/this.range)) * PERIOD

                                    if cost > GetUnitState(this.unit, UNIT_STATE_MANA) then
                                        IssueImmediateOrder(this.unit, "stop")
                                        struct[this.unit] = nil
                                        i = this:remove(i)
                                    else
                                        AddUnitMana(this.unit, -cost)
                                        this.tide:deflect(GetPlayerMouseX(this.player), GetPlayerMouseY(this.player), 0)
                                        BlzSetUnitFacingEx(this.unit, AngleBetweenCoordinates(x, y, this.tide.x, this.tide.y)*bj_RADTODEG)

                                        if this.tide.paused then
                                            this.tide:pause(false)
                                        end
                                    end
                                else
                                    i = this:remove(i)
                                end
                                i = i + 1
                            end
                        end)
                    end
                end
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
                if GetSpellAbilityId() == ABILITY then
                    struct[GetTriggerUnit()] = nil
                end
            end)
        end)
    end
end