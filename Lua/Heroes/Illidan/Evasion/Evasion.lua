OnInit("Evade", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Evasion"
    requires "Utilities"

    -- -------------------------------- Evade v1.3 by Chopinski -------------------------------- --
    
    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Evasion ability
    local ABILITY = S2A('Idn6')
    -- The raw code of the Evasion buff
    local BUFF    = S2A('BId2')

    -- The Evasion bonus per level
    local function GetPassiveBonus(level)
        if level == 1 then
            return 10.
        else
            return 5.
        end
    end

    -- The Evasion bonus on cast
    local function GetActiveBonus(level)
        return 100.
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Evade = Class(Spell)

        function Evade:onTooltip(unit, level, ability)
            return "|cffffcc00Illidan|r has |cffffcc00" .. N2S(5 + 5 * level, 0) .. "%%|r passively increased chance to avoid enemy attacks. When activated his |cffffcc00Evasion|r chance is increased by |cffffcc00" .. N2S(GetActiveBonus(level) * 100, 0) .. "%%|r for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, level - 1), 1) .. "|r seconds."
        end

        function Evade:onLearn(unit, ability, level)
            AddUnitBonus(unit, BONUS_EVASION_CHANCE, GetPassiveBonus(level))
        end

        function Evade:onCast()
            LinkBonusToBuff(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), BUFF)
        end

        function Evade.onInit()
            RegisterSpell(Evade.allocate(), ABILITY)
        end
    end
end)