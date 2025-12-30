OnInit("Afterburner", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"
    requires.optional "Bonus"

    -- ----------------------------- Afterburner v1.7 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Afternurner Ability
    local ABILITY         = S2A('Rgn3')
    -- The raw code of the Afternurner Prox Ability
    local AFTERBURN_PROXY = S2A('Rgn6')
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE     = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC

    -- function responsible to determine the duration of the Afterburn
    -- By default, it uses the Cooldown value in the Object Editor
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
    end

    -- function responsible to determine the AoE of the Afterburn
    -- By default, it uses the AoE value in the Object Editor
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The damage per interval of the Afterburn
    local function GetDamage(unit, level)
        if Bonus then
            return 25. * level + 0.6 * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 25. * level
        end
    end

    -- The damage interval of the Afterburn
    local function GetDamageInterval(unit, level)
        return 1.
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Afterburner = Class(Spell)

        local array = {}

        function Afterburner:destroy()
            DummyRecycle(self.dummy)

            array[self.dummy] = nil

            self.unit = nil
            self.dummy = nil
        end

        function Afterburner.create(x, y, damage, duration, aoe, interval, source)
            local self = { destroy = Afterburner.destroy }
    
            self.unit = source
            self.dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            array[self.dummy] = self

            UnitAddAbility(self.dummy, AFTERBURN_PROXY)
            local skill = BlzGetUnitAbility(self.dummy, AFTERBURN_PROXY)
            BlzSetAbilityRealLevelField(skill, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(skill, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            BlzSetAbilityRealLevelField(skill, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            BlzSetAbilityRealLevelField(skill, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            IncUnitAbilityLevel(self.dummy, AFTERBURN_PROXY)
            DecUnitAbilityLevel(self.dummy, AFTERBURN_PROXY)
            IssuePointOrder(self.dummy, "flamestrike", x, y)

            TimerStart(CreateTimer(), duration + 0.05, false, function ()
                self:destroy()
                DestroyTimer(GetExpiredTimer())
            end)

            return self
        end

        function Afterburner:onTooltip(source, level, ability)
            return "|cffffcc00Ragnaros|r spells leave a trail of fire after cast that burns enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. "|r range for |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage every |cffffcc00" .. N2S(GetDamageInterval(source, level), 1) .. "|r seconds.\n\nLasts |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function Afterburner.onDamage()
            local self = array[Damage.source.unit]

            if self and Damage.amount > 0 then
                Damage.source = self.unit
            end
        end

        function Afterburner.onInit()
            RegisterSpell(Afterburner.allocate(), ABILITY)
            RegisterSpellDamageEvent(Afterburner.onDamage)
        end
    end

    function Afterburn(x, y, source)
        local level = GetUnitAbilityLevel(source, ABILITY)

        if level > 0 then
            Afterburner.create(x, y, GetDamage(source, level), GetDuration(source, level), GetAoE(source, level), GetDamageInterval(source, level), source)
        end
    end
end)