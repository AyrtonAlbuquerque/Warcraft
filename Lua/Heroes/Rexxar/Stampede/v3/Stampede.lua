OnInit("Stampede", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"
    requires.optional "CDR"

    -- ------------------------------- Stampede v1.3 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY            = S2A('Rex5')
    -- The missile model
    local MODEL              = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
    -- The missile scale
    local SCALE              = 1.5
    -- The missile speed
    local SPEED              = 800
    -- The slow model
    local SLOW_MODEL         = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    -- The slow model attach point
    local SLOW_ATTACH        = "origin"
    -- The slow damage model
    local DAMAGE_MODEL       = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    -- The slow damage model attach point
    local DAMAGE_ATTACH      = "origin"
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME = 0.03

    -- The amount of damage dealt when a boar hits an enemy
    local function GetDamage(source, level)
        if Bonus then
            return 750. * level + (0.3 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + ((1 + 0.25 * level) * GetUnitBonus(source, BONUS_DAMAGE))
        else
            return 750. * level
        end
    end

    -- The slow amount
    local function GetSlow(source, level)
        return 0.1 + 0.1 * level
    end

    -- The slow duration
    local function GetSlowDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The ability aoe
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The lizard total distance
    local function GetRange(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The stack cooldown
    local function GetCooldown(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The lizard count (purely cosmetic)
    local function GetLizardCount(source, level)
        return 2 + 0 * level
    end

    -- The unit filter
    local function UnitFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Lizard = Class(Missile)

        function Lizard:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    SlowUnit(unit, self.slow, self.slowDuration, SLOW_MODEL, SLOW_ATTACH, false)
                    DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, unit, DAMAGE_ATTACH))
                end
            end

            return false
        end
    end

    do
        Stampede = Class(Spell)

        local array = {}
        local charges = {}

        function Stampede:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            array[self.unit] = nil
            charges[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.player = nil
        end

        function Stampede:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r calls forth  rampaging lizards to trample all enemy units in its path. The lizards will do |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage and slow any enemy unit in comes in contact with by |cffffcc00" .. N2S(GetSlow(source, level) * 100, 0) .. "%|r for |cffffcc00" .. N2S(GetSlowDuration(source, level), 1) .. "|r seconds. Stampede gains |cffffcc001|r stack every |cffffcc00" .. N2S(GetCooldown(source, level), 0) .. "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction.\n\nCharges: |cffffcc00" .. I2S(charges[source] or 0) .. "|r"
        end

        function Stampede:onCast()
            local this = { 
                x = Spell.x,
                y = Spell.y,
                level = Spell.level,
                unit = Spell.source.unit,
                player = Spell.source.player,
                destroy = Stampede.destroy 
            }

            if (charges[Spell.source.unit] or 0) > 0 then
                charges[Spell.source.unit] = (charges[Spell.source.unit] or 0) - 1

                if charges[Spell.source.unit] > 0 then
                    ResetUnitAbilityCooldown(Spell.source.unit, ABILITY)
                else
                    if CDR then
                        CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, TimerGetRemaining(array[Spell.source.unit].timer))
                    else
                        Spell.cooldown = TimerGetRemaining(array[Spell.source.unit].timer)
                    end
                end
            end

            TimerStart(CreateTimer(), DRAG_AND_DROP_TIME, false, function ()
                local range = GetRange(this.unit, this.level)
                local count = GetLizardCount(this.unit, this.level)
                local angle = AngleBetweenCoordinates(this.x, this.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player))
                local lizard = Lizard.create(this.x, this.y, 0, this.x + range * math.cos(angle), this.y + range * math.sin(angle), 0)
                
                lizard.source = this.unit
                lizard.owner = this.player
                lizard.model = MODEL
                lizard.scale = SCALE
                lizard.speed = SPEED
                lizard.collision = GetAoE(this.unit, this.level)
                lizard.damage = GetDamage(this.unit, this.level)
                lizard.slow = GetSlow(this.unit, this.level)
                lizard.slowDuration = GetSlowDuration(this.unit, this.level)

                if count > 0 then
                    local row = 1
                    local col = 1
                    local flip = 1

                    for i = 0, count, 1 do
                        lizard:attach(MODEL, row * -150, col * flip * 150, 0, SCALE)

                        flip = flip * -1

                        if i > 0 and i % 2 == 0 then
                            row = row + 1
                            col = col + 1
                        end
                    end
                end

                lizard:launch()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function Stampede:onLearn(unit, ability, level)
            if not array[unit] then
                local this = {
                    unit = unit,
                    timer = CreateTimer(),
                    destroy = Stampede.destroy
                }
                
                array[unit] = this
                charges[unit] = 1

                TimerStart(this.timer, GetCooldown(unit, level), true, function ()
                    local level = GetUnitAbilityLevel(this.unit, ABILITY)

                    if level > 0 then
                        if (charges[this.unit] or 0) >= 0 then
                            charges[this.unit] = (charges[this.unit] or 0) + 1

                            BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                        end
                    else
                        charges[this.unit] = 0
                    end
                end)
            else
                local this = array[unit]
                
                if this then
                    charges[this.unit] = (charges[this.unit] or 0) + 1

                    BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                    TimerStart(this.timer, GetCooldown(this.unit, level), true, function ()
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)

                        if level > 0 then
                            if (charges[this.unit] or 0) >= 0 then
                                charges[this.unit] = (charges[this.unit] or 0) + 1

                                BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                            end
                        else
                            charges[this.unit] = 0
                        end
                    end)
                end
            end
        end

        function Stampede.onInit()
            RegisterSpell(Stampede.allocate(), ABILITY)
        end
    end
end)