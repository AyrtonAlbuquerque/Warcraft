OnInit("WaterShield", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"

    -- ----------------------------- Water Shield v1.2 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY                = S2A('Jna2')
    -- The shield model
    local MODEL                  = "WaterShield.mdl"
    -- The shield attachement point
    local ATTACH                 = "origin"
    -- The explosion model
    local EXPLOSION_MODEL        = "LivingTide.mdl"
    -- The scale of the explosion model
    local EXPLOSION_SCALE        = 0.6
    -- The water bolt model
    local BOLT_MODEL             = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
    -- The water bolt scal
    local BOLT_SCALE             = 1.
    -- The water bolt speed
    local BOLT_SPEED             = 1000.

    -- The shield amount
    local function GetAmount(unit, level)
        if Bonus then
            return 100.*level + (0.5 + 0.5*level) * GetHeroInt(unit, true) + 0.25 * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 100.*level + (0.5 + 0.5*level) * GetHeroInt(unit, true)
        end
    end

    -- The water bolt damage
    local function GetBoltDamage(unit, level)
        if Bonus then
            return 25. + 25.*level + 0.15 * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 25. + 25.*level
        end
    end

    -- The range at which units can be selected by water bolt
    local function GetAoE(unit, level)
        return 400. + 0.*level
    end

    -- The aoe of the explosion when there is a remaining shield amount
    local function GetExplosionAoE(unit, level)
        return 400. + 0.*level
    end

    -- The angle in degrees at which units can be selected
    local function GetAngle(unit, level)
        return 90. + 0.*level
    end

    -- The Shield duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The unit filter
    local function UnitFilter(player, target)
        return IsUnitEnemy(target, player) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        WaterBolt = Class(Missile)

        function WaterBolt:onFinish()
            if UnitAlive(self.target) then
                UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
            end

            return true
        end
    end

    do
        WaterShield = Class(Spell)

        local effect = {}
        local defense = {}
        local offense = {}

        function WaterShield:destroy()
            if self.defensive then
                defense[self.target] = nil

                if not offense[self.target] then
                    DestroyEffect(effect[self.target])
                    effect[self.target] = nil
                end
            else
                offense[self.target] = nil

                if not defense[self.target] then   
                    DestroyEffect(effect[self.target])
                    effect[self.target] = nil
                end
            end

            DestroyGroup(self.group)

            self.group = nil
            self.source = nil
            self.target = nil
            self.player = nil
        end

        function WaterShield:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r can cast |cffffcc00Water Shield|r in an ally or enemy unit. When targeting an ally, the |cffffcc00Water Shield|r blocks |cff00ffff" .. N2S(GetAmount(source, level), 0) .. "|r damage and if the shield last it's whole duration it will explode, dealing the remaining shield amount as |cff00ffffMagic|r damage to nearby enemy units within |cffffcc00" .. N2S(GetExplosionAoE(source, level), 0) .. " AoE|r. When targeting an enemy unit, all attacks to the targeted unit will splash water bolts to enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r in a |cffffcc00" .. N2S(GetAngle(source, level), 0) .. "|r degrees angle behind the target unit from the direction of the attack, dealing |cff00ffff" .. N2S(GetBoltDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage.\n\nLasts for |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function WaterShield:onCast()
            local this

            if not effect[Spell.target.unit] then
                effect[Spell.target.unit] = AddSpecialEffectTarget(MODEL, Spell.target.unit, ATTACH)
            end

            if Spell.isEnemy then
                if offense[Spell.target.unit] then
                    this = offense[Spell.target.unit]
                else
                    this = WaterShield.allocate()
                    
                    this.target = Spell.target.unit
                    this.group = CreateGroup()
                    this.defensive = false
                    offense[Spell.target.unit] = this
                end

                this.source = Spell.source.unit
                this.player = Spell.source.player
                this.level = Spell.level
                this.amount = GetBoltDamage(this.source, this.level)
                this.angle = GetAngle(this.source, this.level)
                this.aoe = GetAoE(this.source, this.level)
            else
                if defense[Spell.target.unit] then
                    this = defense[Spell.target.unit]
                else
                    this = WaterShield.allocate()
                    
                    this.target = Spell.target.unit
                    this.group = CreateGroup()
                    this.defensive = true
                    this.amount = 0
                    defense[Spell.target.unit] = this
                end

                this.source = Spell.source.unit
                this.player = Spell.source.player
                this.level = Spell.level
                this.amount = this.amount + GetAmount(this.source, this.level)
                this.aoe = GetExplosionAoE(this.source, this.level)
            end

            TimerStart(CreateTimer(), GetDuration(this.source, this.level), false, function ()
                if this.defensive and this.amount > 0 then
                    GroupEnumUnitsInRange(this.group, GetUnitX(this.target), GetUnitY(this.target), this.aoe, nil)

                    local u = FirstOfGroup(this.group)

                    while u do
                        if UnitFilter(this.player, u) then
                            UnitDamageTarget(this.source, u, this.amount, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                        end
                    end

                    DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, GetUnitX(this.target), GetUnitY(this.target), 0, EXPLOSION_SCALE))
                end

                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function WaterShield.onDamage()
            local self = defense[Damage.target.unit]

            if Damage.amount > 0 and self then
                if Damage.amount <= self.amount then
                    self.amount = self.amount - Damage.amount
                    Damage.amount = 0
                else
                    Damage.amount = Damage.amount - self.amount
                    self.amount = 0

                    self:destroy()
                end
            end
        end

        function WaterShield.onAttack()
            local self = offense[Damage.target.unit]

            if Damage.isEnemy and self then
                GroupEnumUnitsInRange(self.group, Damage.target.x, Damage.target.y, self.aoe, nil)
                GroupRemoveUnit(self.group, Damage.target.unit)

                local u = FirstOfGroup(self.group)

                while u do
                    if UnitFilter(self.player, u) and IsUnitInCone(u, Damage.target.x, Damage.target.y, self.aoe, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y)*bj_RADTODEG, self.angle) then
                        local bolt = WaterBolt.create(Damage.target.x, Damage.target.y, 50, GetUnitX(u), GetUnitY(u), 50)
                        
                        bolt.target = u
                        bolt.source = self.source
                        bolt.model = BOLT_MODEL
                        bolt.speed = BOLT_SPEED
                        bolt.scale = BOLT_SCALE
                        bolt.damage = self.amount

                        bolt:launch()
                    end

                    GroupRemoveUnit(self.group, u)
                    u = FirstOfGroup(self.group)
                end
            end
        end

        function WaterShield.onDeath()
            local unit = GetTriggerUnit()
            local self

            if defense[unit] then
                self = defense[unit]
                self:destroy()
            end

            if offense[unit] then
                self = offense[unit]
                self:destroy()
            end
        end

        function WaterShield.onInit()
            RegisterSpell(WaterShield.allocate(), ABILITY)
            RegisterAnyDamageEvent(WaterShield.onDamage)
            RegisterAttackDamageEvent(WaterShield.onAttack)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, WaterShield.onDeath)
        end
    end
end)