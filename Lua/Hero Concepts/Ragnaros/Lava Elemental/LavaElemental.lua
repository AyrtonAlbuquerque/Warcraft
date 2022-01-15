--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Utilities optional Sulfuras
    /* -------------------- Lava Elemental v1.5 by Chopinski -------------------- */
    // Credits:
    //     Henry         - Lava Elemental model (warcraft3undergorund.com)
    //     Empyreal      - fire base model (xgmguru.ru)
    //     Mythic        - Pillar of Flame model
    //     Blizzard      - icon (edited by me)
    //     Magtheridon96 - RegisterPlayerUnitEvent 
    //     Bribe         - SpellEffectEvent and UnitIndexer
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Lava Elemental ability
    local ABILITY            = FourCC('A004')
    -- The raw code of the Lava Elemental unit
    local LAVA_ELEMENTAL     = FourCC('o000')
    -- This ability cooldown if targeted at a 
    -- structure
    local STRUCTURE_COOLDOWN = 120.
    -- This ability cooldown if targeted at the 
    -- ground
    local NORMAL_COOLDOWN    = 30.
    -- The elemaental duration when targeted at 
    -- the ground
    local ELEMENTAL_DURATION = 60.
    -- The path for the effect that will be
    -- added to the base of the Lava Elemental
    local FIRA_BASE          = "fire_5.mdl"
    -- Effect when spawning a lava elemental
    local SPAWN_EFFECT       = "Pillar of Flame Orange.mdl"

    -- The amount of damage the Lava Elemental has
    local function GetElementalDamage(unit, level)
        local i = GetUnitUserData(unit)
    
        if Sulfuras_stacks[i] then
            return R2I(50 + 0.25*level*Sulfuras_stacks[i])
        else
            return 25 + 25*level
        end
    end

    -- The amount of health the Lava Elemental has
    local function GetElementalHealth(unit, level)
        return R2I(500*level + BlzGetUnitMaxHP(u)*0.3)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local array = {}
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this = {}
            local lava

            if Spell.target.unit then
                lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.target.x, Spell.target.y, 0.0)
                this.unit = Spell.target.unit
                this.effect = AddSpecialEffect(FIRA_BASE, Spell.target.x, Spell.target.y)
                this.key = GetUnitUserData(lava)
                array[this.key] = this
            
                DisarmUnit(Spell.target.unit, true)
                ShowUnit(Spell.target.unit, false)
                SetUnitInvulnerable(Spell.target.unit, true)
                SetUnitX(lava, Spell.target.x)
                SetUnitY(lava, Spell.target.y)
                BlzSetUnitMaxHP(lava, GetElementalHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(lava, 100)
                BlzSetUnitBaseDamage(lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                SetUnitPropWindow(lava, 0)
                BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, STRUCTURE_COOLDOWN)
                IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.target.x, Spell.target.y))
            else
                lava = CreateUnit(Spell.source.player, LAVA_ELEMENTAL, Spell.x, Spell.y, 0.0)
                this.unit = Spell.target.unit
                this.effect = AddSpecialEffect(FIRA_BASE, Spell.x, Spell.y)
                this.key = GetUnitUserData(lava)
                array[this.key] = this

                BlzSetUnitMaxHP(lava, GetElementalHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(lava, 100)
                BlzSetUnitBaseDamage(lava, GetElementalDamage(Spell.source.unit, Spell.level), 0)
                SetUnitPropWindow(lava, 0)
                UnitApplyTimedLife(lava, FourCC('BTLF'), ELEMENTAL_DURATION)
                BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, NORMAL_COOLDOWN)
                IncUnitAbilityLevel(Spell.source.unit, ABILITY)
                DecUnitAbilityLevel(Spell.source.unit, ABILITY)
                DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, Spell.x, Spell.y))
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()
            local key = GetUnitUserData(unit)

            if GetUnitTypeId(unit) == LAVA_ELEMENTAL and array[key] then
                local this = array[key]
                
                DestroyEffect(this.effect)
                if this.unit then
                    DisarmUnit(this.unit, false)
                    ShowUnit(this.unit, true)
                    SetUnitInvulnerable(this.unit, false)
                end
                this = nil
            end
        end)
    end)
end