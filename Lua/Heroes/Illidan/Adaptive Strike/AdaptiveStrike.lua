OnInit("AdaptiveStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Metamorphosis"

    -- --------------------------- Adaptive Strike v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Adaptive Strike ability
    local ABILITY           = S2A('Idn3')
    -- The Adaptive Strike Slash model
    local SLASH             = "Culling Slash.mdl"
    -- The Adaptive Strike Cleave model
    local CLEAVE            = "Culling Cleave.mdl"
    -- The Adaptive Strike Metamorphosis Swipe model
    local SWIPE             = "Reapers Claws Green.mdl"
    -- The Adaptive Strike Metamorphosis Swipe slash Model
    local SWIPE_SLASH       = "Ephemeral Cut Jade.mdl"
    -- The swipe scale
    local SWIPE_SCALE       = 1.3
    -- the swipe height
    local SWIPE_HEIGHT      = 90
    -- The swipe angle
    local SWIPE_ANGLE       = -25

    -- The Adaptive Strike proc chance
    local function GetChance(level)
        return 25. * level
    end

    -- The Adaptive Strike damage
    local function GetDamage(source, level)
        return 25 * level + 0.5 * GetUnitBonus(source, BONUS_DAMAGE)
    end

    -- The Adaptive Strike AoE
    local function GetAoE(slash, level)
        if slash then
            return 300. + 0.*level
        else
            return 300. + 0.*level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        AdaptiveStrike = Class(Spell)

        local state = {}

        function AdaptiveStrike:onTooltip(source, level, ability)
            return "|cffffcc00Illidan|r attacks have a |cffffcc00" .. N2S(GetChance(level), 0) .. "%%|r chance to become |cffffcc00Adaptive|r, varying between a |cffffcc00Cleave|r in front or a |cffffcc00Slash|r around when in his normal form, dealing |cffd45e19" .. N2S(GetDamage(source, level), 0) .. "|r |cffd45e19Pure|r damage to units within |cffffcc00" .. N2S(GetAoE(false, level), 0) .. " AoE|r. In addition, |cffffcc00Illidan|r |cffffcc00Dark|r form attacks becomes an area of effect attack."
        end

        function AdaptiveStrike.onAttack()
            local source = GetAttacker()
            local level = GetUnitAbilityLevel(source, ABILITY)
        
            if Metamorphosis then
                if GetUnitAbilityLevel(source, Metamorphosis_BUFF) > 0 then
                    local effect = AddSpecialEffectEx(SWIPE, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + SWIPE_HEIGHT, SWIPE_SCALE)
                    
                    BlzSetSpecialEffectOrientation(effect, Deg2Rad(GetUnitFacing(source)), 0, Deg2Rad(SWIPE_ANGLE))
                    DestroyEffect(effect)
                elseif level > 0 and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) and GetRandomReal(0, 100) <= GetChance(level) then
                    state[source] = GetRandomInt(1, 2)

                    if state[source] == 1 then
                        SetUnitAnimationByIndex(source, 4)
                        QueueUnitAnimation(source, "Stand Ready")
                        DestroyEffect(AddSpecialEffectTarget(CLEAVE, source, "origin"))
                    else
                        SetUnitAnimationByIndex(source, 5)
                        QueueUnitAnimation(source, "Stand Ready")
                        DestroyEffect(AddSpecialEffectTarget(SLASH, source, "origin"))
                    end
                end
            else
                if level > 0 and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) and GetRandomReal(0, 100) <= GetChance(level) then
                    state[source] = GetRandomInt(1, 2)

                    if state[source] == 1 then
                        SetUnitAnimationByIndex(source, 4)
                        QueueUnitAnimation(source, "Stand Ready")
                        DestroyEffect(AddSpecialEffectTarget(CLEAVE, source, "origin"))
                    else
                        SetUnitAnimationByIndex(source, 5)
                        QueueUnitAnimation(source, "Stand Ready")
                        DestroyEffect(AddSpecialEffectTarget(SLASH, source, "origin"))
                    end
                end
            end
        end

        function AdaptiveStrike.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Metamorphosis then
                if GetUnitAbilityLevel(Damage.source.unit, Metamorphosis_BUFF) > 0 then
                    local group = CreateGroup()

                    GroupEnumUnitsInRange(group, Damage.source.x, Damage.source.y, GetAoE(true, level), nil)

                    local unit = FirstOfGroup(group)

                    while unit do
                        if IsUnitEnemy(unit, Damage.source.player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                            if UnitDamageTarget(Damage.source.unit, unit, GetDamage(Damage.source.unit, level), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, nil) then
                                DestroyEffect(AddSpecialEffectTarget(SWIPE_SLASH, unit, "chest"))
                            end
                        end

                        GroupRemoveUnit(group, unit)
                        unit = FirstOfGroup(group)
                    end

                    DestroyGroup(group)
                elseif (state[Damage.source.unit] or 0) ~= 0 then
                    if (state[Damage.source.unit] or 0) == 1 then
                        UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), 150, GetAoE(false, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                    else
                        UnitDamageArea(Damage.source.unit, Damage.source.x, Damage.source.y, GetAoE(true, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                    end

                    state[Damage.source.unit] = 0
                end
            else
                if (state[Damage.source.unit] or 0) ~= 0 then
                    if (state[Damage.source.unit] or 0) == 1 then
                        UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), 150, GetAoE(false, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                    else
                        UnitDamageArea(Damage.source.unit, Damage.source.x, Damage.source.y, GetAoE(true, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                    end

                    state[Damage.source.unit] = 0
                end
            end
        end
        
        function AdaptiveStrike.onInit()
            RegisterSpell(AdaptiveStrike.allocate(), ABILITY)
            RegisterAttackDamageEvent(AdaptiveStrike.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, AdaptiveStrike.onAttack)
        end
    end
end)