--[[ requires SpellEffectEvent, Utilities, Missiles, optional BlackArrow
    /* ---------------------- ArrowStorm v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Bribe        - SpellEffectEvent
    //     Deathclaw24  - Arrow Storm Icon
    //     AZ           - Black Arrow model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Arrow Storm ability
    local ABILITY           = FourCC('A00H')
    -- The normal arrow model
    local ARROW_MODEL       = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
    -- The cursed arrow model
    local CURSE_ARROW_MODEL = "BlackArrow.mdl"
    -- The arrow size
    local ARROW_SCALE       = 1.3
    -- The arrow speed
    local ARROW_SPEED       = 1500.
    -- The arrow arc in degrees
    local ARROW_ARC         = 30.
    -- The attack type of the damage dealt
    local ATTACK_TYPE       = ATTACK_TYPE_NORMAL  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE       = DAMAGE_TYPE_MAGIC

    -- The number of arrows launched per level
    local function GetArrowCount(level)
        return 20 + 5*level
    end

    -- The damage each arrow deals
    local function GetDamage(level)
        return 25. + 25.*level
    end

    -- The Lauch AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The arrow impact AoE
    local function GetArrowAoE(level)
        return 75.
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local aoe = GetAoE(Spell.source.unit, Spell.level)

            for i = 0, GetArrowCount(Spell.level) - 1 do
                local radius = GetRandomRange(aoe)
                local this = Missiles:create(Spell.source.x, Spell.source.y, 85, GetRandomCoordInRange(Spell.x, radius, true), GetRandomCoordInRange(Spell.y, radius, false), 0)
                
                this.source = Spell.source.unit
                this.owner = Spell.source.player
                this.damage = GetDamage(Spell.level)
                this.aoe = GetArrowAoE(Spell.level)
                this:speed(ARROW_SPEED)
                this:arc(ARROW_ARC)

                if BlackArrow then
                    this.level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                    if BlackArrow.active[Spell.source.unit] then
                        this:model(CURSE_ARROW_MODEL)
                        this.curse = true
                        this.ability = BlackArrow_BLACK_ARROW_CURSE
                        this.curse_duration = BlackArrow_GetCurseDuration(level)
                    else    
                        this:model(ARROW_MODEL)
                        this.curse = false
                    end
                else
                    this:model(ARROW_MODEL)
                    this.curse = false
                end
                this:scale(ARROW_SCALE)

                this.onFinish = function()
                    local group = CreateGroup()

                    GroupEnumUnitsInRange(group, this.x, this.y, this.aoe, null)
                    for i = 0, BlzGroupGetSize(group) - 1 do
                        local unit = BlzGroupUnitAt(group, i)
                        if Filtered(this.owner, unit) then
                            if this.curse then
                                UnitAddAbilityTimed(unit, this.ability, this.curse_duration, this.level, true)
                            end
                            UnitDamageTarget(this.source, unit, this.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                        end
                    end
                    DestroyGroup(group)

                    return true
                end

                this:launch()
            end
        end)
    end)
end