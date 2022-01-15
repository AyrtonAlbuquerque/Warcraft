--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Utilities, DamageInterfaceUtils optional Afterburner
    /* -------------------- Explosive Rune v1.5 by Chopinski -------------------- */
    // Credits:
    //     Mythic           - Conflagrate model
    //     JetFangInferno   - FireRune model
    //     Blizzard         - icon (Edited by me)
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     Bribe            - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Explosive Rune Ability
    local ABILITY             = FourCC('A001')
    -- The number of charges of the ability
    local CHARGES_COUNT       = 4
    -- The number of charges of the ability
    local CHARGES_COOLDOWN    = 15.0
    -- The Explosion delay
    local EXPLOSION_DELAY     = 1.5
    -- The Explosion effect path
    local EXPLOSION_EFFECT    = "Conflagrate.mdl"
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
    -- If true will damage structures
    local DAMAGE_STRUCTURES   = false
    -- If true will damage allies
    local DAMAGE_ALLIES       = false
    -- If true will damage magic immune unit if the
    -- ATTACK_TYPE is not spell damage
    local DAMAGE_MAGIC_IMMUNE = false
    -- If true, the ability tooltip will change accordingly
    local CHANGE_TOOLTIP      = true

    -- The damage amount of the explosion
    local function GetDamage(level)
        return 25.*(level*level -2*level + 2)
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local n = {}
    local charges = {}
    
    local function ToolTip(unit)
        local id = GetUnitUserData(unit) 
        local lvl = GetUnitAbilityLevel(unit, ABILITY)
        local aoe = R2SW(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, lvl - 1), 0, 0)
        local string = ("Ragnaros creates an |cffffcc00Explosive Rune|r in the target location that explodes after" ..  
                    " |cffffcc00" .. R2SW(EXPLOSION_DELAY, 1, 1) .. "|r seconds, dealing |cff00ffff" .. 
                    AbilitySpellDamageEx(GetDamage(lvl), unit) .. " Magic|r damage to enemy units within |cffffcc00" .. 
                    aoe .. " AoE|r. Holds up to |cffffcc00" .. I2S(CHARGES_COUNT) .. "|r charges. " .. 
                    "Gains |cffffcc001|r charge every |cffffcc00" .. R2SW(CHARGES_COOLDOWN, 1, 1) .. "|r seconds.\n\n" .. 

                    "Charges: |cffffcc00" .. I2S(charges[id]) .. "|r")
        BlzSetAbilityExtendedTooltip(ABILITY, string, lvl - 1)
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this
            local rune

            if not n[Spell.source.id] then n[Spell.source.id] = 0 end

            if n[Spell.source.id] == 0 then
                this = {}
                this.timer = CreateTimer()
                this.unit = Spell.source.unit
                this.id = Spell.source.id
                charges[this.id] = CHARGES_COUNT
                n[this.id] = this

                TimerStart(this.timer, CHARGES_COOLDOWN, true, function()
                    if GetUnitAbilityLevel(this.unit, ABILITY) > 0 then
                        if charges[this.id] < CHARGES_COUNT and charges[this.id] >= 0 then
                            charges[this.id] = charges[this.id] + 1
                            BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                            if CHANGE_TOOLTIP then
                                ToolTip(this.unit)
                            end
                        end
                    else
                        PauseTimer(this.timer)
                        DestroyTimer(this.timer)
                        charges[this.id] = 0
                        n[this.id] = 0
                        this = nil
                    end
                end)
            else
                this = n[Spell.source.id]
            end
            
            rune = {}
            rune.timer = CreateTimer()
            rune.unit = Spell.source.unit
            rune.damage = GetDamage(Spell.level)
            rune.aoe = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_AREA_OF_EFFECT, Spell.level - 1)
            rune.x = Spell.x
            rune.y = Spell.y
            
            if charges[this.id] > 0 then
                charges[this.id] = charges[this.id] - 1
                if charges[this.id] >= 1 then
                    ResetUnitAbilityCooldown(this.unit, ABILITY)
                else
                    if CDR then
                        CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, TimerGetRemaining(this.timer))
                    else
                        BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, TimerGetRemaining(this.timer))
                        IncUnitAbilityLevel(this.unit, ABILITY)
                        DecUnitAbilityLevel(this.unit, ABILITY)
                    end
                end
            end

            TimerStart(rune.timer, EXPLOSION_DELAY, false, function()
                if Afterburner then
                    Afterburn(rune.x, rune.y, rune.unit)
                end
                UnitDamageArea(rune.unit, rune.x, rune.y, rune.aoe, rune.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_MAGIC_IMMUNE, DAMAGE_ALLIES)
                DestroyEffect(AddSpecialEffect(EXPLOSION_EFFECT, rune.x, rune.y))
                PauseTimer(rune.timer)
                DestroyTimer(rune.timer)
                rune = nil
            end)

            if CHANGE_TOOLTIP then
                ToolTip(this.unit)
            end
        end)
    end)
end