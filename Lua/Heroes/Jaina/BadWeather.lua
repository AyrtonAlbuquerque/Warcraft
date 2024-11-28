--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, TimerUtils, Utilities, DamageInterface
    /* ---------------------- Bad Weather v1.0 by Chopinski --------------------- */
    // Credits:
    //     Bribe                - SpellEffectEvent
    //     Magtheridon96        - RegisterPlayerUnitEvent
    //     Vexorian             - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY       = FourCC('A005')
    -- The raw code of the debuff Ability
    local DEBUFF        = FourCC('A007')
    -- The raw code of the debuff buff
    local BUFF          = FourCC('B001')
    -- The rain model
    local MODEL         = "Rain.mdl"
    -- The rain model scale
    local SCALE         = 2.5
    -- The raw code of the Jaina unit in the editor
    local JAINA_ID      = FourCC('H000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Jaina will gain Bad Weather at this level
    local GAIN_AT_LEVEL = 20

    -- The rain duration
    local function GetDuratoin(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The bonus damage dealt (use different buffs per level in the debuff ability)
    local function GetDamageBonus(buff)
        if buff == BUFF then
            return 0.2
        else
            return 0.2
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
                local unit = GetTriggerUnit()

                if GAIN_AT_LEVEL > 0 then
                    if GetUnitTypeId(unit) == JAINA_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                        UnitAddAbility(unit, ABILITY)
                        UnitMakeAbilityPermanent(unit, true, ABILITY)
                    end
                end
            end)

            RegisterSpellEffectEvent(ABILITY, function()
                local timer = CreateTimer()
                local unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
                local effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

                UnitAddAbility(unit, DEBUFF)
                TimerStart(timer, GetDuratoin(Spell.source.unit, Spell.level), false, function()
                    UnitRemoveAbility(unit, DEBUFF)
                    DestroyEffect(effect)
                    DummyRecycle(unit)
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end)
            end)

            RegisterSpellDamageEvent(function()
                if GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 and Damage.isEnemy then
                    BlzSetEventDamage(GetEventDamage()*(1 + GetDamageBonus(BUFF)))
                end
            end)
        end)
    end
end