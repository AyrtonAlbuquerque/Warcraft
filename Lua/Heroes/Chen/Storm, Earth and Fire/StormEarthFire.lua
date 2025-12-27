OnInit("StormEarthFire", function(requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "Zap"
    requires "Fissure"
    requires "KegSmash"
    requires "BreathOfFire"
    requires "LightningAttack"

    -- ------------------------ Storm, Earth and Fire v1.5 by Chopinski ------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of Storm, Earth and Fire ability
    local ABILITY       = S2A('Chn9')
    -- The raw code of Storm unit
    local STORM         = S2A('uch1')
    -- The raw code of Earth unit
    local EARTH         = S2A('uch2')
    -- The raw code of Fire unit
    local FIRE          = S2A('uch0')
    -- The raw code Fire Immolation ability
    local IMMOLATION    = S2A('ChnA')

    -- The max hp of each element
    local function GetHealth(unittype, level, source)
        if unittype == STORM then
            return R2I(500*level + BlzGetUnitMaxHP(source)*0.5)
        elseif unittype == EARTH then
            return R2I(2000*level  + BlzGetUnitMaxHP(source))
        else
            return R2I(1000*level + BlzGetUnitMaxHP(source)*0.8)
        end
    end

    -- The max mana of each element
    local function GetMana(unittype, level, source)
        if unittype == STORM then
            return R2I(500*level + BlzGetUnitMaxMana(source))
        elseif unittype == EARTH then
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.5)
        else 
            return R2I(250*level + BlzGetUnitMaxMana(source)*0.8)
        end
    end

    -- The base damage of each element
    local function GetDamage(unittype, level, source)
        if unittype == STORM then
            return R2I(25 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.8)
        elseif unittype == EARTH then
            return R2I(100 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*0.5)
        else  
            return R2I(75 + 0*level + GetUnitBonus(source, BONUS_DAMAGE)*1.5)
        end
    end

    -- The base armor of each element
    local function GetArmor(unittype, level, source)
        if unittype == STORM then
            return 0.*level  + GetUnitBonus(source, BONUS_ARMOR)*0.3
        elseif unittype == EARTH then
            return 5.*level + GetUnitBonus(source, BONUS_ARMOR)
        else  
            return 2.*level + GetUnitBonus(source, BONUS_ARMOR)*0.8
        end
    end

    local function GetDamageBlock(source, level)
        return 50. * level + GetUnitBonus(source, BONUS_DAMAGE_BLOCK)
    end

    local function GetImmolationDamage(source, level)
        return 75. * level + (0.1 * level * GetUnitBonus(source, BONUS_SPELL_POWER))
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        StormEarthFire = Class(Spell)

        function StormEarthFire:onCast()
            local this = {
                player = Spell.source.player,
                unit = Spell.source.unit,
                level = Spell.level,
                group = CreateGroup()
            }

            TimerStart(CreateTimer(), 1, false, function()
                GroupEnumUnitsOfPlayer(this.group, this.player, nil)

                local u = FirstOfGroup(this.group)

                while u do
                    local id = GetUnitTypeId(u)

                    if id == STORM then
                        SetUnitAbilityLevel(u, Zap_ABILITY, this.level)
                        SetUnitAbilityLevel(u, LightningAttack_ABILITY, this.level)
                        BlzSetUnitMaxHP(u, GetHealth(id, this.level, this.unit))
                        BlzSetUnitMaxMana(u, GetMana(id, this.level, this.unit))
                        BlzSetUnitBaseDamage(u, GetDamage(id, this.level, this.unit), 0)
                        BlzSetUnitArmor(u, GetArmor(id, this.level, this.unit))
                        SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(this.unit, BONUS_SPELL_POWER))
                        SetUnitLifePercentBJ(u, 100)
                        SetUnitManaPercentBJ(u, 100)
                    elseif id == EARTH then
                        SetUnitAbilityLevel(u, KegSmash_ABILITY, GetUnitAbilityLevel(this.unit, KegSmash_ABILITY))
                        SetUnitAbilityLevel(u, Fissure_ABILITY, GetUnitAbilityLevel(this.unit, Fissure_ABILITY))
                        BlzSetUnitMaxHP(u, GetHealth(id, this.level, this.unit))
                        BlzSetUnitMaxMana(u, GetMana(id, this.level, this.unit))
                        BlzSetUnitBaseDamage(u, GetDamage(id, this.level, this.unit), 0)
                        BlzSetUnitArmor(u, GetArmor(id, this.level, this.unit))
                        AddUnitBonus(u, BONUS_DAMAGE_BLOCK, GetDamageBlock(this.unit, this.level))
                        SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(this.unit, BONUS_SPELL_POWER))
                        SetUnitLifePercentBJ(u, 100)
                        SetUnitManaPercentBJ(u, 100)
                    elseif id == FIRE then
                        SetUnitAbilityLevel(u, BreathOfFire_ABILITY, GetUnitAbilityLevel(this.unit, BreathOfFire_ABILITY))
                        BlzSetUnitMaxHP(u, GetHealth(id, this.level, this.unit))
                        BlzSetUnitMaxMana(u, GetMana(id, this.level, this.unit))
                        BlzSetUnitBaseDamage(u, GetDamage(id, this.level, this.unit), 0)
                        BlzSetUnitArmor(u, GetArmor(id, this.level, this.unit))
                        SetUnitBonus(u, BONUS_SPELL_POWER, GetUnitBonus(this.unit, BONUS_SPELL_POWER))
                        SetUnitLifePercentBJ(u, 100)
                        SetUnitManaPercentBJ(u, 100)
                        BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, IMMOLATION), ABILITY_RLF_DAMAGE_PER_INTERVAL, 0, GetImmolationDamage(this.unit, this.level))
                        BlzUnitDisableAbility(u, IMMOLATION, true, true)
                        BlzUnitDisableAbility(u, IMMOLATION, false, false)
                    end

                    GroupRemoveUnit(this.group, u)
                    u = FirstOfGroup(this.group)
                end

                DestroyGroup(this.group)
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function StormEarthFire.onInit()
            RegisterSpell(StormEarthFire.allocate(), ABILITY)
        end        
    end
end)