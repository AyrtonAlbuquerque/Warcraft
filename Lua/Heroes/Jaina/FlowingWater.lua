OnInit("FlowingWater", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Flowing Water v1.0 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = S2A('Jna4')
    -- The effect model
    local EFFECT  = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
    -- The effect model attach point
    local ATTACH  = "origin"

    -- The trigger chance
    local function GetChance(source, level)
        return 0.2 + 0.1 * level
    end

    -- The reduction percentage
    local function GetReduction(source, level)
        return 0.4 + 0.1 * level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        FlowingWater = Class(Spell)

        function FlowingWater:onTooltip(source, level, ability)
            return "When casting an |cffffcc00Active|r ability |cffffcc00Jaina|r has |cffffcc00" .. N2S(GetChance(source, level) * 100, 0) .. "%%|r chance to reduce the casted ability cooldown by |cffffcc00" .. N2S(GetReduction(source, level) * 100, 0) .. "%%|r."
        end

        function FlowingWater.onSpell()
            local level = GetUnitAbilityLevel(Spell.source.unit, ABILITY)

            if level > 0 then
                if GetRandomReal(0, 1) <= GetChance(Spell.source.unit, level) then
                    if Spell.cooldown > 0 then
                        DestroyEffect(AddSpecialEffectTarget(EFFECT, Spell.source.unit, ATTACH))
                        StartUnitAbilityCooldown(Spell.source.unit, Spell.id, (1 - GetReduction(Spell.source.unit, level)) * Spell.cooldown)
                    end
                end
            end
        end

        function FlowingWater.onInit()
            RegisterSpell(FlowingWater.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, FlowingWater.onSpell)
        end
    end
end)