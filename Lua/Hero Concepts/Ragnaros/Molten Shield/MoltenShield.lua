--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, DamageInterface, NewBonusUtils
    /* --------------------- Molten Shield v1.5 by Chopinski -------------------- */
    // Credits:
    //     Power            - Shield model
    //     Mythic           - Explosion model
    //     Magtheridon96    - RegisterPlayerUnitEvent 
    //     Bribe            - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Molten Shield Ability
    local ABILITY           = FourCC('A006')
    -- The raw code of the Ragnaros unit in the editor
    local RAGNAROS_ID       = FourCC('H001')
    -- The raw code of the buff used to link bonus
    local BUFF_ID           = FourCC('B001')
    -- The GAIN_AT_LEVEL is greater than 0
    -- ragnaros will gain molten shield at this level 
    local GAIN_AT_LEVEL     = 20
    -- The Explosion effect path
    local EXPLOSION_EFFECT  = "Damnation Orange.mdl"
    -- The Explosion effect attachment point
    local ATTACH_POINT      = "origin"
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE       = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE       = DAMAGE_TYPE_FIRE

    -- The amount of movement speed the target of Molten Shield gains
    local function GetMovementBonus(level)
        return 100*level
    end

    -- The percentage of damage reduced to units with molten shield
    local function GetDamageFactor(level)
        return 0.5
    end

    -- The damage area
    local function GetDamageAoe(level)
        return 350. + 50*level
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local timer = CreateTimer()
    local stored = {}
    local array = {}
    local key = 0
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if GetUnitTypeId(unit) == RAGNAROS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end)
        
        RegisterSpellEffectEvent(ABILITY, function()
            if GetUnitAbilityLevel(Spell.target.unit, BUFF_ID) == 0 then
                local this = {}
                
                this.unit = Spell.target.unit
                --this.id = Spell.target.id
                this.level = Spell.level
                key = key + 1
                array[key] = this

                LinkBonusToBuff(Spell.target.unit, BONUS_MOVEMENT_SPEED, GetMovementBonus(Spell.level), BUFF_ID)

                if key == 1 then
                    TimerStart(timer, 0.03125000, true, function()
                        local i = 1
                        
                        while i <= key do
                            local this = array[i]
                            
                            if GetUnitAbilityLevel(this.unit, BUFF_ID) == 0 then
                                if stored[this.unit] then
                                    UnitDamageArea(this.unit, GetUnitX(this.unit), GetUnitY(this.unit), GetDamageAoe(this.level), stored[this.unit], ATTACK_TYPE, DAMAGE_TYPE, false, false, false)
                                end
                                DestroyEffect(AddSpecialEffectTarget(EXPLOSION_EFFECT, this.unit, ATTACH_POINT))
                                array[i] = array[key]
                                key = key - 1
                                stored[this.unit] = nil
                                this = nil

                                if key == 0 then
                                    PauseTimer(timer)
                                end

                                i = i - 1
                            end
                            i = i + 1
                        end
                    end)
                end
            end
        end)
        
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
            local buffed = GetUnitAbilityLevel(Damage.target.unit, BUFF_ID)

            if buffed > 0 and damage > 0 then
                damage = damage*GetDamageFactor(buffed)
                stored[Damage.target.unit] = (stored[Damage.target.unit] or 0) + damage
                print(stored[Damage.target.unit])
                BlzSetEventDamage(damage)
            end
        end)
    end)
end