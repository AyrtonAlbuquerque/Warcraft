--[[ requires RegisterPlayerUnitEvent, NewBonusUtils
    /* ---------------------- Immolation v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Vexorian        - TimerUtils
    //     Mythic          - Immolation Effect (Edited by me)
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Immolation ability
    local ABILITY      = FourCC('A002')
    -- The raw code of the Immolation buff
    local BUFF         = FourCC('B002')
    -- The immolation damage period
    local PERIOD       = 1.
    -- The immolation Damage model
    local MODEL        = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
    -- The immolation Damage model
    local ATTACH_POINT = "head"

    -- The immolation AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Immolation damage
    local function GetDamage(level)
        return 20.*level
    end

    -- The Immolation armor debuff duration
    local function GetDuration(level)
        return 5. + 0.*level
    end

    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local n = {}
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
            local unit = GetOrderedUnit()

            if not n[unit] and GetIssuedOrderId() == 852177 then
                local timer = CreateTimer()
                local group = CreateGroup()
                local player = GetOwningPlayer(unit)
                n[unit] = true

                LinkEffectToBuff(unit, BUFF, "Ember Green.mdl", "chest")
                TimerStart(timer, PERIOD, true, function()
                    if GetUnitAbilityLevel(unit, BUFF) > 0 then
                        local level = GetUnitAbilityLevel(unit, ABILITY)
                        
                        GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), nil)
                        for i = 0, BlzGroupGetSize(group) - 1 do
                            local u = BlzGroupUnitAt(group, i)
                            if DamageFilter(player, u) then
                                if UnitDamageTarget(unit, u, GetDamage(level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    DestroyEffect(AddSpecialEffectTarget(MODEL, u, ATTACH_POINT))
                                    AddUnitBonusTimed(u, BONUS_ARMOR, -1, GetDuration(level))
                                end
                            end
                        end
                    else
                        n[unit] = nil
                        DestroyGroup(group)
                        PauseTimer(timer)
                        DestroyTimer(timer)
                    end
                end)
            end
        end)
    end)
end