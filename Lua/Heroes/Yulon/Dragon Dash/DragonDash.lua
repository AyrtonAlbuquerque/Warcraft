OnInit("DragonDash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"

    -- ----------------------------- Dragon Dash v1.2 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    DragonDash_ABILITY   = S2A('Yul4')
    -- The Model
    local MODEL          = "DDash.mdl"
    -- The model scale
    local SCALE          = 1
    -- The dash speed
    local SPEED          = 2000
    -- The dash effect offset
    local OFFSET         = 100
    -- The secondary model
    local WIND_MODEL     = "WindBlow.mdl"
    -- The secondary attach point
    local ATTACH_POINT   = "origin"

    -- The Dash distance
    local function GetDistance(level)
         return 600. + 50.*level
    end

    -- The Cooldown Reduction per unit dashed through
    local function GetCooldownReduction(level)
         return 0.5*level
    end

    -- The Dash collision
    local function GetCollision(level)
        return 64. + 0.*level
    end

    -- The Dash unit filter.
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Dash = Class(Missile)
    
    do
        function Dash:onPeriod()
            BlzSetSpecialEffectPosition(self.dash, self.x + OFFSET*math.cos(self.theta), self.y + OFFSET*math.sin(self.theta), self.z)
            BlzSetSpecialEffectYaw(self.dash, self.effect.yaw)
            
            return false
        end

        function Dash:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                local cooldown = BlzGetUnitAbilityCooldownRemaining(self.source, DragonDash_ABILITY)
                
                if self.reduction >= cooldown then
                    ResetUnitAbilityCooldown(self.source, DragonDash_ABILITY)
                else
                    StartUnitAbilityCooldown(self.source, DragonDash_ABILITY, cooldown - self.reduction)
                end
            end
            
            return false
        end

        function Dash:onPause()
            return true
        end

        function Dash:onRemove()
            IssueImmediateOrder(self.source, "stop")
            SetUnitAnimation(self.source, "Stand")
            DestroyEffect(self.wind)
            DestroyEffect(self.dash)
            
            self.wind = nil
            self.dash = nil
        end
    end

    do
        DragonDash = Class(Spell)

        function DragonDash:onTooltip(source, level, ability)
            return "|cffffcc00Yu'lon|r dashes up to |cffffcc00" .. N2S(GetDistance(level), 0) .. "|r range towards the targeted direction and with no collision. For each enemy unit |cffffcc00Yu'lon|r pass trough, |cffffcc00Dragon Dash|r cooldown is reduced by |cffffcc00" .. N2S(GetCooldownReduction(level), 1) .. "|r second."
        end

        function DragonDash:onCast()
            local point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetDistance(Spell.level)
            
            if point < distance then
                distance = point
            end
            
            local dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*math.cos(angle), Spell.source.y + distance*math.sin(angle), 0)

            dash.speed = SPEED
            dash.theta = angle
            dash.owner = Spell.source.player
            dash.unit = Spell.source.unit
            dash.source = Spell.source.unit
            dash.collision = GetCollision(Spell.level)
            dash.reduction = GetCooldownReduction(Spell.level)
            dash.dash = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET*math.cos(angle), Spell.source.y + OFFSET*math.sin(angle), 0, SCALE)
            dash.wind = AddSpecialEffectTarget(WIND_MODEL, dash.source, ATTACH_POINT)
            
            BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            SetUnitAnimation(dash.source, "Spell Channel")
            dash:launch()
        end

        function DragonDash.onInit()
            RegisterSpell(DragonDash.allocate(), DragonDash_ABILITY)
        end
    end
end)