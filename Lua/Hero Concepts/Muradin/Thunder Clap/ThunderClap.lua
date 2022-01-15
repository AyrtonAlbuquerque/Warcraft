--[[ requires SpellEffectEvent, TimedHandles
    /* --------------------- Thunder Clap v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    //     TriggerHappy   - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Thunder Clap ability
    ThunderClap_ABILITY             = FourCC('A003')
    -- The raw code of the Thunder Clap Recast ability
    ThunderClap_THUNDER_CLAP_RECAST = FourCC('A004')
    -- The raw code of the War Stomp ability
    ThunderClap_WAR_STOMP           = FourCC('A005')
    -- The model used when storm bolt refunds mana on kill
    local HEAL_EFFECT               = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
    -- The attachment point of the bonus dmaage model
    local ATTACH_POINT              = "origin"

    -- The AoE for calculating the heal
    local function GetAoE(unit, ability, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- Filter for units
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    ThunderClap = setmetatable({}, {})
    local mt = getmetatable(ThunderClap)
    mt.__index = mt
    
    function mt:onCast(source, ability, player, level)
        local group = CreateGroup()
        local heal = 0

        GroupEnumUnitsInRange(group, GetUnitX(source), GetUnitY(source), GetAoE(source, ability, level), nil)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local unit = BlzGroupUnitAt(group, i)
            if Filtered(player, unit) then
                if IsUnitType(unit, UNIT_TYPE_HERO) then
                    heal = heal + 0.1
                else
                    heal = heal + 0.025
                end
            end
        end
        DestroyGroup(group)
        SetWidgetLife(source, GetWidgetLife(source) + (BlzGetUnitMaxHP(source)*heal))
        DestroyEffectTimed(AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT), 1.0)
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ThunderClap_ABILITY, function()
            ThunderClap:onCast(Spell.source.unit, Spell.id, Spell.source.player, Spell.level)
        end)
        
        RegisterSpellEffectEvent(ThunderClap_THUNDER_CLAP_RECAST, function()
            ThunderClap:onCast(Spell.source.unit, Spell.id, Spell.source.player, Spell.level)
        end)
        
        RegisterSpellEffectEvent(ThunderClap_WAR_STOMP, function()
            ThunderClap:onCast(Spell.source.unit, Spell.id, Spell.source.player, Spell.level)
        end)
        
    end)
end