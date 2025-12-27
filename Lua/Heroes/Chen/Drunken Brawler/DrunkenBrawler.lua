OnInit("DrunkenBrawler", function(requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"

    -- --------------------------- Drunken Brawler v1.3 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Drunken Brawler ability
    local ABILITY = S2A('Chn8')

    -- The Evasion bonus
    local function GetEvasionBonus(level)
        return 0.07 + 0.*level
    end

    -- The Critical chance bonus
    local function GetCriticalChanceBonus(level)
        return 0.05 + 0.*level
    end

    -- The Critical damage bonus
    local function GetCriticalDamageBonus(level)
        return 0.075 + 0.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DrunkenBrawler = Class(Spell)

        function DrunkenBrawler:onTooltip(unit, level, abiltiy)
            return "|cffffcc00Chen|r has |cffffcc00" .. N2S(GetEvasionBonus(level) * 100 * level, 1) .. "%%|r chance to dodge attacks and have increased |cffffcc00" .. N2S(GetCriticalChanceBonus(level) * 100 * level, 1) .. "%%|r |cffffcc00Critical Strike Chance|r and |cffffcc00" .. N2S(GetCriticalDamageBonus(level) * 100 * level, 1) .. "%%|r |cffffcc00Critical Strike Damage|r."
        end

        function DrunkenBrawler:onLearn(unit, ability, level)
            AddUnitBonus(unit, BONUS_EVASION_CHANCE, GetEvasionBonus(level))
            AddUnitBonus(unit, BONUS_CRITICAL_CHANCE, GetCriticalChanceBonus(level))
            AddUnitBonus(unit, BONUS_CRITICAL_DAMAGE, GetCriticalDamageBonus(level))
        end

        function DrunkenBrawler.onInit()
            RegisterSpell(DrunkenBrawler.allocate(), ABILITY)
        end
    end
end)