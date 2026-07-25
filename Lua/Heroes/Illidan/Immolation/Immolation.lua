OnInit("Immolation", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------ Immolation v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Immolation ability
    local ABILITY      = S2A('Idn2')
    -- The immolation damage period
    local PERIOD       = 1.
    -- The immolation model
    local MODEL        = "Ember Green.mdl"
    -- The immolation Damage model point
    local MODEL_POINT  = "chest"
    -- The immolation Damage model
    local DAMAGE_MODEL = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
    -- The immolation Damage model
    local ATTACH_POINT = "head"

    -- The immolation AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Immolation damage
    local function GetDamage(source, level)
        return 20. * level + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Immolation damage increase
    local function GetDamageIncrease(source, level)
        return 0.025 * level
    end

    -- The Immolation max damage increase
    local function GetMaxDamageIncrease(source, level)
        return 0.25 * level
    end

    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Immolation = Class(Spell)

        local array= {}

        function Immolation:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            
            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.player = nil
            self.effect = nil
            self.multiplier = nil
        end

        function Immolation:onTooltip(unit, level, ability)
            return "Engulfs |cffffcc00Illidan|r in fel flames, dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" .. N2S(GetAoE(unit, level), 0) .. " AoE|r and shreding their armor by |cffffcc00" .. N2S(GetArmorReduction(level), 0) .. "|r every time they are affected by |cffffcc00Immolation|r for |cffffcc00" .. N2S(GetDuration(level), 0) .. "|r seconds.\n\nDrains mana until deactivated."
        end

        function Immolation:onLearn(unit, ability, level)
            if IsUnitInCombat(unit) and not array[unit] and level == 1 then
                local this = {
                    unit = unit,
                    multiplier = 0,
                    timer = CreateTimer(),
                    group = CreateGroup(),
                    player = GetOwningPlayer(unit),
                    effect = AddSpecialEffectTarget(MODEL, unit, MODEL_POINT),
                    destroy = Immolation.destroy
                }

                array[unit] = this

                TimerStart(this.timer, PERIOD, true, function ()
                    if IsUnitInCombat(this.unit) then
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)
                        local damage = GetDamage(this.unit, level) * (1 + this.multiplier)
                        local maximum = GetMaxDamageIncrease(this.unit, level)
                        local increase = GetDamageIncrease(this.unit, level)
                        
                        GroupEnumUnitsInRange(this.group, GetUnitX(this.unit), GetUnitY(this.unit), GetAoE(this.unit, level), nil)

                        local u = FirstOfGroup(this.group)

                        while u do
                            if DamageFilter(this.player, u) then
                                if UnitDamageTarget(this.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, u, ATTACH_POINT))
                                end
                            end

                            GroupRemoveUnit(this.group, u)
                            u = FirstOfGroup(this.group)
                        end

                        this.multiplier = math.min(this.multiplier + increase, maximum)
                    else
                        this:destroy()
                    end
                end)
            end
        end

        function Immolation.onEnter()
            local source = GetCombatSourceUnit()

            if GetUnitAbilityLevel(source, ABILITY) > 0 and not array[source] then
                local self = {
                    unit = source,
                    multiplier = 0,
                    timer = CreateTimer(),
                    group = CreateGroup(),
                    player = GetOwningPlayer(source),
                    effect = AddSpecialEffectTarget(MODEL, source, MODEL_POINT),
                    destroy = Immolation.destroy
                }

                array[source] = self

                TimerStart(self.timer, PERIOD, true, function ()
                    if IsUnitInCombat(self.unit) then
                        local level = GetUnitAbilityLevel(self.unit, ABILITY)
                        local damage = GetDamage(self.unit, level) * (1 + self.multiplier)
                        local maximum = GetMaxDamageIncrease(self.unit, level)
                        local increase = GetDamageIncrease(self.unit, level)
                        
                        GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.unit, level), nil)

                        local u = FirstOfGroup(self.group)

                        while u do
                            if DamageFilter(self.player, u) then
                                if UnitDamageTarget(self.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, u, ATTACH_POINT))
                                end
                            end

                            GroupRemoveUnit(self.group, u)
                            u = FirstOfGroup(self.group)
                        end

                        self.multiplier = math.min(self.multiplier + increase, maximum)
                    else
                        self:destroy()
                    end
                end)
            end
        end

        function Immolation.onInit()
            RegisterSpell(Immolation.allocate(), ABILITY)
            RegisterUnitEnterCombatEvent(Immolation.onEnter)
        end
    end
end)