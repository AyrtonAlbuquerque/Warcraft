OnInit("ArrowStorm", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"
    requires.optional "BlackArrow"

    -- ------------------------------ ArrowStorm v1.5 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Arrow Storm ability
    local ABILITY           = S2A('Svn3')
    -- The normal arrow model
    local ARROW_MODEL       = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
    -- The cursed arrow model
    local CURSE_ARROW_MODEL = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"
    -- The arrow size
    local ARROW_SCALE       = 1.
    -- The arrow speed
    local ARROW_SPEED       = 1500.
    -- The arrow arc in degrees
    local ARROW_ARC         = 30.
    -- The attack type of the damage dealt
    local ATTACK_TYPE       = ATTACK_TYPE_NORMAL  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE       = DAMAGE_TYPE_MAGIC

    -- The number of arrows launched per level
    local function GetArrowCount(level)
        return 20 + 5*level
    end

    -- The damage each arrow deals
    local function GetDamage(source, level)
        if Bonus then
            return 25. + 25.*level + (0.15 * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.1 * level * GetHeroAgi(source, true))
        else
            return 25. + 25.*level
        end
    end

    -- The Lauch AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The arrow impact AoE
    local function GetArrowAoE(level)
        return 100.
    end

    -- The cooldown reduction per attack
    local function GetCooldownReduction(source, level)
        return 1. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Arrow = Class(Missile)

        function Arrow:onFinish()
            local group = CreateGroup()

            GroupEnumUnitsInRange(group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                 if Filtered(self.owner, u) then
                    if UnitDamageTarget(self.source, u, self.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil) and self.curse then
                        if BlackArrow then
                            BlackArrow.curse(u, self.source, self.owner)
                        end
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        ArrowStorm = Class(Spell)

        function ArrowStorm:onTooltip(source, level, ability)
            return "|cffffcc00Sylvanas|r lauches |cffffcc00" .. N2S(GetArrowCount(level), 0) .. "|r arrows into the air that will land within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. "|r |cffffcc00AoE|r of targeted area in random spots, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage to enemy units hitted. If |cffffcc00Black Arrows|r is active, |cffffcc00Arrow Storm|r will curse enemy units hit. Additionally, every auto attack reduces the cooldown of |cffffcc00Arrow Storm|r by |cffffcc001|r second."
        end

        function ArrowStorm:onCast()
            for i = 0, GetArrowCount(Spell.level) do
                local radius = GetRandomRange(GetAoE(Spell.source.unit, Spell.level))
                local arrow = Arrow.create(Spell.source.x, Spell.source.y, 85, GetRandomCoordInRange(Spell.x, radius, true), GetRandomCoordInRange(Spell.y, radius, false), 0)

                arrow.source = Spell.source.unit
                arrow.owner = Spell.source.player
                arrow.speed = ARROW_SPEED
                arrow.arc = ARROW_ARC * bj_DEGTORAD
                arrow.damage = GetDamage(Spell.source.unit, Spell.level)
                arrow.aoe = GetArrowAoE(Spell.level)

                if BlackArrow then
                    if BlackArrow.active[Spell.source.unit] then
                        arrow.level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                        arrow.model = CURSE_ARROW_MODEL
                        arrow.curse = arrow.level > 0
                        arrow.ability = BlackArrow_BLACK_ARROW_CURSE
                        arrow.timeout = BlackArrow_GetCurseDuration(arrow.level)
                    else    
                        arrow.model = ARROW_MODEL
                        arrow.curse = false
                    end
                else
                    arrow.model = ARROW_MODEL
                    arrow.curse = false
                end

                arrow.scale = ARROW_SCALE

                arrow:launch()
            end
        end

        function ArrowStorm.onDamage()
            if Damage.isEnemy then
                local cooldown = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, ABILITY)
                local reduction = GetCooldownReduction(Damage.source.unit, GetUnitAbilityLevel(Damage.source.unit, ABILITY))

                if cooldown >= reduction then
                    StartUnitAbilityCooldown(Damage.source.unit, ABILITY, cooldown - reduction)
                else
                    ResetUnitAbilityCooldown(Damage.source.unit, ABILITY)
                end
            end
        end

        function ArrowStorm.onInit()
            RegisterSpell(ArrowStorm.allocate(), ABILITY)
            RegisterAttackDamageEvent(ArrowStorm.onDamage)
        end
    end
end)