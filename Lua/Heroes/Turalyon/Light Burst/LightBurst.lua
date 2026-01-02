OnInit("LightBurst", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "LightInfusion"

    -- ------------------------------------ Light Burst v1.5 ----------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Light Burst Ability
    local ABILITY      = S2A('Trl3')
    -- The Light Burst Missile Model
    local MODEL        = "Light Burst.mdl"
    -- The Light Burst Missile Model scale
    local SCALE        = 1.5
    -- The Light Burst Missile Speed
    local SPEED        = 2000.
    -- The Light Burst Missile Height offset
    local HEIGHT       = 100.
    -- The Light Burst Stomp Model
    local STOMP        = "LightStomp.mdl"
    -- The Light Burst Stomp scale
    local STOMP_SCALE  = 0.55
    -- The Light Burst disarm Model
    local DISARM       = "Disarm.mdl"
    -- The Light Burst disarm attach point
    local ATTACH       = "overhead"

    -- The Light Burst AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Light Burst Buff/Debuff duration
    local function GetDuration(level)
        return 5. + 0.*level
    end

    -- The Light Burst Slow amount
    local function GetSlow(level)
        return 0.1 + 0.1*level
    end

    -- The Light Burst Movement Speed bonus
    local function GetBonus(level)
        return 20 + 20*level
    end

    -- The Light Burst Damage
    local function GetDamage(source, level)
        return (100 + 100. * level) + ((0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.4 * level * GetHeroStr(source, true))
    end

    -- The Light Burst Damage Filter for enemy units
    local function DamageFilter(unit)
        return not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Burst = Class(Missile)

        function Burst:onFinish()
            local group = CreateGroup()

            DestroyEffect(AddSpecialEffectEx(STOMP, self.x, self.y, 0, STOMP_SCALE))
            GroupEnumUnitsInRange(group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if UnitAlive(u) then
                    if IsUnitEnemy(u, self.owner) then
                        if DamageFilter(u) then
                            if UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                SlowUnit(u, self.slow, self.time, nil, nil, false)

                                if self.infused then
                                    DisarmUnit(u, self.time, DISARM, ATTACH, false)
                                end
                            end
                        end
                    else
                        if self.infused then
                            AddUnitBonusTimed(u, BONUS_MOVEMENT_SPEED, self.bonus, self.time)
                        end
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        LightBurst = Class(Spell)

        function LightBurst:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r thrusts his light sword releasing a |cffffcc00Light Burst|r towards the targeted direction. Upon arrival it explodes, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage and slowing all enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r by |cffffcc00" .. N2S(GetSlow(level) * 100, 0) .. "%%|r.\n\n|cffffcc00Light Infused|r: |cffffcc00Light Burst|r increases the |cffffff00Movement Speed|r of any allied unit within its explosion range by |cffffcc00" .. I2S(GetBonus(level)) .. "|r and |cffff0000Disarms|r enemy units for |cffffcc00" .. N2S(GetDuration(level), 1) .. "|r seconds."
        end

        function LightBurst:onCast()
            local burst = Burst.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, 0)

            burst.model = MODEL
            burst.scale = SCALE
            burst.speed = SPEED
            burst.source = Spell.source.unit 
            burst.owner = Spell.source.player
            burst.slow = GetSlow(Spell.level)
            burst.time = GetDuration(Spell.level)
            burst.aoe = GetAoE(Spell.source.unit, Spell.level)
            burst.damage = GetDamage(Spell.source.unit, Spell.level)

            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    burst.infused = true
                    burst.bonus = GetBonus(Spell.level)

                    LightInfusion.consume(Spell.source.unit)
                end
            end

            burst:launch()
        end

        function LightBurst.onInit()
            RegisterSpell(LightBurst.allocate(), ABILITY)
        end
    end
end)