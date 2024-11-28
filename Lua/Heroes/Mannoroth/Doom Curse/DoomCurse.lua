--[[ requires requires DamageInterface, TimerUtils, SpellEffectEvent, PluginSpellEffect, NewBonus
    /* ---------------------- Doom Curse v1.4 by Chopinski --------------------- */
    // Credits:
    //     marilynmonroe - Pit Infernal model
    //     Mr.Goblin     - Inferno icon
    //     Vexorian      - TimerUtils Library
    //     Mytich        - Soul Armor Spring.mdx
    //     Bribe         - SpellEffectEvent Library
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Doom Curse ability
    local ABILITY     = FourCC('A004')
    -- The raw code of the Doom Curse buff
    local CURSE_BUFF  = FourCC('B001')
    -- The raw code of the unit created
    local UNIT_ID     = FourCC('n001')
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE = DAMAGE_TYPE_MAGIC

    -- The damage dealt per interval
    local function GetDamage(level)
        return 125.*level
    end

    -- The interval at which the damage is dealt
    local function GetInterval(level)
        return 1. + 0.*level
    end

    -- The damage amplification cursed units take from caster
    local function GetAmplification(level)
        return 1.1 + 0.2*level
    end

    -- The Pit Infernal base damage
    local function GetBaseDamage(unit, level)
        return R2I(50*level + GetUnitBonus(unit, BONUS_DAMAGE)*0.5)
    end

    -- The Pit Infernal base health
    local function GetHealth(unit, level)
        return R2I(1000 + 500*level + BlzGetUnitMaxHP(unit)*0.5)
    end

    -- The Pit Infernal base armor
    local function GetArmor(unit, level)
        return 10.*level + GetUnitBonus(unit, BONUS_ARMOR)
    end

    -- The Pit Infernal duration. By default is the ability summoned unit duration field. If 0 the unit will last forever.
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_SUMMONED_UNIT_DURATION_SECONDS_NDO3, level - 1)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local source = {}
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local level = Spell.level
            local target = Spell.target.unit
            local damage = GetDamage(Spell.level)
            source[target] = unit

            TimerStart(timer, GetInterval(Spell.level), true, function()
                if GetUnitAbilityLevel(target, CURSE_BUFF) > 0 then
                    UnitDamageTarget(unit, target, damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                else
                    source[target] = nil
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end
            end)
        end)
        
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
            local cursed = GetUnitAbilityLevel(Damage.target.unit, CURSE_BUFF) > 0
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if cursed and damage > 0 then
                if source[Damage.target.unit] == Damage.source.unit then
                    damage = damage*GetAmplification(level)
                    BlzSetEventDamage(damage)
                end

                if damage >= GetWidgetLife(Damage.target.unit) and source[Damage.target.unit] then
                    local unit = CreateUnit(GetOwningPlayer(source[Damage.target.unit]), UNIT_ID, Damage.target.x, Damage.target.y, 0.)
                    SetUnitAnimation(unit, "Birth")
                    BlzSetUnitBaseDamage(unit, GetBaseDamage(source[Damage.target.unit], level), 0)
                    BlzSetUnitMaxHP(unit, GetHealth(source[Damage.target.unit], level))
                    BlzSetUnitArmor(unit, GetArmor(source[Damage.target.unit], level))
                    SetUnitLifePercentBJ(unit, 100)
                    if GetDuration(source[Damage.target.unit], level) > 0 then
                        UnitApplyTimedLife(unit, FourCC('BTLF'), GetDuration(source[Damage.target.unit], level))
                    end
                end
            end
        end)
    end)
end