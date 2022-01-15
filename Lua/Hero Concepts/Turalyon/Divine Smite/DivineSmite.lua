--[[ requires SpellEffectEvent, Utilities, optional LightInfusion
    /* --------------------- Divine Smite v1.2 by Chopinski --------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    //     Bribe           - SpellEffectEvent
    //     Mythic          - Divine Edict Effect
    //     AZ              - Light Stomp effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Divine Smite ability
    local ABILITY       = FourCC('A001')
    -- The Divine Smite model
    local MODEL         = "Divine Edict.mdl"
    -- The  Divine Smite heal model
    local HEAL_MODEL    = "HolyLight2.mdl"
    -- The Divine Smite model
    local ATTACH_POINT  = "origin"
    -- The Divine Smite normal scale
    local SCALE         = 0.6
    -- The Divine Smite infused scale
    local INFUSED_SCALE = 1.
    -- The Divine Smite stomp model
    local STOMP         = "LightStomp.mdl"
    -- The Divine Smite stomp scale
    local STOMP_SCALE   = 0.8

    -- The Divine Smite damage/heal
    local function GetDamage(unit, level, infused)
        if infused then
            return 50.*level
        else    
            return 100.*level
        end
    end

    -- The Divine Smite AoE
    local function GetAoE(unit, level, infused)
        if infused then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1) + 50*level
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
        end
    end

    -- The Divine Smite Infused duration
    local function GetDuration(level)
        return 3. + 0.*level
    end

    -- The Divine Smite infused damage/heal interval
    local function GetInterval(level)
        return 0.5 + 0.*level
    end

    -- Filter for damage/heal
    local function GroupFilter(player, unit)
        return UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local function Smite(unit, player, x, y, aoe, damage)
        local group = CreateGroup()

        GroupEnumUnitsInRange(group, x, y, aoe, nil)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)
            if GroupFilter(player, u) then
                if IsUnitEnemy(u, player) then
                    UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                else
                    SetWidgetLife(u, GetWidgetLife(u) + damage)
                    DestroyEffect(AddSpecialEffectTarget(HEAL_MODEL, u, ATTACH_POINT))
                end
            end
        end
        DestroyGroup(group)
    end
    
    local function Cast(unit, player, level, x, y, aoe, damage, infused)
        if infused then
            local timer = CreateTimer()
            local i = R2I(GetDuration(level)/GetInterval(level))

            Smite(unit, player, x, y, aoe, damage)
            SpamEffect(MODEL, x, y, 0, INFUSED_SCALE, 0.15, 20)
            DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
            TimerStart(timer, GetInterval(level), true, function()
                if i > 0 then
                    Smite(unit, player, x, y, aoe, damage)
                else
                    DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, STOMP_SCALE))
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end
                i = i - 1
            end)
        else
            Smite(unit, player, x, y, aoe, damage)
            DestroyEffect(AddSpecialEffectEx(MODEL, x, y, 0, SCALE))
            DestroyEffect(AddSpecialEffectEx(STOMP, x, y, 0, SCALE))
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            if LightInfusion then
                local infused = (LightInfusion.charges[Spell.source.unit] or 0) > 0
                
                LightInfusion:consume(Spell.source.unit)
                Cast(Spell.source.unit, Spell.source.player, Spell.level, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, infused), GetDamage(Spell.source.unit, Spell.level, infused), infused)
            else
                Cast(Spell.source.unit, Spell.source.player, Spell.level, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false), false)
            end
        end)
    end)
end