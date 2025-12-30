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
    -- The raw code of the Lava Elemental unit
    local LAVA_ELEMENTAL     = S2A('rgn0')
    -- This ability cooldown if targeted at a 
    -- structure
    local STRUCTURE_COOLDOWN = 120.
    -- This ability cooldown if targeted at the 
    -- ground
    local NORMAL_COOLDOWN    = 30.
    -- The elemaental duration when targeted at 
    -- the ground
    local ELEMENTAL_DURATION = 60.
    -- The path for the effect that will be
    -- added to the base of the Lava Elemental
    local FIRA_BASE          = "fire_5.mdl"
    -- Effect when spawning a lava elemental
    local SPAWN_EFFECT       = "Pillar of Flame Orange.mdl"

    -- The amount of damage the Lava Elemental has
    local function GetElementalDamage(unit, level)
        if Sulfuras.stacks[unit] then
            return R2I(50 + 0.25 * level * (Sulfuras.stacks[unit] or 0))
        else
            return 25 + 25 * level
        end
    end

    -- The amount of health the Lava Elemental has
    local function GetElementalHealth(unit, level)
        return R2I(500*level + BlzGetUnitMaxHP(unit)*0.3)
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
            self.effect = nil
        end

        function LavaElemental:onTooltip(source, level, ability)
            return "|cffffcc00Ragnaros|r summons a |cffffcc00Lava Elemental|r. This abiliy can be targeted in the |cffffcc00ground|r or |cffffcc00allied structure|r. When summoned in the ground, the |cffffcc00Lava Elemental|r has a life time of |cffffcc00" .. N2S(ELEMENTAL_DURATION, 1) .. " seconds|r and this ability cooldown is set to |cffffcc00" .. N2S(NORMAL_COOLDOWN, 1) .. " seconds|r. When targeted at an allied building, the |cffffcc00Lava Elemental|r takes that building place and lasts forever or until it dies and this ability cooldown is set to |cffffcc00" .. N2S(STRUCTURE_COOLDOWN, 1) .. " seconds|r. All the damage that would be given to the structure is instead taken by the |cffffcc00Lava Elemental|r.\n\n|cffffcc00Lava Elemental|r damage is |cffff0000" .. N2S(GetElementalDamage(source, level), 0) .. "|r and it's attacks burn the ground around the impact for |cff00ffff50 Magic|r damage per second for |cffffcc002 seconds|r."
        end

        function LavaElemental:onCast()
            local this = { destroy = LavaElemental.destroy }

            if Spell.target.unit then
                this.lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.target.x, Spell.target.y, 0)
                this.unit = Spell.target.unit
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
                BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, STRUCTURE_COOLDOWN)
                IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.target.x, Spell.target.y))
            else
                this.lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.x, Spell.y, 0)
                this.unit = Spell.target.unit
                this.effect = AddSpecialEffect(FIRA_BASE, Spell.x, Spell.y)
                array[this.lava] = this

                BlzSetUnitMaxHP(this.lava, GetElementalHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(this.lava, 100)
                BlzSetUnitBaseDamage(this.lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                SetUnitPropWindow(this.lava, 0)
                UnitApplyTimedLife(this.lava, S2A('BTLF'), ELEMENTAL_DURATION)
                BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, NORMAL_COOLDOWN)
                IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.x, Spell.y))
            end
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