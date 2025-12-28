OnInit("NimbleDash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Evasion"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "CDR"
    requires.optional "Metamorphosis"

    -- ----------------------------- Nimble Dash v1.0 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local  ABILITY      = S2A('Idn1')
    -- The Model
    local  MODEL        = "Windwalk Necro Soul.mdl"
    -- The dash speed
    local  SPEED        = 1500
    -- The slash Model
    local  SLASH        = "Ephemeral Cut Jade.mdl"
    -- The fear model
    local  FEAR_MODEL   = "Fear.mdl"
    -- The the fear attachment point
    local  ATTACH_FEAR  = "overhead"

    -- The dash damage
    local function GetDamage(source, level)
        return 50 + 50*level + (1.1 + 0.1*level)*GetHeroAgi(source, true)
    end

    -- The maximum Dash distance
    local function GetDistance(source, level)
        if Metamorphosis then
            if GetUnitAbilityLevel(source, Metamorphosis_BUFF) > 0 then
                return 2 * (300. + 50.*level)
            else
                return 300. + 50.*level
            end
        else
            return 300. + 50.*level
        end
    end

    -- The passive Evasion bonus per level
    local function GetPassiveBonus(level)
        return 0.05
    end

    -- The active Evasion bonus per level
    local function GetActiveBonus(level)
        return 0.025*level
    end

    -- The evasion active bonus duration
    local function GetDuration(source, level)
         return 15. + 0.*level
    end

    -- The Dash charges
    local function GetCharges(source, level)
        return 3
    end

    -- The Dash charge cooldown
    local function GetCooldown(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The evasion active bonus duration
    local function GetFearDuration(source, level)
         return 0.5 + 0.*level
    end

    -- The Dash collision
    local function GetCollision(level)
        return 150. + 0.*level
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
        function Dash:onUnit(unit)
            if Metamorphosis then
                if IsUnitEnemy(unit, self.owner) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                    if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil) then
                        DestroyEffect(AddSpecialEffectTarget(SLASH, unit, "chest"))
                        
                        if GetUnitAbilityLevel(self.source, Metamorphosis_BUFF) > 0 then
                            FearUnit(unit, self.fear, FEAR_MODEL, ATTACH_FEAR, true)
                        end
                    end
                end
            else
                if IsUnitEnemy(unit, self.owner) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                    if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil) then
                        DestroyEffect(AddSpecialEffectTarget(SLASH, unit, "chest"))
                    end
                end
            end
            
            return false
        end

        function Dash:onPause()
            return true    
        end

        function Dash:onRemove()
            DestroyEffect(self.sfx)
            SetUnitTimeScale(self.source, 1)

            self.sfx = nil
        end
    end

    do
        NimbleDash = Class(Spell)

        local array = {}
        local charges = {}

        function NimbleDash:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            charges[self.unit] = nil
            array[self.unit] = nil
            array[self.timer] = nil
            self.unit = nil
            self.timer = nil
        end

        function NimbleDash:onTooltip(source, level, ability)
            return "|cffffcc00Illidan|r dashes up to |cffffcc00" .. N2S(GetDistance(source, level), 0) .. "|r range towards the targeted direction, gaining |cffffcc00" .. N2S(GetActiveBonus(level)*100, 1) .. "%%|r |cffff00ffEvasion|r for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds and dealing |cffff0000" .. N2S(GetDamage(source, level), 0) .. " Physical|r damage when passing through enemy units. |cffffcc00Nimble Dash|r can stack up to |cffffcc00" .. N2S(GetCharges(source, level), 0) .. "|r charges. When in |cffffcc00Metamorphosis|r, the dash range is doubled |cffffcc00Fears|r enemy units for |cffffcc00" .. N2S(GetFearDuration(source, level), 2) .. "|r seconds. Additionally |cffffcc00Illidan|r has |cffffcc00" .. N2S(GetPassiveBonus(level)*100*level, 0) .. "%%|r passively increased chance to avoid enemy attacks.\n\nCharges: " .. N2S((charges[source] or 0), 0)
        end

        function NimbleDash.onPeriod()
            local self = array[GetExpiredTimer()]

            if self then
                local level = GetUnitAbilityLevel(self.unit, ABILITY)

                if level > 0 then
                    if charges[self.unit] < GetCharges(self.unit, level) and charges[self.unit] >= 0 then
                        charges[self.unit] = charges[self.unit] + 1

                        BlzEndUnitAbilityCooldown(self.unit, ABILITY)
                    end
                else
                    self:destroy()
                end
            end
        end

        function NimbleDash:onCast()
            local point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetDistance(Spell.source.unit, Spell.level)

            if point < distance then
                distance = point
            end
            
            local dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*math.cos(angle), Spell.source.y + distance*math.sin(angle), 0)
            
            dash.speed = SPEED
            dash.owner = Spell.source.player
            dash.source = Spell.source.unit
            dash.unit = Spell.source.unit
            dash.damage = GetDamage(Spell.source.unit, Spell.level)
            dash.collision = GetCollision(Spell.level)
            dash.fear = GetFearDuration(Spell.source.unit, Spell.level)
            dash.sfx = AddSpecialEffectTarget(MODEL, Spell.source.unit, "chest")

            if Metamorphosis then
                if GetUnitAbilityLevel(Spell.source.unit, Metamorphosis_BUFF) > 0 then
                    SetUnitAnimation(Spell.source.unit, "Walk Alternate")
                end
            end

            if charges[Spell.source.unit] > 0 then
                charges[Spell.source.unit] = (charges[Spell.source.unit] or 0) - 1

                if charges[Spell.source.unit] >= 1 then
                    ResetUnitAbilityCooldown(Spell.source.unit, ABILITY)
                else
                    if CDR then
                        CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, TimerGetRemaining(array[Spell.source.unit].timer))
                    else
                        Spell.cooldown = TimerGetRemaining(array[Spell.source.unit].timer)
                    end
                end
            end
            
            SetUnitTimeScale(Spell.source.unit, 2)
            AddUnitBonusTimed(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), GetDuration(Spell.source.unit, Spell.level))
            BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            dash:launch()
        end

        function NimbleDash:onLearn(unit, ability, level)
            local this = array[unit]

            AddUnitBonus(unit, BONUS_EVASION_CHANCE, GetPassiveBonus(level))

            if not this then
                this = NimbleDash.allocate()
                
                this.unit = unit
                this.timer = CreateTimer()
                array[unit] = this
                array[this.timer] = this
                charges[unit] = GetCharges(unit, level)

                TimerStart(this.timer, GetCooldown(unit, level), true, NimbleDash.onPeriod)
            else
                TimerStart(this.timer, GetCooldown(unit, level), true, NimbleDash.onPeriod)
            end
        end

        function NimbleDash.onInit()
            RegisterSpell(NimbleDash.allocate(), ABILITY)
        end
    end
end)