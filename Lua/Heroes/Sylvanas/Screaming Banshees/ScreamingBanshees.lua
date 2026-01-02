OnInit("ScreamingBanshees", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Effect"
    requires "Missiles"
    requires "Utilities"

    -- -------------------------- Screaming Banshees v1.4 by Chopinski ------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Screaming Banshees ability
    local ABILITY       = S2A('Svn4')
    -- The raw code of the Screaming Banshees Teleport ability
    local TELEPORT      = S2A('Svn9')
    -- The missile model
    local MISSILE_MODEL = "Bats Only.mdl"
    -- The missile size
    local MISSILE_SCALE = 1.3
    -- The missile speed
    local MISSILE_SPEED = 750.
    -- The hit model
    local HIT_MODEL     = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
    -- The attachment point
    local ATTACH_POINT  = "origin"
    -- The missile extra attachment model
    local EXTRA_MODEL   = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
    -- The extra attachment scale
    local EXTRA_SCALE   = 1.75

    -- The misisle max distance
    local function GetDistance(level)
        return 1100. + 100.*level
    end

    -- The armor reductoin duration
    local function GetDuration(level)
        return 10. + 0.*level
    end

    -- The amount of armor reduced when passing through units
    local function GetArmorReduction(level)
        return 2 + 2*level
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 100. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Banshee = Class(Missile)

        function Banshee:onPeriod()
            if self.traveled >= (self.distance * 0.5) and self.traveled <= (self.distance * 0.75) and not self.attachment then
                self.attachment = self:attach("Abilities\\Spells\\Other\\TalkToMe\\TalkToMe", 0, 0, 100, 1)
            elseif self.traveled > (self.distance * 0.75) and self.attachment then
                self.attachment:color(255, 0, 0)
            end

            return false
        end

        function Banshee:onUnit(unit)
            if Filtered(self.owner, unit) then
                DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, unit, ATTACH_POINT))
                AddUnitBonusTimed(unit, BONUS_ARMOR, -self.armor, self.timeout)
            end

            return false
        end

        function Banshee:onRemove()
            UnitRemoveAbility(self.source, TELEPORT)
            BlzUnitHideAbility(self.source, ABILITY, false)
        end
    end

    do
        ScreamingBanshees = Class(Spell)

        local array = {}

        function ScreamingBanshees:onTooltip(source, level, ability)
            return "|cffffcc00Sylvanas|r releases |cffffcc00Screaming Banshees|r in the target direction. The banshees travel |cffffcc00" .. N2S(GetDistance(level), 0) .. "|r distance and when passing through an enemy unit it reduces its |cff808080Armor|r by |cff808080" .. N2S(GetArmorReduction(level), 0) .. "|r for |cffffcc00" .. N2S(GetDuration(level), 0) .. "|r seconds. |cffffcc00Sylvanas|r can reactivate the ability to teleport to the banshees position."
        end

        function ScreamingBanshees:onCast()
            if Spell.id == ABILITY then
                local distance = GetDistance(Spell.level)
                local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
                local banshee = Banshee.create(Spell.source.x, Spell.source.y, 50, Spell.source.x + distance * math.cos(angle), Spell.source.y + distance * math.sin(angle), 50)

                banshee.distance = distance
                banshee.source = Spell.source.unit
                banshee.owner = Spell.source.player
                banshee.model = MISSILE_MODEL
                banshee.scale = MISSILE_SCALE
                banshee.speed = MISSILE_SPEED
                banshee.collision = GetCollisionSize(Spell.level)
                banshee.armor = GetArmorReduction(Spell.level)
                banshee.timeout = GetDuration(Spell.level)
                array[Spell.source.unit] = banshee

                banshee:attach(EXTRA_MODEL, 0, 0, banshee.z + 50, EXTRA_SCALE)
                UnitAddAbility(Spell.source.unit, TELEPORT)
                BlzUnitHideAbility(Spell.source.unit, ABILITY, true)
                banshee:launch()
            else
                local banshee = array[Spell.source.unit]

                if banshee then
                    SetUnitX(banshee.source, banshee.x)
                    SetUnitY(banshee.source, banshee.y)
                    IssueImmediateOrder(banshee.source, "stop")
                    banshee:terminate()
                    array[Spell.source.unit] = nil
                end
            end
        end

        function ScreamingBanshees.onInit()
            RegisterSpell(ScreamingBanshees.allocate(), ABILITY)
            RegisterSpell(ScreamingBanshees.allocate(), TELEPORT)
        end
    end
end)