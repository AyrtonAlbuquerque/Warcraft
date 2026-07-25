OnInit("LavaElemental", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Sulfuras"

    -- ---------------------------- Lava Elemental v1.7 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Lava Elemental ability
    local ABILITY            = S2A('Rgn4')
    -- The raw code of the Burning Oil ability
    local BURN               = S2A('Rgn7')
    -- The raw code of the Lava Elemental unit
    local LAVA_ELEMENTAL     = S2A('rgn0')
    -- The path for the effect that will be
    -- added to the base of the Lava Elemental
    local FIRA_BASE          = "fire_5.mdl"
    -- Effect when spawning a lava elemental
    local SPAWN_EFFECT       = "Pillar of Flame Orange.mdl"

    -- The amount of damage the Lava Elemental has
    local function GetElementalDamage(unit, level)
        if Sulfuras then
            return R2I(50 + (0.25 * level * (Sulfuras.stacks[unit] or 0)) + (0.05 * level * GetUnitBonus(unit, BONUS_SPELL_POWER)))
        else
            return 25 + 25 * level
        end
    end

    -- The elemental burning oil damage
    local function GetBurnDamage(source, level)
        return R2I(50. * level + (0.05 * level * GetUnitBonus(source, BONUS_SPELL_POWER)))
    end

    -- The Elemental cooldown
    local function GetCooldown(source, target, level)
        if not target then
            return 30. + 0.*level
        else
            return 180. + 0.*level
        end
    end

    -- The Elemental duration
    local function GetDuration(source, level)
        return 60. + 0.*level
    end

    -- The amount of health the Lava Elemental has
    local function GetElementalHealth(unit, level)
        return R2I(500 * level + (BlzGetUnitMaxHP(unit) * 0.3) + (0.4 + 0.2 * level * GetUnitBonus(unit, BONUS_SPELL_POWER)))
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        LavaElemental = Class(Spell)

        local array = {}

        function LavaElemental:destroy()
            array[self.lava] = nil

            self.unit = nil
            self.lava = nil
            self.burn = nil
            self.effect = nil
        end

        function LavaElemental:onTooltip(source, level, ability)
            return "|cffffcc00Ragnaros|r summons a |cffffcc00Lava Elemental|r. This abiliy can be targeted in the |cffffcc00ground|r or |cffffcc00allied structure|r. When summoned in the ground, the |cffffcc00Lava Elemental|r has a life time of |cffffcc00" .. N2S(GetDuration(source, level), 1) .. " seconds|r and this ability cooldown is set to |cffffcc00" .. N2S(30. + 0.*level, 1) .. " seconds|r. When targeted at an allied building, the |cffffcc00Lava Elemental|r takes that building place and lasts forever or until it dies and this ability cooldown is set to |cffffcc00" .. N2S(180. + 0.*level, 1) .. " seconds|r. All the damage that would be given to the structure is instead taken by the |cffffcc00Lava Elemental|r.\n\n|cffffcc00Lava Elemental|r damage is |cffff0000" .. N2S(GetElementalDamage(source, level), 0) .. "|r and it's attacks burn the ground around the impact for |cff00ffff" .. N2S(GetBurnDamage(source, level), 0) .. " Magic|r damage per second for |cffffcc002 seconds|r."
        end

        function LavaElemental:onCast()
            local this = { destroy = LavaElemental.destroy }

            if Spell.target.unit then
                this.lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.target.x, Spell.target.y, 0)
                this.unit = Spell.target.unit
                this.burn = BlzGetUnitAbility(this.lava, BURN)
                this.effect = AddSpecialEffect(FIRA_BASE, Spell.target.x, Spell.target.y)
                array[this.lava] = this
                
                UnitAddAbility(Spell.target.unit, S2A('Abun'))
                ShowUnit(Spell.target.unit, false)
                SetUnitInvulnerable(Spell.target.unit, true)
                SetUnitX(this.lava, Spell.target.x)
                SetUnitY(this.lava, Spell.target.y)
                BlzSetUnitMaxHP(this.lava, GetElementalHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(this.lava, 100)
                BlzSetUnitBaseDamage(this.lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                SetUnitPropWindow(this.lava, 0)
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.target.x, Spell.target.y))
                BlzSetAbilityRealLevelField(this.burn, ABILITY_RLF_FULL_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                BlzSetAbilityRealLevelField(this.burn, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                IncUnitAbilityLevel(this.lava, BURN)
                DecUnitAbilityLevel(this.lava, BURN)
            else
                this.lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.x, Spell.y, 0)
                this.unit = Spell.target.unit
                this.burn = BlzGetUnitAbility(this.lava, BURN)
                this.effect = AddSpecialEffect(FIRA_BASE, Spell.x, Spell.y)
                array[this.lava] = this

                BlzSetUnitMaxHP(this.lava, GetElementalHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(this.lava, 100)
                BlzSetUnitBaseDamage(this.lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                SetUnitPropWindow(this.lava, 0)
                UnitApplyTimedLife(this.lava, S2A('BTLF'), GetDuration(Spell.source.unit, Spell.level))
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.x, Spell.y))
                BlzSetAbilityRealLevelField(this.burn, ABILITY_RLF_FULL_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                BlzSetAbilityRealLevelField(this.burn, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, GetBurnDamage(Spell.source.unit, Spell.level))
                IncUnitAbilityLevel(this.lava, BURN)
                DecUnitAbilityLevel(this.lava, BURN)
            end

            Spell.cooldown = GetCooldown(Spell.source.unit, Spell.target.unit, Spell.level)
        end

        function LavaElemental.onDeath()
            local self = array[GetTriggerUnit()]

            if self then
                UnitRemoveAbility(self.unit, S2A('Abun'))
                ShowUnit(self.unit, true)
                SetUnitInvulnerable(self.unit, false)
                DestroyEffect(self.effect)
                self:destroy()
            end
        end

        function LavaElemental.onInit()
            RegisterSpell(LavaElemental.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, LavaElemental.onDeath)
        end
    end
end)