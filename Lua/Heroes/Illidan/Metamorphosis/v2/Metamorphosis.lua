OnInit("Metamorphosis", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Combat"
    requires "Damage"
    requires "Utilities"
    requires "CrowdControl"
    requires "SpellEffectEvent"

    -- ----------------------------------- Metamorphosis v1.5 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Metamorphosis ability
    local ABILITY       = S2A('Idn5')
    -- The raw code of the Metamorphosis tranformation ability
    local MORPH         = S2A('Idn7')
    -- The raw code of the Metamorphosis buff
    Metamorphosis_BUFF  = S2A('BEme')
    -- The Metamorphosis lift off model
    local MODEL         = "Damnation Black.mdl"
    -- The fear model
    local FEAR_MODEL    = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR   = "overhead"

    -- The Metamorphosis AoE for Fear effect
    local function GetAoE(level)
        return 400. + 0.*level
    end

    -- The Metamorphosis Fear Duration
    local function GetDuration(source, level)
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        end
    end

    -- The Metamorphosis Health Bonus
    local function GetBonusHealth(source, level)
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 100*level
        else
            return 50*level
        end
    end

    -- The Metamorphosis Damage Bonus
    local function GetBonusDamage(source, level)
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 10*level
        else
            return 5*level
        end
    end

    -- The Metamorphosis Omnivamp Bonus
    local function GetOmnivampBonus(source, level)
        return 0.15 * level
    end

    -- The Movement Speed Bonus
    local function GetMovementSpeedBonus(source, level)
        return 50. * level
    end

    -- The amount of in combat time required to transform
    local function GetInCombatTime(level)
        return 10. - 0.*level
    end

    -- The transformation duration after leaving combat
    local function GetOutOfCombatDuration(level)
        return 5. + 0.*level
    end

    -- Fear Filter
    local function FearFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Metamorphosis = Class(Spell)

        local array = {}

        function Metamorphosis:destroy()
            self.unit = nil
            self.group = nil
            self.timer = nil
            self.player = nil
        end

        function Metamorphosis:onTooltip(source, level, abiltiy)
            return "After staying in combat for |cffffcc00" .. N2S(GetInCombatTime(level), 0) .. "|r seconds, |cffffcc00Illidan|r transforms into a powerful |cffffcc00Demon|r and gains |cffff0000" .. N2S(50 * level, 0) .. "|r bonus |cffff0000Health|r and |cffff0000" .. N2S(5 * level, 0) .. "|r bonus |cffff0000Damage|r for each enemy unit affected by his transformation (doubled for |cffffcc00Heroes|r). |cffffcc00Illidan|r also gains |cffffcc00" .. N2S(GetOmnivampBonus(source, level) * 100, 0) .. "%%|r |cff8080ffOmnivamp|r, |cff00ff00" .. N2S(GetMovementSpeedBonus(source, level), 0) .. " Movement Speed|r and |cffffcc00Fly|r movement type while in his dark form. When lifting off and landing while transforming, all enemy units within |cffffcc00" .. N2S(GetAoE(level), 0) .. " AoE|r will be |cffffcc00Feared|r for |cffffcc005|r seconds (|cffffcc002|r for Heroes). |cffffcc00Illidan|r transforms back to his normal form |cffffcc00" .. N2S(GetOutOfCombatDuration(level), 0) .. "|r seconds after exiting combat."
        end

        function Metamorphosis.onPeriod()
            local self = array[GetExpiredTimer()]

            if self then
                self.time = self.time - 1

                if self.time <= 0 then
                    if GetUnitAbilityLevel(self.unit, MORPH) == 0 then
                        UnitAddAbility(self.unit, MORPH)
                        UnitMakeAbilityPermanent(self.unit, true, MORPH)
                    end

                    IssueImmediateOrder(self.unit, "metamorphosis")
                end

                if not (self.time > 0 and IsUnitInCombat(self.unit) and GetUnitAbilityLevel(self.unit, Metamorphosis_BUFF) == 0) then
                    PauseTimer(self.timer)
                    DestroyTimer(self.timer)
                    array[self.timer] = nil
                    self:destroy()
                end
            end
        end

        function Metamorphosis:onLearn(unit, ability, level)
            if IsUnitInCombat(unit) then
                local this = {
                    unit = unit,
                    timer = CreateTimer(),
                    time = GetInCombatTime(level),
                    destroy = Metamorphosis.destroy
                }

                array[this.timer] = this

                TimerStart(this.timer, 1, true, Metamorphosis.onPeriod)
            end
        end

        function Metamorphosis.onSpell()
            local self = {
                unit = Spell.source.unit,
                player = Spell.source.player,
                group = CreateGroup(),
                level = GetUnitAbilityLevel(Spell.source.unit, ABILITY),
                destroy = Metamorphosis.destroy
            }

            TimerStart(CreateTimer(), 0.5, false, function()
                local health = 0
                local damage = 0

                DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(self.unit), GetUnitY(self.unit), GetUnitZ(self.unit), 2))
                GroupEnumUnitsInRange(self.group, GetUnitX(self.unit), GetUnitY(self.unit), GetAoE(self.level), nil)

                local u = FirstOfGroup(self.group)

                while u do
                    if FearFilter(self.player, u) then
                        health = health + GetBonusHealth(u, self.level)
                        damage = damage + GetBonusDamage(u, self.level)

                        FearUnit(u, GetDuration(u, self.level), FEAR_MODEL, ATTACH_FEAR, false)
                    end

                    GroupRemoveUnit(self.group, u)
                    u = FirstOfGroup(self.group)
                end

                LinkBonusToBuff(self.unit, BONUS_HEALTH, health, Metamorphosis_BUFF)
                LinkBonusToBuff(self.unit, BONUS_DAMAGE, damage, Metamorphosis_BUFF)
                LinkBonusToBuff(self.unit, BONUS_OMNIVAMP, GetOmnivampBonus(self.unit, self.level), Metamorphosis_BUFF)
                LinkBonusToBuff(self.unit, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(self.unit, self.level), Metamorphosis_BUFF)
                DestroyGroup(self.group)
                DestroyTimer(GetExpiredTimer())
                self:destroy()
            end)
        end
        
        function Metamorphosis.onEnter()
            if GetUnitAbilityLevel(GetCombatSourceUnit(), ABILITY) > 0 then
                local self = {
                    unit = GetCombatSourceUnit(),
                    timer = CreateTimer(),
                    time = GetInCombatTime(GetUnitAbilityLevel(GetCombatSourceUnit(), ABILITY)),
                    destroy = Metamorphosis.destroy
                }

                array[self.timer] = self

                TimerStart(self.timer, 1, true, Metamorphosis.onPeriod)
            end
        end

        function Metamorphosis.onLeave()
            if GetUnitAbilityLevel(GetCombatSourceUnit(), MORPH) > 0 then
                local self = {
                    unit = GetCombatSourceUnit(),
                    destroy = Metamorphosis.destroy
                }

                TimerStart(CreateTimer(), GetOutOfCombatDuration(GetUnitAbilityLevel(self.unit, ABILITY)), false, function()
                    if GetUnitAbilityLevel(self.unit, Metamorphosis_BUFF) > 0 and not IsUnitInCombat(self.unit) then
                        IssueImmediateOrder(self.unit, "metamorphosis")
                    end

                    self:destroy()

                    DestroyTimer(GetExpiredTimer())
                end)
            end
        end

        function Metamorphosis.onInit()
            RegisterSpell(Metamorphosis.allocate(), ABILITY)
            RegisterUnitEnterCombatEvent(Metamorphosis.onEnter)
            RegisterUnitLeaveCombatEvent(Metamorphosis.onLeave)
            RegisterSpellEffectEvent(MORPH, Metamorphosis.onSpell)
        end
    end
end)