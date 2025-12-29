OnInit("LivingTide", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires.optional "Bonus"
    requires.optional "WaterElemental"

    -- ----------------------------- Living Tide v1.1 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY    = S2A('Jna5')
    -- The Living Tide model
    local MODEL      = "LivingTide.mdl"
    -- The Living Tide scale
    local SCALE      = 1.
    -- The Living Tide speed
    local SPEED      = 550.
    -- The update period
    local PERIOD     = 0.03125000

    -- The amount of damage dealt in a second
    local function GetDamagePerSecond(unit, level)
        if Bonus then
            return 300. * level + (0.2 + 0.1*level) * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 300. * level
        end
    end

    -- The living tide collision size
    local function GetCollision(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The living tide sight range
    local function GetVisionRange(unit, level)
        return 1000. + 0.*level
    end

    -- The base mana cost per second
    local function GetBaseManaCostPerSecond(unit, level)
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_ILF_MANA_COST, level - 1)
    end

    -- The range step to change the amount of mana consumed
    local function GetManaCostRangeIncrement(unit, level)
        return 100.
    end

    -- The mana cost amount per range increment
    local function GetManaCostPerIncrement(unit, level)
        return 5.
    end

    -- The unit filter for damage
    local function UnitFilter(player, target)
        return UnitAlive(target) and IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Tide = Class(Missile)
       
        function Tide:onUnit(unit)
            if WaterElemental then
                if UnitFilter(self.owner, unit) then
                    if UnitDamageTarget(self.source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        self:flush(unit)
                    end
                elseif GetUnitTypeId(unit) == WaterElemental_ELEMENTAL and GetOwningPlayer(unit) == self.owner then
                    SetWidgetLife(unit, GetWidgetLife(unit) + self.damage)
                    self:flush(unit)
                end

            else
                if UnitFilter(self.owner, unit) then
                    if UnitDamageTarget(self.source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        self:flush(unit)
                    end
                end
            end

            return false
        end

        function Tide:onFinish()
            self:pause(true)
            return false
        end
    end

    do
        LivingTide = Class(Spell)

        local array = {}

        function LivingTide:destroy()
            self.tide:terminate()

            self.unit = nil
            self.player = nil
        end

        function LivingTide:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r conjures a |cffffcc00Living Tide|r at the target location that follows the cursor at constant speed and deals |cff00ffff" .. N2S(GetDamagePerSecond(source, level), 0) .. " Magic|r damage to enemy units within |cffffcc00" .. N2S(GetCollision(source, level), 0) .. " AoE|r and heals her |cffffcc00Water Elementals|r for the same amount. |cffffcc00Jaina|r can keep the |cffffcc00Living Tide|r alive for as long as she has mana or until being interrupted. Drains |cffffcc00" .. N2S(GetBaseManaCostPerSecond(source, level), 0) .. "|r mana per second. Mana drain is increased by |cffffcc00" .. N2S(GetManaCostPerIncrement(source, level), 0) .. "|r for every |cffffcc00" .. N2S(GetManaCostRangeIncrement(source, level), 0) .. "|r range between |cffffcc00Jaina|r and the |cffffcc00Living Tide|r."
        end

        function LivingTide:onCast()
            if not array[Spell.source.unit] then
                local this = LivingTide.allocate()
                
                this.unit = Spell.source.unit
                this.level = Spell.level
                this.player = Spell.source.player
                this.timer = CreateTimer()
                this.mana = GetBaseManaCostPerSecond(this.unit, this.level)
                this.range = GetManaCostRangeIncrement(this.unit, this.level)
                this.step = GetManaCostPerIncrement(this.unit, this.level)
                this.tide = Tide.create(Spell.x, Spell.y, 0, Spell.source.x, Spell.source.y, 0)
                array[Spell.source.unit] = this

                this.tide.model = MODEL
                this.tide.scale = SCALE
                this.tide.speed = SPEED
                this.tide.source = this.unit
                this.tide.owner = this.player
                this.tide.vision = GetVisionRange(this.unit, this.level)
                this.tide.damage = GetDamagePerSecond(this.unit, this.level) * Missile.period
                this.tide.collision = GetCollision(this.unit, this.level)

                this.tide:launch()

                TimerStart(this.timer, PERIOD, true, function ()
                    if array[this.unit] then
                        local x = GetUnitX(this.unit)
                        local y = GetUnitY(this.unit)
                        local cost = (this.mana + this.step*(DistanceBetweenCoordinates(x, y, this.tide.x, this.tide.y)/this.range)) * PERIOD

                        if cost > GetUnitState(this.unit, UNIT_STATE_MANA) then
                            IssueImmediateOrder(this.unit, "stop")
                            array[this.unit] = nil
                        else
                            this.tide.damage = GetDamagePerSecond(this.unit, this.level) * Missile.period

                            AddUnitMana(this.unit, -this.cost)
                            this.tide:deflect(GetPlayerMouseX(this.player), GetPlayerMouseY(this.player), 0)
                            BlzSetUnitFacingEx(this.unit, AngleBetweenCoordinates(x, y, this.tide.x, this.tide.y)*bj_RADTODEG)

                            if this.tide.paused then
                                this.tide:pause(false)
                            end
                        end
                    else
                        this:destroy()
                    end
                end)
            end
        end

        function LivingTide:onEnd()
            array[GetTriggerUnit()] = nil
        end

        function LivingTide.onInit()
            RegisterSpell(LivingTide.allocate(), ABILITY)
        end
    end
end)