OnInit("HolyStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Heal"
    requires "Utilities"

    -- ----------------------------- Holy Strike v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Holy Strike ablity
    local ABILITY      = S2A('Trl4')
    -- The Holy Strike level 1 buff
    local BUFF         = S2A('BTr0')
    -- The Holy Strike heal model
    local MODEL        = "HolyStrike.mdl"
    -- The Holy Strike heal attchment point
    local ATTACH_POINT = "origin"

    -- The Holy Strike Heal
    local function GetHeal(source, level, isRanged)
        local heal = 10. * level + (0.03 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.05 * level * GetHeroStr(source, true))

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
        local sources = CreateGroup()

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
            return "|cffffcc00Turalyon|r provides to all nearby allied units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r the ability to |cffffcc00Holy Strike|r, healing |cffffcc00" .. N2S(GetHeal(source, level, false), 0) .. "|r health with every auto attack. Healing halved for ranged attacks. In addition |cffffcc00Turalyon|r gains |cffffcc002|r (|cffffcc0010|r for |cffffcc00Heroes|r) |cffff0000Strength|r for every allied unit in range."
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

            if not IsUnitInGroup(source, sources) then
                GroupAddUnit(sources, source)
            end
        end

        function HolyStrike.onDamage()
            local source
            local highest = 1

            if Damage.isEnemy then
                if GetUnitAbilityLevel(Damage.source.unit, BUFF) > 0 then
                    local size = BlzGroupGetSize(sources)

                    if size > 0 then
                        for i = 0, size - 1, 1 do
                            local unit = BlzGroupUnitAt(sources, i)
                            local level = GetUnitAbilityLevel(unit, ABILITY)

                            if level > 0 then
                                if UnitAlive(unit) and IsUnitInRangeXY(unit, Damage.source.x, Damage.source.y, BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1) + 100) then
                                    if level >= highest then
                                        highest = level
                                        source = unit
                                    end
                                end
                            else
                                GroupRemoveUnit(sources, unit)
                            end
                        end
                    end

                    if source then
                        if HealUnit(Damage.source.unit, Damage.source.unit, GetHeal(source, highest, Damage.source.isRanged), HEALTH, false) then
                            DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                        end
                    end
                end
            end
        end

        function HolyStrike.onInit()
            RegisterSpell(HolyStrike.allocate(), ABILITY)
            RegisterAttackDamageEvent(HolyStrike.onDamage)
        end
    end
end)