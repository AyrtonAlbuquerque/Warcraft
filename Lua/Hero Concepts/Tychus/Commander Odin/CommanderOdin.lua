--[[ requires SpellEffectEvent, optional FragGranade, optional AutomatedTurrent, optional Overkill, optional RunAndGun, optional OdinAttack, optional OdinAnnihilate, optional OdinIncinerate
    /* -------------------- Commander Odin v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Commander Odin ability
    local ABILITY = FourCC('A006')

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    CommanderOdin = setmetatable({}, {})
    local mt = getmetatable(CommanderOdin)
    mt.__index = mt
    
    CommanderOdin.morphed = {}
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local level = Spell.level
            local hide = not CommanderOdin.morphed[unit]

            CommanderOdin.morphed[unit] = not CommanderOdin.morphed[unit]

            TimerStart(timer, BlzGetAbilityRealLevelField(BlzGetUnitAbility(Spell.source.unit, ABILITY), ABILITY_RLF_DURATION_NORMAL, Spell.level - 1) + 0.01, false, function()
                if hide then
                    if OdinAttack then
                        SetUnitAbilityLevel(unit, OdinAttack_ABILITY, level)
                    end

                    if OdinAnnihilate then
                        SetUnitAbilityLevel(unit, OdinAnnihilate_ABILITY, level)
                    end

                    if OdinIncinerate then
                        SetUnitAbilityLevel(unit, OdinIncinerate_ABILITY, level)
                    end
                end

                if FragGranade then
                    BlzUnitDisableAbility(unit, FragGranade_ABILITY, hide, hide)
                end

                if AutomatedTurrent then
                    BlzUnitDisableAbility(unit, AutomatedTurrent_ABILITY, hide, hide)
                end

                if Overkill then
                    BlzUnitDisableAbility(unit, Overkill_ABILITY, hide, hide)
                end

                if RunAndGun then
                    BlzUnitDisableAbility(unit, RunAndGun_ABILITY, hide, hide)
                end

                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end)
end