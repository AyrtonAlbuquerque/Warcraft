OnInit("Zap", function(requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"

    -- --------------------------------- Zap v1.4 by Chopinski --------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Zap ability
    Zap_ABILITY        = S2A('ChnC')
    -- The Zap model
    local MODEL        = "ZapMissile.mdl"
    -- The Zap scale
    local SCALE        = 1.
    -- The Zap Missile speed
    local SPEED        = 2000.
    -- The Zap Missile heigth
    local HEIGHT       = 150.
    -- The Zap Missile damage model
    local IMPACT_MODEL = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
    -- The Zap Missile damage model attach point
    local ATTACH       = "origin"

    -- The Zap missile collision
    local function GetCollision(level)
        return 150. + 0.*level
    end

    -- The Zap damage
    local function GetDamage(source, level)
        if Bonus then
            return 150. * level + 1 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        end
    end

    -- The Zap mana drain per second
    local function GetManaDrain(level)
        return 100.*level
    end

    -- The Zap Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Lightning = Class(Missile)

        function Lightning:onPeriod()
            local hasMana = self.mana <= GetUnitState(self.source, UNIT_STATE_MANA)

            if hasMana then
                AddUnitMana(self.source, -self.mana)
            end

            return not hasMana
        end

        function Lightning:onUnit(unit)
            if DamageFilter(self.owner, unit) then
                UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, nil)
                DestroyEffect(AddSpecialEffectTarget(IMPACT_MODEL, unit, ATTACH))
            end

            return false
        end

        function Lightning:onRemove()
            SetUnitX(self.source, self.x)
            SetUnitY(self.source, self.y)
            ShowUnit(self.source, true)
            SelectUnitAddForPlayer(self.source, self.owner)
        end
    end

    do
        Zap = Class(Spell)

        function Zap:onTooltip(unit, level, ability)
            return "|cffffcc00Storm|r transforms into a lightning, flying towards the targeted direction and dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage to enemy unit in his path. |cffffcc00Zap|r drains |cff00ffff" .. N2S(GetManaDrain(level), 0) .. " Mana|r per second."
        end

        function Zap:onCast()
            local zap = Lightning.create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, HEIGHT)

            zap.model = MODEL
            zap.scale = SCALE
            zap.speed = SPEED
            zap.source = Spell.source.unit
            zap.owner = Spell.source.player
            zap.vision = 1000
            zap.damage = GetDamage(Spell.source.unit, Spell.level)
            zap.collision = GetCollision(Spell.level)
            zap.mana = GetManaDrain(Spell.level) * Missile.period

            ShowUnit(Spell.source.unit, false)
            zap:launch()
        end

        function Zap.onInit()
            RegisterSpell(Zap.allocate(), Zap_ABILITY)
        end
    end
end)