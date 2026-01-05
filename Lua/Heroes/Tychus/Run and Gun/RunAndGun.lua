OnInit("RunAndGun", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "TimedHandles"
    requires.optional "ArsenalUpgrade"

    -- ----------------------------- Run And Gun v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- -------------------------------------------------------------------------- --
        -- The raw code of the Run and Gun ability
        RunAndGun_ABILITY = S2A('Tyc4')
        -- The Buff model
        local MODEL       = "Valiant Charge Royal.mdl"
        -- The Buff attachment point
        local ATTACH      = "origin"

    -- The Run and Gun duration.
    local function GetDuration(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 5. + 0.*level
            else
                return 2.5 + 0.*level
            end
        else
            return 2.5 + 0.*level
        end
    end

    -- The Run and Gun Movement Speed bonus per kill.
    local function GetBonus(level, hero)
        if hero then
            return 20*level
        else
            return 5*level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        RunAndGun = Class(Spell)

        function RunAndGun:onTooltip(source, level, ability)
            return "When killing an enemy unit |cffffcc00Tychus|r gains |cffffcc00" .. N2S(5 * level, 0) .. "|r (|cffffcc00" .. N2S(20 * level, 0) .. "|r for Heroes) bonus |cffffff00Movement Speed|r for |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function RunAndGun.onDeath()
            local killed = GetTriggerUnit()
            local killer = GetKillingUnit()
            local level = GetUnitAbilityLevel(killer, RunAndGun_ABILITY)

            if IsUnitEnemy(killed, GetOwningPlayer(killer)) and level > 0 then
                local duration = GetDuration(killer, level)

                AddUnitBonusTimed(killer, BONUS_MOVEMENT_SPEED, GetBonus(level, IsUnitType(killed, UNIT_TYPE_HERO)), duration)
                DestroyEffectTimed(AddSpecialEffectTarget(MODEL, killer, ATTACH), duration)
            end
        end

        function RunAndGun.onInit()
            RegisterSpell(RunAndGun.allocate(), RunAndGun_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, RunAndGun.onDeath)
        end
    end
end)