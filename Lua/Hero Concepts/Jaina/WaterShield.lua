--[[requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, DamageInterface, Missiles, Utilities, TimerUtils
    /* --------------------- Water Shield v1.1 by Chopinski --------------------- */
    -- Credits:
    --     Darkfang        - Icon
    --     Bribe           - SpellEffectEvent
    --     Vexorian        - TimerUtils
    --     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY                = FourCC('A002')
    -- The shield model
    local MODEL                  = "WaterShield.mdl"
    -- The shield attachement point
    local ATTACH                 = "origin"
    -- The explosion model
    local EXPLOSION_MODEL        = "LivingTide.mdl"
    -- The scale of the explosion model
    local EXPLOSION_SCALE        = 0.6
    -- The water bolt model
    local BOLT_MODEL             = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
    -- The water bolt scal
    local BOLT_SCALE             = 1.
    -- The water bolt speed
    local BOLT_SPEED             = 1000.

    -- The shield amount
    local function GetAmount(unit, level)
        return 100.*level + (0.5 + 0.5*level)*GetHeroInt(unit, true)
    end

    -- The water bolt damage
    local function GetBoltDamage(unit, level)
        return 25. + 25.*level
    end

    -- The range at which units can be selected by water bolt
    local function GetAoE(unit, level)
        return 400. + 0.*level
    end

    -- The aoe of the explosion when there is a remaining shield amount
    local function GetExplosionAoE(unit, level)
        return 400. + 0.*level
    end

    -- The angle in degrees at which units can be selected
    local function GetAngle(unit, level)
        return 90. + 0.*level
    end

    -- The Shield duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The unit filter
    local function UnitFilter(player, target)
        return IsUnitEnemy(target, player) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local WaterShield = setmetatable({}, {})
        local mt = getmetatable(WaterShield)
        mt.__index = mt

        local offense = {}
        local defense = {}
        local effect = {}

        function mt:allocate()
            local this = {}
            setmetatable(this, mt)
            return this
        end

        function mt:destroy()
            if self.defensive then
                defense[self.target] = nil

                if offense[self.target] == nil then
                    DestroyEffect(effect[self.target])
                    effect[self.target] = nil
                end
            else
                offense[self.target] = nil

                if defense[self.target] == nil  then
                    DestroyEffect(effect[self.target])
                    effect[self.target] = nil
                end
            end

            DestroyGroup(self.group)
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            self = nil
        end

        function mt:onExpire()
            if self.defensive and self.amount > 0 then
                GroupEnumUnitsInRange(self.group, GetUnitX(self.target), GetUnitY(self.target), self.aoe, nil)
                for i = 0, BlzGroupGetSize(self.group) - 1 do
                    local unit = BlzGroupUnitAt(self.group, i)

                    if UnitFilter(self.player, unit) then
                        UnitDamageTarget(self.source, unit, self.amount, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                    end
                end
                DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, GetUnitX(self.target), GetUnitY(self.target), 0, EXPLOSION_SCALE))
            end

            self:destroy()
        end

        onInit(function()
            RegisterSpellEffectEvent(ABILITY, function()
                local this

                if effect[Spell.target.unit] == nil then
                    effect[Spell.target.unit] = AddSpecialEffectTarget(MODEL, Spell.target.unit, ATTACH)
                end

                if IsUnitEnemy(Spell.target.unit, Spell.source.player) then
                    if offense[Spell.target.unit] then
                        this = offense[Spell.target.unit]
                    else
                        this = WaterShield:allocate()
                        this.timer = CreateTimer()
                        this.target = Spell.target.unit
                        this.group = CreateGroup()
                        this.defensive = false
                        offense[this.target] = this
                    end

                    this.source = Spell.source.unit
                    this.player = Spell.source.player
                    this.level = Spell.level
                    this.amount = GetBoltDamage(this.source, this.level)
                    this.angle = GetAngle(this.source, this.level)
                    this.aoe = GetAoE(this.source, this.level)
                else
                    if defense[Spell.target.unit] then
                        this = defense[Spell.target.unit]
                    else
                        this = WaterShield:allocate()
                        this.timer = CreateTimer()
                        this.target = Spell.target.unit
                        this.group = CreateGroup()
                        this.defensive = true
                        defense[this.target] = this
                    end

                    this.source = Spell.source.unit
                    this.player = Spell.source.player
                    this.level = Spell.level
                    this.amount = (this.amount or 0) + GetAmount(this.source, this.level)
                    this.aoe = GetExplosionAoE(this.source, this.level)
                end

                TimerStart(this.timer, GetDuration(this.source, this.level), false, function() this:onExpire() end)
            end)

            RegisterAnyDamageEvent(function()
                local damage = GetEventDamage()

                if damage > 0 and defense[Damage.target.unit] then
                    local this = defense[Damage.target.unit]

                    if damage <= this.amount then
                        this.amount = this.amount - damage
                        BlzSetEventDamage(0)
                    else
                        damage = damage - this.amount
                        this.amount = 0

                        BlzSetEventDamage(damage)
                        this:destroy()
                    end
                end
            end)

            RegisterAttackDamageEvent(function()
                if Damage.isEnemy and offense[Damage.target.unit] then
                    local this = offense[Damage.target.unit]

                    GroupEnumUnitsInRange(this.group, Damage.target.x, Damage.target.y, this.aoe, nil)
                    GroupRemoveUnit(this.group, Damage.target.unit)
                    for i = 0, BlzGroupGetSize(this.group) - 1 do
                        local unit = BlzGroupUnitAt(this.group, i)

                        if UnitFilter(this.player, unit) and IsUnitInCone(unit, Damage.target.x, Damage.target.y, this.aoe, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y)*bj_RADTODEG, this.angle) then
                            local bolt = Missiles:create(Damage.target.x, Damage.target.y, 50, GetUnitX(unit), GetUnitY(unit), 50)

                            bolt:model(BOLT_MODEL)
                            bolt:speed(BOLT_SPEED)
                            bolt:scale(BOLT_SCALE)
                            bolt.source = this.source
                            bolt.target = unit
                            bolt.damage = this.amount

                            bolt.onFinish = function()
                                if UnitAlive(bolt.target) then
                                    UnitDamageTarget(bolt.source, bolt.target, bolt.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                end

                                return true
                            end

                            bolt:launch()
                        end
                    end
                end
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
                local unit = GetTriggerUnit()

                if offense[unit] then
                    local this = offense[unit]
                    this:destroy()
                end

                if defense[unit] then
                    local this = defense[unit]
                    this:destroy()
                end
            end)
        end)
    end
end