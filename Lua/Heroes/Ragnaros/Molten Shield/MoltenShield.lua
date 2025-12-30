OnInit("MoltenShield", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Molten Shield v1.7 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Molten Shield Ability
    local ABILITY           = S2A('Rgn7')
    -- The raw code of the Ragnaros unit in the editor
    local RAGNAROS_ID       = S2A('Rgns')
    -- The raw code of the buff used to link bonus
    local BUFF_ID           = S2A('BRg0')
    -- The GAIN_AT_LEVEL is greater than 0
    -- ragnaros will gain molten shield at this level 
    local GAIN_AT_LEVEL     = 20
    -- The Explosion effect path
    local EXPLOSION_EFFECT  = "Damnation Orange.mdl"
    -- The Explosion effect attachment point
    local ATTACH_POINT      = "origin"
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE       = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE       = DAMAGE_TYPE_FIRE

    -- The damages
    local function GetDamage(source, level, stored)
        return stored + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The amount of movement speed the target of Molten Shield gains
    local function GetMovementBonus(level)
        return 100*level
    end

    -- The percentage of damage reduced to units with molten shield
    local function GetDamageFactor(level)
        return 0.5
    end

    -- The damage area
    local function GetDamageAoe(level)
        return 350. + 50*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        MoltenShield = Class(Spell)

        local stored = {}

        function MoltenShield:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            stored[self.unit] = nil

            self.unit = nil
            self.timer = nil
        end

        function MoltenShield:onTooltip(source, level, ability)
            return "Upon cast engulfs the target in a |cffffcc00Molten shield|r that reduces all damage taken by |cffffcc00" .. N2S(GetDamageFactor(level) * 100, 1) .. "%%|r and increases |cffffcc00Movement Speed|r by |cffffcc00" .. N2S(GetMovementBonus(level), 0) .. "|r for |cffffcc0010|r seconds. All damage reduced by |cffffcc00Molten Shield|r is stored and when depleated all damage stored is dealt as |cff00ffffMagic|r damage, dealing |cff00ffff" .. N2S(GetDamage(source, level, stored[source]), 0) .. " Magic|r damage to all enemy units within |cffffcc00" .. N2S(GetDamageAoe(level), 0) .. " AoE|r."
        end

        function MoltenShield:onCast()
            if GetUnitAbilityLevel(Spell.target.unit, BUFF_ID) == 0 then
                local this = { destroy = MoltenShield.destroy }
                
                this.unit = Spell.target.unit
                this.level = Spell.level
                this.timer = CreateTimer()

                LinkBonusToBuff(Spell.target.unit, BONUS_MOVEMENT_SPEED, GetMovementBonus(Spell.level), BUFF_ID)
                TimerStart(this.timer, 0.03125, true, function ()
                    if GetUnitAbilityLevel(this.unit, BUFF_ID) == 0 then
                        if stored[this.unit] > 0 then
                            UnitDamageArea(this.unit, GetUnitX(this.unit), GetUnitY(this.unit), GetDamageAoe(this.level), GetDamage(this.unit, this.level, stored[this.unit]), ATTACK_TYPE, DAMAGE_TYPE, false, false, false)
                        end

                        DestroyEffect(AddSpecialEffectTarget(EXPLOSION_EFFECT, this.unit, ATTACH_POINT))
                        this:destroy()
                    end
                end)
            end
        end

        function MoltenShield.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == RAGNAROS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end

        function MoltenShield.onDamage()
            local level = GetUnitAbilityLevel(Damage.target.unit, BUFF_ID)

            if level > 0 and Damage.amount > 0 then
                Damage.amount = Damage.amount * GetDamageFactor(level)
                stored[Damage.target.unit] = (stored[Damage.target.unit] or 0) + Damage.amount
            end
        end

        function MoltenShield.onInit()
            RegisterSpell(MoltenShield.allocate(), ABILITY)
            RegisterAnyDamageEvent(MoltenShield.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, MoltenShield.onLevelUp)
        end
    end
end)