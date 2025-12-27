OnInit("KegSmash", function(requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"

    -- ------------------------------ Keg Smash v1.5 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Keg Smash Ability
    KegSmash_ABILITY   = S2A('Chn4')
    -- The Keg Smash Ignite ability
    local IGNITE       = S2A('Chn6')
    -- The Keg Smash Brew Cloud Ability
    local DEBUFF       = S2A('Chn5')
    -- The Keg Smash Brew Cloud debuff
    KegSmash_BUFF      = S2A('BNdh')
    -- The Keg Smash Missile model
    local MODEL        = "RollingKegMissle.mdl"
    -- The Keg Smash Missile scale
    local SCALE        = 1.25
    -- The Keg Smash Missile speed
    local SPEED        = 1000.
    -- The Keg Smash Brew Cloud model
    local CLOUD        = "BrewCloud.mdl"
    -- The Keg Smash Brew Cloud scale
    local CLOUD_SCALE  = 0.6
    -- The Keg Smash Brew Cloud Period
    local PERIOD       = 0.5

    -- The Keg Smash miss chance per level
    local function GetChance(level)
        return 0.2*level
    end

    -- The Keg Smash Brew Cloud duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, KegSmash_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Keg Smash slow amount
    local function GetSlow(unit, level)
        return 0.4 + 0.*level
    end

    -- The Keg Smash slow duration
    local function GetSlowDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, DEBUFF), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Keg Smash AoE
    function KegSmash_GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, KegSmash_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Keg Smash Damage
    local function GetDamage(source, level)
        return 75. + 50.*level + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Keg Smash Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Ignite = Class()

        local proxy = {}

        function Ignite.create(x, y, damage, duration, aoe, interval, source)
            local self = Ignite.allocate()

            self.unit = source
            self.damage = damage
            self.dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            proxy[self.dummy] = self

            UnitAddAbility(self.dummy, IGNITE)
            local spell = BlzGetUnitAbility(self.dummy, IGNITE)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            IncUnitAbilityLevel(self.dummy, IGNITE)
            DecUnitAbilityLevel(self.dummy, IGNITE)
            IssuePointOrder(self.dummy, "flamestrike", x, y)
            TimerStart(CreateTimer(), duration + 0.05, false, function()
                UnitRemoveAbility(self.dummy, IGNITE)
                DummyRecycle(self.dummy)
                DestroyTimer(GetExpiredTimer())

                proxy[self.dummy] = nil
                self.unit = nil
                self.dummy = nil
            end)

            return self
        end

        function Ignite.onDamage()
            local self = proxy[Damage.source.unit]

            if self and Damage.amount > 0 then
                Damage.source = self.unit
            end
        end

        function Ignite.onInit()
            RegisterSpellDamageEvent(Ignite.onDamage)
        end
    end

    do
        BrewCloud = Class()

        local array = {}

        function BrewCloud:destroy()
            UnitRemoveAbility(self.unit, DEBUFF)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            DummyRecycle(self.unit)
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            array[self.unit] = nil

            self.unit = nil
            self.group = nil
            self.timer = nil
            self.player = nil
            self.effect = nil
            self.source = nil
        end

        function BrewCloud.ignite(dummy, damage, duration, interval)
            local self = array[dummy]

            if self then
                if not self.ignited then
                    self.duration = 0
                    self.ignited = true

                    Ignite.create(self.x, self.y, damage, duration, self.aoe, interval, self.source)
                end
            end
        end

        function BrewCloud.active(dummy)
            local self = array[dummy]

            if self then
                return not self.ignited
            end

            return false
        end

        function BrewCloud.create(player, source, dummy, x, y, aoe, duration, slow, slowDuration, level)
            local self = BrewCloud.allocate()

            self.x = x
            self.y = y
            self.aoe = aoe
            self.slow = slow
            self.unit = dummy
            self.level = level
            self.player = player
            self.source = source
            self.ignited = false
            self.duration = duration
            self.slowDuration = slowDuration
            self.timer = CreateTimer()
            self.group = CreateGroup()
            self.effect = AddSpecialEffectEx(CLOUD, x, y, 0, CLOUD_SCALE)
            array[dummy] = self

            TimerStart(self.timer, PERIOD, true, function()
                self.duration = self.duration - PERIOD

                if self.duration > 0 then
                    if not self.ignited then
                        GroupEnumUnitsInRange(self.group, x, y, aoe, nil)
                        
                        local u = FirstOfGroup(self.group)

                        while u do
                            if UnitAlive(u) and IsUnitEnemy(u, self.player) and GetUnitAbilityLevel(u, KegSmash_BUFF) == 0 then
                                if not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                                    IssueTargetOrder(self.unit, "drunkenhaze", u)
                                    SlowUnit(u, slow, slowDuration, nil, nil, false)
                                end
                            end

                            GroupRemoveUnit(self.group, u)
                            u = FirstOfGroup(self.group)
                        end
                    else
                        DestroyEffect(self.effect)
                    end
                else
                    self:destroy()
                end
            end)

            return self
        end

        function BrewCloud.onCast()
            if GetUnitAbilityLevel(GetSpellTargetUnit(), KegSmash_BUFF) == 0 then
                LinkBonusToBuff(GetSpellTargetUnit(), BONUS_MISS_CHANCE, GetChance(GetUnitAbilityLevel(GetTriggerUnit(), DEBUFF)), KegSmash_BUFF)
            end
        end

        function BrewCloud.onInit()
            RegisterSpellEffectEvent(DEBUFF, BrewCloud.onCast)
        end
    end
    
    do
        Keg = Class(Missile)

        Keg:property("unit", {
            get = function(self) return self.cloud end,
            set = function(self, value)
                self.cloud = value
                
                if value then
                    UnitAddAbility(value, DEBUFF)
                    SetUnitAbilityLevel(value, DEBUFF, self.level)
                end
            end
        })

        function Keg:onFinish()
            local duration = GetSlowDuration(self.unit, self.level)

            BrewCloud.create(self.owner, self.source, self.unit, self.x, self.y, self.aoe, self.time, self.slow, duration, self.level)
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    if UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        IssueTargetOrder(self.unit, "drunkenhaze", u)
                        SlowUnit(u, self.slow, duration, nil, nil, false)
                    end
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)

            self.unit = nil
            self.group = nil

            return true
        end
    end

    do
        KegSmash = Class(Spell)

        function KegSmash:onTooltip(unit, level, abiltiy)
            return "|cffffcc00Chen|r rolls his keg in the targeted direction. Upon arrival the keg explodes, dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage, slowing all enemy units within |cffffcc00" .. N2S(KegSmash_GetAoE(unit, level), 0) .. " AoE|r by |cffffcc00" .. N2S(GetSlow(unit, level) * 100, 0) .. "%%|r and leaving a |cffffcc00Brew Cloud|r. Enemy units that come in contact with the |cffffcc00Brew Cloud|r get soaked with brew and drunk, having their |cffffff00Movement Speed|r reduced by |cffffcc00" .. N2S(GetSlow(unit, level) * 100, 0) .. "%%|r and when attacking they have |cffffcc00" .. N2S(GetChance(level) * 100, 0) .. "%%|r chance of missing their target.\n\nLasts for |cffffcc00" .. N2S(GetDuration(unit, level), 1) .. "|r seconds."
        end

        function KegSmash:onCast()
            local keg = Keg.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)

            keg.model = MODEL
            keg.scale = SCALE
            keg.speed = SPEED
            keg.level = Spell.level
            keg.source = Spell.source.unit 
            keg.owner = Spell.source.player
            keg.group = CreateGroup()
            keg.damage = GetDamage(Spell.source.unit, Spell.level)
            keg.aoe = KegSmash_GetAoE(Spell.source.unit, Spell.level)
            keg.time = GetDuration(Spell.source.unit, Spell.level)
            keg.slow = GetSlow(Spell.source.unit, Spell.level)
            keg.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            
            keg:launch()
        end

        function KegSmash.onInit()
            RegisterSpell(KegSmash.allocate(), KegSmash_ABILITY)
        end
    end
end)