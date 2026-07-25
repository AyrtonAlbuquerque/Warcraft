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
    local ABILITY      = S2A('Idn5')
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
        return 500. + 0.*level
    end

    -- The Metamorphosis Fear Duration
    local function GetDuration(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
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
            return "|cffffcc00Illidan|r transforms into a powerful |cffffcc00Demon|r and gains |cffff0000" + N2S(50 * level, 0) + "|r bonus |cffff0000Health|r and |cffff0000" .. N2S(5 * level, 0) .. "|r bonus |cffff0000Damage|r for each enemy unit affected by his transformation (doubled for |cffffcc00Heroes|r). |cffffcc00Illidan|r also gains |cffffcc00" .. N2S(GetOmnivampBonus(source, level) * 100, 0) .. "%|r |cff8080ffOmnivamp|r, |cff00ff00" .. N2S(GetMovementSpeedBonus(source, level), 0) .. " Movement Speed|r and |cffffcc00Fly|r movement type while in his dark form. When lifting off and landing while transforming, all enemy units within |cffffcc00" .. N2S(GetAoE(level), 0) .. " AoE|r will be |cffffcc00Feared|r for |cffffcc005|r seconds (|cffffcc002|r for Heroes)."
        end

        function Metamorphosis:onCast()
            local this = {
                group = CreateGroup(),
                level = Spell.level,
                unit = Spell.source.unit,
                player = Spell.source.player,
                destroy = Metamorphosis.destroy
            }

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
                LinkBonusToBuff(this.unit, BONUS_OMNIVAMP, GetOmnivampBonus(this.unit, this.level), Metamorphosis_BUFF)
                LinkBonusToBuff(this.unit, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(this.unit, this.level), Metamorphosis_BUFF)
                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function Metamorphosis.onInit()
            RegisterSpell(Metamorphosis.allocate(), ABILITY)
        end
    end
end)