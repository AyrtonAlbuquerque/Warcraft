OnInit("HolyStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"

    -- ----------------------------- Holy Strike v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Holy Strike ablity
    local ABILITY      = S2A('Trl4')
    -- The Holy Strike level 1 buff
    local BUFF_1       = S2A('BTr0')
    -- The Holy Strike level 2 buff
    local BUFF_2       = S2A('BTr1')
    -- The Holy Strike level 3 buff
    local BUFF_3       = S2A('BTr2')
    -- The Holy Strike level 4 buff
    local BUFF_4       = S2A('BTr3')
    -- The Holy Strike heal model
    local MODEL        = "HolyStrike.mdl"
    -- The Holy Strike heal attchment point
    local ATTACH_POINT = "origin"

    -- The Holy Strike Heal
    local function GetHeal(level, isRanged)
        local heal = 20.*level

        if isRanged then
            heal = heal/2
        end

        return heal
    end

    -- The Holy Strike bonus strength per unit type
    local function GetBonus(source, level)
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 10 + 0*level
        else
            return 2 + 0*level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        HolyStrike = Class(Spell)

        local array = {}

        function HolyStrike:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)

            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.player = nil
            self.ability = nil
        end

        function HolyStrike:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r provides to all nearby allied units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r the ability to |cffffcc00Holy Strike|r, healing |cffffcc00" .. N2S(GetHeal(level, false), 0) .. "|r health with every auto attack. Healing halved for ranged attacks. In addition |cffffcc00Turalyon|r gains |cffffcc002|r (|cffffcc0010|r for |cffffcc00Heroes|r) |cffff0000Strength|r for every allied unit in range."
        end

        function HolyStrike:onLearn(source, skill, level)
            local this = array[source]

            if not this then
                this = { destroy = HolyStrike.destroy }

                this.bonus = 0
                this.unit = source
                this.level = level
                this.timer = CreateTimer()
                this.group = CreateGroup()
                this.player = GetOwningPlayer(source)
                this.ability = BlzGetUnitAbility(source, skill)
                this.aoe = BlzGetAbilityRealLevelField(this.ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)
                array[source] = this

                TimerStart(this.timer, 0.3, true, function ()
                    if this.level > 0 then
                        AddUnitBonus(this.unit, BONUS_STRENGTH, -this.bonus)
                        GroupEnumUnitsInRange(this.group, GetUnitX(this.unit), GetUnitY(this.unit), this.aoe, nil)
                        GroupRemoveUnit(this.group, this.unit)

                        this.bonus = 0

                        local u = FirstOfGroup(this.group)

                        while u do
                            if UnitAlive(u) and IsUnitAlly(u, this.player) then
                                this.bonus = this.bonus + GetBonus(u, this.level)
                            end

                            GroupRemoveUnit(this.group, u)
                            u = FirstOfGroup(this.group)
                        end

                        AddUnitBonus(this.unit, BONUS_STRENGTH, this.bonus)
                    else
                        this:destroy()
                    end
                end)
            else
                this.level = level
                this.aoe = BlzGetAbilityRealLevelField(this.ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1)
            end
        end

        function HolyStrike.onDamage()
            if Damage.isEnemy then
                if GetUnitAbilityLevel(Damage.source.unit, BUFF_4) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(4, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_3) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(3, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_2) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(2, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_1) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(1, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                end
            end
        end

        function HolyStrike.onInit()
            RegisterSpell(HolyStrike.allocate(), ABILITY)
            RegisterAttackDamageEvent(HolyStrike.onDamage)
        end
    end
end)