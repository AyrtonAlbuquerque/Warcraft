--[[ requires SpellEffectEvent, PluginSpellEffect, Missiles, NewBonusUtils, TimerUtils
    /* ---------------------- Eagle's Eye v1.0 by Chopinksi --------------------- */
    -- Credits: SkriK
    --     SkriK           - Icon
    --     Bribe           - SpellEffectEvent
    --     Vexorian        - TimerUtils
    --     Vinz            - Blind and Death models
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY = FourCC('A004')
    -- The missile model
    local MODEL = "Eagle.mdl"
    -- The missile scale
    local SCALE = 0.6
    -- The model used for the blind effect
    local BLIND_MODEL = "Burning Rage Red.mdl"
    -- The blind model attachment point
    local ATTACH = "overhead"
    -- The model used when the eagle hits its target
    local DEATH_MODEL = "Ephemeral Slash Silver.mdl"
    -- The death model scale
    local DEATH_SCALE = 1.5
    -- The missile speed
    local SPEED = 1200
    -- The missile final height
    local HEIGHT = 350
    -- The eagle search period
    local PERIOD = 0.5

    -- The amount of vision granted while the missile travels and the aoe used to detect units
    local function GetVisionRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The amount of damage dealt when single target
    local function GetDamage(unit, level)
        return 100. + 50. * level
    end

    -- The
    local function GetAoE(unit, level)
        return 250. + 50. * level
    end

    -- The amount of damage dealt when targeted at the ground
    local function GetAoEDamage(unit, level)
        return 50. * level
    end

    -- The amount of vision reduced
    local function GetVisionReduction(unit, level)
        return 1400. + 100. * level
    end

    -- The duration of the vision debuff
    local function GetReductionDuraiton(unit, level)
        return 5. + 0. * level
    end

    -- The duration that the ealge will stay in place searching
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The unit detection filter
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- The unit damage filter
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this

            if Spell.target.unit == nil then
                this = Missiles:create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, HEIGHT)
                this.targeted = false
                this.aoe = GetAoE(Spell.source.unit, Spell.level)
                this.damage = GetAoEDamage(Spell.source.unit, Spell.level)
            else
                this = Missiles:create(Spell.source.x, Spell.source.y, 50, Spell.target.x, Spell.target.y, 50)
                this.targeted = true
                this.target = Spell.target.unit
                this.damage = GetDamage(Spell.source.unit, Spell.level)
            end

            this:model(MODEL)
            this:scale(SCALE)
            this:speed(SPEED)
            this.source = Spell.source.unit
            this.owner = Spell.source.player
            this.level = Spell.level
            this:vision(GetVisionRange(this.source, this.level))
            this.time = GetReductionDuraiton(this.source, this.level)
            this.reduction = GetVisionReduction(this.source, this.level)
            this.timeout = GetDuration(this.source, this.level)
            this.group = CreateGroup()

            this.onFinish = function()
                if this.target == nil then
                    local timer = CreateTimer()

                    this:pause(true)
                    TimerStart(timer, PERIOD, true, function()
                        if this.timeout > 0 then
                            GroupEnumUnitsInRange(this.group, this.x, this.y, this.Vision, nil)
                            for i = 0, BlzGroupGetSize(this.group) - 1 do
                                local unit = BlzGroupUnitAt(this.group, i)
                                if UnitFilter(this.owner, unit) then
                                    this:deflect(GetUnitX(unit), GetUnitY(unit), 50)
                                    this.target = unit
                                    this:pause(false)
                                    PauseTimer(timer)
                                    DestroyTimer(timer)
                                    break
                                end
                            end
                            this.timeout = this.timeout - PERIOD
                        else
                            PauseTimer(timer)
                            DestroyTimer(timer)
                            this:terminate()
                        end
                    end)

                    return false
                else
                    if this.targeted then
                        if UnitAlive(this.target) then
                            if UnitDamageTarget(this.source, this.target, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                if UnitAlive(this.target) then
                                    AddUnitBonus(this.target, BONUS_SIGHT_RANGE, -this.reduction, this.time)
                                    DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, this.target, ATTACH), this.time)
                                end
                            end
                        end
                    else
                        GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                        for i = 0, BlzGroupGetSize(this.group) - 1 do
                            local unit = BlzGroupUnitAt(this.group, i)
                            if DamageFilter(this.owner, unit) then
                                if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    if UnitAlive(unit) then
                                        AddUnitBonus(unit, BONUS_SIGHT_RANGE, -this.reduction, this.time)
                                        DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, unit, ATTACH), this.time)
                                    end
                                end
                            end
                        end
                        DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, this.x, this.y, 50, DEATH_SCALE))
                    end
                    this:alpha(0)

                    return true
                end
            end

            this.onRemove = function()
                DestroyGroup(this.group)
            end

            this:launch()
        end)
    end)
end