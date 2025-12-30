OnInit("StormBolt", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"

    -- ------------------------------------ Storm Bolt v1.6 ------------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Storm Bolt ability
    StormBolt_ABILITY         = S2A('Mrd1')
    -- The missile model
    local MISSILE_MODEL       = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
    -- The missile size 
    local MISSILE_SCALE       = 1.15
    -- The missile speed
    local MISSILE_SPEED       = 1250.
    -- The model used when storm bolt deal bonus damage
    local DAMAGE_MODEL        = "ShockHD.mdl"
    -- The attachment point of the bonus damage model
    local ATTACH_POINT        = "origin"
    -- The extra eye candy model
    local EXTRA_MODEL         = "StormShock.mdl"
    -- The model used when storm bolt slows a unit
    local SLOW_MODEL          = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
    -- The attachment point of the slow model
    local SLOW_POINT          = "origin"
    -- the hammer ground model
    local GROUND_MODEL        = "StaticShock.mdl"
    -- the hammer ground model scale
    local GROUND_SCALE        = 1.0
    -- The lightning effect model
    local LIGHTNING_MODEL     = "LightningShock.mdl"
    -- The lightning effect scale
    local LIGHTNING_SCALE     = 1.0

    -- The storm bolt damage
    function StormBolt_GetDamage(source, level)
        if Bonus then
            return 100. + 100.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100. + 100.*level
        end
    end

    -- The hammer duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The storm bolt AoE
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The hammer vision range
    local function GetVisionRange(source, level)
        return 400. + 0.*level
    end

    -- Hammer Pickup range
    local function GetPickupRange(source, level)
        return 150. + 0.*level
    end

    local function GetCooldownReduction(source, level)
        return 0.5 + 0.1 * level
    end

    -- The storm bolt minimum travel distance
    local function GetMinimumDistance(level)
        return 300. + 0.*level
    end

    -- The storm bolt slow amount
    local function GetSlow(level)
        return 0.1 + 0.1*level
    end

    -- The storm bolt slow duration
    local function GetSlowDuration(level)
        return 2. + 0.*level
    end

    -- The Damage Filter units
    local function DamageFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Hammer = Class(Missile)

        function Hammer:onUnit(unit)
            if DamageFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    SlowUnit(unit, self.slow, self.slowDuration, SLOW_MODEL, SLOW_POINT, false)
                    DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, unit, ATTACH_POINT))
                end
            end
            
            return false
        end

        function Hammer:onFinish()
            self:pause(true)
            self:detach(self.attachment)
            StormBolt.create(self)

            self.effect.pitch = Deg2Rad(60)

            return false
        end
    end

    do
        StormBolt = Class(Spell)

        local lists = {}

        function StormBolt:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)
            self.hammer:terminate()
            self.list:remove(self.hammer)

            self.timer = nil
            self.effect = nil
        end

        function StormBolt.lightning(source, damage, aoe)
            local list = lists[source]
            local group = CreateGroup()

            if list then
                for _, hammer in pairs(list) do
                    GroupEnumUnitsInRange(group, hammer.x, hammer.y, aoe, nil)

                    local u = FirstOfGroup(group)

                    while u do
                        if DamageFilter(hammer.owner, u) then
                            UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                        end

                        GroupRemoveUnit(group, u)
                        u = FirstOfGroup(group)
                    end

                    DestroyEffect(AddSpecialEffectEx(LIGHTNING_MODEL, hammer.x, hammer.y, 0, LIGHTNING_SCALE))
                end              
            end

            DestroyGroup(group)
        end

        function StormBolt.create(hammer)
            local self = { destroy = StormBolt.destroy }
            local list = lists[hammer.source]

            if not list then
                list = List.create()
                lists[hammer.source] = list
            end

            self.list = list
            self.hammer = hammer
            self.timer = CreateTimer()
            self.range = GetPickupRange(hammer.source, hammer.level)
            self.duration = GetDuration(hammer.source, hammer.level)
            self.reduction = GetCooldownReduction(hammer.source, hammer.level)
            self.effect = AddSpecialEffectEx(GROUND_MODEL, hammer.x, hammer.y, 0, GROUND_SCALE)

            self.list:insert(hammer)
            TimerStart(self.timer, 0.2, true, function ()
                self.duration = self.duration - 0.2

                if self.duration > 0 then
                    if DistanceBetweenCoordinates(GetUnitX(self.hammer.source), GetUnitY(self.hammer.source), self.hammer.x, self.hammer.y) <= self.range then
                        BlzStartUnitAbilityCooldown(self.hammer.source, StormBolt_ABILITY, (1 - self.reduction) * BlzGetUnitAbilityCooldownRemaining(self.hammer.source, StormBolt_ABILITY))
                        self:destroy()
                    end
                else
                    self:destroy()
                end
            end)

            return self
        end

        function StormBolt:onTooltip(source, level, ability)
            return "|cffffcc00Muradin|r throw his hammer towards a target location. On its way the hammer deals |cff00ffff" .. N2S(StormBolt_GetDamage(source, level), 0) .. " Magic|r damage and slows enemy units by |cffffcc00" .. N2S(GetSlow(level) * 100, 0) .. "%%|r for |cffffcc00" .. N2S(GetSlowDuration(level), 1) .. "|r seconds. Upon reaching the destination the hammer stays in position for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds and when casting |cffffcc00Thunder Clap|r a lightning will strike at the hammer position dealing the same amount of damage. Additionaly, if |cffffcc00Muradin|r comes in range of the hammer he will pick it up, restoring |cffffcc00" .. N2S(GetCooldownReduction(source, level) * 100, 0) .. "%%|r of |cffffcc00Storm Bolt|r remaining cooldown"
        end

        function StormBolt:onCast()
            local level = GetUnitAbilityLevel(Spell.source.unit, StormBolt_ABILITY)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetMinimumDistance(level)
            local hammer

            if DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) < distance then
                hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.source.x + distance * math.cos(angle), Spell.source.y + distance * math.sin(angle), 60)
            else
                hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)
            end

            hammer.source = Spell.source.unit
            hammer.owner = Spell.source.player
            hammer.model = MISSILE_MODEL
            hammer.speed = MISSILE_SPEED
            hammer.scale = MISSILE_SCALE
            hammer.level = level
            hammer.damage = StormBolt_GetDamage(Spell.source.unit, level)
            hammer.collision = GetAoE(Spell.source.unit, level)
            hammer.slow = GetSlow(level)
            hammer.vision = GetVisionRange(Spell.source.unit, level)
            hammer.slowDuration = GetSlowDuration(level)
            hammer.attachment = hammer:attach(EXTRA_MODEL, 0, 0, 0, MISSILE_SCALE)

            hammer:launch()
        end

        function StormBolt.onInit()
            RegisterSpell(StormBolt.allocate(), StormBolt_ABILITY)
        end
    end
end)