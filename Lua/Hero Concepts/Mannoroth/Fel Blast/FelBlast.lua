--[[ requires SpellEffectEvent, Utilities optional FelBeam
    /* ----------------------- Fel Blast v1.4 by Chopinski ---------------------- */
    // Credits:
    //     Vexorian - TimerUtils Library
    //     Bribe    - SpellEffectEvent
    //     Mythic   - Nther Blast model
    //     san      - Miasma icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the fel blast ability
    local ABILITY     = FourCC('A002')
    -- The amount of time it takes to do the damage
    local BLAST_DELAY   = 0.75
    -- The blast model
    local BLAST_MODEL   = "NetherBlast.mdx"
    -- The size of the blast model
    local BLAST_SCALE   = 1.
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE   = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC

    -- The damage amount of the blast
    local function GetDamage(unit, level)
        return 50.*level + GetHeroStr(unit, true)*(1 + 0.25*level)
    end

    -- The damage area of effect. By default is the ability AoE field in the editor
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The filter for units that will be damaged by the fel blast
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local x = Spell.x
            local y = Spell.y
            local player = Spell.source.player
            local damage = GetDamage(unit, Spell.level)
            local radius = GetAoE(unit, Spell.level)
            local armor
            local duration

            if FelBeam then
                armor = FelBeam_GetArmorReduction(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
                duration = FelBeam_GetCurseDuration(GetUnitAbilityLevel(unit, FelBeam_ABILITY))
            end
        
            DestroyEffect(AddSpecialEffectEx(BLAST_MODEL, x, y, 0, BLAST_SCALE))
            TimerStart(timer, BLAST_DELAY, false, function()
                local group = GetEnemyUnitsInRange(player, x, y, radius, false, false)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if DamageFilter(player, u) then
                        if FelBeam then
                            FelBeam.source[u] = unit
                            Curse.cursed[u] = true
                            Curse:create(u, duration, armor)
                        end
                        UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                    end
                end
                DestroyGroup(group)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end)
end