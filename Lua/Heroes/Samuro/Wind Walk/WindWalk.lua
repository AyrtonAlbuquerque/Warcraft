OnInit("WindWalk", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------ Wind Walk v1.3 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Wind Walk ability
    WindWalk_ABILITY = S2A('Smr9')
    -- The raw code of the Wind Walk buff
    local BUFF       = S2A('BOwk')

    -- The health regeneration bonus
    local function GetRegenBonus(level)
        return 15. + 5.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        WindWalk = Class(Spell)

        function WindWalk:onTooltip(source, level, ability)
            return "Allows |cffffcc00Samuro|r to become invisible, and move |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_OWK2, level -1) * 100, 0) .. "%%|r faster for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, level -1), 1) .. "|r seconds. While invisible, |cffffcc00Samuro|r has |cff00ff00" .. N2S(GetRegenBonus(level), 0) .. "|r increased |cff00ff00Health Regeneration|r. When |cffffcc00Samuro|r attacks a unit to break invisibility, he will hit a |cffffcc00Critical Strike|r with |cffffcc00100%|r bonus |cffffcc00Critical Damage|r and |cffff0000" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_BACKSTAB_DAMAGE, level -1), 0) .. "|r bonus damage on that attack."
        end

        function WindWalk:onCast()
            LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH_REGEN, GetRegenBonus(Spell.level), BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_CRITICAL_CHANCE, 1, BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_CRITICAL_DAMAGE, 1, BUFF)
        end

        function WindWalk.onInit()
            RegisterSpell(WindWalk.allocate(), WindWalk_ABILITY)
        end
    end
end)