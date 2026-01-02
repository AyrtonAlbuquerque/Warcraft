OnInit("BlazingDash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Effect"
    requires "Missiles"
    requires "Utilities"

    -- ----------------------------- Blazing Dash v1.0 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY    = S2A('Smr5')
    -- The Model
    local MODEL      = "CriticalDash.mdl"
    -- The model scale
    local SCALE      = 1
    -- The dash speed
    local SPEED      = 5000
    -- The dash effect offset
    local OFFSET     = 600

    -- The Damage
    local function GetDamage(source, level)
        return 375. * level + (1. * level * GetUnitBonus(source, BONUS_DAMAGE))
    end

    -- The Dash distance
    local function GetDistance(source, level)
         return 1250. + 0.*level
    end

    -- The Cooldown Reduction per unit dashed through
    local function GetCooldownReduction(source, level)
         if IsUnitType(source, UNIT_TYPE_HERO) then
             return 0.2 + 0.*level
         else
             return 0.1 + 0.*level
         end
    end

    -- The damage bonus
    local function GetBonusDamage(source, level)
        return 25. * level
    end

    -- The crit chance bonus
    local function GetBonusCriticalChance(source, level)
        return 0.1 * level
    end

    -- The crit damage bonus
    local function GetBonusCriticalDamage(source, level)
        return 0.1 * level
    end

    -- The Bonus duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Dash AoE
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Dash unit filter.
    local function UnitFilter(p, u)
        return UnitAlive(u) and IsUnitEnemy(u, p) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Dash = Class(Missile)
    
    do
        function Dash:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                self.reduction = self.reduction + GetCooldownReduction(unit, self.level)

                UnitDamageTarget(self.source, unit, self.damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil)
            end
            
            return false
        end

        function Dash:onPause()
            return true
        end

        function Dash:onRemove()
            local cooldown = BlzGetUnitAbilityCooldownRemaining(self.source, ABILITY)
                
            if self.reduction >= 1 then
                ResetUnitAbilityCooldown(self.source, ABILITY)
            else
                StartUnitAbilityCooldown(self.ource, ABILITY, cooldown - (cooldown * self.reduction))
            end

            IssueImmediateOrder(self.source, "stop")
            SetUnitAnimation(self.source, "Stand Ready")
            AddUnitBonusTimed(self.source, BONUS_DAMAGE, GetBonusDamage(self.source, self.level), self.time)
            AddUnitBonusTimed(self.source, BONUS_CRITICAL_CHANCE, GetBonusCriticalChance(self.source, self.level), self.time)
            AddUnitBonusTimed(self.source, BONUS_CRITICAL_DAMAGE, GetBonusCriticalDamage(self.source, self.level), self.time)
        end
    end

    do
        BlazingDash = Class(Spell)

        function BlazingDash:onTooltip(source, level, ability)
            return "|cffffcc00Samuro|r dashes up to |cffffcc00" .. N2S(GetDistance(source, level), 0) .. "|r range towards the targeted direction dealing |cffff0000" .. N2S(GetDamage(source, level), 0) .. " Physical|r damage to enemy units it comes in contact with and applies |cff8080ffOn Hit|r effects. Addtionally, after dashing |cffffcc00Samuro|r gains |cffff0000" .. N2S(GetBonusDamage(source, level), 0) .. " Damage|r, |cffffcc00" .. N2S(GetBonusCriticalChance(source, level) * 100, 0) .. "%%|r |cffff0000Critical Chance|r and |cffffcc00" .. N2S(GetBonusCriticalDamage(source, level) * 100, 0) .. "%%|r |cffff0000Critical Damage|r for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds. For each enemy unit |cffffcc00Samuro|r pass trough, |cffffcc00Critical Dash|r cooldown is reduced by |cffffcc0010%|r (Doubled for Heroes)."
        end

        function BlazingDash:onCast()
            local point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetDistance(Spell.source.unit, Spell.level)
            local effect = Effect.create(MODEL, Spell.source.x + OFFSET * math.cos(angle), Spell.source.y + OFFSET * math.sin(angle), 0, SCALE)
            
            if point < distance then
                effect.scale = SCALE * (point / distance)
                effect.x = Spell.source.x + OFFSET * (point / distance) * math.cos(angle)
                effect.y = Spell.source.y + OFFSET * (point / distance) * math.sin(angle)
                distance = point
            end
            
            local dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*math.cos(angle), Spell.source.y + distance*math.sin(angle), 0)

            dash.speed = SPEED
            dash.reduction = 0
            dash.level = Spell.level
            dash.owner = Spell.source.player
            dash.unit = Spell.source.unit
            dash.source = Spell.source.unit
            dash.damage = GetDamage(Spell.source.unit, Spell.level)
            dash.collision = GetAoE(Spell.source.unit, Spell.level)
            dash.time = GetDuration(Spell.source.unit, Spell.level)
            effect.yaw = angle
            
            dash:launch()
            effect:destroy()
        end

        function BlazingDash.onInit()
            RegisterSpell(BlazingDash.allocate(), ABILITY)
        end
    end
end)