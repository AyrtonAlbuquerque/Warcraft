OnInit("Avatar", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"

    -- -------------------------------- Avatar v1.5 by Chopinski ------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Avatar ability
    Avatar_ABILITY = S2A('Mrd5')
    -- The raw code of the Avatar buff
    Avatar_BUFF    = S2A('BHav')

    -- The Health Bonus
    local function GetBonusHealth(level)
        return 500 + 500*level
    end

    -- The Damage Bonus
    local function GetBonusDamage(source, level)
        return 50 * level + R2I(BlzGetUnitMaxHP(source) * 0.01 * level)
    end

    -- The Armor Bonus
    local function GetBonusArmor(level)
        return 10*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Avatar = Class(Spell)

        function Avatar:onTooltip(source, level, ability)
            return "When activated, |cffffcc00Muradin|r gains |cffff0000" .. N2S(GetBonusDamage(source, level), 0) .. " Damage|r, |cff00ff00" .. N2S(GetBonusHealth(level), 0) .. " Health|r, |cff808080" .. N2S(GetBonusArmor(level), 0) .. " Armor|r and becomes immune to |cff00ffffMagic|r. While in |cffffcc00Avatar|r form, |cffffcc00Double Thunder|r has |cffffcc00100%%|r of occuring."
        end

        function Avatar:onCast()
            LinkBonusToBuff(Spell.source.unit, BONUS_DAMAGE, GetBonusDamage(Spell.source.unit, Spell.level), Avatar_BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH, GetBonusHealth(Spell.level), Avatar_BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, GetBonusArmor(Spell.level), Avatar_BUFF)
        end

        function Avatar.onInit()
            RegisterSpell(Avatar.allocate(), Avatar_ABILITY)
        end
    end
end)