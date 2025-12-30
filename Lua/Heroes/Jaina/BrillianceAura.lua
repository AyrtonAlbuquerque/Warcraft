OnInit("BrillanceAura", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- --------------------------- Brilliance Aura v1.2 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = S2A('Jna3')
    -- If true the bonus regen will stack with each cast
    local STACK   = false

    -- The bonus mana regen when an ability is cast
    local function GetBonusManaRegen(unit, level)
        return 1.5 * level
    end

    -- The duration of the bonus regen
    local function GetDuration(unit, level)
        return 2.5 * level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BrillianceAura = Class(Spell)

        local array = {}

        function BrillianceAura:destroy()
            DestroyTimer(self.timer)

            for i = 0, self.levels - 1 do
                BlzSetAbilityRealLevelField(self.ability, self.field, i, BlzGetAbilityRealLevelField(self.ability, self.field, i) - self.bonus)
                IncUnitAbilityLevel(self.unit, ABILITY)
                DecUnitAbilityLevel(self.unit, ABILITY)
            end

            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.field = nil
            self.ability = nil
        end

        function BrillianceAura:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r gives additional |cff00ffff" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_MANA_REGENERATION_INCREASE, level - 1), 1) .. "|r |cff00ffffMana Regeneration|r to nearby friendly units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r. When she casts an ability the bonus |cff00ffffMana Regeneration|r is increased by |cff00ffff" .. N2S(GetBonusManaRegen(source, level), 1) .. "|r for a |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function BrillianceAura.onSpell()
            local source = GetTriggerUnit()
            local level = GetUnitAbilityLevel(source, ABILITY)
            local self

            if level > 0 then
                if STACK then
                    self = { destroy = BrillianceAura.destroy }

                    self.unit = source
                    self.timer = CreateTimer()
                    self.field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                    self.ability = BlzGetUnitAbility(source, ABILITY)
                    self.levels = BlzGetAbilityIntegerField(self.ability, ABILITY_IF_LEVELS)
                    self.bonus = GetBonusManaRegen(source, level)

                    for i = 0, self.levels - 1 do
                        BlzSetAbilityRealLevelField(self.ability, self.field, i, BlzGetAbilityRealLevelField(self.ability, self.field, i) + self.bonus)
                        IncUnitAbilityLevel(source, ABILITY)
                        DecUnitAbilityLevel(source, ABILITY)
                    end
                else
                    self = array[source]

                    if not self then
                        self = { destroy = BrillianceAura.destroy }

                        self.bonus = 0
                        self.unit = source
                        self.timer = CreateTimer()
                        self.field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                        self.ability = BlzGetUnitAbility(source, ABILITY)
                        self.levels = BlzGetAbilityIntegerField(self.ability, ABILITY_IF_LEVELS)
                        array[source] = self
                    end
                    
                    if (self.bonus or 0) == 0 then
                        self.bonus = GetBonusManaRegen(source, level)

                        for i = 0, self.levels - 1 do
                            BlzSetAbilityRealLevelField(self.ability, self.field, i, BlzGetAbilityRealLevelField(self.ability, self.field, i) + self.bonus)
                            IncUnitAbilityLevel(source, ABILITY)
                            DecUnitAbilityLevel(source, ABILITY)
                        end
                    end
                end

                TimerStart(self.timer, GetDuration(source, level), false, function ()
                    self:destroy()
                end)
            end
        end

        function BrillianceAura.onInit()
            RegisterSpell(BrillianceAura.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, BrillianceAura.onSpell)
        end
    end
end)    