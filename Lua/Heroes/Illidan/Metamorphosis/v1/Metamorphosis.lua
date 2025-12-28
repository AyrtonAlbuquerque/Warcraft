OnInit("Metamorphosis", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "CrowdControl"

    -- ----------------------------------- Metamorphosis v1.5 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Metamorphosis ability
    local ABILITY      = S2A('Idn8')
    -- The raw code of the Metamorphosis buff
    Metamorphosis_BUFF = S2A('BEme')
    -- The Metamorphosis lift off model
    local  MODEL       = "Damnation Black.mdl"
    -- The fear model
    local FEAR_MODEL   = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR  = "overhead"

    -- The Metamorphosis AoE for Fear effect
    local function GetAoE(level)
        return 400. + 0.*level
    end

    -- The Metamorphosis Fear Duration
    local function GetDuration(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        end
    end

    -- The Metamorphosis Armor debuff Duration
    local function GetArmorReduction(level)
        return 1. + 0.*level
    end

    -- The Metamorphosis Armor debuff Duration
    local function GetArmorDuration(unit, level)
        return 5. + 0.*level
    end

    -- The Metamorphosis Health Bonus
    local function GetBonusHealth(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 100*level
        else
            return 50*level
        end
    end

    -- The Metamorphosis Damage Bonus
    local function GetBonusDamage(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 10*level
        else
            return 5*level
        end
    end

    -- Fear Filter
    local function FearFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Metamorphosis = Class(Spell)

        function Metamorphosis:destroy()
            DestroyGroup(self.group)

            self.unit = nil
            self.group = nil
            self.player = nil
        end

        function Metamorphosis:onTooltip(source, level, abiltiy)
            return "|cffffcc00Illidan|r transforms into a powerful |cffffcc00Demon|r with a ranged |cffffcc00AoE|r attack and gains |cffff0000" .. N2S(50 * level, 0) .. "|r bonus |cffff0000Health|r and |cffff0000" .. N2S(5 * level, 0) .. "|r bonus |cffff0000Damage|r for each enemy unit affected by his transformation (doubled fo |cffffcc00Heroes|r). |cffffcc00Illidan|r also gains |cffffcc00Fly|r movement type while in his dark form and his basic attacks reduce all damaged enemy units armor by |cffffcc00" .. N2S(GetArmorReduction(level), 0) .. "|r for |cffffcc00" .. N2S(GetArmorDuration(source, level), 0) .. "|r seconds. When lifting off and landing when transforming, all enemy units within |cffffcc00" .. N2S(GetAoE(level), 0) .. " AoE|r will be |cffffcc00Feared|r for |cffffcc005|r seconds (|cffffcc002|r for Heroes).\n\nLasts for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(abiltiy, ABILITY_RLF_DURATION_HERO, level - 1), 0) .. "|r seconds."
        end

        function Metamorphosis:onCast()
            local this = Metamorphosis.allocate()

            this.group = CreateGroup()
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.player = Spell.source.player

            TimerStart(CreateTimer(), 0.5, false, function()
                local health = 0
                local damage = 0

                DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(this.unit), GetUnitY(this.unit), GetUnitZ(this.unit), 2))
                GroupEnumUnitsInRange(this.group, GetUnitX(this.unit), GetUnitY(this.unit), GetAoE(this.level), nil)

                local u = FirstOfGroup(this.group)

                while u do
                    if FearFilter(this.player, u) then
                        health = health + GetBonusHealth(u, this.level)
                        damage = damage + GetBonusDamage(u, this.level)

                        FearUnit(u, GetDuration(u, this.level), FEAR_MODEL, ATTACH_FEAR, false)
                    end

                    GroupRemoveUnit(this.group, u)
                    u = FirstOfGroup(this.group)
                end

                LinkBonusToBuff(this.unit, BONUS_HEALTH, health, Metamorphosis_BUFF)
                LinkBonusToBuff(this.unit, BONUS_DAMAGE, damage, Metamorphosis_BUFF)
                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function Metamorphosis.onDamage()
            if GetUnitAbilityLevel(Damage.source.unit, Metamorphosis_BUFF) > 0 then
                if Damage.isEnemy and not Damage.target.isMagicImmune then
                    AddUnitBonusTimed(Damage.target.unit, BONUS_ARMOR, -GetArmorReduction(GetUnitAbilityLevel(Damage.source.unit, ABILITY)), GetArmorDuration(Damage.target.unit, GetUnitAbilityLevel(Damage.source.unit, ABILITY)))
                end
            end
        end

        function Metamorphosis.onInit()
            RegisterSpell(Metamorphosis.allocate(), ABILITY)
            RegisterAttackDamageEvent(Metamorphosis.onDamage)
        end
    end
end)